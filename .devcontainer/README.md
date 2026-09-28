# Municipio Deployment Dev Container

This guide describes the local development environment for Municipio Deployment.

## Prerequisites

- [Docker](https://www.docker.com/)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## Getting Started

1. Clone the repository and open it in VS Code.
2. Run `Dev Containers: Reopen in Container` from the command palette.
3. On first start, `postCreateCommand.sh` creates `.devcontainer/.env` and configures package credentials when present.
4. Edit `.devcontainer/.env` and set:
    - `GH_TOKEN` to a GitHub personal access token with the `read:packages` scope for private Composer and npm packages.
   - `ACF_PRO_KEY` for Advanced Custom Fields Pro Composer packages.
5. Run the local site setup:

   ```bash
   .devcontainer/scripts/setup.sh
   ```

   Or use the Composer alias:

   ```bash
   composer devcontainer:reset
   ```

6. Open [http://localhost:8080](http://localhost:8080).

The default administrator is `superadmin` with password `superadmin`. Set `SITE_TITLE`, `ADMIN_USER`, `ADMIN_PASSWORD`, and `ADMIN_EMAIL` in `.devcontainer/.env` to override the defaults.

The dev container prints an attach-time status banner when VS Code attaches. Run `.devcontainer/scripts/status.sh` to show the same status again.

The dev container prints a configuration status banner when VS Code attaches. Run `.devcontainer/scripts/status.sh` to show the same status again.

### Xdebug

Start the `Listen for Xdebug` configuration in VS Code before triggering a session. Web requests start a session when requested with `?XDEBUG_TRIGGER=1` (or with an `XDEBUG_TRIGGER=1` cookie). For example, open `http://localhost:8080/?XDEBUG_TRIGGER=1`. CLI sessions can be triggered with:

```bash
XDEBUG_TRIGGER=1 wp post list --allow-root
```

The debugger pauses at the first line of a triggered request or command.

### GitHub Codespaces

Add `GH_TOKEN` and `ACF_PRO_KEY` as Codespaces repository secrets before creating the codespace. `GH_TOKEN` must be a GitHub personal access token with the `read:packages` scope. Codespaces exposes the secrets to the dev container automatically, so no `.env` file is required for startup. Environment values take precedence over values copied from `.env.example`.

The container can also start without these credentials. Package installation that requires private GitHub packages or ACF Pro remains unavailable until the corresponding credential is configured, but the missing values no longer prevent container creation.

## Services

| Service | Address | Purpose |
| --- | --- | --- |
| WordPress | [http://localhost:8080](http://localhost:8080) | Local site |
| MariaDB | `localhost:8306` | WordPress database |
| phpMyAdmin | [http://localhost:8090](http://localhost:8090) | Database administration |
| Valkey | `localhost:6379` | Object cache |
| Typesense | `localhost:8108` | Search service |
| MinIO API | `localhost:9000` | S3-compatible object storage |
| MinIO console | [http://localhost:9091](http://localhost:9091) | Object storage administration |

The MinIO development credentials are `minioadmin` / `minioadmin`. The `municipio` bucket is created automatically.

## Local Site Setup

`setup.sh` resets the MariaDB database, copies configuration files, installs Composer packages, installs WordPress, activates the required plugins and Municipio theme, creates cache directories, and copies the devcontainer `.htaccess` file.

By default, setup prompts for a single site or a subfolder multisite network. Set `SITE_TYPE=single` or `SITE_TYPE=multisite` to skip the prompt. A non-interactive run defaults to `multisite` when `SITE_TYPE` is unset.

The required plugins are `advanced-custom-fields-pro`, `s3-uploads`, `s3-local-index`, and `municipio-clone`. Redis and LiteSpeed cache plugins are installed but remain inactive by default. `ACF_PRO_KEY` configures Composer access to ACF Pro; package installation is performed by Composer.

Redis object caching and LiteSpeed page caching are disabled by default, including after a setup/reset. Enable them for the current site with `.devcontainer/scripts/cache-enable.sh`; turn them off with `.devcontainer/scripts/cache-disable.sh`.

Setup is destructive: running it again resets the database and overwrites generated configuration files.

## Clone a Site

After local site setup, copy the example clone configuration and edit the mapping for each site you want to clone:

```bash
cp .devcontainer/sites.example.json .devcontainer/sites.json
```

In `.devcontainer/sites.json`, set `source_url` to the remote site and `target` to the local site URL (for example, `http://localhost:8080/somesite`). Set `username_env` and `application_password_env` to the names of environment variables containing a remote WordPress username and application password. Set `keep_remote_media_urls` to `true` to keep media URLs pointing to the remote site.

Export the named variables in the shell running Composer (the example uses `MUNICIPIO_CLONE_USERNAME` and `MUNICIPIO_CLONE_APPLICATION_PASSWORD`), then run the alias from the repository root:

```bash
composer devcontainer:clone
```

This runs `wp municipio clone-batch --config=.devcontainer/sites.json` using the mappings in your copied configuration.

## Developing a Package

The package setup script removes installed packages and reinstalls them from the configured Composer repositories. It can then reinstall one selected `helsingborg-stad/*` or `municipio-se/*` package from source. Local changes inside installed package directories are lost, so commit or stash them first.

Interactive mode:

```bash
.devcontainer/scripts/setup-dev-package.sh
```

Non-interactive examples:

```bash
# Reinstall production packages only
.devcontainer/scripts/setup-dev-package.sh -y --skip-select

# Set up a package from source without opening another editor
.devcontainer/scripts/setup-dev-package.sh -y \
    -p helsingborg-stad/municipio --no-editor

# Composer alias
composer dev
```

Options:

| Flag | Description |
| --- | --- |
| `-y`, `--yes` | Skip the confirmation prompt |
| `-s`, `--skip-select` | Skip package selection |
| `-p`, `--package <name>` | Select a package directly |
| `-e`, `--editor <cmd>` | Editor command, default `code` |
| `--no-editor` | Do not open the package in an editor |
| `-h`, `--help` | Show help |

Package installation validates Composer files and runs `composer install --prefer-dist --no-interaction --ignore-platform-reqs`. If Composer validation fails, the script removes `composer.lock` before installing.

## Updating Sub-packages

`updateSubPackage.sh` finds installed packages blocking a dependency update, updates the existing dependency constraint, verifies the result, and can push a branch and create a GitHub pull request for each package.

```bash
.devcontainer/scripts/updateSubPackage.sh \
    --package='helsingborg-stad/wputilservice' \
    --version='^0.3'
```

Requirements are Composer, Git, and an authenticated GitHub CLI (`gh auth login`). The script only updates dependencies already declared by a package. It may discard local changes when reinstalling affected packages from source.

## Additional Commands

```bash
# Reset the local WordPress installation
composer devcontainer:reset

# Run the package setup workflow
composer dev
```

For more information, see the [Dev Containers documentation](https://code.visualstudio.com/docs/devcontainers/containers).
