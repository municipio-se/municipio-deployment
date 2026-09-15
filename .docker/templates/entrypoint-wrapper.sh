#!/bin/bash
set -euo pipefail

./prepare_wordpress.sh
./conf_database.sh
./conf_seed_db.sh
./wp_deactivate_plugins.sh

exec /entrypoint.sh "$@"
