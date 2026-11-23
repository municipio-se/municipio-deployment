# syntax=docker/dockerfile:1.7
# Node.js is copied from the official image instead of installed from
# NodeSource, so it matches the Debian release of the PHP image below.
FROM node:24-bookworm-slim AS node

# The build stage only needs PHP CLI, Composer, Node.js and Git.
FROM php:8.3-cli-bookworm AS builder

# Git lets Composer fetch VCS packages; unzip lets it extract dist archives
# (the PHP image ships neither unzip nor ext-zip).
RUN apt-get update && \
    apt-get install -y --no-install-recommends git unzip && \
    rm -rf /var/lib/apt/lists/*

# WP-CLI (copied into the runtime image, which the startup scripts use)
ADD --chmod=755 https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar /usr/local/bin/wp

# PHP Composer
COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

# Node 24.*
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -s ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx && \
    node --version && npm --version && wp --version --allow-root

# Set the working directory for the application.
WORKDIR /var/www/vhosts/localhost/html

# Build the checked-out source revision. Release workflows check out either
# the release PR head or the pushed semver tag before invoking this Dockerfile.
COPY . .

# Build the project with Composer and the Municipio build script.
# ext-imagick is only needed at runtime (the runtime image provides it), so it
# is not installed here just to satisfy Composer's platform check.
RUN --mount=type=secret,id=acf_pro_key,required=true \
    ACF_PRO_KEY="$(cat /run/secrets/acf_pro_key)" && \
    export COMPOSER_AUTH='{"http-basic": {"connect.advancedcustomfields.com": {"username": "'"$ACF_PRO_KEY"'", "password": "http://localhost"}}}' && \
    php composer-local-merge.php install --prefer-dist --no-progress --optimize-autoloader --classmap-authoritative --ignore-platform-req=ext-imagick && \
    php ./build.php --cleanup --no-composer-in-child-packages --install-npm && \
    rm -rf .git .htaccess config config-example docker && \
    chmod -R 755 .

# FrankenPHP runs PHP inside the Caddy web server, so PHP sees the container's
# environment directly and the web server is configured by docker/Caddyfile.
FROM dunglas/frankenphp:1-php8.3-bookworm AS runtime

# PHP extensions used by WordPress and Municipio, and the MariaDB client used by
# `wp db` commands. The site runs as an unprivileged user with uid 1000.
RUN install-php-extensions bcmath exif gd imagick intl mysqli redis tidy tideways zip && \
    apt-get update && \
    apt-get install -y --no-install-recommends mariadb-client && \
    rm -rf /var/lib/apt/lists/* && \
    cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \
    useradd --uid 1000 --user-group --no-create-home municipio && \
    chown -R municipio:municipio /config /data

WORKDIR /var/www/vhosts/localhost/html

# WP-CLI is needed by the entrypoint, but Composer, Node.js, npm, and Git
# are build-only dependencies and stay in the builder stage.
COPY --from=builder /usr/local/bin/wp /usr/local/bin/wp
COPY --from=builder --chown=1000:1000 /var/www/vhosts/localhost/html/ ./

COPY docker/Caddyfile /etc/frankenphp/Caddyfile
COPY docker/php.ini $PHP_INI_DIR/conf.d/zz-municipio.ini
COPY --chmod=755 docker/entrypoint.sh /usr/local/bin/municipio-entrypoint
COPY --chown=1000:1000 docker/wp-config.php ./wp-config.php

RUN install -d -o 1000 -g 1000 wp-content/uploads wp-content/uploads/cache wp-content/uploads/cache/blade-cache

USER municipio

EXPOSE 8080

HEALTHCHECK CMD curl -fsS -o /dev/null http://127.0.0.1:8080/healthz

ENTRYPOINT ["municipio-entrypoint"]
