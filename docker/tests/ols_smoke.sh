#!/usr/bin/env bash
# Smoke test for a built image: runtime tuning defaults, overrides, restarts
# and validation.
#   docker/tests/ols_smoke.sh municipio-ols:local
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <image>" >&2
  exit 1
fi
readonly IMAGE=$1
readonly NAME=ols-hbg-smoke-$$
readonly CONF=/usr/local/lsws/conf/httpd_config.conf

failures=0
fail() { echo "FAIL: $*" >&2; failures=$((failures + 1)); }
pass() { echo "ok: $*"; }
cleanup() { docker rm -f "$NAME" >/dev/null 2>&1 || true; }
trap cleanup EXIT

start() {
  cleanup
  docker run -d --name "$NAME" "$@" "$IMAGE" >/dev/null
  for _ in $(seq 1 50); do
    if docker exec "$NAME" test -f /tmp/lshttpd/lshttpd.pid 2>/dev/null; then
      sleep 1  # let lsphp come up
      return
    fi
    sleep 0.2
  done
  docker logs "$NAME" >&2
  echo "Container did not start" >&2
  exit 1
}

# Evaluate a PHP expression in lsphp behind OpenLiteSpeed (not the CLI), so
# the result reflects what web requests see.
web_php() {
  docker exec "$NAME" sh -c '
    printf "<?php echo %s;" "$1" > /var/www/vhosts/localhost/html/smoke.php &&
    chown 1000:1000 /var/www/vhosts/localhost/html/smoke.php &&
    curl -fsS http://localhost/smoke.php &&
    rm -f /var/www/vhosts/localhost/html/smoke.php' sh "$1"
}

web_memory_limit() { web_php 'ini_get("memory_limit")'; }

# expect_web <description> <php expression> <expected output>
expect_web() {
  local actual
  actual=$(web_php "$2")
  if [ "$actual" = "$3" ]; then pass "$1"; else fail "$1: expected '$3', got '$actual'"; fi
}

# expect_conf <description> <extended regex> <expected count>
expect_conf() {
  local count
  count=$(docker exec "$NAME" grep -cE "$2" "$CONF" || true)
  if [ "$count" = "$3" ]; then pass "$1"; else fail "$1: expected $3 match(es) of /$2/, got $count"; fi
}

expect_settings() {
  local workers=$1 children=$2 keepalive=$3 memory=$4 label=$5
  expect_conf "$label httpdWorkers" "^httpdWorkers +$workers$" 1
  expect_conf "$label single httpdWorkers" "^[[:space:]]*httpdWorkers" 1
  expect_conf "$label maxConns" "^ +maxConns +$children$" 1
  expect_conf "$label PHP_LSAPI_CHILDREN" "^ +env +PHP_LSAPI_CHILDREN=$children$" 1
  expect_conf "$label single PHP_LSAPI_CHILDREN" "PHP_LSAPI_CHILDREN=" 1
  expect_conf "$label pcKeepAliveTimeout" "^ +pcKeepAliveTimeout +$keepalive$" 1
  local actual
  actual=$(web_memory_limit)
  if [ "$actual" = "$memory" ]; then pass "$label memory_limit"; else fail "$label memory_limit: expected $memory, got $actual"; fi
}

expect_admin_disabled() {
  expect_conf "$1 WebAdmin disabled" "^disableWebAdmin +1$" 1
  expect_conf "$1 single WebAdmin setting" "^[[:space:]]*disableWebAdmin" 1
  if docker exec "$NAME" sh -c '
    for host in 127.0.0.1 "$(hostname -i | awk "{print \$1}")"; do
      status=0
      curl -ks --noproxy "*" --connect-timeout 2 --max-time 3 "https://$host:7080/" >/dev/null || status=$?
      [ "$status" -eq 7 ] || { echo "WebAdmin check for $host returned curl status $status" >&2; exit 1; }
    done'; then
    pass "$1 WebAdmin port refuses connections"
  else
    fail "$1 WebAdmin port did not refuse connections"
  fi
}

echo "== defaults (no container memory limit)"
start
expect_settings 1 10 5 512M defaults
expect_admin_disabled defaults

echo "== defaults after restart"
docker restart "$NAME" >/dev/null
sleep 3
expect_settings 1 10 5 512M restart
expect_admin_disabled restart
docker exec "$NAME" sed -i 's/^disableWebAdmin .*/disableWebAdmin 0/' "$CONF"
docker restart "$NAME" >/dev/null
sleep 3
expect_admin_disabled "persisted config after restart"

echo "== empty server and admin config volumes are hydrated"
start --tmpfs /usr/local/lsws/conf --tmpfs /usr/local/lsws/admin/conf
expect_settings 1 10 5 512M "empty config volumes"
docker exec "$NAME" test -f /usr/local/lsws/conf/templates/docker.conf
docker exec "$NAME" sh -c 'test -n "$(ls -A /usr/local/lsws/admin/conf)"'
expect_admin_disabled "empty config volumes"

echo "== children follow the container memory limit"
# (3072M - 512M reserved) / 512M = 5
start --memory 3g
expect_settings 1 5 5 512M "3g limit"
# (3072M - 512M) / 256M = 10
start --memory 3g -e PHP_MEMORY_LIMIT=256M
expect_settings 1 10 5 256M "3g limit, 256M requests"
# Less than one request fits: still one child.
start --memory 600m
expect_settings 1 1 5 512M "600m limit"

echo "== overrides"
start --memory 3g -e OLS_PHP_CHILDREN=6 -e OLS_PHP_KEEPALIVE_TIMEOUT=30 -e PHP_MEMORY_LIMIT=1G
expect_settings 1 6 30 1G overrides

echo "== extensions are always loaded"
for ext in tidy tideways; do
  expect_web "$ext loaded in web PHP" "var_export(extension_loaded(\"$ext\"), true)" true
done

echo "== container environment stays out of web PHP; Tideways via ini"
start -e WP_CONF_SMOKE_SETTING=wp-value -e TIDEWAYS_APIKEY=tw-key -e TIDEWAYS_SERVICE=smoke \
  -e TIDEWAYS_SERVICE_HOST=10.0.0.1 -e PHP_INI_SETTINGS=$'max_input_vars=4321\n\n  display_errors = Off  \n'
expect_web "WP_CONF_* not in web PHP env" 'var_export(getenv("WP_CONF_SMOKE_SETTING"), true)' false
expect_web "TIDEWAYS_* not in web PHP env" 'var_export(getenv("TIDEWAYS_APIKEY"), true)' false
expect_web "TIDEWAYS_APIKEY -> tideways.api_key" 'ini_get("tideways.api_key")' tw-key
expect_web "TIDEWAYS_SERVICE -> tideways.service" 'ini_get("tideways.service")' smoke
expect_web "ini setting applied" 'ini_get("max_input_vars")' 4321
expect_conf "no forwarded env lines" "^ +env +(WP_CONF|TIDEWAYS)_" 0
expect_conf "PHP_LSAPI_CHILDREN kept once" "PHP_LSAPI_CHILDREN=" 1
expect_conf "image env lines kept" "LSAPI_AVOID_FORK=" 1
# Env lines from earlier versions on a persisted conf volume are removed.
docker exec "$NAME" sed -i '/extProcessor lsphp{/a\    env WP_CONF_OLD=leftover' "$CONF"
docker restart "$NAME" >/dev/null
sleep 3
expect_conf "old WP_CONF_* env lines removed" "WP_CONF_OLD=" 0
# Rerun configure without the Tideways key and ini settings, as a later start
# would. docker exec inherits the container's environment, so unset them.
docker exec "$NAME" env -u TIDEWAYS_APIKEY -u TIDEWAYS_SERVICE -u PHP_INI_SETTINGS ols-hbg-configure >/dev/null
if docker exec "$NAME" sh -c 'ls /usr/local/lsws/lsphp*/etc/php/*/mods-available/70-hbg-tideways.ini' >/dev/null 2>&1; then
  fail "Tideways ini removed when no TIDEWAYS_* settings are set"
else
  pass "Tideways ini removed when no TIDEWAYS_* settings are set"
fi
if docker exec "$NAME" sh -c 'ls /usr/local/lsws/lsphp*/etc/php/*/mods-available/60-hbg-ini-settings.ini' >/dev/null 2>&1; then
  fail "ini settings file removed when PHP_INI_SETTINGS is empty"
else
  pass "ini settings file removed when PHP_INI_SETTINGS is empty"
fi

echo "== invalid values stop startup"
# <variable=value>|<expected message fragment>
for case in \
  "OLS_PHP_CHILDREN=two|OLS_PHP_CHILDREN must be" \
  "OLS_PHP_KEEPALIVE_TIMEOUT=-1|OLS_PHP_KEEPALIVE_TIMEOUT must be" \
  "PHP_MEMORY_LIMIT=lots|PHP_MEMORY_LIMIT must be" \
  "PHP_INI_SETTINGS=memory_limit=1G|Set memory_limit with PHP_MEMORY_LIMIT" \
  "PHP_INI_SETTINGS=not a directive|Invalid PHP ini directive" \
  'TIDEWAYS_APIKEY=bad"key|TIDEWAYS_APIKEY must be a single line'; do
  setting=${case%%|*} expected=${case#*|}
  cleanup
  if output=$(docker run --name "$NAME" -e "$setting" "$IMAGE" 2>&1); then
    fail "$setting: container started"
  elif grep -qF "$expected" <<<"$output"; then
    pass "$setting rejected"
  else
    fail "$setting: unexpected output: $output"
  fi
done

if [ "$failures" -gt 0 ]; then
  echo "$failures check(s) failed" >&2
  exit 1
fi
echo "All checks passed"
