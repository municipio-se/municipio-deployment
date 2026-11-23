#!/usr/bin/env bash
set -euo pipefail

# SHA256 of the upstream OLS tarballs. openlitespeed.org publishes no checksums,
# so these were recorded from the download on first use; a mismatch means the
# file changed upstream and must be investigated before re-pinning. Bumping
# OLS_VERSION requires adding both arch hashes here:
#   curl -fsSL https://openlitespeed.org/packages/openlitespeed-<ver>-<platform>.tgz | sha256sum
case "${OLS_VERSION}-${PLATFORM}" in
  1.8.5-x86_64-linux)  ols_sha256=e50eff3ad5f7a1b5f0571c7d8d29d006ad3978c8b32dcba0b9fb3e7d638db511 ;;
  1.8.5-aarch64-linux) ols_sha256=75aedc2d962ecb984b924fcc09f6ec01d056da291e5161567feb6f8dd17fd25a ;;
  *) echo "No pinned SHA256 for openlitespeed-${OLS_VERSION}-${PLATFORM}.tgz; add it to setup_ols.sh" >&2; exit 1 ;;
esac

# LiteSpeed apt repo signing key (lst_repo.gpg, fingerprint
# 3E892522DB44E1B063D366C5011AA62DEDA1F085). Pinned by file hash instead of
# running https://repo.litespeed.sh, which fetches keys over plain HTTP.
readonly LST_KEY_SHA256=186cd78298b9349134c38130f48b015e87fc228b9a9ca9aeb0c65e47630ed2d5

# Fail fast on slow or unreachable mirrors instead of hanging the build:
# apt and wget retry a few times with short timeouts.
cat > /etc/apt/apt.conf.d/80-hbg-network <<'APT'
Acquire::Retries "5";
Acquire::http::Timeout "30";
Acquire::https::Timeout "30";
APT
WGET=(wget --quiet --timeout=30 --tries=3)

# Install OpenLiteSpeed. Only what the image needs, without recommended extras
# (systemd, dbus, ...): ca-certificates for HTTPS downloads, python3 for
# Municipio's docker/setup scripts, curl for the health check.
apt-get update
apt-get install -y --no-install-recommends ca-certificates python3 \
  wget curl cron tzdata zip less
ols_tgz="openlitespeed-${OLS_VERSION}-${PLATFORM}.tgz"
"${WGET[@]}" "https://openlitespeed.org/packages/$ols_tgz"
echo "$ols_sha256  $ols_tgz" | sha256sum -c -
tar xzf "$ols_tgz"
( cd openlitespeed && ./install.sh )
echo 'cloud-docker' > "$LS_FD/PLAT"
rm -rf /openlitespeed "/$ols_tgz"

# Add the LiteSpeed apt repo (HTTPS, key pinned and scoped via signed-by).
"${WGET[@]}" -O /usr/share/keyrings/litespeed.gpg https://rpms.litespeedtech.com/debian/lst_repo.gpg
echo "$LST_KEY_SHA256  /usr/share/keyrings/litespeed.gpg" | sha256sum -c -
. /etc/os-release
echo "deb [signed-by=/usr/share/keyrings/litespeed.gpg] https://rpms.litespeedtech.com/debian/ $VERSION_CODENAME main" \
  > /etc/apt/sources.list.d/litespeed.list

# Install PHP modules from the LiteSpeed repo added above
apt-get update
# Municipio needs all of these, including tidy and Tideways, so every
# extension is enabled at build time; there is no runtime toggle.
apt-get install -y --no-install-recommends mysql-client \
  "$PHP_VERSION" "$PHP_VERSION"-common "$PHP_VERSION"-opcache \
  "$PHP_VERSION"-curl "$PHP_VERSION"-imagick "$PHP_VERSION"-intl \
  "$PHP_VERSION"-mysql "$PHP_VERSION"-tidy

"${WGET[@]}" -O /usr/share/keyrings/tideways.asc https://packages.tideways.com/key.gpg
echo 'deb [signed-by=/usr/share/keyrings/tideways.asc] https://packages.tideways.com/apt-packages-main any-version main' \
  > /etc/apt/sources.list.d/tideways.list
apt-get update
apt-get install -y --no-install-recommends tideways-php

# Configure OpenLiteSpeed (admin/misc/lsup.sh comes from the pinned tarball)
ln -s "$LS_FD/$PHP_VERSION/bin/php" /usr/bin/php
ln -sf "$LS_FD/$PHP_VERSION/bin/lsphp" "$LS_FD/fcgi-bin/lsphp8"
ln -sf "$LS_FD/fcgi-bin/lsphp8" "$LS_FD/fcgi-bin/lsphp"

# Resolve the lsphp ini path (the PHP minor-version subdir is glob-expanded).
php_ini_candidates=("$LS_FD/$PHP_VERSION"/etc/php/*/litespeed/php.ini)
php_ini=${php_ini_candidates[0]}
if [ ! -f "$php_ini" ]; then
  echo "Could not locate lsphp php.ini under $LS_FD/$PHP_VERSION/etc/php/" >&2
  exit 1
fi

# Append Municipio overrides. PHP honours last-definition-wins, so this
# overrides the shipped defaults without mutating them in place.
cat >> "$php_ini" <<'INI'

; --- Municipio overrides ---
; memory_limit is set at runtime from PHP_MEMORY_LIMIT (see configure.sh).
upload_max_filesize = 1024M
post_max_size = 1024M
max_execution_time = 300

opcache.validate_timestamps = 0
opcache.memory_consumption = 256
opcache.max_accelerated_files = 20000
opcache.interned_strings_buffer = 16
INI

# Build-time default for PHP_MEMORY_LIMIT, so `RUN php ...` in the Municipio
# build sees the same limit. configure.sh rewrites this file on every start;
# keep the file name and default in sync with configure.sh.
php_etc=${php_ini%/litespeed/php.ini}
printf 'memory_limit = 512M\n' > "$php_etc/mods-available/50-hbg-runtime.ini"

# Tideways ships one .so per PHP version; link the one for this lsphp into
# its extension dir. Its ini (from tideways-php) stays in mods-available, so
# the extension is always loaded.
php_version=$(php -r 'echo PHP_MAJOR_VERSION, ".", PHP_MINOR_VERSION, PHP_ZTS ? "-zts" : "";')
extension_dir=$(php -r 'echo ini_get("extension_dir");')
ln -sf "/usr/lib/tideways/tideways-php-$php_version.so" "$extension_dir/tideways.so"
for ext in tidy tideways; do
  [ -f "$php_etc/mods-available/$ext.ini" ] || { echo "Missing $ext.ini in $php_etc/mods-available" >&2; exit 1; }
done

# Cleanup
apt-get purge -y wget zip
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
