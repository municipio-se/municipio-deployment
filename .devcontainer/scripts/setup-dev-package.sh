#!/usr/bin/env bash
set -euo pipefail

#############################################################################
# Setup Dev Package Script
# Cleans, reinstalls packages, and optionally sets up a package for development
#
# Usage:
#   setup-dev-package.sh [options]
#
# Options:
#   -y, --yes               Skip confirmation prompt
#   -s, --skip-select       Skip package selection (only clean and install)
#   -p, --package <name>    Specify package name directly (skip interactive selection)
#   -e, --editor <cmd>      Editor command to open package (default: code)
#   --no-editor             Don't open editor after setup
#############################################################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Defaults
SKIP_CONFIRM=false
SKIP_SELECT=false
PACKAGE=""
EDITOR_CMD="code"
OPEN_EDITOR=true

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -y|--yes)
      SKIP_CONFIRM=true
      shift
      ;;
    -s|--skip-select)
      SKIP_SELECT=true
      shift
      ;;
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
    -h|--help)
      echo "Usage: setup-dev-package.sh [options]"
      echo ""
      echo "Options:"
      echo "  -y, --yes               Skip confirmation prompt"
      echo "  -s, --skip-select       Skip package selection (only clean and install)"
      echo "  -p, --package <name>    Specify package name directly"
      echo "  -e, --editor <cmd>      Editor command (default: code)"
      echo "  --no-editor             Don't open editor after setup"
      echo "  -h, --help              Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use -h or --help for usage information."
      exit 1
      ;;
  esac
done

# Confirmation prompt
if [ "$SKIP_CONFIRM" = false ]; then
  echo ""
  echo ""
  echo "=========================================================================="
  echo "⚠️  This script will REMOVE all installed packages, repositories and reinstall them."
  echo "   Any local changes in installed packages will be lost (both tracked and untracked)."
  echo "   Script will run in the project root: $PROJECT_ROOT"
  echo "=========================================================================="
  echo ""
  read -p "👉 Do you want to continue? (y/n): " CONFIRM

  if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "❌ Operation cancelled by user."
    exit 1
  fi
fi

echo ""
echo "=========================================================================="
echo "📁 Moving to project root: $PROJECT_ROOT"
echo "=========================================================================="
cd "$PROJECT_ROOT"

# Step 1: Clean packages
"$SCRIPT_DIR/dev-package/clean-packages.sh" "$PROJECT_ROOT"

# Step 2: Install packages
echo ""
"$SCRIPT_DIR/dev-package/install-packages.sh" "$PROJECT_ROOT"

# Step 3: Select and setup dev package (unless skipped)
if [ "$SKIP_SELECT" = false ]; then
  SELECT_ARGS=()

  if [ -n "$PACKAGE" ]; then
    SELECT_ARGS+=("--package" "$PACKAGE")
  fi

  SELECT_ARGS+=("--editor" "$EDITOR_CMD")

  if [ "$OPEN_EDITOR" = false ]; then
    SELECT_ARGS+=("--no-editor")
  fi

  "$SCRIPT_DIR/dev-package/select-dev-package.sh" "${SELECT_ARGS[@]}" "$PROJECT_ROOT"
fi

echo ""
echo "=========================================================================="
echo "🎉 Setup complete!"
echo "=========================================================================="
