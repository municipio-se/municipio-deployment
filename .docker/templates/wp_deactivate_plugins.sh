#!/bin/bash
set -euo pipefail

wp plugin deactivate force-ssl active-directory-api-wp-integration \
  --network \
  --allow-root \
  --url="${PUBLIC_DOMAIN}"
