#!/usr/bin/env bash
# Smoke test for a built image: runtime tuning defaults, overrides, restarts
# and validation.
#   tests/smoke.sh ghcr.io/helsingborg-stad/ols-docker-hbg:test-php8.4
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

echo "== defaults (no container memory limit)"
start
expect_settings 1 10 5 512M defaults

echo "== defaults after restart"
docker restart "$NAME" >/dev/null
sleep 3
expect_settings 1 10 5 512M restart

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
start --memory 3g -e OLS_HTTPD_WORKERS=2 -e OLS_PHP_CHILDREN=6 -e OLS_PHP_KEEPALIVE_TIMEOUT=30 -e PHP_MEMORY_LIMIT=1G
expect_settings 2 6 30 1G overrides

echo "== extensions are always loaded"
for ext in tidy tideways; do
  expect_web "$ext loaded in web PHP" "var_export(extension_loaded(\"$ext\"), true)" true
done

echo "== WP_CONF_* and TIDEWAYS_* reach web PHP without listing"
start -e WP_CONF_SMOKE_SETTING=wp-value -e TIDEWAYS_APIKEY=tw-key -e SMOKE_UNLISTED=hidden
expect_web "WP_CONF_* forwarded" 'getenv("WP_CONF_SMOKE_SETTING")' wp-value
expect_web "TIDEWAYS_* forwarded" 'getenv("TIDEWAYS_APIKEY")' tw-key
expect_web "other variables not forwarded" 'var_export(getenv("SMOKE_UNLISTED"), true)' false
docker restart "$NAME" >/dev/null
sleep 3
expect_conf "WP_CONF_* line not duplicated after restart" "^ +env +WP_CONF_SMOKE_SETTING=wp-value$" 1
expect_conf "TIDEWAYS_* line not duplicated after restart" "^ +env +TIDEWAYS_APIKEY=tw-key$" 1
docker exec "$NAME" env -u WP_CONF_SMOKE_SETTING ols-hbg-configure >/dev/null
expect_conf "unset WP_CONF_* variable removed" "WP_CONF_SMOKE_SETTING=" 0

echo "== OLS_PHP_ENV_VARS and PHP_INI_SETTINGS"
start -e SMOKE_A=alpha -e "SMOKE_B=two words" -e SMOKE_C=gamma -e OLS_PHP_ENV_VARS="SMOKE_A, SMOKE_B" \
  -e PHP_INI_SETTINGS=$'max_input_vars=4321\n\n  display_errors = Off  \n'
expect_web "env var reaches web PHP" 'getenv("SMOKE_A")' alpha
expect_web "env value with spaces" 'getenv("SMOKE_B")' "two words"
expect_web "unlisted env var not forwarded" 'var_export(getenv("SMOKE_C"), true)' false
expect_web "ini setting applied" 'ini_get("max_input_vars")' 4321
docker restart "$NAME" >/dev/null
sleep 3
expect_conf "env line not duplicated after restart" "^ +env +SMOKE_A=alpha$" 1
expect_conf "PHP_LSAPI_CHILDREN kept once" "PHP_LSAPI_CHILDREN=" 1
expect_conf "image env lines kept" "LSAPI_AVOID_FORK=" 1
# Rerun configure in the same container with a shorter list and no ini
# settings, as a later start with changed variables would. docker exec
# inherits the container's environment, so unset what should be gone.
docker exec "$NAME" env -u PHP_INI_SETTINGS OLS_PHP_ENV_VARS=SMOKE_A ols-hbg-configure
expect_conf "dropped env var removed" "SMOKE_B=" 0
expect_conf "kept env var still once" "^ +env +SMOKE_A=alpha$" 1
docker exec "$NAME" env -u OLS_PHP_ENV_VARS -u PHP_INI_SETTINGS ols-hbg-configure
expect_conf "all forwarded env vars removed" "SMOKE_" 0
if docker exec "$NAME" sh -c 'ls /usr/local/lsws/lsphp*/etc/php/*/mods-available/60-hbg-ini-settings.ini' >/dev/null 2>&1; then
  fail "ini settings file removed when PHP_INI_SETTINGS is empty"
else
  pass "ini settings file removed when PHP_INI_SETTINGS is empty"
fi

echo "== invalid values stop startup"
# <variable=value>|<expected message fragment>
for case in \
  "OLS_HTTPD_WORKERS=0|OLS_HTTPD_WORKERS must be" \
  "OLS_PHP_CHILDREN=two|OLS_PHP_CHILDREN must be" \
  "OLS_PHP_KEEPALIVE_TIMEOUT=-1|OLS_PHP_KEEPALIVE_TIMEOUT must be" \
  "PHP_MEMORY_LIMIT=lots|PHP_MEMORY_LIMIT must be" \
  "OLS_PHP_ENV_VARS=SMOKE_MISSING|unset variable: SMOKE_MISSING" \
  "OLS_PHP_ENV_VARS=BAD-NAME|Invalid name in OLS_PHP_ENV_VARS" \
  "OLS_PHP_ENV_VARS=PHP_LSAPI_CHILDREN|use OLS_PHP_CHILDREN" \
  "PHP_INI_SETTINGS=memory_limit=1G|Set memory_limit with PHP_MEMORY_LIMIT" \
  "PHP_INI_SETTINGS=not a directive|Invalid PHP ini directive"; do
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
