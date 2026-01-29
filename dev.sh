#!/usr/bin/env bash
set -euo pipefail

EDITOR_CMD="code"
AVABILE_PACKAGES_TO_EDIT=("helsingborg-stad/*" "municipio-se/*")

# Clean up existing installations
echo ""
echo "🧹 Removing all installed resources (vendor, plugins, mu-plugins, themes)"
rm -rf vendor/*
rm -rf wp-content/plugins/*
rm -rf wp-content/mu-plugins/*
rm -rf wp-content/themes/*

# Install all packages
echo ""
echo "🔄 Installing all packages with --prefer-dist, --no-cache"

# Check if composer install succeeded
if ! composer install --prefer-dist --no-interaction --ignore-platform-req=ext-imagick --no-cache; then
  echo "❌ Composer install failed. Please check your setup."
  exit 1
fi

echo ""
echo "📦 Installed packages:"
PACKAGES=()

# Populate PACKAGES array without using a subshell
PACKAGES=($(composer show --name-only))

# Filter packages to include only those listed in composer.json
REQUIRED_PACKAGES=$(jq -r '.require | keys[]' composer.json)
FILTERED_PACKAGES=()
for pkg in "${PACKAGES[@]}"; do
  for pattern in "${AVABILE_PACKAGES_TO_EDIT[@]}"; do
    if [[ "$pkg" == $pattern ]] && echo "$REQUIRED_PACKAGES" | grep -q "^$pkg$"; then
      FILTERED_PACKAGES+=("$pkg")
    fi
  done
done

# Replace PACKAGES with FILTERED_PACKAGES
PACKAGES=("${FILTERED_PACKAGES[@]}")

# Check if filtered PACKAGES array is empty
if [ ${#PACKAGES[@]} -eq 0 ]; then
  echo "❌ No matching packages found in composer.json or AVABILE_PACKAGES_TO_EDIT."
  exit 1
fi

i=1
for pkg in "${PACKAGES[@]}"; do
  printf "%3d) %s\n" "$i" "$pkg"
  ((i++))
done

echo ""
read -p "👉 Select a package number to work on: " SELECTION

if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || (( SELECTION < 1 || SELECTION > ${#PACKAGES[@]} )); then
  echo "❌ Invalid selection"
  exit 1
fi

PACKAGE="${PACKAGES[$((SELECTION-1))]}"

echo ""
echo "🛠 Reinstalling $PACKAGE as source"

PACKAGE_VERSION=$(jq -r --arg package "$PACKAGE" '.require[$package]' composer.json)

composer require \
  --no-interaction \
  --ignore-platform-req=ext-imagick \
  --prefer-source \
  "$PACKAGE:$PACKAGE_VERSION"

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

# Check if PACKAGE_PATH is still empty
if [ -z "$PACKAGE_PATH" ]; then
  echo "⚠️ Could not determine the installation path for $PACKAGE."
  exit 1
fi

# Checkout head to revive any local changes
git -C "$PACKAGE_PATH" checkout HEAD || true

# Open the package in the specified editor
echo ""
echo "✏️ Opening $PACKAGE in $EDITOR_CMD from $PACKAGE_PATH"
cd "$PACKAGE_PATH"
$EDITOR_CMD .