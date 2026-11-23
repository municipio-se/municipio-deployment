# OpenLiteSpeed + lsphp base layer for the Municipio image. It is not
# published on its own: docker-bake.hcl (repo root) builds it as the "ols"
# target and passes it to docker/Dockerfile as the named context "ols".
FROM ubuntu:24.04

ARG OLS_VERSION=1.8.5
ARG PHP_VERSION=lsphp84
# TARGETARCH is auto-populated by BuildKit (e.g. amd64, arm64).
ARG TARGETARCH

ENV PATH="/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin"
ENV LS_FD="/usr/local/lsws"

# OpenLiteSpeed + PHP
RUN --mount=type=bind,source=templates/setup_ols.sh,target=setup_ols.sh <<EOT
  set -eu
  case "$TARGETARCH" in
    arm64) PLATFORM=aarch64-linux ;;
    amd64) PLATFORM=x86_64-linux ;;
    *) echo "Unsupported TARGETARCH: ${TARGETARCH:-<unset>}" >&2; exit 1 ;;
  esac
  export PLATFORM
  ./setup_ols.sh
EOT

# Vhost template lives in the image (referenced by httpd_config.conf at runtime).
COPY templates/docker.conf $LS_FD/conf/templates/docker.conf
COPY --chmod=+x templates/entrypoint.sh /entrypoint.sh
COPY --chmod=+x templates/configure.sh /usr/local/bin/ols-hbg-configure

# Configure the listener/vhost and snapshot conf for empty-volume hydration.
RUN --mount=type=bind,source=templates/setup_docker.sh,target=setup_docker.sh <<EOT
  set -eu
  touch $LS_FD/admin/conf/htpasswd
  ./setup_docker.sh
  chown -R 994:994 $LS_FD/conf
  cp -RP $LS_FD/conf/ $LS_FD/.conf/
  cp -RP $LS_FD/admin/conf $LS_FD/admin/.conf
EOT

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
CMD []
