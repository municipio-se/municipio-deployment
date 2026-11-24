# OpenLiteSpeed base layer

This directory configures the OpenLiteSpeed + lsphp layer that the Municipio image runs on. It contains no application code. [`../Dockerfile`](../Dockerfile) starts from LiteSpeed's official OpenLiteSpeed image, adds Municipio-specific server configuration, and builds the application on top; the layers are built together into **one** image, and the configured OLS layer is not published on its own.

The OLS and PHP base image is pinned by version and multi-architecture digest in [`../Dockerfile`](../Dockerfile). The stage adds only the PHP Tidy extension, Tideways, Python for Municipio's setup scripts, and Municipio's server/PHP configuration.

## What is built where

| Part | Directory | Contents |
| --- | --- | --- |
| Server layer | `docker/ols/` | The official OpenLiteSpeed/lsphp base plus Municipio-specific packages, `php.ini` tuning, listener/vhost config, `/entrypoint.sh` and `ols-hbg-configure` |
| Application layer | `docker/wordpress/` | WordPress config, per-site-type `.htaccess` files and startup scripts; the Dockerfile builds Municipio and adds WP-CLI |

[`docker/Dockerfile`](../Dockerfile) builds both. Its first stage, `ols`, starts from the pinned LiteSpeed image and runs the scripts in this directory; the final stage starts `FROM ols`.

## Building and testing this layer

From the repository root:

```bash
# Build only the OLS layer (no ACF key needed).
docker build --target ols -f docker/Dockerfile -t municipio-ols:local .

# Smoke test: runtime tuning defaults, overrides, restarts and validation.
docker/tests/ols_smoke.sh municipio-ols:local

# Build the full Municipio image (OLS layer included).
docker build --secret id=acf_pro_key,env=ACF_PRO_KEY -f docker/Dockerfile -t municipio:local .
```

A healthy empty OLS layer answers `404` with `Server: LiteSpeed` on port 80. The site is served from `/var/www/vhosts/localhost/html/`, with `.htaccess` rewrites enabled. The base image version and digest are pinned in the Dockerfile; `install-extensions.sh` adds only what Municipio needs beyond that image.

The pinned base image currently provides OpenLiteSpeed 1.9.4 and lsphp83 on Ubuntu 26.04 for both amd64 and arm64. To update either, select and verify a new vendor tag and multi-architecture digest in the Dockerfile.

The OpenLiteSpeed WebAdmin listener is disabled on every start, including when
using an existing server config volume. The upstream image advertises port 7080
in its inherited image metadata, but Municipio does not listen on that port.
Only port 80 should be published for the application.

## Sizing

OpenLiteSpeed and PHP are sized for Municipio on every container start. Normally the only thing to set is the container's memory limit; the number of PHP children follows from it.

| Variable | Default | Sets | What it controls |
| --- | --- | --- | --- |
| `PHP_MEMORY_LIMIT` | `512M` | PHP `memory_limit` | Maximum memory one PHP request may use. Accepts PHP sizes such as `512M`, `1G`, or `-1` (no limit). Municipio's `WP_MEMORY_LIMIT` follows it ([`../wordpress/config/memory.php`](../wordpress/config/memory.php)). |
| `OLS_PHP_CHILDREN` | automatic | lsphp `maxConns` and `PHP_LSAPI_CHILDREN` (always equal) | Maximum number of PHP requests handled at the same time; further requests wait in a queue. |
| `OLS_PHP_KEEPALIVE_TIMEOUT` | `5` | lsphp `pcKeepAliveTimeout`, in seconds | How long an idle connection from OpenLiteSpeed keeps a PHP child reserved. |

OpenLiteSpeed uses one worker; Municipio does not try to derive worker count from the container's CPU allocation. The PHP and keepalive settings are rewritten on each start, so removing an override restores its default even on a restarted container or a persisted `conf` volume. An invalid value stops the container at startup with an error naming the variable.

### PHP children

When `OLS_PHP_CHILDREN` is not set, `ols-hbg-configure` reads the container's memory limit (cgroup v2 `memory.max`, or cgroup v1 `memory.limit_in_bytes`) and starts as many PHP children as fit if every one of them reaches `PHP_MEMORY_LIMIT`:

```
children = (container memory limit − 512M) ÷ PHP_MEMORY_LIMIT     (at least 1)
```

The 512M covers the OPcache (256M, shared by all children), OpenLiteSpeed and the lsphp parent process. Without a memory limit, or with `PHP_MEMORY_LIMIT=-1`, it uses 10. The result is logged at startup, for example `ols-hbg-configure: 5 PHP children ((3072M container limit - 512M reserved) / 512M per request), memory_limit 512M`.

| Container memory limit | `PHP_MEMORY_LIMIT` | Children |
| --- | --- | --- |
| 3 GiB | `512M` (default) | 5 |
| 3 GiB | `256M` | 10 |
| 6 GiB | `512M` (default) | 11 |

Set `OLS_PHP_CHILDREN` only to override this, for example when Imagick-heavy requests need extra headroom (Imagick memory is not counted in `memory_limit`). More children only help if the container also has the CPU to run them; several children per core is normal, because WordPress requests spend much of their time waiting for the database.

**`OLS_PHP_KEEPALIVE_TIMEOUT`:** a short timeout frees children for other connections sooner. Raise it only if logs show PHP processes being started and stopped constantly under steady load.

To check what a running container uses:

```bash
docker compose logs municipio | grep ols-hbg-configure
docker compose exec municipio grep -E 'httpdWorkers|maxConns|PHP_LSAPI_CHILDREN|pcKeepAliveTimeout' /usr/local/lsws/conf/httpd_config.conf
```

Environment variables are not updated in a running pod, so restart it after changing them.

## Environment variables and web PHP

Web requests run in lsphp processes that OpenLiteSpeed starts with the environment in `httpd_config.conf`. That environment is visible to `getenv()`, `$_SERVER`, `phpinfo()`, error trackers and child processes, so `ols-hbg-configure` deliberately passes **no** container variables into it.

- **WordPress settings (`WP_CONF_*`):** Municipio's [`../wordpress/setup/setup.py`](../wordpress/setup/setup.py) writes these to `/var/www/vhosts/localhost/wp-conf.php` on every start. The file is outside the web root, mode `0400`, owned by the site user, and read by [`../wordpress/config/env.php`](../wordpress/config/env.php).
- **Tideways:** see [Tideways](#tideways); its variables become ini settings.
- **Anything else PHP needs:** use `PHP_INI_SETTINGS`, or `WP_CONF_EXTRA_<NAME>` for a WordPress constant.

Env lines that earlier versions wrote (any `WP_CONF_*`, and names recorded in `conf/.hbg-php-env-vars`) are removed from a persisted `conf` volume on the next start. PHP CLI processes (WP-CLI, cron, `docker exec … php`) still see the container's environment directly.

## PHP ini settings

Set any PHP ini directive with `PHP_INI_SETTINGS`, one `name=value` directive per line:

```yaml
environment:
  PHP_INI_SETTINGS: |
    max_input_vars=5000
    upload_max_filesize=64M
```

The directives are written to `mods-available/60-hbg-ini-settings.ini` in PHP's scan directory on every start, and the file is removed when the variable is empty. They apply to web requests and to PHP CLI processes started after the container's configuration step. Blank lines are ignored; any other line that isn't `name=value` stops the container at startup. Use `PHP_MEMORY_LIMIT` for `memory_limit`; setting it here is rejected because the number of PHP children is sized from it (see [Sizing](#sizing)).

The file sorts after the image's own settings. Don't override `PHP_INI_SCAN_DIR`, which can exclude the scan directory.

In Kubernetes, a multi-line value is easiest to manage as a Secret or ConfigMap key named `PHP_INI_SETTINGS`, loaded with `envFrom` (for example `kubectl create secret generic php-ini --from-file=PHP_INI_SETTINGS=./settings.ini`). A Secret mounted as a file does not become this environment variable. Restart the pod after changing it.

## PHP extensions

The image always loads the extensions Municipio needs: OPcache, cURL, Imagick, intl, MySQL, tidy and Tideways. The base image provides the common extensions; [`scripts/install-extensions.sh`](scripts/install-extensions.sh) adds Tidy and Tideways. There is no runtime toggle.

### Tideways

The Tideways extension is always loaded and does nothing until it has an API key. It also needs a separate [daemon](https://support.tideways.com/documentation/setup/installation/docker-with-compose.html) to send data to Tideways. Connect the two on a private container network:

```yaml
services:
  municipio:
    image: ghcr.io/municipio-se/municipio-deployment:latest
    environment:
      TIDEWAYS_APIKEY: ${TIDEWAYS_APIKEY:?Set TIDEWAYS_APIKEY}
      TIDEWAYS_CONNECTION: tcp://tideways-daemon:9135
      # Optional: TIDEWAYS_SERVICE, TIDEWAYS_SAMPLERATE, TIDEWAYS_TRACE_SAMPLE_RATE, TIDEWAYS_FRAMEWORK
    depends_on:
      - tideways-daemon

  tideways-daemon:
    image: ghcr.io/tideways/daemon
```

`ols-hbg-configure` writes these variables to the extension's ini settings (`tideways.api_key`, `tideways.connection`, …) in `mods-available/70-hbg-tideways.ini`, readable only by root and the site user, and removes the file when none are set. They are not put in the web PHP environment. Values must be a single line without double quotes. Other `TIDEWAYS_*` names, such as the `TIDEWAYS_SERVICE_HOST` that Kubernetes adds for a service named `tideways`, are ignored. Supply `TIDEWAYS_APIKEY` from your deployment secrets at runtime, never in the Dockerfile. The daemon does not authenticate incoming connections, so do not publish its port or expose its network publicly. `WP_CONF_EXTRA_TIDEWAYS_APIKEY` would define a WordPress constant instead, which the extension does not read.

## Startup order

`/usr/local/bin/ols-hbg-configure` applies everything in this README, including restoring empty server and admin config volumes from the snapshots in the image. Municipio's [`../wordpress/setup/setup.py`](../wordpress/setup/setup.py) runs it first, so WP-CLI install steps use the same PHP settings as web requests, and finally hands over to the Municipio `/entrypoint.sh` with `OLS_HBG_CONFIGURED=1`, which starts OpenLiteSpeed and streams its logs without configuring again. Run on its own (e.g. the `ols` stage alone), `/entrypoint.sh` runs `ols-hbg-configure` itself. Both must run as root.

## Rewrites, headers and caching

OpenLiteSpeed only reads rewrite rules from `.htaccess` (and only when the server starts); Apache directives such as `Header`, `FilesMatch`/`Deny`, `ExpiresByType`, `ErrorDocument` and `SetEnv` are silently ignored there. So [`config/vhost.conf`](config/vhost.conf) holds everything that is the same for every site type:

- the LiteSpeed Cache plugin's rules (`CacheLookup`, `CacheKeyModify` for tracking parameters, no-cache flags), which the plugin would otherwise write to `.htaccess`
- site-level rewrite rules, which run before `.htaccess`: `www.` removal, a trailing slash on page URLs, blocked `xmlrpc.php`/`wp-trackback.php`/`wp-signup.php`, hidden `?author=` pages, the `Authorization` header passed to PHP
- response headers (`extraHeaders`), with `Access-Control-Allow-Origin: *` only on static assets, since WordPress sends its own CORS headers for pages and the REST API
- browser cache lifetimes (`expiresByType`)
- WordPress's 404 page for missing files (`errorPage 404`)

The document root's `.htaccess` only adds what differs per site type, copied from [`../wordpress/htaccess/`](../wordpress/htaccess/) at startup. [`../tests/htaccess_routing.sh`](../tests/htaccess_routing.sh) checks the routing, headers and caching of all three site types against a mock document root.

## Logs

`/entrypoint.sh` streams the server's logs to the container's output, so `docker logs`, `docker compose logs` and Kubernetes show them as they are written:

- `error.log`: server messages and PHP errors, warnings and notices from web requests (tagged `[STDERR]`)
- `stderr.log`: other output lsphp writes to stderr
- `localhost.access.log`: one line per request, in combined log format

The files stay in `/usr/local/lsws/logs/` and are rotated at 10 MB; the stream follows rotation. Only lines written after the container starts are streamed. The image's health check requests `/` every 30 seconds, which shows up in the access log.
