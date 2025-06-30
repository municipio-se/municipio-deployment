#!/bin/bash
set -e

# Check if SQLite database file exists
if [ ! -f "db.sqlite" ]; then
  echo "🔄 Initializing SQLite database seeding..."
  cp seed.sqlite db.sqlite
  echo "✅ SQLite database seeded."
else
  echo "ℹ️ SQLite database already exists. Skipping seeding."
fi

# Check if the database file is writable
if [ ! -w "db.sqlite" ]; then
  echo "❗ Error: db.sqlite is not writable. Please check permissions."
  exit 1
fi

# Check if the database file is readable
if [ ! -r "db.sqlite" ]; then
  echo "❗ Error: db.sqlite is not readable. Please check permissions."
  exit 1
fi

# Check if the database file is a valid SQLite database
if ! sqlite3 db.sqlite "SELECT 1;" >/dev/null 2>&1; then
  echo "❗ Error: db.sqlite is not a valid SQLite database."
  exit 1
fi  

# Check if the database file is empty
if [ ! -s "db.sqlite" ]; then
  echo "❗ Error: db.sqlite is empty. Please check the seed file."
  exit 1
fi

echo "✅ SQLite database is ready and valid."

# Install mu plugin for sqlite (https://downloads.wordpress.org/plugin/sqlite-database-integration.2.2.2.zip) if not already installed
if [ ! -d "mu-plugins/sqlite-integration" ]; then
  echo "🔄 Installing SQLite integration plugin..."
  mkdir -p mu-plugins
  wget -q https://downloads.wordpress.org/plugin/sqlite-database-integration.2.2.2.zip -O sqlite-database-integration.2.2.2.zip
  unzip -q sqlite-database-integration.2.2.2.zip -d mu-plugins/
  echo "✅ SQLite integration plugin installed."
else
  echo "ℹ️ SQLite integration plugin already installed."
fi