#!/bin/bash
# Applies the image's runtime configuration from environment variables:
# conf hydration, OpenLiteSpeed/PHP tuning, optional PHP extensions, PHP ini
# settings and environment variables forwarded to lsphp. See README.
#
# Installed as /usr/local/bin/ols-hbg-configure. /entrypoint.sh runs it before
# starting OpenLiteSpeed. It is idempotent, so a downstream startup script that
# needs the configuration earlier (for example before running PHP CLI setup
# steps) can run it first and then `exec /entrypoint.sh`. Must run as root.
set -euo pipefail

# 994 = lsadm, created by the OLS install script.
readonly LSADM_UID=994
readonly LSADM_GID=994

readonly LSWS_DIR=/usr/local/lsws
readonly LSWS_CONF=$LSWS_DIR/conf
readonly OLS_CONF=$LSWS_CONF/httpd_config.conf
# Names forwarded by OLS_PHP_ENV_VARS on the previous run, so their env lines
# can be removed again when a name is dropped from the list.
readonly ENV_VARS_STATE=$LSWS_CONF/.hbg-php-env-vars
# Also created at build time by setup_ols.sh; keep the names in sync.
readonly PHP_RUNTIME_INI=50-hbg-runtime.ini
readonly PHP_SETTINGS_INI=60-hbg-ini-settings.ini

fail() {
  echo "$*" >&2
  exit 1
}

# Hydrate /usr/local/lsws/conf from the build-time snapshot when the user
# has mounted an empty volume on top of it.
if [ -z "$(ls -A -- "$LSWS_CONF/")" ]; then
  cp -R "$LSWS_DIR"/.conf/* "$LSWS_CONF/"
fi

# --- Validate everything before changing anything -------------------------

# Runtime tuning. Each setting is written on every start, from its variable or
# its documented default, so unsetting a variable restores the default on a
# reused container or a persisted conf volume. See README "Runtime tuning".
positive_int() {
  [[ "$2" =~ ^[1-9][0-9]*$ ]] || fail "$1 must be a positive integer, got '$2'"
}

ols_httpd_workers=${OLS_HTTPD_WORKERS:-1}
ols_php_children=${OLS_PHP_CHILDREN:-10}
ols_php_keepalive_timeout=${OLS_PHP_KEEPALIVE_TIMEOUT:-5}
php_memory_limit=${PHP_MEMORY_LIMIT:-256M}
positive_int OLS_HTTPD_WORKERS "$ols_httpd_workers"
positive_int OLS_PHP_CHILDREN "$ols_php_children"
positive_int OLS_PHP_KEEPALIVE_TIMEOUT "$ols_php_keepalive_timeout"
[[ "$php_memory_limit" =~ ^(-1|[1-9][0-9]*[KMG]?)$ ]] ||
  fail "PHP_MEMORY_LIMIT must be a size such as 256M, 1G or -1, got '$php_memory_limit'"

# OLS_PHP_ENV_VARS: names (comma or space separated) of container variables to
# pass to lsphp. Web PHP gets its environment from httpd_config.conf, not from
# the container, so only listed variables reach it.
env_names=()
env_lines=""
env_vars_list=${OLS_PHP_ENV_VARS:-}
for name in ${env_vars_list//,/ }; do
  [[ "$name" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || fail "Invalid name in OLS_PHP_ENV_VARS: '$name'"
  [ "$name" != PHP_LSAPI_CHILDREN ] || fail "PHP_LSAPI_CHILDREN can't be set via OLS_PHP_ENV_VARS; use OLS_PHP_CHILDREN"
  [ -n "${!name+set}" ] || fail "OLS_PHP_ENV_VARS references an unset variable: $name"
  [[ " ${env_names[*]} " == *" $name "* ]] && continue
  env_names+=("$name")
  value=${!name}
  # A config line can't span lines, so only the first line of a value is kept.
  env_lines+="    env                             $name=${value%%$'\n'*}"$'\n'
done

# PHP_INI_SETTINGS: one `name=value` directive per line.
ini_settings=""
while IFS= read -r line; do
  line=${line#"${line%%[![:space:]]*}"}
  line=${line%"${line##*[![:space:]]}"}
  [ -n "$line" ] || continue
  [[ "$line" =~ ^([A-Za-z][A-Za-z0-9_.-]*)[[:space:]]*= ]] || fail "Invalid PHP ini directive in PHP_INI_SETTINGS: '$line'"
  [ "${BASH_REMATCH[1]}" != memory_limit ] || fail "Set memory_limit with PHP_MEMORY_LIMIT, not PHP_INI_SETTINGS"
  ini_settings+="$line"$'\n'
done <<<"${PHP_INI_SETTINGS:-}"

php_etc_candidates=("$LSWS_DIR"/lsphp*/etc/php/*)
[ "${#php_etc_candidates[@]}" -eq 1 ] && [ -d "${php_etc_candidates[0]}/mods-available" ] ||
  fail "Expected one lsphp ini directory under $LSWS_DIR, found: ${php_etc_candidates[*]}"
readonly PHP_ETC=${php_etc_candidates[0]}

php_extensions=${PHP_EXTENSIONS:-}
for ext in ${php_extensions//,/ }; do
  [ -f "$PHP_ETC/mods-optional/$ext.ini" ] || fail "Unknown optional PHP extension '$ext'. Available:" \
    "$(cd "$PHP_ETC/mods-optional" && ls -- *.ini | sed 's/\.ini$//' | tr '\n' ' ')"
done

# --- httpd_config.conf -----------------------------------------------------

# Replace top-level httpdWorkers, and inside the lsphp extProcessor: maxConns,
# PHP_LSAPI_CHILDREN, pcKeepAliveTimeout and the env lines for OLS_PHP_ENV_VARS
# (this run's names plus the previous run's). Existing lines for these keys
# are dropped and fresh ones written, so the result is the same however many
# times this runs. Other lsphp lines (such as env lines added by downstream
# images) are kept.
previous_names=""
[ -f "$ENV_VARS_STATE" ] && previous_names=$(tr '\n' ' ' <"$ENV_VARS_STATE")
env_lines_file=$(mktemp)
printf '%s' "$env_lines" >"$env_lines_file"
awk \
  -v workers="$ols_httpd_workers" \
  -v children="$ols_php_children" \
  -v keepalive="$ols_php_keepalive_timeout" \
  -v env_remove="$previous_names ${env_names[*]}" \
  -v env_lines_file="$env_lines_file" '
  BEGIN {
    printf "httpdWorkers                     %s\n", workers
    n = split(env_remove, names, " ")
    for (i = 1; i <= n; i++) remove[names[i]] = 1
  }
  depth == 0 && /^[[:space:]]*httpdWorkers([[:space:]]|$)/ { next }
  depth == 0 && /^[[:space:]]*extProcessor[[:space:]]+lsphp[[:space:]]*\{[[:space:]]*$/ {
    print
    printf "    maxConns                        %s\n", children
    printf "    env                             PHP_LSAPI_CHILDREN=%s\n", children
    printf "    pcKeepAliveTimeout              %s\n", keepalive
    while ((getline env_line < env_lines_file) > 0) print env_line
    found = 1; in_lsphp = 1; depth++
    next
  }
  in_lsphp && depth == 1 && /^[[:space:]]*(maxConns|pcKeepAliveTimeout)([[:space:]]|$)/ { next }
  in_lsphp && depth == 1 && /^[[:space:]]*env[[:space:]]+[A-Za-z_][A-Za-z0-9_]*=/ {
    name = $2
    sub(/=.*/, "", name)
    if (name == "PHP_LSAPI_CHILDREN" || name in remove) next
  }
  {
    print
    if ($0 ~ /^[[:space:]]*#/) next
    line = $0
    opened = gsub(/\{/, "", line)
    closed = gsub(/\}/, "", line)
    depth += opened - closed
    if (depth == 0) in_lsphp = 0
  }
  END { if (!found) exit 3 }
' "$OLS_CONF" >"$OLS_CONF.tmp" || {
  rm -f "$OLS_CONF.tmp" "$env_lines_file"
  fail "Could not apply runtime configuration: no 'extProcessor lsphp{' block in $OLS_CONF"
}
rm -f "$env_lines_file"
mv "$OLS_CONF.tmp" "$OLS_CONF"
if [ "${#env_names[@]}" -gt 0 ]; then
  printf '%s\n' "${env_names[@]}" >"$ENV_VARS_STATE"
else
  rm -f "$ENV_VARS_STATE"
fi

chown -R "$LSADM_UID:$LSADM_GID" "$LSWS_CONF"

# --- PHP ini scan dir ------------------------------------------------------

# Optional extensions from PHP_EXTENSIONS. Links are rebuilt on every start so
# removing a name from the env var disables it again on a reused container.
find "$PHP_ETC/mods-available" -maxdepth 1 -type l -lname '../mods-optional/*' -delete
for ext in ${php_extensions//,/ }; do
  ln -sf "../mods-optional/$ext.ini" "$PHP_ETC/mods-available/$ext.ini"
done

# memory_limit, then PHP_INI_SETTINGS, both rewritten on every start. The
# numeric prefixes sort them before other files in the scan dir, so a
# downstream image's own ini file there (e.g. zz-*.ini) still wins.
printf 'memory_limit = %s\n' "$php_memory_limit" >"$PHP_ETC/mods-available/$PHP_RUNTIME_INI"
if [ -n "$ini_settings" ]; then
  printf '%s' "$ini_settings" >"$PHP_ETC/mods-available/$PHP_SETTINGS_INI"
else
  rm -f "$PHP_ETC/mods-available/$PHP_SETTINGS_INI"
fi
