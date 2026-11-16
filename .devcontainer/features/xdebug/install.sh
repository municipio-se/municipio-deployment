#!/bin/bash
set -e

VERSION="${VERSION:-latest}"
PHP_VERSION="${PHPVERSION:-8.3}"
CLIENT_PORT="${CLIENTPORT:-9003}"

PHP_SHORT="${PHP_VERSION//./}"
LSPHP_DIR="/usr/local/lsws/lsphp${PHP_SHORT}"
# Scan dir used by both the lsphp web handler and the php CLI (/usr/bin/php -> lsphp).
INI_DIR="${LSPHP_DIR}/etc/php/${PHP_VERSION}/mods-available"

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends "lsphp${PHP_SHORT}-dev" "lsphp${PHP_SHORT}-pear" "php${PHP_VERSION}-mysql" autoconf pkg-config make gcc

PACKAGE="xdebug"
if [ "$VERSION" != "latest" ]; then
    PACKAGE="xdebug-${VERSION}"
fi

printf "\n" | "${LSPHP_DIR}/bin/pecl" install -f "$PACKAGE"

EXT_DIR="$("${LSPHP_DIR}/bin/php-config" --extension-dir)"

cat > "${INI_DIR}/20-xdebug.ini" <<EOF
zend_extension=${EXT_DIR}/xdebug.so
xdebug.mode=debug
; Only start a session when triggered (XDEBUG_TRIGGER/XDEBUG_SESSION env var, GET/POST param or cookie).
xdebug.start_with_request=trigger
xdebug.client_host=localhost
xdebug.client_port=${CLIENT_PORT}
EOF

if command -v php >/dev/null 2>&1; then
    CLI_API="$(php -i | sed -n 's/^PHP API => //p' | head -n 1)"
    LSPHP_API="$("${LSPHP_DIR}/bin/php" -i | sed -n 's/^PHP API => //p' | head -n 1)"
    CLI_ZTS="$(php -r 'echo PHP_ZTS ? "ZTS" : "NTS";')"
    LSPHP_ZTS="$("${LSPHP_DIR}/bin/php" -r 'echo PHP_ZTS ? "ZTS" : "NTS";')"

    if [ "${CLI_API}" != "${LSPHP_API}" ] || [ "${CLI_ZTS}" != "${LSPHP_ZTS}" ]; then
        echo "CLI PHP and lsphp have incompatible extension APIs; cannot share Xdebug." >&2
        exit 1
    fi

    CLI_INI_DIR="$(php --ini | sed -n 's/^Scan for additional .ini files in: //p')"
    if [ -z "${CLI_INI_DIR}" ] || [ ! -d "${CLI_INI_DIR}" ]; then
        echo "Unable to locate the CLI PHP ini scan directory." >&2
        exit 1
    fi

    cat > "${CLI_INI_DIR}/20-xdebug.ini" <<EOF
zend_extension=${EXT_DIR}/xdebug.so
xdebug.mode=debug
xdebug.start_with_request=trigger
xdebug.client_host=localhost
xdebug.client_port=${CLIENT_PORT}
EOF

    php --ri xdebug >/dev/null
    php --ri mysqli >/dev/null
fi

rm -rf /tmp/pear /var/lib/apt/lists/*

"${LSPHP_DIR}/bin/php" -v
