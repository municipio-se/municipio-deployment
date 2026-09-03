#!/bin/bash
set -euo pipefail

# Generate WP secret-key salt
if [ ! -f "config/salts.php" ]; then
  printf '<?php\n' > "config/salts.php"
  curl -sf https://api.wordpress.org/secret-key/1.1/salt >> "config/salts.php"
  chown 1000:1000 config/salts.php
fi

UPLOAD_FILE="config/upload.php"
REQUIRED_VARS=(
  S3_UPLOADS_CUSTOM_ENDPOINT
  S3_UPLOADS_KEY
  S3_UPLOADS_SECRET
  S3_UPLOADS_BUCKET
  S3_UPLOADS_REGION
  S3_UPLOADS_BUCKET_URL
)

missing=()
for var in "${REQUIRED_VARS[@]}"; do
  [ -n "${!var:-}" ] || missing+=("$var")
done

if [ "${#missing[@]}" -gt 0 ]; then
  echo "Error: missing required environment variable(s): ${missing[*]}" >&2
  exit 1
fi

# Written unconditionally, NOT guarded by [ ! -f ]. The build promotes
# config-example/ to config/ (.github/actions/build/action.yml), and
# config-example ships a plain upload.php -- so a not-exists guard here never
# fires, the S3_UPLOADS_* defines never get written, and s3-uploads fatals on an
# undefined S3_UPLOADS_BUCKET. Regenerating from env every boot is idempotent by
# construction and also self-heals a stale upload.php on a mounted volume.
printf "<?php\ndefine('ALLOW_UNFILTERED_UPLOADS', false);
define('FS_CHMOD_FILE', 0640);
define('FS_CHMOD_DIR', 0750);
define('FS_METHOD', 'direct');
define('S3_UPLOADS_CUSTOM_ENDPOINT', '%s');
define('S3_UPLOADS_DEBUG', '');
define('S3_UPLOADS_KEY', '%s');
define('S3_UPLOADS_SECRET', '%s');
define('S3_UPLOADS_BUCKET', '%s');
define('S3_UPLOADS_REGION', '%s');
define('S3_UPLOADS_BUCKET_URL', '%s');\n" \
  "$S3_UPLOADS_CUSTOM_ENDPOINT" \
  "$S3_UPLOADS_KEY" \
  "$S3_UPLOADS_SECRET" \
  "$S3_UPLOADS_BUCKET" \
  "$S3_UPLOADS_REGION" \
  "$S3_UPLOADS_BUCKET_URL" > "$UPLOAD_FILE"

if ! grep -q "BLADE_CACHE_PATH" config/cache.php 2>/dev/null; then
  printf "define('BLADE_CACHE_PATH', dirname(__FILE__) . '/../wp-content/uploads/cache/blade-cache');" >> config/cache.php
fi

sed -i "s|dev.local.municipio.tech|$PUBLIC_DOMAIN|g" "config/multisite.php"

mkdir -p wp-content/uploads/cache/blade-cache wp-content/fonts
chown 1000:1000 wp-content/uploads/cache/blade-cache wp-content/fonts
rm -f wp-content/object-cache.php # TODO: check if needed later?
