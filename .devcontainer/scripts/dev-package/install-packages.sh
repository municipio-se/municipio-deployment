#!/usr/bin/env bash
set -euo pipefail

#############################################################################
# Install Packages Script
# Installs all composer packages with --prefer-dist
#############################################################################

# Accept project root as argument or determine from script location
PROJECT_ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"

cd "$PROJECT_ROOT"

echo "🔄 Installing all packages with --prefer-dist (using local composer cache)"

# Check that the selected manifest and lock file align.
if ! php composer-local-merge.php validate --no-check-publish ; then
  echo "❌ Composer validation failed. Check the manifest and lock file."
  exit 1
fi

if ! php composer-local-merge.php install --prefer-dist --no-interaction --ignore-platform-reqs ; then
  echo "❌ Composer install failed. Please check your setup."
  exit 1
fi

echo "✓ Packages installed"
