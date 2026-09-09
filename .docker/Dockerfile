# syntax=docker/dockerfile:1.7
FROM webbutvecklinghelsingborg/gitops:openlitespeed-0.0.3

# WP-CLI is baked in here rather than fetched by prepare_wordpress.sh at boot.
# The entrypoint used to mv it into /usr/bin, which fails the moment the
# container runs as anything but root -- and takes the whole entrypoint with it,
# because entrypoint-wrapper.sh runs under `set -e`. Installing at build time
# also drops a network fetch from every pod start.
#
# USER root is believed to be a no-op -- the base image's entrypoint already
# writes to /usr/bin -- but it is the last USER in this file, so it does decide
# the runtime user. Confirm with:
#   docker image inspect webbutvecklinghelsingborg/gitops:openlitespeed-0.0.3 \
#     --format 'User={{.Config.User}}'
USER root
RUN curl -fsSL -o /usr/local/bin/wp \
      https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && chmod 755 /usr/local/bin/wp \
  && wp --version --allow-root

WORKDIR /var/www/vhosts/localhost/html

COPY --chown=1000:1000 build-output/ .
COPY --chown=1000:1000 .docker/templates/htaccess .htaccess
COPY --chown=1000:1000 --chmod=755 \
  .docker/templates/conf_database.sh \
  .docker/templates/conf_seed_db.sh \
  .docker/templates/prepare_wordpress.sh \
  .docker/templates/wp_deactivate_plugins.sh \
  .docker/templates/entrypoint-wrapper.sh \
  ./

EXPOSE 80 7080
ENTRYPOINT ["./entrypoint-wrapper.sh"]
