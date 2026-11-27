# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Configures the OpenLiteSpeed + lsphp **base layer** of the Municipio image, tuned for Municipio's WordPress workload. No application code lives here. It is not published on its own: the first stage of `docker/Dockerfile`, `ols`, starts from LiteSpeed's official image, runs the scripts here, and the final stage starts `FROM ols AS runtime`. The dev container (`.devcontainer/docker-compose.yml`) builds `--target ols` too and runs the stage's `/entrypoint.sh`, adding dev tools as features and dev-only ini settings via `PHP_INI_SETTINGS`, so changes here also affect local development. Keep Municipio-specific server logic in this directory. The current base is pinned to OLS 1.9.4 / lsphp83 on Ubuntu 26.04, with amd64 and arm64 manifests.

These files were copied from the former `helsingborg-stad/ols-docker-hbg` repository at 0.3.0 (`fc12369`). That repo's release, RC and cache workflows, `bin/build_ols.sh` and `env-example` were deliberately not brought over, and its Dockerfile became the `ols` stage of `docker/Dockerfile`.

## Build & smoke-test

Run from the repository root:

```bash
# OLS layer only, for the host arch, loaded into the local daemon.
docker build --target ols -f docker/Dockerfile -t municipio-ols:local .

docker run --rm -d --name ols-hbg -p 8080:80 municipio-ols:local
curl -sI http://localhost:8080/   # 404 + `Server: LiteSpeed` is a healthy empty-docroot response
docker rm -f ols-hbg

# Runtime tuning smoke test (defaults, overrides, restart idempotency, validation).
docker/tests/ols_smoke.sh municipio-ols:local
```

The OLS image tag and multi-architecture digest are pinned in `docker/Dockerfile`. The build context is the repository root, so the stage bind-mounts and copies `docker/ols/scripts/ and docker/ols/config/`. When updating the base, verify its supported architectures, PHP extensions, config layout, users, and entrypoint before changing the pinned reference.

In CI (`.github/workflows/container-image-*.yml`) the whole Dockerfile is built per platform on native runners with a GHA cache (`mode=min`, scope `municipio-<platform>`).

## Architecture notes

**Vendor OLS base.** The `ols` stage starts from the official image pinned by tag and multi-architecture digest. `install-extensions.sh` installs only Municipio-specific additions (Python, Tidy, Tideways) and **appends** Municipio-tuned PHP overrides to the lsphp `php.ini` (1024M upload/post, `opcache.validate_timestamps=0`, etc.) — appended (last-wins), not edited in place, so upstream defaults remain readable above them.

**Runtime configuration lives in `scripts/configure-runtime.sh`**, installed as `/usr/local/bin/ols-hbg-configure`. It is the only code that writes server or PHP config; `docker/wordpress/setup/setup.py` no longer touches `httpd_config.conf` or ini files. `setup.py` runs it first (so WP-CLI install steps see the same PHP config as web requests) and then execs `/entrypoint.sh`, which runs it again and starts OLS, so it must stay idempotent. It validates every variable before changing anything, then: hydrates conf, rewrites `httpd_config.conf`, `chown`s conf, writes the ini files.

**WebAdmin is disabled** by writing `disableWebAdmin 1` on every start, including when a persisted server config enables it. The upstream image advertises port 7080 in its metadata, but the server must not listen on it.

**Sizing.** `configure-runtime.sh` fixes top-level `httpdWorkers` at 1; there is no CPU-count or worker-count override. PHP children are written to lsphp `maxConns` and `env PHP_LSAPI_CHILDREN` (kept equal); `OLS_PHP_KEEPALIVE_TIMEOUT` (default 5) sets `pcKeepAliveTimeout`; `PHP_MEMORY_LIMIT` (default 512M) sets `memory_limit` in `mods-available/50-hbg-runtime.ini`. Children come from `OLS_PHP_CHILDREN` if set, otherwise `(cgroup memory limit − 512M) / PHP_MEMORY_LIMIT` (min 1), falling back to 10 with no limit or `PHP_MEMORY_LIMIT=-1`; the choice is logged. Municipio's `docker/wordpress/config/memory.php` defaults `WP_MEMORY_LIMIT` to `ini_get('memory_limit')` so WordPress doesn't raise requests above the limit the children were sized on. The `httpd_config.conf` rewrite is an `awk` pass that drops existing values and writes fresh ones, so it is idempotent and leaves other lsphp lines (e.g. `LSAPI_AVOID_FORK`) alone. Always writing a value, rather than skipping unset variables, means unsetting a variable restores the default on a reused container or persisted conf volume. `install-extensions.sh` creates `50-hbg-runtime.ini` at build time with the same default so `RUN php …` during the Municipio build sees it; keep the file name and defaults in sync between `install-extensions.sh`, `configure-runtime.sh`, `docker/tests/ols_smoke.sh` and the README tables.

**lsphp env, WordPress settings and Tideways.** Web PHP gets its environment only from the lsphp block in `httpd_config.conf`, and `configure-runtime.sh` deliberately forwards **no** container variables there, because that environment leaks through `getenv()`, `$_SERVER`, `phpinfo()` and child processes. `WP_CONF_*` values reach WordPress through `/var/www/vhosts/localhost/wp-conf.php` instead. `docker/wordpress/setup/setup.py` (`write_wp_conf`) generates it on every start with PHP's `var_export`, atomically, mode `0400`, owned by uid 1000, and `docker/wordpress/config/env.php` (`wp_conf_values()`) reads it before falling back to the process env. Tideways' documented variables (`TIDEWAYS_APIKEY`, `_CONNECTION`, `_SERVICE`, `_SAMPLERATE`, `_TRACE_SAMPLE_RATE`, `_FRAMEWORK`) are mapped by exact name to `tideways.*` ini settings in `mods-available/70-hbg-tideways.ini` (mode 640, group 1000), removed when none are set. Other `TIDEWAYS_*` names are ignored, since Kubernetes injects `TIDEWAYS_SERVICE_HOST` etc. for a service of that name. For persisted conf volumes, the awk pass still drops env lines from earlier versions: any `WP_CONF_*` name plus the names in `conf/.hbg-php-env-vars`, a state file that is then deleted. `PHP_INI_SETTINGS` (one `name=value` per line) is written to `mods-available/60-hbg-ini-settings.ini`, removed when empty; `memory_limit` is rejected there in favour of `PHP_MEMORY_LIMIT`. When testing with `docker exec … ols-hbg-configure`, remember `docker exec` inherits the container's environment; use `env -u` to simulate an unset variable.

**PHP extensions.** Every extension is enabled at build time; there is deliberately no runtime toggle, because Municipio always needs the same set. The vendor image supplies OPcache, curl, Imagick, intl, and MySQL. Tidy is installed from LiteSpeed's repository; Tideways is installed from its own repository and links its PHP 8.3 module into lsphp's extension directory. `install-extensions.sh` fails the build if either extension or ini file is missing.

**Rewrites, headers, caching.** OLS reads only rewrite rules from `.htaccess` (Apache `Header`, `FilesMatch`, `Expires*`, `ErrorDocument`, `SetEnv` are ignored), and reads the docroot `.htaccess` only at server start. So `config/vhost.conf` holds everything shared by all site types: site-level `rewrite { rules }` (paths start with `/`; they run before `.htaccess`, and `[L]` there still continues into `.htaccess`), `extraHeaders` on context `/` and on a regex context for static assets (which adds `Access-Control-Allow-Origin: *` and must keep `RewriteFile .htaccess` so multisite asset rewrites still apply), `expiresByType` and `errorPage 404`. The LiteSpeed Cache plugin's rules are in those site-level rules too (`CacheLookup`, `CacheKeyModify` work there; the plugin can't manage a read-only `.htaccess` anyway). `docker/wordpress/htaccess/<flavor>.htaccess` holds only the WordPress routing per site type (a Python test enforces that); `docker/wordpress/setup/setup_htaccess.py` copies the right one over the docroot `.htaccess` on every start (root-owned, 0644). OLS re-applies `.htaccess` rules to a rewritten path, so every rewrite there must change the path or a missing target loops into a 500. `docker/tests/htaccess_routing.sh <ols image>` tests all three flavors.

**Listener / vhost wiring.** `scripts/configure-listener.sh` runs at build time (also bind-mounted, no COPY) and removes the vendor's `Default`, `HTTP`, `HTTPS`, and `docker` listener/template blocks plus the two unused templates that reference `Default`. It appends Municipio's single `listener HTTP { *:80 }` and `vhTemplate docker`, which points to `templates/docker.conf` with member `localhost` matching `localhost, *`. Site content is served from `/var/www/vhosts/localhost/html/` (chowned to `1000:1000`). `.htaccess` rewrites are enabled (`autoLoadHtaccess 1`). `docker/Dockerfile` replaces `html/` with Municipio.

**Config snapshot pattern.** During the second RUN of the `ols` stage, it copies `$LS_FD/conf` → `$LS_FD/.conf` and `$LS_FD/admin/conf` → `$LS_FD/admin/.conf`. At container start, `scripts/configure-runtime.sh` hydrates either directory from its snapshot when an operator mounts an empty volume there. When a downstream image changes default OLS configuration, the change must land in the snapshot path so it survives volume mounts.

**lsadm uid/gid.** Resolve the `lsadm` account and group from the vendor image by name. The Dockerfile and `configure-runtime.sh` chown server and admin configuration to that account; avoid relying on a fixed numeric id.

**Process model.** Municipio replaces the vendor `/entrypoint.sh` to preserve log streaming and graceful signal handling. The custom entrypoint starts OLS via `lswsctrl start` (which daemonises), polls briefly for `/tmp/lshttpd/lshttpd.pid`, and waits for that process while forwarding shutdown signals. It tails the error, stderr, and access logs to container output. `setup.py` sets `OLS_HBG_CONFIGURED=1` when it execs the entrypoint, which then skips its own `ols-hbg-configure` run. Don't switch to the vendor's polling loop or a naive `exec lswsctrl` without preserving these behaviors.
