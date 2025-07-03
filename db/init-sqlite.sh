#!/bin/bash
set -e

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$BASE_DIR/.."
DB_FILE="$BASE_DIR/db.sqlite"
SEED_FILE="$BASE_DIR/seed.sqlite"
PLUGIN_ZIP_URL="https://downloads.wordpress.org/plugin/sqlite-database-integration.2.2.2.zip"
PLUGIN_NAME="sqlite-database-integration"
PLUGIN_DIR="$PROJECT_ROOT/wp-content/plugins/$PLUGIN_NAME"
DB_DROPIN_TARGET_LOCATION="$PROJECT_ROOT/wp-content/db.php"
DB_DROPIN_SOURCE_LOCATION="$PLUGIN_DIR/db.copy"

initialize_database() {
  if [ ! -f "$DB_FILE" ]; then
    echo "🔄 Initializing SQLite database seeding..."
    cp "$SEED_FILE" "$DB_FILE"
    echo "✅ SQLite database seeded."
  else
    echo "ℹ️ SQLite database already exists. Skipping seeding."
  fi
}

validate_database() {
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
}

install_sqlite_plugin() {
  if [ ! -d "$PLUGIN_DIR" ]; then
    echo "🔄 Installing SQLite integration plugin..."
    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR"
    wget -q "$PLUGIN_ZIP_URL" -O plugin.zip
    unzip -q plugin.zip
    rm plugin.zip
    rm -rf "$PLUGIN_DIR"
    mv "$PLUGIN_NAME" "$PLUGIN_DIR"
    rm -rf "$TMP_DIR"
    echo "✅ SQLite integration plugin installed."
  else
    echo "ℹ️ SQLite integration plugin already exists in $PLUGIN_DIR."
  fi
}

copy_db_dropin() {
  if [ -f "$DB_DROPIN_SOURCE_LOCATION" ]; then
    echo "🔄 Preparing to copy db.php drop-in..."
    rm -f "$DB_DROPIN_TARGET_LOCATION"
    echo "🔄 Copying db.php drop-in to $DB_DROPIN_TARGET_LOCATION..."
    cp "$DB_DROPIN_SOURCE_LOCATION" "$DB_DROPIN_TARGET_LOCATION"
    echo "✅ db.php drop-in copied successfully."
  else
    echo "❗ Error: $DB_DROPIN_SOURCE_LOCATION does not exist. Cannot copy drop-in."
    exit 1
  fi
}

main() {
  initialize_database
  validate_database
  install_sqlite_plugin
  copy_db_dropin
}

main