# syntax=docker/dockerfile:1.7

# Build a code-tree artifact image for Municipio Deployment.
# Final stage is FROM scratch — this image is *not* a runtime; it carries
# the production-built WP+Municipio tree so it can be consumed elsewhere
# (e.g. municipio-docker's runtime image) via:
#   COPY --from=ghcr.io/<org>/municipio-deployment-labs:<tag> / /var/www/html

ARG PHP_VERSION=8.3

FROM php:${PHP_VERSION}-cli-alpine AS builder

RUN <<EOT
  set -euo pipefail
  apk add --no-cache npm curl git unzip imagemagick imagemagick-dev $PHPIZE_DEPS
  pecl install imagick
  docker-php-ext-enable imagick
EOT

COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

WORKDIR /src
COPY . .

RUN --mount=type=secret,id=composer_auth \
    --mount=type=secret,id=acf_url <<EOT
  set -euo pipefail
  if [ -s /run/secrets/composer_auth ]; then
    export COMPOSER_AUTH="$(cat /run/secrets/composer_auth)"
  fi

  php build-pre.php

  composer install \
    --no-dev \
    --no-interaction \
    --prefer-dist \
    --no-progress \
    --optimize-autoloader \
    --classmap-authoritative

  if [ -s /run/secrets/acf_url ]; then
    curl -fsSL -o /tmp/acf.zip "$(cat /run/secrets/acf_url)"
    unzip -q /tmp/acf.zip -d wp-content/plugins/
    rm /tmp/acf.zip
  fi

  php build.php --cleanup --no-composer-in-child-packages

  test -f index.php
  test -d wp
  test -d wp-content
EOT

FROM scratch AS final
COPY --from=builder /src/ /
