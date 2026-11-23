# Builds the Municipio container image in two clearly separated layers:
#
#   ols        docker/ols/       OpenLiteSpeed + lsphp server layer
#   municipio  docker/Dockerfile Municipio application, built FROM the ols layer
#
# The ols target is passed to municipio as the named build context "ols", so
# `docker buildx bake` (default target: municipio) produces one image with the
# server layer built from source. The ols layer is never published on its own.
#
# Requires ACF_PRO_KEY in the environment for the municipio target.

group "default" {
  targets = ["municipio"]
}

target "ols" {
  context    = "docker/ols"
  dockerfile = "Dockerfile"
  args = {
    OLS_VERSION = "1.8.5"
    PHP_VERSION = "lsphp83"
  }
}

target "municipio" {
  context    = "."
  dockerfile = "docker/Dockerfile"
  contexts = {
    ols = "target:ols"
  }
  secret = ["id=acf_pro_key,env=ACF_PRO_KEY"]
  tags   = ["municipio:local"]
}
