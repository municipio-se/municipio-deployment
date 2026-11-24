#!/bin/bash
# Applies the image's runtime configuration: conf hydration, OpenLiteSpeed/PHP
# sizing for Municipio, PHP ini settings and Tideways settings. This is the only script that writes server or PHP config. See README.
#
# Installed as /usr/local/bin/ols-hbg-configure. Municipio's setup.py runs it
# first (so WP-CLI sees the same PHP config as web requests), and
# /entrypoint.sh runs it again before starting OpenLiteSpeed. It is
# idempotent. Must run as root.
set -euo pipefail

readonly LSWS_DIR=/usr/local/lsws
readonly LSWS_CONF=$LSWS_DIR/conf
readonly LSWS_ADMIN_CONF=$LSWS_DIR/admin/conf
readonly OLS_CONF=$LSWS_CONF/httpd_config.conf
# Names forwarded to lsphp by earlier versions of this script, so their env
# lines are removed from a persisted conf volume.
readonly ENV_VARS_STATE=$LSWS_CONF/.hbg-php-env-vars
# Also created at build time by install-extensions.sh; keep the names in sync.
readonly PHP_RUNTIME_INI=50-hbg-runtime.ini
readonly PHP_SETTINGS_INI=60-hbg-ini-settings.ini
readonly TIDEWAYS_SETTINGS_INI=70-hbg-tideways.ini

fail() {
  echo "$*" >&2
  exit 1
}

# Resolve the account created by the vendor image instead of assuming its uid.
id lsadm >/dev/null 2>&1 || fail "OpenLiteSpeed user 'lsadm' is missing"
getent group lsadm >/dev/null || fail "OpenLiteSpeed group 'lsadm' is missing"
readonly LSADM_UID=$(id -u lsadm)
readonly LSADM_GID=$(id -g lsadm)

# Hydrate server and admin config from the image snapshots when an empty volume
# is mounted over either directory.
if [ -z "$(ls -A -- "$LSWS_CONF/")" ]; then
  [ -d "$LSWS_DIR/.conf" ] || fail "Missing OpenLiteSpeed config snapshot at $LSWS_DIR/.conf"
  cp -R "$LSWS_DIR"/.conf/* "$LSWS_CONF/"
fi
if [ -z "$(ls -A -- "$LSWS_ADMIN_CONF/")" ]; then
  [ -d "$LSWS_DIR/admin/.conf" ] || fail "Missing OpenLiteSpeed admin config snapshot at $LSWS_DIR/admin/.conf"
  cp -R "$LSWS_DIR"/admin/.conf/* "$LSWS_ADMIN_CONF/"
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

ols_php_keepalive_timeout=${OLS_PHP_KEEPALIVE_TIMEOUT:-5}
php_memory_limit=${PHP_MEMORY_LIMIT:-512M}
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

# Web PHP gets no container variables: lsphp's environment would expose them
# through getenv(), $_SERVER and phpinfo(). Municipio's WP_CONF_* settings
# reach WordPress through a generated PHP file instead (docker/wordpress/setup/setup.py,
# read by docker/wordpress/config/env.php). Env lines forwarded by earlier versions are
# removed below.
env_names=()
env_lines=""

# Tideways: the documented TIDEWAYS_* variables become the extension's ini
# settings, so the API key never enters lsphp's environment. Only exact names
# are mapped; other TIDEWAYS_* variables (such as Kubernetes' service
# variables TIDEWAYS_SERVICE_HOST/TIDEWAYS_PORT) are ignored.
declare -A TIDEWAYS_INI=(
  [TIDEWAYS_APIKEY]=api_key
  [TIDEWAYS_CONNECTION]=connection
  [TIDEWAYS_SERVICE]=service
  [TIDEWAYS_SAMPLERATE]=sample_rate
  [TIDEWAYS_TRACE_SAMPLE_RATE]=trace_sample_rate
  [TIDEWAYS_FRAMEWORK]=framework
)
tideways_settings=""
for name in $(printf '%s\n' "${!TIDEWAYS_INI[@]}" | sort); do
  [ -n "${!name:-}" ] || continue
  value=${!name}
  [[ "$value" != *[$'\n"']* ]] || fail "$name must be a single line without double quotes"
  tideways_settings+="tideways.${TIDEWAYS_INI[$name]} = \"$value\""$'\n'
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

# Disable WebAdmin, replace top-level httpdWorkers, and inside the lsphp
# extProcessor: maxConns, PHP_LSAPI_CHILDREN and pcKeepAliveTimeout. Env lines
# forwarded by earlier versions (WP_CONF_* and names in the state file) are dropped
# (this run's names plus the previous run's). Existing lines for these keys
# are dropped and fresh ones written, so the result is the same however many
# times this runs. Other lsphp lines (such as LSAPI_AVOID_FORK) are kept.
previous_names=""
[ -f "$ENV_VARS_STATE" ] && previous_names=$(tr '\n' ' ' <"$ENV_VARS_STATE")
env_lines_file=$(mktemp)
printf '%s' "$env_lines" >"$env_lines_file"
awk \
  -v children="$ols_php_children" \
  -v keepalive="$ols_php_keepalive_timeout" \
  -v env_remove="$previous_names ${env_names[*]}" \
  -v env_lines_file="$env_lines_file" '
  BEGIN {
    print "httpdWorkers                     1"
    print "disableWebAdmin                  1"
    n = split(env_remove, names, " ")
    for (i = 1; i <= n; i++) remove[names[i]] = 1
  }
  depth == 0 && /^[[:space:]]*httpdWorkers([[:space:]]|$)/ { next }
  depth == 0 && /^[[:space:]]*disableWebAdmin([[:space:]]|$)/ { next }
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
    if (name == "PHP_LSAPI_CHILDREN" || name ~ /^WP_CONF_/ || name in remove) next
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

chown -R "$LSADM_UID:$LSADM_GID" "$LSWS_CONF" "$LSWS_ADMIN_CONF"
chmod -R u=rwX,go= "$LSWS_ADMIN_CONF"

# --- PHP ini scan dir ------------------------------------------------------

# memory_limit, then PHP_INI_SETTINGS, both rewritten on every start.
printf 'memory_limit = %s\n' "$php_memory_limit" >"$PHP_ETC/mods-available/$PHP_RUNTIME_INI"
if [ -n "$ini_settings" ]; then
  printf '%s' "$ini_settings" >"$PHP_ETC/mods-available/$PHP_SETTINGS_INI"
else
  rm -f "$PHP_ETC/mods-available/$PHP_SETTINGS_INI"
fi
if [ -n "$tideways_settings" ]; then
  printf '%s' "$tideways_settings" >"$PHP_ETC/mods-available/$TIDEWAYS_SETTINGS_INI"
  chmod 640 "$PHP_ETC/mods-available/$TIDEWAYS_SETTINGS_INI"
  chgrp 1000 "$PHP_ETC/mods-available/$TIDEWAYS_SETTINGS_INI"
else
  rm -f "$PHP_ETC/mods-available/$TIDEWAYS_SETTINGS_INI"
fi
