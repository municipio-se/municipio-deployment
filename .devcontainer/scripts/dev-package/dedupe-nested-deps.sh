#!/usr/bin/env bash
set -euo pipefail

#############################################################################
# Dedupe Nested Dependencies Script
# Replaces root/global dependency installs with symlinks to the selected
# package's nested vendor copies when both exist.
#
# This makes the selected prefer-source package the source of truth during
# development, so local dependency updates inside that package are used.
#############################################################################

PROJECT_ROOT="${1:-}"
PACKAGE_PATH="${2:-}"
PACKAGE_NAME="${3:-}"

if [ -z "$PROJECT_ROOT" ] || [ -z "$PACKAGE_PATH" ] || [ -z "$PACKAGE_NAME" ]; then
  echo "Usage: dedupe-nested-deps.sh <project_root> <package_path> <package_name>"
  exit 1
fi

if [ ! -f "$PACKAGE_PATH/composer.json" ]; then
  echo "ℹ️  No composer.json found in selected package, skipping dedupe"
  exit 0
fi

cd "$PROJECT_ROOT"

linked=0
skipped=0

if [ ! -d "$PACKAGE_PATH/vendor" ]; then
  echo "ℹ️  No nested vendor directory found in selected package"
  echo "🔄 Installing selected package dependencies first"

  if ! composer install \
    --working-dir "$PACKAGE_PATH" \
    --no-interaction \
    --ignore-platform-reqs \
    --prefer-source \
    --no-scripts; then
    echo "⚠️  Failed to install selected package dependencies, skipping dedupe"
    exit 0
  fi
fi

mapfile -t required_packages < <(jq -r '.require | keys[]' "$PACKAGE_PATH/composer.json")

for dep in "${required_packages[@]}"; do
  if [ "$dep" = "$PACKAGE_NAME" ] || [ "$dep" = "php" ] || [[ "$dep" == ext-* ]]; then
    continue
  fi

  local_dep_path=$(composer show "$dep" --working-dir "$PACKAGE_PATH" --format=json 2>/dev/null | jq -r '.path // empty')

  if [ -z "$local_dep_path" ]; then
    local_dep_path="$PACKAGE_PATH/vendor/$dep"
  elif [[ "$local_dep_path" != /* ]]; then
    local_dep_path="$PACKAGE_PATH/$local_dep_path"
  fi

  if [ ! -e "$local_dep_path" ]; then
    continue
  fi

  dep_path=$(composer show "$dep" --format=json 2>/dev/null | jq -r '.path // empty')
  if [ -z "$dep_path" ]; then
    skipped=$((skipped + 1))
    continue
  fi

  global_path="$PROJECT_ROOT/$dep_path"
  if [ ! -e "$global_path" ]; then
    skipped=$((skipped + 1))
    continue
  fi

  local_real=$(realpath "$local_dep_path")
  global_real=$(realpath "$global_path")

  if [ "$local_real" = "$global_real" ]; then
    continue
  fi

  rm -rf "$global_path"
  mkdir -p "$(dirname "$global_path")"
  ln -s "$local_dep_path" "$global_path"
  linked=$((linked + 1))

  echo "✓ Linked global $dep_path -> $local_dep_path"
done

echo "=========================================================================="
echo "✅ Dedupe complete: linked $linked dependency paths, skipped $skipped"
echo "=========================================================================="
