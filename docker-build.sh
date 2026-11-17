#!/bin/bash

set -euo pipefail

if [[ $# -ne 1 || -z ${1:-} ]]; then
    printf 'Usage: %s <git-ref>\n' "$0" >&2
    exit 1
fi

gitRef=$1
if [[ $gitRef == -* ]]; then
    printf 'Error: the Git ref must not start with a hyphen.\n' >&2
    exit 1
fi

if [[ -z ${ACF_PRO_KEY:-} ]]; then
    printf 'Error: export ACF_PRO_KEY before building the image.\n' >&2
    exit 1
fi

for command in git docker; do
    if ! command -v "$command" >/dev/null 2>&1; then
        printf 'Error: %s is required.\n' "$command" >&2
        exit 1
    fi
done

export LC_ALL=C
imageTag=${gitRef//[^a-zA-Z0-9_.-]/-}
if [[ $imageTag == [.-]* ]]; then
    imageTag="_$imageTag"
fi
if [[ ${#imageTag} -gt 128 ]]; then
    printf 'Error: the normalized Docker image tag exceeds 128 characters.\n' >&2
    exit 1
fi

buildDirectory=$(mktemp -d)
trap 'rm -rf -- "$buildDirectory"' EXIT

deploymentRepository=https://github.com/municipio-se/municipio-deployment-docker.git
applicationRepository=https://github.com/helsingborg-stad/api.municipio.tech.git
image="api.municipio.tech:$imageTag"

printf 'Fetching the Docker deployment repository...\n'
git clone --depth 1 -- "$deploymentRepository" "$buildDirectory/deployment"

printf 'Building %s from Git ref %s...\n' "$image" "$gitRef"
DOCKER_BUILDKIT=1 docker build \
    --no-cache \
    --secret id=acf_pro_key,env=ACF_PRO_KEY \
    --build-arg "MUNICIPIO_DEPLOYMENT_REPOSITORY=$applicationRepository" \
    --build-arg "MUNICIPIO_DEPLOYMENT_REF=$gitRef" \
    --tag "$image" \
    "$buildDirectory/deployment"

printf 'Built %s locally.\n' "$image"
