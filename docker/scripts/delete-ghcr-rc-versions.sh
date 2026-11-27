#!/usr/bin/env bash
# Delete every vX.Y.Z-rc.N image of a released version from GHCR, including the
# untagged platform, attestation and per-platform index manifests behind them.
#
# Usage: delete-ghcr-rc-versions.sh <owner> <package> <X.Y.Z>
# Env:   GH_TOKEN               token allowed to list/delete package versions
#        REGISTRY_BEARER_TOKEN  ghcr.io pull token for <owner>/<package>
#        DRY_RUN=true           only report what would be deleted
set -euo pipefail

owner="${1:?Usage: delete-ghcr-rc-versions.sh <owner> <package> <X.Y.Z>}"
package="${2:?Usage: delete-ghcr-rc-versions.sh <owner> <package> <X.Y.Z>}"
version="${3:?Usage: delete-ghcr-rc-versions.sh <owner> <package> <X.Y.Z>}"
dry_run="${DRY_RUN:-false}"
token="${REGISTRY_BEARER_TOKEN:-}"
summary="${GITHUB_STEP_SUMMARY:-/dev/null}"

if [[ -z "${GH_TOKEN:-}" || -z "$token" ]]; then
  echo "GH_TOKEN and REGISTRY_BEARER_TOKEN are required." >&2
  exit 1
fi
if ! [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Version must be X.Y.Z, got '$version'." >&2
  exit 1
fi

owner="${owner,,}"
package="${package,,}"
repository="$owner/$package"
rc_pattern="^v${version//./\\.}-rc\\.[0-9]+$"

owner_type="$(gh api "/users/$owner" --jq .type)"
case "$owner_type" in
  Organization) api="/orgs/$owner/packages/container/$package" ;;
  User) api="/users/$owner/packages/container/$package" ;;
  *) echo "Unexpected owner type '$owner_type' for $owner." >&2; exit 1 ;;
esac

versions_file="$(mktemp)"
manifest_file="$(mktemp)"
trap 'rm -f "$versions_file" "$manifest_file"' EXIT

gh api --paginate "$api/versions?per_page=100" | jq -s 'add // []' > "$versions_file"
if ! jq -e 'type == "array" and all(.[]; (.id | type) == "number" and (.name | type) == "string")' \
  "$versions_file" >/dev/null; then
  echo "GitHub returned a malformed package-version list." >&2
  exit 1
fi

# Print the child manifest digests of an index; nothing for an image manifest
# or a manifest that no longer exists.
children_of() {
  local status
  status="$(curl -sS -o "$manifest_file" -w '%{http_code}' \
    -H "Authorization: Bearer $token" \
    -H 'Accept: application/vnd.oci.image.index.v1+json, application/vnd.docker.distribution.manifest.list.v2+json, application/vnd.oci.image.manifest.v1+json, application/vnd.docker.distribution.manifest.v2+json' \
    "https://ghcr.io/v2/$repository/manifests/$1")"
  case "$status" in
    200) jq -r '.manifests[]?.digest' "$manifest_file" ;;
    404) ;;
    *) echo "Fetching manifest $1 failed with HTTP $status." >&2; exit 1 ;;
  esac
}

# Print a digest and every manifest digest reachable from it.
closure_of() {
  local queue=("$1") seen=() digest child children
  declare -A visited=()
  while ((${#queue[@]})); do
    digest="${queue[0]}"
    queue=("${queue[@]:1}")
    [[ -n "${visited[$digest]:-}" ]] && continue
    visited[$digest]=1
    seen+=("$digest")
    children="$(children_of "$digest")"
    while IFS= read -r child; do
      [[ -n "$child" ]] && queue+=("$child")
    done <<< "$children"
  done
  printf '%s\n' "${seen[@]}"
}

# Never touch anything the released image uses. Refuse to run before release.
release_digest="$(jq -r --arg tag "v$version" \
  'map(select(.metadata.container.tags | index($tag))) | .[0].name // empty' "$versions_file")"
if [[ -z "$release_digest" ]]; then
  echo "Image tag v$version does not exist; refusing to delete its release candidates." >&2
  exit 1
fi
declare -A protected=()
closure="$(closure_of "$release_digest")"
while IFS= read -r digest; do protected[$digest]=1; done <<< "$closure"

# Tagged RC versions. A version that also carries a non-RC tag is left alone.
declare -A doomed=()
ordered=()
rc_tags=()
while IFS=$'\t' read -r digest tags; do
  if jq -e --arg re "$rc_pattern" 'any(.[]; test($re) | not)' <<< "$tags" >/dev/null; then
    echo "::warning::Skipping $digest: it also carries non-RC tags $tags."
    continue
  fi
  mapfile -t -O "${#rc_tags[@]}" rc_tags < <(jq -r '.[]' <<< "$tags")
  closure="$(closure_of "$digest")"
  while IFS= read -r child; do
    if [[ -n "${protected[$child]:-}" ]]; then
      echo "Keeping $child: the v$version release also uses it."
    elif [[ -z "${doomed[$child]:-}" ]]; then
      doomed[$child]=1
      ordered+=("$child")
    fi
  done <<< "$closure"
done < <(jq -r --arg re "$rc_pattern" '
  .[] | select(any(.metadata.container.tags[]?; test($re)))
  | [.name, (.metadata.container.tags | tojson)] | @tsv' "$versions_file")

if ((${#rc_tags[@]} == 0)); then
  echo "No release candidates found for v$version."
  echo "No release candidates found for \`v$version\`." >> "$summary"
  exit 0
fi

# imagetools create flattens the per-platform indexes pushed by digest, so the RC
# index does not reference them. Find untagged indexes pushed around the same
# time whose children are all being deleted.
window="$(jq -r --arg re "$rc_pattern" '
  [.[] | select(any(.metadata.container.tags[]?; test($re))) | .created_at | fromdateiso8601]
  | "\(min - 21600) \(max)"' "$versions_file")"
read -r window_start window_end <<< "$window"
while IFS= read -r digest; do
  [[ -n "${doomed[$digest]:-}" || -n "${protected[$digest]:-}" ]] && continue
  index_children="$(children_of "$digest")"
  [[ -n "$index_children" ]] || continue
  mapfile -t children <<< "$index_children"
  orphan=true
  for child in "${children[@]}"; do
    [[ -n "${doomed[$child]:-}" ]] || { orphan=false; break; }
  done
  if [[ "$orphan" == true ]]; then
    doomed[$digest]=1
    ordered+=("$digest")
  fi
done < <(jq -r --argjson start "$window_start" --argjson end "$window_end" '
  .[] | select((.metadata.container.tags // []) == [])
  | select((.created_at | fromdateiso8601) as $t | $t >= $start and $t <= $end)
  | .name' "$versions_file")

mapfile -t sorted_tags < <(printf '%s\n' "${rc_tags[@]}" | sort -V)
if [[ "$dry_run" == true ]]; then
  verb="Would delete"
else
  verb="Deleted"
fi
deleted=0
for digest in "${ordered[@]}"; do
  id="$(jq -r --arg d "$digest" 'map(select(.name == $d)) | .[0].id // empty' "$versions_file")"
  if [[ -z "$id" ]]; then
    echo "No package version for $digest; skipping."
    continue
  fi
  if [[ "$dry_run" == true ]]; then
    echo "Would delete version $id ($digest)."
  else
    if ! output="$(gh api -X DELETE "$api/versions/$id" 2>&1)"; then
      if grep -q 'HTTP 404' <<< "$output"; then
        echo "Version $id ($digest) is already gone."
        continue
      fi
      echo "$output" >&2
      if grep -q 'HTTP 403' <<< "$output"; then
        echo "::error::Deleting package versions was refused. Give this repository the Admin role under the package's \"Manage Actions access\" settings."
      fi
      exit 1
    fi
    echo "Deleted version $id ($digest)."
  fi
  deleted=$((deleted + 1))
done

{
  echo "$verb $deleted package versions for release candidates of \`v$version\`:"
  printf -- '- `%s`\n' "${sorted_tags[@]}"
} >> "$summary"
echo "$verb $deleted package versions for: ${sorted_tags[*]}"
