#!/bin/bash
set -euo pipefail

# Get WP-CLI
if [ ! -f "/usr/bin/wp" ]; then
  curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x wp-cli.phar && mv wp-cli.phar /usr/bin/wp
fi

# Generate WP secret-key salt
if [ ! -f "salts.php" ]; then
  printf '<?php\n' > "config/salts.php"
  curl -sf https://api.wordpress.org/secret-key/1.1/salt >> "config/salts.php"
  chown 1000:1000 config/salts.php
fi

printf "define('FS_CHMOD_FILE', 0640);\n
define('FS_CHMOD_DIR', 0750);\n
define('FS_METHOD', 'direct');\n
define('S3_UPLOADS_CUSTOM_ENDPOINT', '');\n
define('S3_UPLOADS_DEBUG', '');\n
define('S3_UPLOADS_KEY', '');\n
define('S3_UPLOADS_SECRET', '');\n
define('S3_UPLOADS_BUCKET', '');\n
define('S3_UPLOADS_REGION', '');\n
define('S3_UPLOADS_BUCKET_URL', '');" >> config/upload.php

printf "define('BLADE_CACHE_PATH', dirname(__FILE__) . '/../wp-content/uploads/cache/blade-cache');" >> config/cache.php

sed -i "s|dev.local.municipio.tech|$PUBLIC_DOMAIN|g" "config/multisite.php"

mkdir -p wp-content/uploads/cache/blade-cache wp-content/fonts
chown 1000:1000 wp-content/uploads/cache/blade-cache wp-content/fonts
rm wp-content/object-cache.php # TODO: check if needed later?