#!/bin/bash
# Applies the image's runtime configuration: conf hydration, OpenLiteSpeed/PHP
# sizing for Municipio, PHP ini settings and the environment forwarded to
# lsphp. This is the only script that writes server or PHP config. See README.
#
# Installed as /usr/local/bin/ols-hbg-configure. Municipio's setup.py runs it
# first (so WP-CLI sees the same PHP config as web requests), and
# /entrypoint.sh runs it again before starting OpenLiteSpeed. It is
# idempotent. Must run as root.
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

# Sizing. Each setting is written on every start, from its variable or its
# default, so unsetting a variable restores the default on a reused container
# or a persisted conf volume. See README "Sizing".
positive_int() {
  [[ "$2" =~ ^[1-9][0-9]*$ ]] || fail "$1 must be a positive integer, got '$2'"
}

# Memory reserved outside PHP requests: OPcache (256M, shared), OpenLiteSpeed
# and the lsphp parent process.
readonly RESERVED_BYTES=$((512 * 1024 * 1024))
# PHP children when the container has no memory limit to size from.
readonly FALLBACK_PHP_CHILDREN=10

# Container memory limit in bytes, or nothing when unlimited (cgroup v2 "max",
# or cgroup v1's near-2^63 "unlimited" value).
container_memory_limit() {
  local limit=""
  if [ -r /sys/fs/cgroup/memory.max ]; then
    limit=$(cat /sys/fs/cgroup/memory.max)
  elif [ -r /sys/fs/cgroup/memory/memory.limit_in_bytes ]; then
    limit=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)
  fi
  [[ "$limit" =~ ^[0-9]+$ ]] && [ "${#limit}" -lt 16 ] && echo "$limit"
  return 0
}

# PHP size (e.g. 512M, 1G) to bytes.
size_bytes() {
  local number=${1%[KMG]}
  case "$1" in
    *K) echo $((number * 1024)) ;;
    *M) echo $((number * 1024 * 1024)) ;;
    *G) echo $((number * 1024 * 1024 * 1024)) ;;
    *) echo "$number" ;;
  esac
}

ols_httpd_workers=${OLS_HTTPD_WORKERS:-1}
ols_php_keepalive_timeout=${OLS_PHP_KEEPALIVE_TIMEOUT:-5}
php_memory_limit=${PHP_MEMORY_LIMIT:-512M}
positive_int OLS_HTTPD_WORKERS "$ols_httpd_workers"
positive_int OLS_PHP_KEEPALIVE_TIMEOUT "$ols_php_keepalive_timeout"
[[ "$php_memory_limit" =~ ^(-1|[1-9][0-9]*[KMG]?)$ ]] ||
  fail "PHP_MEMORY_LIMIT must be a size such as 512M, 1G or -1, got '$php_memory_limit'"

# PHP children: OLS_PHP_CHILDREN if set, otherwise as many requests at
# PHP_MEMORY_LIMIT as fit in the container's memory limit after the reserve.
if [ -n "${OLS_PHP_CHILDREN:-}" ]; then
  ols_php_children=$OLS_PHP_CHILDREN
  positive_int OLS_PHP_CHILDREN "$ols_php_children"
  children_reason="from OLS_PHP_CHILDREN"
else
  memory_limit_bytes=$(container_memory_limit)
  if [ -z "$memory_limit_bytes" ]; then
    ols_php_children=$FALLBACK_PHP_CHILDREN
    children_reason="default; the container has no memory limit"
  elif [ "$php_memory_limit" = -1 ]; then
    ols_php_children=$FALLBACK_PHP_CHILDREN
    children_reason="default; PHP_MEMORY_LIMIT is -1"
  else
    ols_php_children=$(( (memory_limit_bytes - RESERVED_BYTES) / $(size_bytes "$php_memory_limit") ))
    [ "$ols_php_children" -ge 1 ] || ols_php_children=1
    children_reason="($((memory_limit_bytes / 1024 / 1024))M container limit - 512M reserved) / $php_memory_limit per request"
  fi
fi
echo "ols-hbg-configure: $ols_php_children PHP children ($children_reason), memory_limit $php_memory_limit"

# Variables passed to web PHP. lsphp gets its environment from
# httpd_config.conf, not from the container, so only these reach getenv():
# every WP_CONF_* (Municipio's WordPress config) and TIDEWAYS_* (the Tideways
# extension) variable, plus any names listed in OLS_PHP_ENV_VARS (comma or
# space separated).
env_names=()
env_lines=""
add_env() {
  local name=$1 value
  [[ " ${env_names[*]} " == *" $name "* ]] && return 0
  env_names+=("$name")
  value=${!name}
  # A config line can't span lines, so only the first line of a value is kept.
  env_lines+="    env                             $name=${value%%$'\n'*}"$'\n'
}
while IFS= read -r name; do
  add_env "$name"
done < <(compgen -e | grep -E '^(WP_CONF|TIDEWAYS)_[A-Za-z0-9_]+$' | sort)
env_vars_list=${OLS_PHP_ENV_VARS:-}
for name in ${env_vars_list//,/ }; do
  [[ "$name" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || fail "Invalid name in OLS_PHP_ENV_VARS: '$name'"
  [ "$name" != PHP_LSAPI_CHILDREN ] || fail "PHP_LSAPI_CHILDREN can't be set via OLS_PHP_ENV_VARS; use OLS_PHP_CHILDREN"
  [ -n "${!name+set}" ] || fail "OLS_PHP_ENV_VARS references an unset variable: $name"
  add_env "$name"
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

# --- httpd_config.conf -----------------------------------------------------

# Replace top-level httpdWorkers, and inside the lsphp extProcessor: maxConns,
# PHP_LSAPI_CHILDREN, pcKeepAliveTimeout and the env lines for OLS_PHP_ENV_VARS
# (this run's names plus the previous run's). Existing lines for these keys
# are dropped and fresh ones written, so the result is the same however many
# times this runs. Other lsphp lines (such as LSAPI_AVOID_FORK) are kept.
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

# memory_limit, then PHP_INI_SETTINGS, both rewritten on every start.
printf 'memory_limit = %s\n' "$php_memory_limit" >"$PHP_ETC/mods-available/$PHP_RUNTIME_INI"
if [ -n "$ini_settings" ]; then
  printf '%s' "$ini_settings" >"$PHP_ETC/mods-available/$PHP_SETTINGS_INI"
else
  rm -f "$PHP_ETC/mods-available/$PHP_SETTINGS_INI"
fi
