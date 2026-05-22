#!/bin/bash
set -euo pipefail

cp config/database-example.php config/database.php

sed -i "s|(#db_name#)|${MYSQL_DATABASE}|g" "config/database.php"
sed -i "s|(#db_user#)|${MYSQL_USER}|g" "config/database.php"
sed -i "s|(#db_password#)|${MYSQL_PASSWORD}|g" "config/database.php"
sed -i "s|(#db_host#)|${MYSQL_HOST}|g" "config/database.php"
sed -i "s|(#table_prefix#)|mun_|g" "config/database.php"

SEARCH_REPLACE_FLAG=".search_replace_done"
if [ ! -f "$SEARCH_REPLACE_FLAG" ]; then
  wp search-replace dev.local.municipio.tech "${PUBLIC_DOMAIN}" \
    $(wp db tables --all-tables-with-prefix --format=csv | tr ',' '\n' | grep -Ev '^hbg_[0-9]+_') \
    --skip-plugins \
    --skip-themes \
    --allow-root \
    --url="${PUBLIC_DOMAIN}" \
    --precise \
    --report-changed-only \
    --dry-run

  wp search-replace https:// http:// \
    $(wp db tables --all-tables-with-prefix --format=csv | tr ',' '\n' | grep -Ev '^hbg_[0-9]+_') \
    --skip-plugins \
    --skip-themes \
    --allow-root \
    --url="${PUBLIC_DOMAIN}" \
    --precise \
    --report-changed-only \
    --dry-run

  touch "$SEARCH_REPLACE_FLAG"
fi
