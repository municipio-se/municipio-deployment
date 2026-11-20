# Municipio container image

This directory builds a ready-to-run [Municipio](https://github.com/municipio-se/municipio-deployment) WordPress image from the checked-out source. The image contains FrankenPHP (Caddy and PHP), WordPress, WP-CLI, and the deployment. Composer, Node.js, npm, and Git are used only while building the image and are not included in the runtime image.

On its first start, the container waits for the database and installs WordPress. Later starts reuse the existing database.

## Before you start

You need:

- Docker with Docker Compose
- An ACF Pro license key used to download ACF Pro while building the image

Set the ACF Pro key in your shell. Docker passes it to the build as a temporary BuildKit secret, so it does not need to be written into the Compose file or stored in the image:

```sh
export ACF_PRO_KEY="your-license-key"
```

## Building the image directly

You can also build the image without Compose:

```sh
docker build \
  --secret id=acf_pro_key,env=ACF_PRO_KEY \
  -f docker/Dockerfile \
  -t municipio:local .
```

The `acf_pro_key` secret is required for the build. It is mounted only while Composer installs the dependencies and is not retained in the resulting image.

The build context is the repository root, and the checked-out source is copied into the image. Check out the branch or tag you want to build before running the command.

## Configuration

The image is built on the official [FrankenPHP](https://frankenphp.dev) image. FrankenPHP runs PHP inside the Caddy web server, so PHP reads the container's environment variables directly; nothing has to be forwarded or listed.

| File | Purpose |
| --- | --- |
| [`Caddyfile`](Caddyfile) | Web server configuration: routing to WordPress core in `/wp`, blocked paths, compression. Replaces `.htaccess`. |
| [`wp-config.php`](wp-config.php) | The whole WordPress configuration. |
| [`php.ini`](php.ini) | PHP settings layered on top of `php.ini-production`. |
| [`entrypoint.sh`](entrypoint.sh) | Installs WordPress on the first start, then starts FrankenPHP. |

### WordPress constants

Every environment variable named `WP_CONF_<NAME>` defines the PHP constant `<NAME>`. For example, `WP_CONF_WP_DEBUG: true` defines `WP_DEBUG` and `WP_CONF_S3_UPLOADS_BUCKET: media` defines `S3_UPLOADS_BUCKET`. The values `true`, `false`, `null` and numbers are converted to their PHP types. Constants that are not set use the defaults in [`wp-config.php`](wp-config.php).

| Setting | Purpose |
| --- | --- |
| `WP_CONF_DB_NAME`, `WP_CONF_DB_USER`, `WP_CONF_DB_PASSWORD`, `WP_CONF_DB_HOST` | Database connection. |
| `WP_CONF_DB_TABLE_PREFIX` | Table prefix (default `wp_`). |
| `WP_CONF_WP_HOME` | Public address of the site. |
| `WP_CONF_WP_SITEURL` | Address of WordPress core, normally the site address followed by `/wp`. |
| `WP_CONF_AUTH_KEY` … `WP_CONF_NONCE_SALT` | Authentication keys and salts. Set these in production; the fallback is derived from the database credentials. |
| `WP_CONF_WP_DEBUG` | Set to `true` to enable WordPress debugging. |
| `WP_CONF_WP_REDIS_DISABLED` | Set to `true` when no Redis or Valkey service is used. |
| `WP_CONF_WP_ADMIN_USER`, `WP_CONF_WP_ADMIN_PASSWORD`, `WP_CONF_WP_ADMIN_EMAIL`, `WP_CONF_WP_SITE_TITLE` | Used only to install WordPress on the first start. They are not defined as constants. |

The admin values are only used for the initial installation. If the database already contains WordPress, changing them does not update the existing account.

### Other environment variables

Any other variable, such as `TIDEWAYS_APIKEY`, is available to PHP through `getenv()` as it is. The Tidy and Tideways extensions are installed in the image.

### PHP settings

To change PHP settings, mount an `.ini` file into `/usr/local/etc/php/conf.d/` with a name that sorts after `zz-municipio.ini`:

```yaml
volumes:
  - ./php-overrides.ini:/usr/local/etc/php/conf.d/zzz-overrides.ini:ro
```

In Kubernetes, mount a ConfigMap key to the same path with `subPath`. The image ships with `opcache.validate_timestamps=0`, because its code never changes; restart the container after changing PHP files.

### Web server

The container serves plain HTTP on port **8080** as the unprivileged user `municipio` (uid 1000). TLS is expected to terminate in front of it; WordPress treats requests with `X-Forwarded-Proto: https` as HTTPS. `/healthz` responds with `200` for liveness checks.

FrankenPHP sizes its PHP thread pool from the CPU count. To tune it, set `FRANKENPHP_CONFIG`, for example `FRANKENPHP_CONFIG: "num_threads 8"`.

### Setup commands

A command given as the container command runs after WordPress is installed and before the web server starts, for example `command: wp plugin activate redis-cache`. If it fails (because the change was already applied on an earlier start), the container logs a warning and starts anyway.

### Migrating from the OpenLiteSpeed image

| Before | Now |
| --- | --- |
| Port `80` | Port `8080` |
| `WP_CONF_EXTRA_<NAME>` | `WP_CONF_<NAME>` (the old prefix still works) |
| `WP_CONF_REDIS_HOST`, `_SCHEME`, `_PATH` | `WP_CONF_WP_REDIS_HOST`, `WP_CONF_WP_REDIS_SCHEME`, `WP_CONF_WP_REDIS_PATH` |
| Settings without the `WP_CONF_` prefix, such as `DB_NAME` | Only `WP_CONF_DB_NAME` is read |
| `OLS_PHP_ENV_VARS` | Not needed; PHP sees all environment variables |
| `PHP_INI_SETTINGS` | Mount an `.ini` file (see PHP settings) |
| `ENABLE_LS_CACHE`, LiteSpeed Cache | Removed; there is no LiteSpeed server |
| `.htaccess` templates | [`Caddyfile`](Caddyfile) |
| `?debug` in any URL enabled `WP_DEBUG` | Removed; use `WP_CONF_WP_DEBUG` |
| `exec --user ubuntu` | The container already runs as `municipio` |

## Multisite

Multisite is optional. Add these settings to the `municipio` service to enable a subdomain network:

```yaml
environment:
  WP_CONF_WP_ALLOW_MULTISITE: true
  WP_CONF_SUBDOMAIN_INSTALL: true
  WP_CONF_DOMAIN_CURRENT_SITE: localhost:9090
```

For a real domain, make sure its DNS and local development setup route subdomains to the Docker host. Subdomain multisite on `localhost` may behave differently between browsers and operating systems.

## Examples

The [`examples/`](examples/) directory contains ready-to-run Compose files that build on the base setup above. They use a relative build context (`../..`), so run them from the repository root with `-f`, e.g.:

```sh
export ACF_PRO_KEY="your-license-key"
docker compose -f docker/examples/docker-compose-base.yml up -d --build
```

Tear an example down, including its volumes, before switching to a different one:

```sh
docker compose -f docker/examples/docker-compose-base.yml down -v
```

| File | Description |
| --- | --- |
| `docker-compose-base.yml` | Minimal single-site setup: `municipio` plus a MariaDB `db` service, no cache. |
| `docker-compose-using-redis.yml` | Adds a Valkey (Redis-compatible) service and activates the `redis-cache` plugin for object caching. |
| `docker-compose-using-s3.yml` | Adds a MinIO service for S3-compatible media offloading and activates the `s3-uploads`/`s3-local-index` plugins. See the file's comments for the required `S3_UPLOADS_*` constants. |
| `docker-compose-multisite-subfolder.yml` | Enables WordPress multisite (subfolder mode) and creates a `subsite` site on first start. |
| `docker-compose-local-build.yml` | Builds the image from the current local source checkout. |
| `common-services.yml` | Shared `database` and `redis` service definitions, extended by the other examples via `extends`. Not meant to be run on its own. |

## Useful commands

Follow startup logs:

```sh
docker compose logs -f municipio
```

Run WP-CLI:

```sh
docker compose exec municipio wp option get siteurl
```

Stop the containers while keeping the database and uploaded files:

```sh
docker compose down
```

Remove the containers, database, and uploaded files, allowing a completely fresh installation next time:

```sh
docker compose down --volumes
```

## Releases

The workflows in `municipio-deployment` publish to `ghcr.io/${{ github.repository }}`. Source release tags use plain `X.Y.Z` versions (for example `6.3.7`, without a leading `v`). A tag push builds the final multi-platform image directly from that source revision and publishes `vX.Y.Z`, `vX.Y`, `vX`, and `latest`; floating tags only move forward to newer versions.

A release pull request must target the repository's default branch, come from a branch in that same repository, and have a title containing only `X.Y.Z`. Opening, updating, reopening, or retitling an eligible pull request builds its head commit as the multi-platform staging tag `vX.Y.Z-rc.RUN_NUMBER.RUN_ATTEMPT`. Final images are built independently from source tag pushes, not promoted or retagged from an RC.

On the first release, the final-image workflow treats only GHCR's `404 NAME_UNKNOWN` response for the initial tag-list request as an empty package. Authentication failures, malformed responses, and other registry errors fail the workflow rather than being treated as an empty tag list.

Set this Actions secret in the repository or an organization that grants access to it:

| Secret | Purpose |
| --- | --- |
| `ACF_PRO_KEY` | Downloads Advanced Custom Fields Pro during the image build. |

`GITHUB_TOKEN` is supplied by Actions. The workflows declare `contents: read` and `packages: write` to check out source and publish to GHCR. Set the published package's visibility so target environments can pull it. Release-candidate builds skip pull requests from forks, so forked repositories must create eligible PRs within the fork.

For a fork, enable its Actions workflows and add the secret above. The image path is derived from `github.repository`, so each fork publishes to its own `ghcr.io/<owner>/<repository>` path without a shared image name or source-repository token.

## Notes for deployed environments

The example is deliberately simple and uses local development credentials. For a shared or public environment:

- Use strong, unique passwords and provide secrets through your deployment platform.
- Put the site behind HTTPS and set `WP_CONF_WP_HOME` and `WP_CONF_WP_SITEURL` to the public HTTPS addresses.
- Pin the MariaDB image and use a source semver tag for a tested Municipio deployment version.
- Back up the database and uploads volumes.
- Set the authentication keys and salts (`WP_CONF_AUTH_KEY` and the others).
