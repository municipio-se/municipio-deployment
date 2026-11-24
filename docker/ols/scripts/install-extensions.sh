#!/usr/bin/env bash
set -euo pipefail

# Fail fast on slow or unreachable mirrors instead of hanging the build.
cat > /etc/apt/apt.conf.d/80-hbg-network <<'APT'
Acquire::Retries "5";
Acquire::http::Timeout "30";
Acquire::https::Timeout "30";
APT

# The vendor image already includes OLS, lsphp, curl, cron, tzdata, and the
# PHP extensions Municipio needs other than Tidy and Tideways.
apt-get update
apt-get install -y --no-install-recommends python3 less zip "$PHP_VERSION-tidy"

# Pin the repository key and scope it to the Tideways repository.
readonly TIDEWAYS_KEY_SHA256=828bd5238e7fd404e28c392ad362fc85f80958f86267903bdad925009bcc7b7d
curl -fsSL --retry 3 --connect-timeout 30 \
  -o /usr/share/keyrings/tideways.asc https://packages.tideways.com/key.gpg
echo "$TIDEWAYS_KEY_SHA256  /usr/share/keyrings/tideways.asc" | sha256sum -c -
echo 'deb [signed-by=/usr/share/keyrings/tideways.asc] https://packages.tideways.com/apt-packages-main any-version main' \
  > /etc/apt/sources.list.d/tideways.list
apt-get update
apt-get install -y --no-install-recommends tideways-php

# Resolve the lsphp ini path (the PHP minor-version subdir is glob-expanded).
php_ini_candidates=("$LS_FD/$PHP_VERSION"/etc/php/*/litespeed/php.ini)
[ "${#php_ini_candidates[@]}" -eq 1 ] ||
  { echo "Expected one lsphp php.ini under $LS_FD/$PHP_VERSION/etc/php/" >&2; exit 1; }
php_ini=${php_ini_candidates[0]}
if [ ! -f "$php_ini" ]; then
  echo "Could not locate lsphp php.ini under $LS_FD/$PHP_VERSION/etc/php/" >&2
  exit 1
fi

# Append Municipio overrides. PHP honours last-definition-wins, so this
# overrides the shipped defaults without mutating them in place.
cat >> "$php_ini" <<'INI'

; --- Municipio overrides ---
; memory_limit is set at runtime from PHP_MEMORY_LIMIT (see configure-runtime.sh).
upload_max_filesize = 1024M
post_max_size = 1024M
max_execution_time = 300

opcache.validate_timestamps = 0
opcache.memory_consumption = 256
opcache.max_accelerated_files = 20000
opcache.interned_strings_buffer = 16
INI

# Build-time default for PHP_MEMORY_LIMIT, so `RUN php ...` in the Municipio
# build sees the same limit. configure-runtime.sh rewrites this file on every start;
# keep the file name and default in sync with configure-runtime.sh.
php_etc=${php_ini%/litespeed/php.ini}
printf 'memory_limit = 512M\n' > "$php_etc/mods-available/50-hbg-runtime.ini"

# Tideways ships one .so per PHP version; link the one for this lsphp into
# its extension dir. Its ini (from tideways-php) stays in mods-available, so
# the extension is always loaded.
php_version=$(php -r 'echo PHP_MAJOR_VERSION, ".", PHP_MINOR_VERSION, PHP_ZTS ? "-zts" : "";')
extension_dir=$(php -r 'echo ini_get("extension_dir");')
tideways_extension="/usr/lib/tideways/tideways-php-$php_version.so"
[ -f "$tideways_extension" ] || { echo "Missing $tideways_extension" >&2; exit 1; }
ln -sf "$tideways_extension" "$extension_dir/tideways.so"
for ext in tidy tideways; do
  [ -f "$php_etc/mods-available/$ext.ini" ] || { echo "Missing $ext.ini in $php_etc/mods-available" >&2; exit 1; }
done

# Cleanup
apt-get clean
rm -rf /var/lib/apt/lists/*
