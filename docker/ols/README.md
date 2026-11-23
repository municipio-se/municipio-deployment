# OpenLiteSpeed base layer

This directory builds the OpenLiteSpeed + lsphp layer that the Municipio image runs on. It contains no application code. [`../Dockerfile`](../Dockerfile) adds Municipio on top of it, and the two are built together into **one** image; this layer is not published on its own.

This layer used to be built and published separately as `ghcr.io/helsingborg-stad/ols-docker-hbg`. The files here were copied from that repository at version 0.3.0 (commit `fc12369`).

## What is built where

| Part | Directory | Contents |
| --- | --- | --- |
| Server layer | `docker/ols/` | Ubuntu, OpenLiteSpeed, lsphp and its extensions, `php.ini` tuning, listener/vhost config, `/entrypoint.sh` and `ols-hbg-configure` |
| Application layer | `docker/` | Municipio build (Composer, npm), WP-CLI, WordPress config, `.htaccess` templates and the `setup.py` startup script |

[`docker-bake.hcl`](../../docker-bake.hcl) at the repository root ties them together. Its `ols` target builds this directory, and its `municipio` target receives that result as the named build context `ols`, which `docker/Dockerfile` uses in `FROM ols AS runtime`.

## Building and testing this layer

From the repository root:

```bash
# Build only the OLS layer and load it into the local Docker daemon.
docker buildx bake ols --set ols.tags=municipio-ols:local --set ols.output=type=docker

# Smoke test: runtime tuning defaults, overrides, restarts and validation.
docker/ols/tests/smoke.sh municipio-ols:local

# Build the full Municipio image (OLS layer included).
docker buildx bake municipio --load
```

A healthy empty OLS layer answers `404` with `Server: LiteSpeed` on port 80. The site is served from `/var/www/vhosts/localhost/html/`, with `.htaccess` rewrites enabled.

The PHP line is set by `PHP_VERSION` on the `ols` target in `docker-bake.hcl` (for example `lsphp83`), and the OpenLiteSpeed version by `OLS_VERSION`. The PHP patch level is whatever LiteSpeed's apt repository ships at build time.

## Sizing

OpenLiteSpeed and PHP are sized for Municipio on every container start. Normally the only thing to set is the container's memory limit; the number of PHP children follows from it.

| Variable | Default | Sets | What it controls |
| --- | --- | --- | --- |
| `PHP_MEMORY_LIMIT` | `512M` | PHP `memory_limit` | Maximum memory one PHP request may use. Accepts PHP sizes such as `512M`, `1G`, or `-1` (no limit). Municipio's `WP_MEMORY_LIMIT` follows it ([`../config/memory.php`](../config/memory.php)). |
| `OLS_PHP_CHILDREN` | automatic | lsphp `maxConns` and `PHP_LSAPI_CHILDREN` (always equal) | Maximum number of PHP requests handled at the same time; further requests wait in a queue. |
| `OLS_HTTPD_WORKERS` | `1` | `httpdWorkers` in `httpd_config.conf` | Number of OpenLiteSpeed worker processes. |
| `OLS_PHP_KEEPALIVE_TIMEOUT` | `5` | lsphp `pcKeepAliveTimeout`, in seconds | How long an idle connection from OpenLiteSpeed keeps a PHP child reserved. |

Every setting is written on each start, from its variable or its default, so removing a variable restores the default even on a restarted container or a persisted `conf` volume. An invalid value stops the container at startup with an error naming the variable.

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

**`OLS_HTTPD_WORKERS`: keep it at `1` unless the container has well over 2 CPU cores.** OpenLiteSpeed's own default sizes the worker count from the CPU count of the *host*, not the container's CPU limit. Each worker keeps its own pool of connections to lsphp, and when the workers together hold more connections than there are PHP children, requests fail with `No request delivery notification has been received from LSAPI application`.

**`OLS_PHP_KEEPALIVE_TIMEOUT`:** a short timeout frees children for other connections sooner. Raise it only if logs show PHP processes being started and stopped constantly under steady load.

To check what a running container uses:

```bash
docker compose logs municipio | grep ols-hbg-configure
docker compose exec municipio grep -E 'httpdWorkers|maxConns|PHP_LSAPI_CHILDREN|pcKeepAliveTimeout' /usr/local/lsws/conf/httpd_config.conf
```

Environment variables are not updated in a running pod, so restart it after changing them.

## Environment variables for web PHP

Web requests run in lsphp processes that OpenLiteSpeed starts with the environment in `httpd_config.conf`, not the container's environment. `ols-hbg-configure` writes these into it automatically:

- every `WP_CONF_*` variable, which Municipio's WordPress config reads (see [`../config/env.php`](../config/env.php))
- every `TIDEWAYS_*` variable, which the Tideways extension reads

To pass any other variable, list its name in `OLS_PHP_ENV_VARS` (comma or space separated).

- Values are rewritten on every start. A variable that is removed, or a name removed from the list, disappears from the config on the next start.
- Only the first line of a multi-line value is passed on, because a config line can't span lines.
- An invalid name in `OLS_PHP_ENV_VARS`, or a listed name whose variable is not set, stops the container at startup. An empty value is allowed.
- `PHP_LSAPI_CHILDREN` can't be listed; use `OLS_PHP_CHILDREN`.
- PHP CLI processes (WP-CLI, cron, `docker exec … php`) already see the container's environment.
- Passed values end up in `httpd_config.conf` and in `phpinfo()`, so don't expose `phpinfo()` publicly.

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

The image always loads the extensions Municipio needs: OPcache, cURL, Imagick, intl, MySQL, tidy and Tideways. There is no runtime toggle; to add or drop one, change the package list in [`templates/setup_ols.sh`](templates/setup_ols.sh).

### Tideways

The Tideways extension is always loaded and does nothing until it has an API key. It also needs a separate [daemon](https://support.tideways.com/documentation/setup/installation/docker-with-compose.html) to send data to Tideways. Connect the two on a private container network:

```yaml
services:
  municipio:
    image: ghcr.io/municipio-se/municipio-deployment:latest
    environment:
      TIDEWAYS_APIKEY: ${TIDEWAYS_APIKEY:?Set TIDEWAYS_APIKEY}
      TIDEWAYS_CONNECTION: tcp://tideways-daemon:9135
    depends_on:
      - tideways-daemon

  tideways-daemon:
    image: ghcr.io/tideways/daemon
```

`TIDEWAYS_*` variables reach web PHP automatically. Supply `TIDEWAYS_APIKEY` from your deployment secrets at runtime, never in the Dockerfile. The daemon does not authenticate incoming connections, so do not publish its port or expose its network publicly. `WP_CONF_EXTRA_TIDEWAYS_APIKEY` would define a WordPress constant instead, which the extension does not read.

## Startup order

`/usr/local/bin/ols-hbg-configure` applies everything in this README. Municipio's [`../setup/setup.py`](../setup/setup.py) runs it first, so WP-CLI install steps use the same PHP settings as web requests, and finally hands over to `/entrypoint.sh`, which runs it again (it is idempotent) and starts OpenLiteSpeed. Both must run as root.
