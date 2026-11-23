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

## Runtime tuning

OpenLiteSpeed and PHP sizing is set with environment variables. The entrypoint writes every setting each time the container starts, using the variable if it is set and the default below if it isn't. Removing a variable therefore restores the default, even on a restarted container or a persisted `conf` volume. An invalid value stops the container at startup with an error naming the variable.

| Variable | Default | Sets | What it controls |
| --- | --- | --- | --- |
| `OLS_HTTPD_WORKERS` | `1` | `httpdWorkers` in `httpd_config.conf` | Number of OpenLiteSpeed worker processes. |
| `OLS_PHP_CHILDREN` | `10` | lsphp `maxConns` and `PHP_LSAPI_CHILDREN` (always equal) | Maximum number of PHP requests handled at the same time. Further requests wait in a queue. |
| `OLS_PHP_KEEPALIVE_TIMEOUT` | `5` | lsphp `pcKeepAliveTimeout`, in seconds | How long an idle connection from OpenLiteSpeed keeps a PHP child reserved. |
| `PHP_MEMORY_LIMIT` | `256M` | PHP `memory_limit` | Maximum memory one PHP request may use. Accepts PHP sizes such as `512M`, `1G`, or `-1` (no limit). |

The defaults suit a pod with about 1.5 CPU cores and 3 GiB of memory. Change them together, using the rules below.

### What affects each setting

**`OLS_HTTPD_WORKERS`: keep it at `1` unless the container has well over 2 CPU cores.** OpenLiteSpeed's own default sizes the worker count from the CPU count of the *host*, not the container's CPU limit, so on a large Kubernetes node it can start many workers. Each worker keeps its own pool of connections to lsphp. When the workers together hold more connections than there are PHP children, requests fail with `No request delivery notification has been received from LSAPI application`. One worker handles many concurrent connections, because PHP rather than OpenLiteSpeed is the bottleneck for WordPress.

**`OLS_PHP_CHILDREN` and `PHP_MEMORY_LIMIT` together decide how much memory PHP can use.** In the worst case every child reaches the memory limit at once. Keep this within the container's memory limit:

```
OLS_PHP_CHILDREN × PHP_MEMORY_LIMIT + about 512M  ≤  container memory limit
```

The 512M covers the OPcache (256M, shared by all children), OpenLiteSpeed and the lsphp parent process. Leave extra room if the application processes images with Imagick, whose memory is not counted in `memory_limit`.

| Container memory | `PHP_MEMORY_LIMIT` | `OLS_PHP_CHILDREN` |
| --- | --- | --- |
| 3 GiB | `256M` | `10` (default) |
| 3 GiB | `512M` | `5` |
| 6 GiB | `256M` | `22` |
| 6 GiB | `512M` | `11` |

More children only help if the container also has the CPU to run them. Several children per core is normal, because WordPress requests spend much of their time waiting for the database and other services.

**`OLS_PHP_KEEPALIVE_TIMEOUT`:** a short timeout frees children for other connections sooner. Raise it only if logs show PHP processes being started and stopped constantly under steady load.

**WordPress can raise `memory_limit` itself.** `WP_MEMORY_LIMIT` (and `WP_MAX_MEMORY_LIMIT` in the admin) call `ini_set()` and raise the limit for the request if they are higher than `PHP_MEMORY_LIMIT`. If your application sets them, use them as `PHP_MEMORY_LIMIT` in the calculation above, or lower them.

**Ini files in the scan directory win.** `PHP_MEMORY_LIMIT` is written to `mods-available/50-hbg-runtime.ini` in PHP's scan directory. A downstream image's own ini file that sorts after it (for example `zz-*.ini`) and sets `memory_limit` overrides it.

### Examples

Docker Compose:

```yaml
services:
  municipio:
    image: ghcr.io/municipio-se/municipio-deployment:latest
    environment:
      OLS_PHP_CHILDREN: "5"
      PHP_MEMORY_LIMIT: 512M
```

Kubernetes, for a pod with 6 GiB of memory:

```yaml
resources:
  requests:
    cpu: 3000m
    memory: 6144Mi
  limits:
    cpu: 3000m
    memory: 6144Mi
env:
  - name: OLS_HTTPD_WORKERS
    value: "1"
  - name: OLS_PHP_CHILDREN
    value: "22"
  - name: PHP_MEMORY_LIMIT
    value: 256M
```

Like all settings in this README, these are applied when the container starts (see [Custom startup scripts](#custom-startup-scripts)). Environment variables are not updated in a running pod, so restart it after changing them. To check what a running container uses:

```bash
docker exec my-app grep -E 'httpdWorkers|maxConns|PHP_LSAPI_CHILDREN|pcKeepAliveTimeout' /usr/local/lsws/conf/httpd_config.conf
docker exec my-app sh -c 'cat /usr/local/lsws/lsphp*/etc/php/*/mods-available/50-hbg-runtime.ini'
```

Changes from earlier versions: the `memory_limit` default was `1024M` before these variables were added, and `httpdWorkers` was sized from the host's CPU count.

## Environment variables for web PHP

Web requests run in lsphp processes that OpenLiteSpeed starts with the environment in `httpd_config.conf`, not the container's environment. A variable set on the container is therefore invisible to `getenv()` in web PHP unless you list its name in `OLS_PHP_ENV_VARS` (comma or space separated):

```yaml
environment:
  TIDEWAYS_APIKEY: ${TIDEWAYS_APIKEY:?Set TIDEWAYS_APIKEY}
  MY_API_KEY: ${MY_API_KEY}
  OLS_PHP_ENV_VARS: "TIDEWAYS_APIKEY,MY_API_KEY"
```

- The values are written to the lsphp block of `httpd_config.conf` on every start. A name removed from the list is removed from the config on the next start.
- Only the first line of a multi-line value is passed on, because a config line can't span lines.
- An invalid name, or a name whose variable is not set, stops the container at startup. An empty value is allowed.
- `PHP_LSAPI_CHILDREN` can't be listed; use `OLS_PHP_CHILDREN`.
- PHP CLI processes (`docker exec … php`, cron, startup scripts) already see the container's environment and don't need this.
- Only list values that PHP should be able to read. Treat them as secrets: they end up in `httpd_config.conf`, and `phpinfo()` shows them, so don't expose `phpinfo()` publicly.

## PHP ini settings

Set any PHP ini directive with `PHP_INI_SETTINGS`, one `name=value` directive per line:

```yaml
environment:
  PHP_INI_SETTINGS: |
    max_input_vars=5000
    upload_max_filesize=64M
```

The directives are written to `mods-available/60-hbg-ini-settings.ini` in PHP's scan directory on every start, and the file is removed when the variable is empty. They apply to web requests and to PHP CLI processes started after the container's configuration step. Blank lines are ignored; any other line that isn't `name=value` stops the container at startup. Use `PHP_MEMORY_LIMIT` for `memory_limit`; setting it here is rejected so that the sizing rules in [Runtime tuning](#runtime-tuning) stay in one place.

The file sorts after the image's own settings and before a downstream image's `zz-*.ini` files, which still win. Don't override `PHP_INI_SCAN_DIR`, which can exclude the scan directory.

In Kubernetes, a multi-line value is easiest to manage as a Secret or ConfigMap key named `PHP_INI_SETTINGS`, loaded with `envFrom` (for example `kubectl create secret generic php-ini --from-file=PHP_INI_SETTINGS=./settings.ini`). A Secret mounted as a file does not become this environment variable. Restart the pod after changing it.

## Custom startup scripts

All settings in this README (runtime tuning, `OLS_PHP_ENV_VARS`, `PHP_INI_SETTINGS` and `PHP_EXTENSIONS`) are applied by `/usr/local/bin/ols-hbg-configure`, which `/entrypoint.sh` runs before starting OpenLiteSpeed. Keep the base image's entrypoint, or end your own startup script with `exec /entrypoint.sh "$@"`. Both must run as root (the default), so don't add a `USER` before them.

`ols-hbg-configure` is idempotent. If your startup script runs PHP before handing over to `/entrypoint.sh`, for example WP-CLI install steps, run it first so those steps see the same ini settings and extensions as web requests:

```bash
#!/bin/bash
set -euo pipefail
ols-hbg-configure
wp core is-installed --allow-root || wp core install --allow-root …
exec /entrypoint.sh "$@"
```

## Optional PHP extensions

Some PHP extensions are installed in the image but disabled by default, because not every consumer needs them. Enable them with the `PHP_EXTENSIONS` environment variable (comma or space separated). The image's entrypoint links them into PHP's config when the container starts.

Currently available: `tidy`, `excimer` and `tideways`. The Municipio image sets `PHP_EXTENSIONS=tidy,tideways` in [`../Dockerfile`](../Dockerfile).

### Enabling extensions

1. **Set `PHP_EXTENSIONS` in `docker/Dockerfile`** (or per deployment, see below):

   ```dockerfile
   FROM ols AS runtime

   ENV PHP_EXTENSIONS=tidy,excimer
   ```

2. **Keep the base image's entrypoint.** The extensions are enabled when the container starts; see [Custom startup scripts](#custom-startup-scripts) if you have your own.

3. **Build and check** (runs only the configure step, so no database is needed):

   ```bash
   docker buildx bake municipio --load
   docker run --rm --entrypoint sh municipio:local -c \
     'ols-hbg-configure && /usr/local/lsws/lsphp*/bin/php -m | grep -Ei "^(tidy|excimer)$"'   # should print both names
   ```

### Using Tideways

Tideways requires a separate [daemon](https://support.tideways.com/documentation/setup/installation/docker-with-compose.html) to send data to Tideways. Enable the extension in your application container and connect it to the daemon on a private container network:

```yaml
services:
   municipio:
      image: ghcr.io/municipio-se/municipio-deployment:latest
      environment:
         PHP_EXTENSIONS: tideways
         TIDEWAYS_APIKEY: ${TIDEWAYS_APIKEY:?Set TIDEWAYS_APIKEY}
         TIDEWAYS_CONNECTION: tcp://tideways-daemon:9135
         # Web PHP only sees variables listed here; see "Environment variables for web PHP".
         OLS_PHP_ENV_VARS: TIDEWAYS_APIKEY,TIDEWAYS_CONNECTION
      depends_on:
         - tideways-daemon

   tideways-daemon:
      image: ghcr.io/tideways/daemon
```

Supply `TIDEWAYS_APIKEY` from your deployment secrets at runtime, never in the Dockerfile. Set `TIDEWAYS_SERVICE` or `TIDEWAYS_TRACE_SAMPLE_RATE` in the app environment if needed, and add them to `OLS_PHP_ENV_VARS`. The daemon does not authenticate incoming connections, so do not publish its port or expose its network publicly. Check that the extension loads with `docker compose exec municipio php -m | grep -i tideways`; confirm that the web PHP process loads it and that traces reach your Tideways project with a real API key.

### Things to know

- **Runtime only:** extensions are enabled when the container starts, not during `docker build`. A `RUN php -m` or a `composer install` that checks for `ext-tidy`, `ext-excimer`, or `ext-tideways` during the build won't see them. For Composer, use `--ignore-platform-req=ext-<name>` in that step as needed.
- **Changing it without a rebuild:** override the variable per deployment with `docker run -e PHP_EXTENSIONS=excimer …` or `env:` in Kubernetes. Setting it to empty disables the extensions again, because the links are rebuilt on every start.
- **Spelling:** an unknown name stops the container at startup with an "Unknown optional PHP extension" error that lists the valid names. Check `docker logs` if the container exits immediately.
- **Don't create the link yourself during the build:** the entrypoint deletes every link pointing to `mods-optional/` on startup, so a `RUN ln -s …` in your Dockerfile would be removed. Use the variable.
