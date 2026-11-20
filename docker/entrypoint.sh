#!/usr/bin/env bash
# Container entrypoint: installs WordPress against an empty database, runs the
# optional setup command given as the container command (for example
# `wp plugin activate redis-cache`), then starts FrankenPHP.
set -euo pipefail

# Reads WP_CONF_<name>, falling back to a default.
conf() {
	local var="WP_CONF_$1"
	printf '%s' "${!var:-${2:-}}"
}

require() {
	local value
	value="$(conf "$1")"
	if [[ -z "$value" ]]; then
		echo "entrypoint: WP_CONF_$1 must be set to install WordPress" >&2
		exit 1
	fi
	printf '%s' "$value"
}

install_wordpress() {
	local tries=0
	until wp db check --quiet >/dev/null 2>&1; do
		if ((++tries >= 30)); then
			echo "entrypoint: the database never became reachable" >&2
			exit 1
		fi
		sleep 2
	done

	if wp core is-installed 2>/dev/null; then
		return
	fi

	local multisite url
	multisite="$(conf WP_ALLOW_MULTISITE false)"
	if [[ "$multisite" == true ]]; then
		url="$(require DOMAIN_CURRENT_SITE)"
	else
		url="$(require WP_HOME)"
	fi

	local args=(
		--url="$url"
		--title="$(conf WP_SITE_TITLE WordPress)"
		--admin_user="$(require WP_ADMIN_USER)"
		--admin_password="$(require WP_ADMIN_PASSWORD)"
		--admin_email="$(require WP_ADMIN_EMAIL)"
		--skip-email
	)

	if [[ "$multisite" == true ]]; then
		[[ "$(conf SUBDOMAIN_INSTALL false)" == true ]] && args+=(--subdomains)
		wp core multisite-install "${args[@]}"
	else
		wp core install "${args[@]}"
	fi
}

install_wordpress

if (($#)); then
	echo "entrypoint: running setup command: $*"
	"$@" || echo "entrypoint: setup command failed with exit code $?, starting anyway" >&2
fi

exec frankenphp run --config /etc/frankenphp/Caddyfile --adapter caddyfile
