# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Builds the OpenLiteSpeed + lsphp **base layer** of the Municipio image, tuned for Municipio's WordPress workload. No application code lives here. It is not published on its own: `docker-bake.hcl` at the repository root builds it as the `ols` target and hands it to `docker/Dockerfile` as the named build context `ols` (`FROM ols AS runtime`), so CI produces a single Municipio image. Ubuntu 24.04 base, multi-arch (arm64 + amd64) via BuildKit.

These files were copied from the former `helsingborg-stad/ols-docker-hbg` repository at 0.3.0 (`fc12369`). That repo's release, RC and cache workflows, `bin/build_ols.sh` and `env-example` were deliberately not brought over; bake replaces them.

## Build & smoke-test

Run from the repository root:

```bash
# OLS layer only, for the host arch, loaded into the local daemon.
docker buildx bake ols --set ols.tags=municipio-ols:local --set ols.output=type=docker

docker run --rm -d --name ols-hbg -p 8080:80 municipio-ols:local
curl -sI http://localhost:8080/   # 404 + `Server: LiteSpeed` is a healthy empty-docroot response
docker rm -f ols-hbg

# Runtime tuning smoke test (defaults, overrides, restart idempotency, validation).
docker/ols/tests/smoke.sh municipio-ols:local
```

`PHP_VERSION` (e.g. `lsphp83`) and `OLS_VERSION` are set on the `ols` target in `docker-bake.hcl`; the Dockerfile's own `ARG` defaults only apply to a bare `docker build docker/ols`. Architecture inside the build is auto-detected from BuildKit's `TARGETARCH` and mapped to the OLS tarball (`aarch64-linux` / `x86_64-linux`) in `Dockerfile`. The PHP patch level is whatever LiteSpeed's apt repo ships at build time.

In CI (`.github/workflows/container-image-*.yml`) the `ols` target is built per platform on native runners as part of the `municipio` bake, with a GHA cache scoped `ols-<platform>`.

## Architecture notes

**Two-phase OLS install.** `Dockerfile` bind-mounts `templates/setup_ols.sh` at build time (no COPY, no leftover file in the image) and runs it. The script installs OpenLiteSpeed from the pinned upstream tarball, adds the LiteSpeed apt repo for the lsphp modules Municipio needs (curl, imagick, intl, mysql, opcache, tidy) plus Tideways, and **appends** Municipio-tuned PHP overrides to the lsphp `php.ini` (1024M upload/post, `opcache.validate_timestamps=0`, etc.) — appended (last-wins), not edited in place, so upstream defaults remain readable above them.

**Runtime configuration lives in `templates/configure.sh`**, installed as `/usr/local/bin/ols-hbg-configure`. It is the only code that writes server or PHP config; `docker/setup/setup.py` no longer touches `httpd_config.conf` or ini files. `setup.py` runs it first (so WP-CLI install steps see the same PHP config as web requests) and then execs `/entrypoint.sh`, which runs it again and starts OLS, so it must stay idempotent. It validates every variable before changing anything, then: hydrates conf, rewrites `httpd_config.conf`, `chown`s conf, writes the ini files.

**Sizing.** `configure.sh` writes four settings on every start: `OLS_HTTPD_WORKERS` (default 1) → top-level `httpdWorkers`; PHP children → lsphp `maxConns` and `env PHP_LSAPI_CHILDREN` (kept equal); `OLS_PHP_KEEPALIVE_TIMEOUT` (default 5) → lsphp `pcKeepAliveTimeout`; `PHP_MEMORY_LIMIT` (default 512M) → `memory_limit` in `mods-available/50-hbg-runtime.ini`. Children come from `OLS_PHP_CHILDREN` if set, otherwise `(cgroup memory limit − 512M) / PHP_MEMORY_LIMIT` (min 1), falling back to 10 with no limit or `PHP_MEMORY_LIMIT=-1`; the choice is logged. Municipio's `docker/config/memory.php` defaults `WP_MEMORY_LIMIT` to `ini_get('memory_limit')` so WordPress doesn't raise requests above the limit the children were sized on. The `httpd_config.conf` rewrite is an `awk` pass that drops any existing lines for those keys (only at top level, and only inside `extProcessor lsphp{`) and writes fresh ones (the same pass handles the forwarded env, below), so it is idempotent and leaves other lsphp lines (e.g. `LSAPI_AVOID_FORK`) alone. Always writing a value, rather than skipping unset variables, means unsetting a variable restores the default on a reused container or persisted conf volume. `setup_ols.sh` creates `50-hbg-runtime.ini` at build time with the same default so `RUN php …` during the Municipio build sees it; keep the file name and defaults in sync between `setup_ols.sh`, `configure.sh`, `tests/smoke.sh` and the README tables.

**lsphp env and ini settings.** Web PHP gets its environment only from the lsphp block in `httpd_config.conf`. `configure.sh` forwards every `WP_CONF_*` (Municipio's WordPress config) and `TIDEWAYS_*` (Tideways extension) variable automatically, plus names listed in `OLS_PHP_ENV_VARS`. Each becomes an `env NAME=value` line (first line of the value only). To remove names that went away without touching env lines the image put there (e.g. `LSAPI_AVOID_FORK`), the names written are recorded in `conf/.hbg-php-env-vars`, and the awk pass drops env lines for the previous run's names plus this run's before writing fresh ones. The state file lives in `conf/` so it travels with a persisted conf volume and is absent on a fresh one. `PHP_INI_SETTINGS` (one `name=value` per line) is written to `mods-available/60-hbg-ini-settings.ini`, removed when empty; `memory_limit` is rejected there in favour of `PHP_MEMORY_LIMIT`. `PHP_LSAPI_CHILDREN` is rejected in `OLS_PHP_ENV_VARS` in favour of `OLS_PHP_CHILDREN`. When testing with `docker exec … ols-hbg-configure`, remember `docker exec` inherits the container's environment; use `env -u` to simulate an unset variable.

**PHP extensions.** Every extension is enabled at build time; there is deliberately no runtime toggle, because Municipio always needs the same set. tidy's and Tideways' ini files stay in `etc/php/<X.Y>/mods-available/` (lsphp's ini scan dir), and `setup_ols.sh` fails the build if either is missing. To add an extension, add `"$PHP_VERSION"-<ext>` to the apt list in `setup_ols.sh`.

**Listener / vhost wiring.** `templates/setup_docker.sh` runs at build time (also bind-mounted, no COPY) and rewrites `httpd_config.conf` in two passes: (1) an `awk` filter strips the OLS-shipped `listener Default { *:8088 }` block and the two vhTemplates (`centralConfigLog`, `EasyRailsWithSuEXEC`) that reference it — leaving them in would expose a confusing `:8088` listener that downstream consumers would inherit; (2) it appends a `listener HTTP { *:80 }` plus a `vhTemplate docker` that points to `templates/docker.conf` with member `localhost` matching `localhost, *`. Site content is served from `/var/www/vhosts/localhost/html/` (chowned to `1000:1000`). `.htaccess` rewrites are enabled (`autoLoadHtaccess 1`). `docker/Dockerfile` replaces `html/` with Municipio.

**Config snapshot pattern.** During the second build RUN, `Dockerfile` copies `$LS_FD/conf` → `$LS_FD/.conf` and `$LS_FD/admin/conf` → `$LS_FD/admin/.conf`. At container start, `templates/configure.sh` checks whether `/usr/local/lsws/conf` is empty (which happens when the operator mounts a fresh volume there) and, if so, hydrates it from `.conf`. When a downstream image changes default OLS configuration, the change must land in the snapshot path so it survives volume mounts.

**lsadm uid/gid.** OLS's `lsadm` user is uid/gid `994`. The Dockerfile chowns `$LS_FD/conf` to `994:994`, and `configure.sh` re-applies the chown after hydration. Preserve this when adding files under `conf/`.

**Process model.** `Dockerfile` sets `ENTRYPOINT ["/entrypoint.sh"]` with `CMD []` — the explicit empty CMD overrides Ubuntu's inherited `bash` so the entrypoint doesn't receive `bash` as a stray arg. `entrypoint.sh` starts OLS via `lswsctrl start` (which daemonises), polls briefly for the pid file at `/tmp/lshttpd/lshttpd.pid` (lshttpd writes it under `/tmp/lshttpd/`, not under `$LS_FD/logs/`), then runs `tail --pid=<lshttpd.pid> -f /dev/null` in the background so SIGTERM/SIGINT reach the trap and shut OLS down cleanly. Don't switch to a naive `exec lswsctrl` — signal handling depends on this layout.
