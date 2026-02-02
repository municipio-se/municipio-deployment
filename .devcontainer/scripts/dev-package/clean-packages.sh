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

if [ -d vendor ]; then
  rm -rf vendor/*
fi

if [ -d wp-content/plugins ]; then
  # Keep advanced-custom-fields-pro (temporary fix)
  find wp-content/plugins/ -mindepth 1 -maxdepth 1 ! -name 'advanced-custom-fields-pro' -exec rm -rf {} +
fi

if [ -d wp-content/mu-plugins ]; then
  # Keep loader.php
  find wp-content/mu-plugins/ -mindepth 1 -maxdepth 1 ! -name 'loader.php' -exec rm -rf {} +
fi

if [ -d wp-content/themes ]; then
  rm -rf wp-content/themes/*
fi

echo "=========================================================================="
echo "✅ Cleanup complete"
echo "=========================================================================="
