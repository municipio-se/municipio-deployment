#!/bin/bash
set -e

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$BASE_DIR/.."
DB_FILE="$BASE_DIR/db.sqlite"
SEED_FILE="$BASE_DIR/seed.sqlite"
MU_PLUGIN_DIR="$PROJECT_ROOT/wp-content/mu-plugins"
PLUGIN_ZIP_URL="https://downloads.wordpress.org/plugin/sqlite-database-integration.2.2.2.zip"
PLUGIN_NAME="sqlite-database-integration"
PLUGIN_DIR="$MU_PLUGIN_DIR/$PLUGIN_NAME"

# Ensure db exists
if [ ! -f "$DB_FILE" ]; then
  echo "🔄 Initializing SQLite database seeding..."
  cp "$SEED_FILE" "$DB_FILE"
  echo "✅ SQLite database seeded."
else
  echo "ℹ️ SQLite database already exists. Skipping seeding."
fi

# Permissions and validity
if [ ! -w "$DB_FILE" ]; then
  echo "❗ Error: $DB_FILE is not writable. Please check permissions."
  exit 1
fi

if [ ! -r "$DB_FILE" ]; then
  echo "❗ Error: $DB_FILE is not readable. Please check permissions."
  exit 1
fi

if ! sqlite3 "$DB_FILE" "SELECT 1;" >/dev/null 2>&1; then
  echo "❗ Error: $DB_FILE is not a valid SQLite database."
  exit 1
fi  

if [ ! -s "$DB_FILE" ]; then
  echo "❗ Error: $DB_FILE is empty. Please check the seed file."
  exit 1
fi

echo "✅ SQLite database is ready and valid."

# Install SQLite plugin as mu-plugin
if [ ! -d "$PLUGIN_DIR" ]; then
  echo "🔄 Installing SQLite integration plugin..."
  mkdir -p "$MU_PLUGIN_DIR"
  cd "$MU_PLUGIN_DIR"
  wget -q "$PLUGIN_ZIP_URL" -O plugin.zip
  unzip -q plugin.zip
  rm plugin.zip
  echo "✅ SQLite integration plugin installed."
else
  echo "ℹ️ SQLite integration plugin already exists in $MU_PLUGIN_DIR."
fi