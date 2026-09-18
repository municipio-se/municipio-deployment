#!/usr/bin/env bash
set -euo pipefail

#############################################################################
# Clean Packages Script
# Removes all installed packages (vendor, plugins, mu-plugins, themes)
#############################################################################

# Accept project root as argument or determine from script location
PROJECT_ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"

cd "$PROJECT_ROOT"

echo "=========================================================================="
echo "🧹 Removing all installed resources (vendor, plugins, mu-plugins, themes)"
echo "=========================================================================="

# Retry deletion a few times: the app container can serve a request mid-cleanup
# and have a plugin (e.g. miniorange-saml) write files back into its own folder,
# which makes "rm -rf" transiently fail with "Directory not empty".
rm_rf_retry() {
  local target="$1"
  local attempt
  for attempt in 1 2 3; do
    rm -rf "$target" && return 0
    [ -e "$target" ] || return 0
    sleep 1
  done
  rm -rf "$target"
}

if [ -d vendor ]; then
  for entry in vendor/*; do
    [ -e "$entry" ] && rm_rf_retry "$entry"
  done
fi

if [ -d wp-content/plugins ]; then
  # Keep advanced-custom-fields-pro (temporary fix)
  while IFS= read -r -d '' entry; do
    rm_rf_retry "$entry"
  done < <(find wp-content/plugins/ -mindepth 1 -maxdepth 1 ! -name 'advanced-custom-fields-pro' -print0)
fi

if [ -d wp-content/mu-plugins ]; then
  # Keep loader.php
  while IFS= read -r -d '' entry; do
    rm_rf_retry "$entry"
  done < <(find wp-content/mu-plugins/ -mindepth 1 -maxdepth 1 ! -name 'loader.php' ! -name 'migrate.php' -print0)
fi

if [ -d wp-content/themes ]; then
  for entry in wp-content/themes/*; do
    [ -e "$entry" ] && rm_rf_retry "$entry"
  done
fi

echo "=========================================================================="
echo "✅ Cleanup complete"
echo "=========================================================================="
