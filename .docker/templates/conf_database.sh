#!/bin/bash
set -euo pipefail

cp config/database-example.php config/database.php

sed -i "s|(#db_name#)|${MYSQL_DATABASE}|g" "config/database.php"
sed -i "s|(#db_user#)|${MYSQL_USER}|g" "config/database.php"
sed -i "s|(#db_password#)|${MYSQL_PASSWORD}|g" "config/database.php"
sed -i "s|(#db_host#)|${MYSQL_HOST}|g" "config/database.php"
sed -i "s|(#table_prefix#)|mun_|g" "config/database.php"
