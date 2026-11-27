#!/usr/bin/env bash
# Routing test for the .htaccess flavors in docker/wordpress/htaccess/ together with the
# OpenLiteSpeed site config from the ols stage (shared rewrite rules,
# LiteSpeed Cache rules, headers, cache lifetimes, 404 page). Runs each flavor against a mock document root laid out like the
# image: core in wp/, wp-content/ and the wp-admin/ + wp-login.php redirect
# shims in the root. Every PHP file prints which file it is.
#
#   docker build --target ols -f docker/Dockerfile -t municipio-ols:local .
#   docker/tests/htaccess_routing.sh municipio-ols:local
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <image built with --target ols>" >&2
  exit 1
fi
readonly IMAGE=$1
readonly HTACCESS_DIR=$(cd "$(dirname "$0")/../wordpress/htaccess" && pwd)
readonly NAME=htaccess-routing-$$

failures=0
fail() { echo "FAIL: $*" >&2; failures=$((failures + 1)); }
pass() { echo "ok: $*"; }
cleanup() { docker rm -f "$NAME" >/dev/null 2>&1 || true; }
trap cleanup EXIT

start() {
  local flavor=$1
  cleanup
  docker run -d --name "$NAME" --entrypoint sleep -v "$HTACCESS_DIR:/opt/htaccess:ro" "$IMAGE" infinity >/dev/null
  docker exec "$NAME" sh -c '
    set -e
    H=/var/www/vhosts/localhost/html
    php() { mkdir -p "$(dirname "$H/$1")"; printf "<?php echo \"%s\", \" q=\", \$_SERVER[\"QUERY_STRING\"] ?? \"\";" "$2" > "$H/$1"; }
    php index.php "index"
    php wp-login.php "root-shim:wp-login"
    php wp-admin/index.php "root-shim:wp-admin"
    php wp/wp-admin/index.php "core:wp-admin/index"
    php wp/wp-admin/edit.php "core:wp-admin/edit"
    php wp/wp-login.php "core:wp-login"
    php wp/wp-cron.php "core:wp-cron"
    php wp/xmlrpc.php "core:xmlrpc"
    php wp/wp-signup.php "core:wp-signup"
    php xmlrpc.php "root:xmlrpc"
    # Marks itself cacheable the way the LiteSpeed Cache plugin does.
    printf "<?php header(\"X-LiteSpeed-Cache-Control: public,max-age=60\"); echo \"cached \", uniqid();" > $H/cached.php
    mkdir -p $H/wp-content/litespeed/debug && echo log > $H/wp-content/litespeed/debug/debug.log
    mkdir -p $H/wp/wp-includes/js $H/wp-content/themes/t $H/wp-content/uploads
    echo "js" > $H/wp/wp-includes/js/a.js
    echo "css" > $H/wp-content/themes/t/a.css
    cp /opt/htaccess/'"$flavor"'.htaccess $H/.htaccess
    chown -R 1000:1000 $H && chown root:root $H/.htaccess
    ols-hbg-configure >/dev/null
    /usr/local/lsws/bin/lswsctrl start >/dev/null
  '
  for _ in $(seq 1 50); do
    docker exec "$NAME" curl -fso /dev/null http://localhost/ 2>/dev/null && return
    sleep 0.2
  done
}

# request <path> [host]: prints "<status> <location> <body>"
request() {
  docker exec "$NAME" sh -c '
    curl -s -o /tmp/body -D /tmp/head -H "Host: $2" "http://localhost$1"
    status=$(head -1 /tmp/head | cut -d" " -f2)
    location=$(grep -i "^location:" /tmp/head | cut -d" " -f2 | tr -d "\r")
    printf "%s %s %s" "$status" "${location:--}" "$(head -c 200 /tmp/body | tr -d "\n")"' sh "$1" "${2:-localhost}"
}

header() {
  docker exec "$NAME" sh -c 'curl -s -o /dev/null -D - "http://localhost$1" | grep -i "^$2:" | cut -d" " -f2- | tr -d "\r"' sh "$1" "$2"
}

# expect <description> <path> <status> <location or -> <body prefix or -> [host]
expect() {
  local actual status location body
  actual=$(request "$2" "${6:-}")
  status=${actual%% *}
  location=$(cut -d" " -f2 <<<"$actual")
  body=$(cut -d" " -f3- <<<"$actual")
  if [ "$status" != "$3" ]; then fail "$1: $2 status $status, expected $3 ($actual)"; return; fi
  if [ "$4" != - ] && [ "$location" != "$4" ]; then fail "$1: $2 redirects to $location, expected $4"; return; fi
  if [ "$5" != - ] && [[ "$body" != "$5"* ]]; then fail "$1: $2 body '$body', expected '$5…'"; return; fi
  pass "$1"
}

expect_header() {
  local actual
  actual=$(header "$2" "$3")
  if [ "$actual" = "$4" ]; then pass "$1"; else fail "$1: $3 on $2 is '$actual', expected '$4'"; fi
}

# expect_cache <description> <path> <expected X-LiteSpeed-Cache value or "">
expect_cache() {
  local actual
  actual=$(header "$2" X-LiteSpeed-Cache)
  if [ "$actual" = "$3" ]; then pass "$1"; else fail "$1: X-LiteSpeed-Cache on $2 is '$actual', expected '$3'"; fi
}

common_checks() {
  local f=$1
  expect "$f: front page" / 200 - "index q="
  expect "$f: page goes to index.php" /some-page/ 200 - "index q="
  expect "$f: slash appended to pages" /some-page 301 https://localhost/some-page/ -
  expect "$f: www removed" /x/ 301 https://example.com/x/ - www.example.com
  expect "$f: author enumeration rewritten" "/?author=1" 200 - "index q=author=999999"
  expect "$f: xmlrpc.php blocked" /xmlrpc.php 403 - -
  expect "$f: wp/xmlrpc.php blocked" /wp/xmlrpc.php 403 - -
  expect "$f: wp-signup.php blocked" /wp/wp-signup.php 403 - -
  expect "$f: core admin" /wp/wp-admin/edit.php 200 - "core:wp-admin/edit"
  expect "$f: core login" /wp/wp-login.php 200 - "core:wp-login"
  expect "$f: root wp-admin shim" /wp-admin/ 200 - "root-shim:wp-admin"
  expect "$f: theme asset" /wp-content/themes/t/a.css 200 - css
  expect "$f: core asset not slash-redirected" /wp/wp-includes/js/a.js 200 - js
  # WordPress decides (and renders its own 404 page); the mock index.php returns 200.
  expect "$f: missing upload goes to WordPress" /wp-content/uploads/missing.png 200 - "index q="
  expect "$f: missing PHP file goes to WordPress" /missing.php 200 - "index q="
  expect_header "$f: HSTS" / Strict-Transport-Security "max-age=31536000"
  expect_header "$f: nosniff" / X-Content-Type-Options nosniff
  expect_header "$f: Referrer-Policy" / Referrer-Policy strict-origin-when-cross-origin
  expect_header "$f: Permissions-Policy" / Permissions-Policy "microphone=(), camera=(), geolocation=()"
  expect_header "$f: no CORS on pages" / Access-Control-Allow-Origin ""
  expect_header "$f: CORS on assets" /wp-content/themes/t/a.css Access-Control-Allow-Origin "*"
  expect_header "$f: nosniff on assets" /wp-content/themes/t/a.css X-Content-Type-Options nosniff
  expect_header "$f: 1y cache on assets" /wp-content/themes/t/a.css Cache-Control "public, max-age=31557600"
  # LiteSpeed Cache rules from docker.conf: the page cache works and ignores
  # tracking parameters (CacheKeyModify), but not other query strings.
  expect_cache "$f: cacheable page, first request" /cached.php miss
  expect_cache "$f: cacheable page served from cache" /cached.php hit
  expect_cache "$f: utm_* ignored for the cache key" "/cached.php?utm_source=x&gclid=y" hit
  expect_cache "$f: other query strings cached separately" "/cached.php?page=2" miss
  expect_cache "$f: pages not marked cacheable aren't cached" / ""
  expect "$f: LiteSpeed Cache debug log blocked" /wp-content/litespeed/debug/debug.log 403 - -
}

multisite_core_checks() {
  local f=$1
  expect "$f: wp-admin without /wp/" /wp-admin/edit.php 200 - "core:wp-admin/edit"
  expect "$f: wp-*.php without /wp/" /wp-cron.php 200 - "core:wp-cron"
}

echo "== single-site"
start single-site
common_checks single-site
expect "single-site: root login shim" /wp-login.php 200 - "root-shim:wp-login"

echo "== multisite-subdomain"
start multisite-subdomain
common_checks multisite-subdomain
multisite_core_checks multisite-subdomain

echo "== multisite-subfolder"
start multisite-subfolder
common_checks multisite-subfolder
multisite_core_checks multisite-subfolder
f=multisite-subfolder
expect "$f: site page" /sub/some-page/ 200 - "index q="
expect "$f: site page slash appended" /sub/some-page 301 https://localhost/sub/some-page/ -
expect "$f: site admin via /wp/" /sub/wp/wp-admin/edit.php 200 - "core:wp-admin/edit"
expect "$f: site admin without /wp/" /sub/wp-admin/edit.php 200 - "core:wp-admin/edit"
expect "$f: site admin trailing slash" /sub/wp-admin 301 - -
expect "$f: site login via /wp/" /sub/wp/wp-login.php 200 - "core:wp-login"
expect "$f: site login without /wp/" /sub/wp-login.php 200 - "core:wp-login"
expect "$f: site theme asset" /sub/wp-content/themes/t/a.css 200 - css
expect "$f: site core asset" /sub/wp/wp-includes/js/a.js 200 - js
expect "$f: site xmlrpc blocked" /sub/wp/xmlrpc.php 403 - -
expect "$f: site missing upload goes to WordPress" /sub/wp-content/uploads/missing.png 200 - "index q="
expect "$f: missing core file -> 404 page" /sub/wp/wp-includes/missing.js 404 - "index q=error=404"
expect "$f: missing core PHP -> 404 page" /sub/wp-admin/missing.php 404 - "index q=error=404"
expect_header "$f: CORS on site assets" /sub/wp-content/themes/t/a.css Access-Control-Allow-Origin "*"

if [ "$failures" -gt 0 ]; then
  echo "$failures check(s) failed" >&2
  exit 1
fi
echo "All checks passed"
