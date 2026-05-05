#!/bin/bash
set -euo pipefail

# DEMO DB
if [ "${INSTALL_DEMO_DB:-true}" = "false" ]; then
  exit 0
fi

MAX_TRIES=10
COUNT=0
until wp db check --allow-root; do
	COUNT=$((COUNT + 1))
	if [ "$COUNT" -ge "$MAX_TRIES" ]; then
		exit 1
	fi
	sleep 2
done

SEED_FLAG=".seed_done"
if [ ! -f "$SEED_FLAG" ]; then
  wp db reset --yes --allow-root
  wp db import db_seed.sql --allow-root
	wp search-replace dev.local.municipio.tech "${PUBLIC_DOMAIN}" --skip-plugins --skip-themes --network --all-tables --allow-root --url="${PUBLIC_DOMAIN}"
	wp search-replace https:// http:// --skip-plugins --skip-themes --network --all-tables --allow-root --url="${PUBLIC_DOMAIN}"
	touch "$SEED_FLAG"
	rm db_seed.sql
fi
