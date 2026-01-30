#!/bin/bash
# Test script for composer-local-merge.php
# This script validates the merge and restore workflow

set -e

echo "==================================="
echo "Testing Composer Local Merge Script"
echo "==================================="
echo ""

# Save current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Create temporary test files
TEST_DIR="/tmp/composer-merge-test-$$"
mkdir -p "$TEST_DIR"

# Cleanup function
cleanup() {
    echo ""
    echo "Cleaning up test files..."
    rm -rf "$TEST_DIR"
    # Restore original composer.local.json if needed
    if [ -f "$SCRIPT_DIR/.composer.local.json.test.bkup" ]; then
        mv "$SCRIPT_DIR/.composer.local.json.test.bkup" "$SCRIPT_DIR/composer.local.json"
    fi
    echo "Cleanup complete"
}

trap cleanup EXIT

echo "Test 1: Empty composer.local.json (should skip merge)"
echo "------------------------------------------------------"
# Backup current composer.local.json if it exists
if [ -f "$SCRIPT_DIR/composer.local.json" ]; then
    cp "$SCRIPT_DIR/composer.local.json" "$SCRIPT_DIR/.composer.local.json.test.bkup"
fi

# Create empty composer.local.json
cat > "$SCRIPT_DIR/composer.local.json" << 'EOF'
{
  "name": "municipio-se/municipio-deployment-custom",
  "license": "MIT",
  "description": "Additions for your own install of Municipio.",
  "require": {}
}
EOF

php "$SCRIPT_DIR/composer-local-merge.php" pre-install
if [ -f "$SCRIPT_DIR/.composer-merge-active" ]; then
    echo "FAIL: Merge was performed when it shouldn't have been"
    exit 1
fi
echo "✓ Test 1 passed: Merge correctly skipped for empty requirements"
echo ""

echo "Test 2: composer.local.json with requirements (should merge and restore)"
echo "------------------------------------------------------------------------"
# Create composer.local.json with test requirements
cat > "$SCRIPT_DIR/composer.local.json" << 'EOF'
{
  "name": "municipio-se/municipio-deployment-custom",
  "license": "MIT",
  "description": "Additions for your own install of Municipio.",
  "require": {
    "test/package": "1.0.0"
  },
  "require-dev": {
    "test/dev-package": "2.0.0"
  }
}
EOF

# Save original composer.json content
ORIGINAL_COMPOSER=$(cat "$SCRIPT_DIR/composer.json")

# Run pre-install
php "$SCRIPT_DIR/composer-local-merge.php" pre-install

# Check if merge flag exists
if [ ! -f "$SCRIPT_DIR/.composer-merge-active" ]; then
    echo "FAIL: Merge flag not created"
    exit 1
fi

# Check if test package was added to composer.json
if ! grep -q "test/package" "$SCRIPT_DIR/composer.json"; then
    echo "FAIL: Test package not found in composer.json after merge"
    exit 1
fi

# Check if backups were created
if [ ! -f "$SCRIPT_DIR/composer.json.bkup" ]; then
    echo "FAIL: composer.json backup not created"
    exit 1
fi

echo "✓ Pre-install: Merge performed correctly"

# Run post-install
php "$SCRIPT_DIR/composer-local-merge.php" post-install

# Check if merge flag was removed
if [ -f "$SCRIPT_DIR/.composer-merge-active" ]; then
    echo "FAIL: Merge flag not removed after post-install"
    exit 1
fi

# Check if test package was removed from composer.json
if grep -q "test/package" "$SCRIPT_DIR/composer.json"; then
    echo "FAIL: Test package still in composer.json after restore"
    exit 1
fi

# Check if backups were cleaned up
if [ -f "$SCRIPT_DIR/composer.json.bkup" ]; then
    echo "FAIL: Backup files not cleaned up"
    exit 1
fi

echo "✓ Post-install: Restore performed correctly"
echo "✓ Test 2 passed: Merge and restore completed successfully"
echo ""

# Restore original composer.local.json
mv "$SCRIPT_DIR/.composer.local.json.test.bkup" "$SCRIPT_DIR/composer.local.json"

echo "==================================="
echo "All tests passed! ✓"
echo "==================================="
