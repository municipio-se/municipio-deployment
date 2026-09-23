# Municipio Deployment Dev Container

This guide describes the local development environment for Municipio Deployment.

## Prerequisites

- [Docker](https://www.docker.com/)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## Getting Started

1. Clone the repository and open it in VS Code.
2. Run `Dev Containers: Reopen in Container` from the command palette.
3. On first start, `postCreateCommand.sh` creates `.devcontainer/.env` from `.env.example` and configures Composer and npm credentials when tokens are present.
4. Edit `.devcontainer/.env` and set:
   - `MUNICIPIO_GITHUB_TOKEN` for private Composer and npm packages.
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

The required plugins are `advanced-custom-fields-pro`, `s3-uploads`, `s3-local-index`, `redis-cache`, `litespeed-cache`, and `municipio-clone`. `ACF_PRO_KEY` configures Composer access to ACF Pro; package installation is performed by Composer.

Setup is destructive: running it again resets the database and overwrites generated configuration files.

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
