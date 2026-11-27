# Municipio container image

This directory builds a ready-to-run [Municipio](https://github.com/municipio-se/municipio-deployment) WordPress image from the checked-out source. The image contains OpenLiteSpeed, PHP, WordPress, WP-CLI, and the deployment. Composer, Node.js, npm, and Git are used only while building the image and are not included in the runtime image.

On its first start, the container connects to the database, installs WordPress, and activates ACF Pro automatically. Later starts reuse the existing database and ensure that ACF Pro remains active.

## How the image is built

The image is built in two layers that are kept in separate directories, so it is always clear which part configures the server and which part configures Municipio:

| Layer | Directory | What it contains |
| --- | --- | --- |
| Server (OpenLiteSpeed) | [`ols/`](ols/), built by the `ols` stage of [`Dockerfile`](Dockerfile) | LiteSpeed's version- and digest-pinned OpenLiteSpeed/lsphp image plus Municipio-specific PHP extensions, `php.ini` tuning, listener and vhost config, `/entrypoint.sh` and `ols-hbg-configure`. Its runtime settings are summarised under [Common settings](#common-settings) and detailed in the [OLS layer guide](ols/README.md). |
| Application (Municipio) | [`wordpress/`](wordpress/) | WordPress configuration, site-type rewrite rules and startup scripts. The `builder` and `runtime` stages of [`Dockerfile`](Dockerfile) build Municipio and add these files. |

One Dockerfile builds both into **one** image: its `ols` stage extends the pinned official image with the scripts in `docker/ols/`, and the final stage starts `FROM ols`. The configured server layer is not published separately. All Municipio-specific server logic stays in `docker/ols/`. The dev container ([`.devcontainer/`](../.devcontainer/README.md#production-parity)) also builds the `ols` stage, so changes there affect local development too.

The other directories are [`examples/`](examples/) for Compose deployments,
[`tests/`](tests/) for container and startup checks, and [`scripts/`](scripts/)
for release tooling. Inside [`ols/`](ols/), `config/` contains the vhost
template and `scripts/` contains the server build and startup scripts.

## Before you start

You need:

- Docker with Docker Compose
- An ACF Pro license key used to download ACF Pro while building the image

Set the ACF Pro key in your shell. Docker passes it to the build as a temporary BuildKit secret, so it does not need to be written into the Compose file or stored in the image:

```sh
export ACF_PRO_KEY="your-license-key"
```

## Building the image directly

You can also build the image without Compose, from the repository root:

```sh
docker build \
  --secret id=acf_pro_key,env=ACF_PRO_KEY \
  -f docker/Dockerfile \
  -t municipio:local .
```

The `acf_pro_key` secret is required for the build. It is mounted only while Composer installs the dependencies and is not retained in the resulting image.

The build context is the repository root, and the checked-out source is copied into the image. Check out the branch or tag you want to build before running the command.

Check that the built image's upload and cache directories are writable by the
site user:

```sh
bash docker/tests/upload_permissions.sh municipio:local
```

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

The database and admin values are only used to perform the initial installation. If a database volume already contains WordPress, changing the initial admin values will not update the existing account.

### Web server rules

The image ships fixed web server rules; nothing is generated or edited at runtime.

- **Shared by every site type**, in OpenLiteSpeed's site config [`ols/config/vhost.conf`](ols/config/vhost.conf):
  - the LiteSpeed Cache plugin's rules (page cache lookup, tracking parameters left out of the cache key); they have no effect until the plugin is activated
  - rewrites: `www.` removal, a trailing slash on page URLs, blocking `xmlrpc.php`, `wp-trackback.php` and `wp-signup.php`, hiding `?author=` pages, and passing the `Authorization` header to PHP
  - response headers: HSTS, `X-Content-Type-Options`, `Referrer-Policy`, `Permissions-Policy`, and `Access-Control-Allow-Origin: *` on static assets
  - one-year browser cache lifetimes for media, scripts, styles and fonts
  - WordPress's 404 page for missing files
- **Per site type**, in [`wordpress/htaccess/`](wordpress/htaccess/): `single-site.htaccess`, `multisite-subdomain.htaccess` and `multisite-subfolder.htaccess`. Each holds only the WordPress routing for that site type.

On every start, the file matching `WP_CONF_WP_ALLOW_MULTISITE` and `WP_CONF_SUBDOMAIN_INSTALL` is copied over the document root's `.htaccess`, owned by root and read-only for WordPress. Edits made inside the container, by hand or by a plugin, are replaced on the next start; change the files in the repository instead. OpenLiteSpeed only reads rewrite rules from `.htaccess`, and only when the server starts, which is why headers and the like live in the server config.

Any additional WordPress constant can be defined with `WP_CONF_EXTRA_`. For example, `WP_CONF_EXTRA_MY_SETTING: enabled` defines the `MY_SETTING` constant.

### Server sizing

The server sizes itself from Municipio's needs, so normally only the container memory limit needs setting:

| Setting | Default | Effect |
| --- | --- | --- |
| `PHP_MEMORY_LIMIT` | `512M` | Memory one PHP request may use. WordPress's `WP_MEMORY_LIMIT` follows it unless `WP_CONF_WP_MEMORY_LIMIT` is set. |
| `OLS_PHP_CHILDREN` | automatic | PHP requests handled at once. When unset: (container memory limit − 512M) ÷ `PHP_MEMORY_LIMIT`, so a 3 GiB pod gets 5 and a 6 GiB pod gets 11. Without a memory limit: 10. |

The chosen values are logged at startup. OpenLiteSpeed uses one worker; see the [OLS layer guide](ols/README.md#sizing) for the less common `OLS_PHP_KEEPALIVE_TIMEOUT`.

### PHP extensions and environment

tidy, Tideways, Imagick, intl, cURL, MySQL and OPcache are always enabled.

`WP_CONF_*` variables reach WordPress through a file, not through the web server's environment. On every start, the container writes them to `/var/www/vhosts/localhost/wp-conf.php`. That file is outside the web root, readable only by the site user, and read by [`wordpress/config/env.php`](wordpress/config/env.php). The values are therefore never in `getenv()`, `$_SERVER` or `phpinfo()`, nor in the environment of processes PHP starts. Set `WP_CONF_*` as environment variables as usual; nothing has to be mounted.

Other container variables are not passed to web PHP at all. Tideways is configured with its usual variables, which the server turns into the extension's ini settings:

| Variable | Tideways setting |
| --- | --- |
| `TIDEWAYS_APIKEY` | `tideways.api_key` |
| `TIDEWAYS_CONNECTION` | `tideways.connection`, e.g. `tcp://tideways-daemon:9135` |
| `TIDEWAYS_SERVICE` | `tideways.service` |
| `TIDEWAYS_SAMPLERATE` | `tideways.sample_rate` |
| `TIDEWAYS_TRACE_SAMPLE_RATE` | `tideways.trace_sample_rate` |
| `TIDEWAYS_FRAMEWORK` | `tideways.framework` |

For any other PHP setting, use `PHP_INI_SETTINGS`. For a WordPress constant, use `WP_CONF_EXTRA_<NAME>`.

### PHP ini settings

Set other PHP ini directives with `PHP_INI_SETTINGS`, one `name=value` per line:

```yaml
environment:
  PHP_INI_SETTINGS: |
    allow_url_include=0
    upload_max_filesize=64M
```

They apply to web requests and to WP-CLI during container setup. Use `PHP_MEMORY_LIMIT` rather than `memory_limit` here; a `memory_limit` line, or any line that isn't `name=value`, stops startup. In Kubernetes, load a multi-line value from a Secret or ConfigMap key named `PHP_INI_SETTINGS` with `envFrom`. Restart the pod after changing it.

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

Follow the logs: startup, then OpenLiteSpeed's error log (including PHP errors and warnings) and access log as requests come in:

```sh
docker compose logs -f municipio
```

Run WP-CLI as the webroot owner, so files created by commands remain writable by OpenLiteSpeed:

```sh
docker compose exec --user ubuntu municipio wp option get siteurl
```

Use `docker compose exec --user ubuntu municipio <command>` for other commands that write to the webroot. The container starts as root to install optional packages and configure OpenLiteSpeed.

Stop the containers while keeping the database. Uploaded files inside the
container are lost unless `wp-content/uploads` is stored in a volume or
offloaded to object storage:

```sh
docker compose down
```

Remove the containers and their named volumes, allowing a completely fresh installation next time:

```sh
docker compose down --volumes
```

For persistent local uploads, mount a volume at
`/var/www/vhosts/localhost/html/wp-content/uploads`. An existing volume must be
writable by the site user (UID/GID `1000:1000`).

## Releases

The workflows in `municipio-deployment` publish to `ghcr.io/${{ github.repository }}`. Source release tags use plain `X.Y.Z` versions (for example `6.3.7`, without a leading `v`). A tag push builds the final multi-platform image directly from that source revision and publishes `vX.Y.Z`, `vX.Y`, `vX`, and `latest`; floating tags only move forward to newer versions.

A release pull request must target the repository's default branch, come from a branch in that same repository, and have a title containing only `X.Y.Z`. Opening, updating, reopening, or retitling an eligible pull request builds its head commit as the multi-platform staging tag `vX.Y.Z-rc.N`, where `N` starts at `0` and increases with each build for that version. Final images are built independently from source tag pushes, not promoted or retagged from an RC.

After a release publishes `vX.Y.Z`, the release workflow deletes that version's `vX.Y.Z-rc.N` images from GHCR, together with the untagged platform, attestation, and per-platform index manifests behind them ([docker/scripts/delete-ghcr-rc-versions.sh](scripts/delete-ghcr-rc-versions.sh)). Nothing the `vX.Y.Z` image uses is deleted, and an RC image that also carries another tag is skipped. To clean up versions released before this existed, run the **Delete container release candidates** workflow manually; it defaults to a dry run and refuses to run for a version without a `vX.Y.Z` image.

Deleting package versions with `GITHUB_TOKEN` requires the repository to have the **Admin** role under the package's *Manage Actions access* settings. This is the default when the repository's workflow published the package first; otherwise the cleanup fails with HTTP 403.

On the first release, the final-image workflow treats only GHCR's `404 NAME_UNKNOWN` response for the initial tag-list request as an empty package. Authentication failures, malformed responses, and other registry errors fail the workflow rather than being treated as an empty tag list.

Set these Actions secrets in the repository or an organization that grants access to it:

| Secret | Purpose |
| --- | --- |
| `ACF_PRO_KEY` | Downloads Advanced Custom Fields Pro during the image build. |
| `DOCKERHUB_USERNAME` | Authenticates to Docker Hub when pulling public base images (Ubuntu, PHP, Node.js), to avoid anonymous rate limits. |
| `DOCKERHUB_TOKEN` | Docker Hub access token for that login. |

`GITHUB_TOKEN` is supplied by Actions. The workflows declare `contents: read` and `packages: write` to check out source and publish to GHCR. Set the published package's visibility so target environments can pull it. Release-candidate builds skip pull requests from forks, so forked repositories must create eligible PRs within the fork.

For a fork, enable its Actions workflows and add the three secrets above. The image path is derived from `github.repository`, so each fork publishes to its own `ghcr.io/<owner>/<repository>` path without a shared image name or source-repository token.

## Notes for deployed environments

The example is deliberately simple and uses local development credentials. For a shared or public environment:

- Use strong, unique passwords and provide secrets through your deployment platform.
- Put the site behind HTTPS and set `WP_CONF_WP_HOME` and `WP_CONF_WP_SITEURL` to the public HTTPS addresses.
- Pin the MariaDB image and use a source semver tag for a tested Municipio deployment version.
- Back up the database and uploads volumes.
- Only publish the application port. The OpenLiteSpeed WebAdmin listener is disabled even though the upstream image advertises port 7080 in its metadata.
