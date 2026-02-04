#!/usr/bin/env bash
set -euo pipefail

#############################################################################
# Install Packages Script
# Installs all composer packages with --prefer-dist
#############################################################################

# Accept project root as argument or determine from script location
PROJECT_ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"

cd "$PROJECT_ROOT"

echo "🔄 Installing all packages with --prefer-dist, --no-cache"

# Check if composer.json and composer.lock align
if ! composer validate --no-check-publish ; then
  echo "❌ Composer validation failed. Please check your composer.json and composer.lock. Removing lockfile."
  rm -f composer.lock
fi

if ! composer install --prefer-dist --no-interaction --ignore-platform-reqs --no-cache ; then
  echo "❌ Composer install failed. Please check your setup."
  exit 1
fi

echo "✓ Packages installed"
