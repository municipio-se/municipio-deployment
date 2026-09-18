#!/bin/bash
set -e

VERSION="${VERSION:-latest}"

if [ "$VERSION" = "latest" ]; then
    URL="https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar"
else
    URL="https://github.com/wp-cli/wp-cli/releases/download/v${VERSION}/wp-cli.phar"
fi

curl -fsSL "$URL" -o /tmp/wp-cli.phar

php /tmp/wp-cli.phar --info

install -m 0755 /tmp/wp-cli.phar /usr/local/bin/wp

rm /tmp/wp-cli.phar

wp --info