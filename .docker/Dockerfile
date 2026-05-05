# syntax=docker/dockerfile:1.7
FROM mrspex/helsingborg:openlitespeed-0.0.1

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

EXPOSE 80 7080 8088
ENTRYPOINT ["./entrypoint-wrapper.sh"]
