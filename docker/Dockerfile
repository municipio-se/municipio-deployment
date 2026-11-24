# syntax=docker/dockerfile:1.7
# Municipio container image, built from the repository root:
#
#   docker build --secret id=acf_pro_key,env=ACF_PRO_KEY -f docker/Dockerfile -t municipio:local .
#
# Stages:
#   ols      OpenLiteSpeed + lsphp server layer; configuration lives in docker/ols/.
#   node     Node.js binaries for the builder.
#   builder  Builds Municipio with Composer and npm.
#   runtime  The final image: the ols stage plus the built Municipio.

# --- OpenLiteSpeed server layer (docker/ols/) -------------------------------
ARG OLS_IMAGE=litespeedtech/openlitespeed:1.9.4-lsphp83@sha256:628ae67acd413213d28bfa553bd333e1bd2f655aad0919a2f000eb16103dda83
FROM ${OLS_IMAGE} AS ols

ARG PHP_VERSION=lsphp83

# The vendor image provides OpenLiteSpeed, lsphp, and the common PHP extensions.
# Add only Municipio-specific packages and PHP configuration.
RUN --mount=type=bind,source=docker/ols/scripts/install-extensions.sh,target=install-extensions.sh <<EOT
  set -eu
  ./install-extensions.sh
EOT

# Vhost template lives in the image (referenced by httpd_config.conf at runtime).
COPY docker/ols/config/vhost.conf $LS_FD/conf/templates/docker.conf
COPY --chmod=755 docker/ols/scripts/entrypoint.sh /entrypoint.sh
COPY --chmod=755 docker/ols/scripts/configure-runtime.sh /usr/local/bin/ols-hbg-configure

# Configure the Municipio listener/vhost and snapshot server config for
# empty-volume hydration.
RUN --mount=type=bind,source=docker/ols/scripts/configure-listener.sh,target=configure-listener.sh <<EOT
  set -eu
  ./configure-listener.sh
  chown -R lsadm:lsadm $LS_FD/conf
  cp -RP $LS_FD/conf/. $LS_FD/.conf/
EOT

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
CMD []

# --- Municipio build ----------------------------------------------------------
# Node.js is copied from the official image instead of installed from
# NodeSource, so it matches the Debian release of the PHP image below.
FROM node:24-bookworm-slim AS node

# The build stage only needs PHP CLI, Composer, Node.js and Git. It uses the
# slim official PHP image rather than the OpenLiteSpeed runtime image.
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
    rm -rf .git config-example docker && \
    chmod -R 755 .

# --- Final image ----------------------------------------------------------------
# Start from the ols stage above so build tools and package manager caches do
# not become part of the deployed image.
FROM ols AS runtime

USER root

WORKDIR /var/www/vhosts/localhost/html

# WP-CLI is needed by the startup scripts, but Composer, Node.js, npm, and Git
# are build-only dependencies and stay in the builder stage.
COPY --from=builder /usr/local/bin/wp /usr/local/bin/wp
COPY --from=builder --chown=1000:1000 /var/www/vhosts/localhost/html/ ./

COPY --chown=1000:1000 --chmod=755 docker/wordpress/htaccess ./htaccess
COPY --chown=1000:1000 --chmod=755 docker/wordpress/config ./config
COPY --chown=1000:1000 --chmod=755 docker/wordpress/setup ./setup

RUN mkdir -p wp-content/uploads/cache/blade-cache && \
    chown 1000:1000 wp-content/uploads wp-content/uploads/cache wp-content/uploads/cache/blade-cache

EXPOSE 80

# Define a health check for the web server
HEALTHCHECK CMD test "$(curl -s -o /dev/null -w '%{http_code}' http://localhost/)" = "200"

ENTRYPOINT ["./setup/setup.py"]
