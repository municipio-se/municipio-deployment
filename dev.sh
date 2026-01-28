#!/usr/bin/env bash
set -euo pipefail

EDITOR_CMD="code"
AVABILE_PACKAGES_TO_EDIT=("helsingborg-stad/*" "municipio-se/*")

echo "🔄 Installing all packages with --prefer-dist"

# Check if composer install succeeded
if ! composer install --prefer-dist --no-interaction --ignore-platform-req=ext-imagick; then
  echo "❌ Composer install failed. Please check your setup."
  exit 1
fi

echo ""
echo "📦 Installed packages:"
PACKAGES=()

# Populate PACKAGES array without using a subshell
PACKAGES=($(composer show --name-only))

# Filter packages based on AVABILE_PACKAGES_TO_EDIT
FILTERED_PACKAGES=()
for pkg in "${PACKAGES[@]}"; do
  for pattern in "${AVABILE_PACKAGES_TO_EDIT[@]}"; do
    if [[ "$pkg" == $pattern ]]; then
      FILTERED_PACKAGES+=("$pkg")
    fi
  done
done

# Replace PACKAGES with FILTERED_PACKAGES
PACKAGES=("${FILTERED_PACKAGES[@]}")

# Check if filtered PACKAGES array is empty
if [ ${#PACKAGES[@]} -eq 0 ]; then
  echo "❌ No matching packages found. Check your AVABILE_PACKAGES_TO_EDIT filter."
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

# Remove only from vendor, keep composer.json/lock intact
rm -rf "vendor/$PACKAGE"

composer install \
  --prefer-source \
  --no-interaction \
  --ignore-platform-req=ext-imagick \
  "$PACKAGE"

PACKAGE_PATH="vendor/$PACKAGE"

if [ -d "$PACKAGE_PATH" ]; then
  echo "🚀 Opening $PACKAGE_PATH"
  $EDITOR_CMD "$PACKAGE_PATH"
else
  echo "⚠️ Package path not found"
fi