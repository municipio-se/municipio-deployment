#!/usr/bin/env bash

### Create a new local subfolder site from a remote subdomain site ###

### CONFIGURATION ###

SSH_PORT=3022
REMOTE_SSH="ubuntu@91.197.42.88"
REMOTE_PATH="/var/www/prod"   # WordPress root on remote
LOCAL_PATH="/var/www/html"
REMOTE_SITE_PROTOCOL="https://"
REMOTE_SITE_DOMAIN="sundsparlan.se"
REMOTE_SITE_URL="${REMOTE_SITE_PROTOCOL}${REMOTE_SITE_DOMAIN}"
LOCAL_SITE_DOMAIN="localhost:8443"
LOCAL_MU_SITE_URL="https://${LOCAL_SITE_DOMAIN}"
LOCAL_SITE_SLUG="sundsparlan"
LOCAL_SITE_URL="$LOCAL_MU_SITE_URL/$LOCAL_SITE_SLUG"
REMOTE_PREFIX="hbg_"
LOCAL_PREFIX="mun_"
TMP_SQL="/tmp/${LOCAL_SITE_SLUG}.sql"

# Check if local site already exists, and prompt to delete or not
if wp site list --allow-root --url=$LOCAL_SITE_URL | grep -q "$LOCAL_SITE_URL"; then
  echo "Local site $LOCAL_SITE_URL already exists."
  read -p "Do you want to delete it and continue? (y/n): " choice
  if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    echo "Deleting local site $LOCAL_SITE_URL..."
    wp site delete $LOCAL_SITE_SLUG --allow-root --url=$LOCAL_MU_SITE_URL --yes
  else
    echo "Aborting migration."
    exit 1
  fi
fi

echo "=== Exporting remote subsite database ==="

echo "Connecting to remote server..."
echo "If prompted, please enter the SSH password for $REMOTE_SSH."
ssh -q -p $SSH_PORT $REMOTE_SSH <<EOF
cd $REMOTE_PATH

# Export the subsite's tables
wp db export $TMP_SQL --add-drop-table --tables=\$(wp db tables --scope=blog --url=$REMOTE_SITE_DOMAIN --skip-plugins --skip-themes --allow-root | paste -sd, -) --skip-plugins --skip-themes
exit

EOF

# Extract REMOTE_SITE_ID from remote and make it available locally
echo "=== Getting remote site ID ==="
REMOTE_SITE_ID=$(ssh -q -p $SSH_PORT $REMOTE_SSH "cd $REMOTE_PATH; wp site list --skip-plugins --skip-themes --allow-root | grep '$REMOTE_SITE_URL' | awk '{print \$1}'")
if [ -z "$REMOTE_SITE_ID" ]; then
  echo "Failed to get REMOTE_SITE_ID from remote. Aborting."
  exit 1
fi

echo "REMOTE_SITE_ID is $REMOTE_SITE_ID"

# remove local temp file if exists
if [ -f $TMP_SQL ]; then
  echo "Removing existing local temp SQL file..."
  rm -f $TMP_SQL
fi

echo "=== Downloading SQL file ==="
scp -P $SSH_PORT $REMOTE_SSH:$TMP_SQL $TMP_SQL
echo "Ran command scp -P $SSH_PORT $REMOTE_SSH:$TMP_SQL $TMP_SQL"

echo "=== Cleaning remote temp file ==="
ssh -p $SSH_PORT $REMOTE_SSH "rm -f $TMP_SQL"

echo "=== Importing into local database ==="
cd $LOCAL_PATH

# Create the subfolder site locally
wp site create --slug=$LOCAL_SITE_SLUG --allow-root

# Get the ID of the newly created subsite
LOCAL_SITE_ID=$(wp site list --allow-root | grep "$LOCAL_SITE_URL" | awk '{print $1}')

# Import SQL
wp db import $TMP_SQL --allow-root

echo "=== Updating table prefixes ==="

# Rename imported tables from remote prefix to local prefix

# Extract remote site ID from one of the remote tables (e.g., hbg_1001_posts)
LOCAL_SITE_PREFIX="${LOCAL_PREFIX}${LOCAL_SITE_ID}_"

# Ensure table list is not empty and pattern matches correctly
tables_to_rename=$(wp db tables --all-tables --allow-root | grep "^${REMOTE_PREFIX}${REMOTE_SITE_ID}_")
if [ -n "$tables_to_rename" ]; then
  echo "Found tables to rename:"
  for table in $tables_to_rename; do
    # Extract the suffix after the remote prefix and site id
    suffix="${table#${REMOTE_PREFIX}${REMOTE_SITE_ID}_}"
    newtable="${LOCAL_PREFIX}${LOCAL_SITE_ID}_${suffix}"
    # Debug: Check for line breaks or unexpected characters
    
    echo "Renaming table $table to $newtable"
    wp db query "DROP TABLE $newtable;" --allow-root
    wp db query "RENAME TABLE $table TO $newtable;" --allow-root
  done
else
  echo "No tables found to rename with pattern ^${REMOTE_PREFIX}${REMOTE_SITE_ID}_"
fi

echo "Replacing $REMOTE_SITE_DOMAIN with $LOCAL_SITE_DOMAIN in database..."
wp search-replace "$REMOTE_SITE_DOMAIN" "$LOCAL_SITE_DOMAIN" --allow-root \
  --network \
  --skip-columns=guid

wp option update siteurl "${LOCAL_SITE_URL}" --allow-root --url=$LOCAL_SITE_URL
wp option update home "${LOCAL_SITE_URL}" --allow-root --url=$LOCAL_SITE_URL

echo "=== Done! ==="

echo "Cleaning up temporary SQL file..."
rm -f $TMP_SQL
