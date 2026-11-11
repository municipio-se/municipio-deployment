# Municipio container image

This directory builds a ready-to-run [Municipio](https://github.com/municipio-se/municipio-deployment) WordPress image from the checked-out source. The image contains OpenLiteSpeed, PHP, WordPress, WP-CLI, and the deployment. Composer, Node.js, npm, and Git are used only while building the image and are not included in the runtime image.

On its first start, the container connects to the database, installs WordPress, and activates ACF Pro automatically. Later starts reuse the existing database and ensure that ACF Pro remains active.

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

## Common settings

Runtime settings use the `WP_CONF_` prefix. The most useful ones are:

| Setting | Purpose |
| --- | --- |
| `WP_CONF_DB_NAME` | Database name. |
| `WP_CONF_DB_USER` | Database user. |
| `WP_CONF_DB_PASSWORD` | Database password. |
| `WP_CONF_DB_HOST` | Database service name or host. |
| `WP_CONF_WP_HOME` | Public address of the site. |
| `WP_CONF_WP_SITEURL` | Address of WordPress core, normally the site address followed by `/wp`. |
| `WP_CONF_WP_ADMIN_USER` | Admin username created on the first start. |
| `WP_CONF_WP_ADMIN_PASSWORD` | Admin password created on the first start. |
| `WP_CONF_WP_ADMIN_EMAIL` | Admin email created on the first start. |
| `WP_CONF_WP_DEBUG` | Set to `true` to enable WordPress debugging. |
| `WP_CONF_WP_REDIS_DISABLED` | Set to `true` when no Redis or Valkey service is used. |
| `ENABLE_LS_CACHE` | Set to `true` to enable LiteSpeed Cache plugin and include LiteSpeed rewrite rules when `.htaccess` is first created. |
| `ENABLE_PHP_TIDY` | Set to `true` to install the Tidy extension for the current LiteSpeed PHP version on startup (requires access to the package repository). |

The database and admin values are only used to perform the initial installation. If a database volume already contains WordPress, changing the initial admin values will not update the existing account.

On startup, `.htaccess` is created from the selected single-site or multisite template only if it does not already exist. Existing files, including plugin-generated rules and ownership, are left untouched; changing multisite or cache settings does not rewrite them. An installed site with a missing `.htaccess` receives the template without a WordPress rewrite flush.

Any additional WordPress constant can be defined with `WP_CONF_EXTRA_`. For example, `WP_CONF_EXTRA_MY_SETTING: enabled` defines the `MY_SETTING` constant.

To configure Tideways for web requests, pass `TIDEWAYS_APIKEY` as a runtime environment variable and add its name to `OLS_PHP_ENV_VARS`. For example:

```yaml
environment:
  TIDEWAYS_APIKEY: your-key
  OTHER_API_KEY: another-key
  OLS_PHP_ENV_VARS: "TIDEWAYS_APIKEY,OTHER_API_KEY"
```

For any additional setting needed by web PHP, add its name to the comma-separated `OLS_PHP_ENV_VARS` list and set its value separately in the container. `WP_CONF_*` variables continue to be forwarded automatically; all other variables, including `TIDEWAYS_*`, require explicit listing. Invalid or unset names in the list stop startup instead of silently omitting them. `WP_CONF_EXTRA_TIDEWAYS_APIKEY` instead defines a WordPress constant named `TIDEWAYS_APIKEY`; it does not set the environment variable used by the Tideways extension. Only list values PHP should be able to access; treat keys as secrets and avoid exposing `phpinfo()` publicly.

To set PHP ini directives, use `PHP_INI_SETTINGS` with one `name=value` directive per line:

```yaml
environment:
  PHP_INI_SETTINGS: |
    allow_url_include=0
    upload_max_filesize=64M
```

The container discovers the LiteSpeed PHP version in the runtime image and writes these directives to an additional ini file in its default scanned directory, so they apply to both web requests and PHP processes started during container setup. If no single PHP ini directory can be found, or a directive line is invalid, startup stops with an error.

In Kubernetes, an `envFrom.secretRef` Secret must have a key named `PHP_INI_SETTINGS` containing the newline-separated directives (for example, create it with `kubectl create secret generic php-ini --from-file=PHP_INI_SETTINGS=./settings.ini`). A Secret mounted as a file does not automatically become this environment variable. Restart the pod after changing the Secret; environment variables are not updated in running pods. Avoid overriding `PHP_INI_SCAN_DIR`, which can exclude the default scanned directory.

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
| `docker-compose-using-lscache.yml` | Enables the `litespeed-cache` plugin and applies LiteSpeed Cache `.htaccess` rewrite rules. |
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

Run WP-CLI as the webroot owner, so files created by commands remain writable by OpenLiteSpeed:

```sh
docker compose exec --user ubuntu municipio wp option get siteurl
```

Use `docker compose exec --user ubuntu municipio <command>` for other commands that write to the webroot. The container starts as root to install optional packages and configure OpenLiteSpeed.

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

Set these Actions secrets in the repository or an organization that grants access to it:

| Secret | Purpose |
| --- | --- |
| `ACF_PRO_KEY` | Downloads Advanced Custom Fields Pro during the image build. |
| `DOCKERHUB_USERNAME` | Authenticates to Docker Hub to pull the private OpenLiteSpeed base image. |
| `DOCKERHUB_TOKEN` | Docker Hub access token for that login. |

`GITHUB_TOKEN` is supplied by Actions. The workflows declare `contents: read` and `packages: write` to check out source and publish to GHCR. Set the published package's visibility so target environments can pull it. Release-candidate builds skip pull requests from forks, so forked repositories must create eligible PRs within the fork.

For a fork, enable its Actions workflows and add the three secrets above. The image path is derived from `github.repository`, so each fork publishes to its own `ghcr.io/<owner>/<repository>` path without a shared image name or source-repository token.

## Notes for deployed environments

The example is deliberately simple and uses local development credentials. For a shared or public environment:

- Use strong, unique passwords and provide secrets through your deployment platform.
- Put the site behind HTTPS and set `WP_CONF_WP_HOME` and `WP_CONF_WP_SITEURL` to the public HTTPS addresses.
- Pin the MariaDB image and use a source semver tag for a tested Municipio deployment version.
- Back up the database and uploads volumes.
- Do not publish the OpenLiteSpeed administration port unless it is specifically needed and protected.
