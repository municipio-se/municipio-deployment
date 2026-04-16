#!/usr/bin/env bash
set -euo pipefail

#############################################################################
# Select Dev Package Script
# Lists available packages and reinstalls selected one from source for development
#
# Usage:
#   select-dev-package.sh [options] [project_root]
#
# Options:
#   -p, --package <name>    Specify package name directly (skip interactive selection)
#   -e, --editor <cmd>      Editor command to open package (default: code)
#   --no-editor             Don't open editor after setup
#############################################################################

# Defaults
EDITOR_CMD="code"
OPEN_EDITOR=true
PACKAGE=""
AVAILABLE_PACKAGES_TO_EDIT=("helsingborg-stad/*" "municipio-se/*")

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -p|--package)
      PACKAGE="$2"
      shift 2
      ;;
    -e|--editor)
      EDITOR_CMD="$2"
      shift 2
      ;;
    --no-editor)
      OPEN_EDITOR=false
      shift
      ;;
    -*)
      echo "Unknown option: $1"
      exit 1
      ;;
    *)
      PROJECT_ROOT="$1"
      shift
      ;;
  esac
done

# Determine project root
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "$0")/../../.." && pwd)}"

cd "$PROJECT_ROOT"

echo ""
echo "=========================================================================="
echo "📦 Available packages for development:"
echo "=========================================================================="

# Get all installed packages
PACKAGES=($(composer show --name-only))

# Filter packages to include only those listed in composer.json and matching patterns
REQUIRED_PACKAGES=$(jq -r '.require | keys[]' composer.json)
FILTERED_PACKAGES=()
for pkg in "${PACKAGES[@]}"; do
  for pattern in "${AVAILABLE_PACKAGES_TO_EDIT[@]}"; do
    if [[ "$pkg" == $pattern ]] && echo "$REQUIRED_PACKAGES" | grep -q "^$pkg$"; then
      FILTERED_PACKAGES+=("$pkg")
    fi
  done
done

PACKAGES=("${FILTERED_PACKAGES[@]}")

if [ ${#PACKAGES[@]} -eq 0 ]; then
  echo "=========================================================================="
  echo "❌ No matching packages found in composer.json or AVAILABLE_PACKAGES_TO_EDIT."
  echo "=========================================================================="
  exit 1
fi

# If package not specified via flag, show interactive selection
if [ -z "$PACKAGE" ]; then
  i=1
  for pkg in "${PACKAGES[@]}"; do
    printf "%3d) %s\n" "$i" "$pkg"
    ((i++))
  done

  echo ""
  echo "=========================================================================="
  read -p "👉 Select a package number to work on: " SELECTION
  echo "=========================================================================="

  if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || (( SELECTION < 1 || SELECTION > ${#PACKAGES[@]} )); then
    echo "❌ Invalid selection"
    exit 1
  fi

  PACKAGE="${PACKAGES[$((SELECTION-1))]}"
else
  # Validate that specified package is in the list
  FOUND=false
  for pkg in "${PACKAGES[@]}"; do
    if [[ "$pkg" == "$PACKAGE" ]]; then
      FOUND=true
      break
    fi
  done

  if [ "$FOUND" = false ]; then
    echo "=========================================================================="
    echo "❌ Package '$PACKAGE' is not available for development."
    echo "=========================================================================="
    echo "Available packages:"
    printf "  %s\n" "${PACKAGES[@]}"
    exit 1
  fi
fi

echo ""
echo "=========================================================================="
echo "🛠 Reinstalling $PACKAGE as source"
echo "=========================================================================="

# Get the version of the selected package from composer.json
PACKAGE_VERSION=$(jq -r --arg package "$PACKAGE" '.require[$package]' composer.json)

# Reinstall the selected package as source
composer reinstall --no-interaction --ignore-platform-reqs --prefer-source $PACKAGE

# Determine the correct installation path for the package
PACKAGE_PATH=""
INSTALLER_PATHS=$(jq -r '.extra["installer-paths"] | to_entries[] | .key + " " + (.value | join(","))' composer.json)
for entry in $INSTALLER_PATHS; do
  IFS=' ' read -r path types <<< "$entry"
  for type in ${types//,/ }; do
    if composer show "$PACKAGE" --format=json | jq -e ".type == \"$type\"" > /dev/null; then
      PACKAGE_PATH="${path//\$name/${PACKAGE##*/}}"
      break 2
    fi
  done
done

# Fallback: Use composer show to get the path if installer-paths does not resolve
if [ -z "$PACKAGE_PATH" ]; then
  PACKAGE_PATH=$(composer show "$PACKAGE" --format=json | jq -r '.path // empty')
fi

if [ -z "$PACKAGE_PATH" ]; then
  echo ""
  echo "=========================================================================="
  echo "⚠️ Could not determine the installation path for $PACKAGE."
  echo "=========================================================================="
  exit 1
fi

# Checkout HEAD to revive any local changes
git -C "$PACKAGE_PATH" checkout HEAD || true

# Checkout main branch
cd "$PACKAGE_PATH"
git checkout main || git checkout master || true

echo "=========================================================================="
echo "✅ Package $PACKAGE is ready for development at $PACKAGE_PATH"
echo "=========================================================================="

# Open in editor if enabled
if [ "$OPEN_EDITOR" = true ]; then
  echo ""
  echo "=========================================================================="
  echo "✏️  Opening $PACKAGE in $EDITOR_CMD"
  echo "=========================================================================="
  $EDITOR_CMD .
fi
