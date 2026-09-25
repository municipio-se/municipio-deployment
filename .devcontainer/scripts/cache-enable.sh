#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

cd "$PROJECT_ROOT"

WP_ARGS=(--allow-root --skip-plugins --skip-themes)
PLUGIN_SCOPE=()

if [[ "$(wp eval 'echo is_multisite() ? "1" : "0";' "${WP_ARGS[@]}")" == "1" ]]; then
	PLUGIN_SCOPE=(--network)
fi

wp plugin activate redis-cache litespeed-cache "${WP_ARGS[@]}" "${PLUGIN_SCOPE[@]}"
wp redis enable "${WP_ARGS[@]}"