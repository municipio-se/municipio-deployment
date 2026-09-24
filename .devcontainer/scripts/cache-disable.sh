#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

cd "$PROJECT_ROOT"

WP_ARGS=(--allow-root)
WP_SAFE_ARGS=(--allow-root --skip-plugins --skip-themes)
PLUGIN_SCOPE=()

if [[ "$(wp eval 'echo is_multisite() ? "1" : "0";' "${WP_SAFE_ARGS[@]}")" == "1" ]]; then
	PLUGIN_SCOPE=(--network)
fi

if wp plugin is-active litespeed-cache "${WP_SAFE_ARGS[@]}" "${PLUGIN_SCOPE[@]}"; then
	wp eval 'define("LITESPEED_PURGE_SILENT", true); do_action("litespeed_purge_all", "devcontainer cache-disable");' "${WP_ARGS[@]}" --skip-themes
fi

wp cache flush "${WP_SAFE_ARGS[@]}"
wp plugin deactivate redis-cache litespeed-cache "${WP_SAFE_ARGS[@]}" "${PLUGIN_SCOPE[@]}"