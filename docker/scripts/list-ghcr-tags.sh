#!/usr/bin/env bash
set -euo pipefail

repository="${1:?Usage: list-ghcr-tags.sh <owner/repository>}"
token="${REGISTRY_BEARER_TOKEN:-}"
if [[ -z "$token" ]]; then
  echo "REGISTRY_BEARER_TOKEN is required." >&2
  exit 1
fi

response_file="$(mktemp)"
headers_file="$(mktemp)"
trap 'rm -f "$response_file" "$headers_file"' EXIT

url="/v2/$repository/tags/list?n=1000"
first_page=true
while [[ -n "$url" ]]; do
  if ! status="$(curl -sS -D "$headers_file" -o "$response_file" -w '%{http_code}' \
    -H "Authorization: Bearer $token" "https://ghcr.io$url")"; then
    echo "GHCR tag lookup request failed." >&2
    exit 1
  fi

  case "$status" in
    200)
      if ! jq -e --arg repository "$repository" '
        type == "object"
        and (.name | type) == "string"
        and ((.name | ascii_downcase) == ($repository | ascii_downcase))
        and has("tags")
        and (.tags == null or ((.tags | type) == "array" and all(.tags[]; type == "string")))
      ' "$response_file" >/dev/null; then
        echo "GHCR returned a malformed tag-list response." >&2
        exit 1
      fi
      jq -r '.tags[]?' "$response_file"
      first_page=false
      url="$(sed -nE 's/^link: *<([^>]+)>; *rel="next".*/\1/Ip' "$headers_file" | tr -d '\r')"
      ;;
    404)
      if [[ "$first_page" == true ]] && jq -e '
        type == "object"
        and (.errors | type) == "array"
        and (.errors | length) == 1
        and (.errors[0].code == "NAME_UNKNOWN")
      ' "$response_file" >/dev/null 2>&1; then
        exit 0
      fi
      echo "GHCR tag lookup returned an unexpected HTTP 404." >&2
      exit 1
      ;;
    *)
      echo "GHCR tag lookup failed with HTTP $status." >&2
      exit 1
      ;;
  esac
done
