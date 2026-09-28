# Municipio Deployment Dev Container

This guide covers setting up a local WordPress site, cloning a remote site, and developing Municipio packages inside the dev container. Run the commands below in the VS Code terminal inside the container, from the repository root unless stated otherwise.

## Prerequisites

- [Docker](https://www.docker.com/)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## Getting Started

1. Clone the repository, open it in VS Code, and run `Dev Containers: Reopen in Container` from the command palette. Wait for container creation to finish.
2. On first start, the container copies `.devcontainer/.env.example` to `.devcontainer/.env` if the latter does not exist. Edit `.devcontainer/.env` and set `GH_TOKEN` to a GitHub personal access token with `read:packages` access and `ACF_PRO_KEY` to your Advanced Custom Fields Pro Composer key. You can also set `SITE_TYPE` (`single` or `multisite`), `SITE_TITLE`, `ADMIN_USER`, `ADMIN_PASSWORD`, and `ADMIN_EMAIL` for the local install.
3. If you added package credentials after the container was created, apply them to Composer and npm before installing packages:

    ```bash
    bash .devcontainer/scripts/postCreateCommand.sh
    ```

4. Set up WordPress. This resets the local database and generated configuration, so do not rerun it to preserve local content:

    ```bash
    composer devcontainer:reset
    ```

5. Open [http://localhost:8080](http://localhost:8080) and sign in. The default administrator credentials are `superadmin` / `superadmin` unless overridden in `.devcontainer/.env`.

VS Code shows a configuration status banner when you attach to the container. Run `.devcontainer/scripts/status.sh` to see it again.

### Xdebug

Start the `Listen for Xdebug` configuration in VS Code before triggering a session. Web requests start a session when requested with `?XDEBUG_TRIGGER=1` (or with an `XDEBUG_TRIGGER=1` cookie). For example, open `http://localhost:8080/?XDEBUG_TRIGGER=1`. CLI sessions can be triggered with:

```bash
XDEBUG_TRIGGER=1 wp post list --allow-root
```

The debugger pauses at the first line of a triggered request or command.

### GitHub Codespaces

Add `GH_TOKEN` and `ACF_PRO_KEY` as Codespaces repository secrets before creating the codespace. `GH_TOKEN` must be a GitHub personal access token with the `read:packages` scope. Codespaces exposes the secrets to the dev container automatically, so you do not need to put credentials in `.devcontainer/.env`. The container still creates that file from `.env.example` on first start; inherited credentials take precedence during credential setup.

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

`composer devcontainer:reset` runs `.devcontainer/scripts/setup.sh`. It resets the MariaDB database, replaces generated configuration, reinstalls packages, installs WordPress, activates the required plugins and Municipio theme, creates cache directories, and copies the devcontainer `.htaccess` file. Back up any local content and package changes you need before running it again.

Choose `single` for one WordPress site or `multisite` for a network with sites under paths such as `/somesite`. Setup asks which to install when run interactively; set `SITE_TYPE=single` or `SITE_TYPE=multisite` in `.devcontainer/.env` to skip the prompt. Without a terminal or a configured `SITE_TYPE`, setup defaults to `multisite`.

ACF Pro is installed as a must-use plugin and loads automatically. Setup activates `s3-uploads`, `s3-local-index`, and `municipio-clone` (network-wide on multisite). Redis and LiteSpeed cache plugins are installed but remain inactive by default. `ACF_PRO_KEY` configures Composer access to ACF Pro.

Redis object caching and LiteSpeed page caching are disabled by default, including after a setup/reset. Enable them for the current site with `.devcontainer/scripts/cache-enable.sh`; turn them off with `.devcontainer/scripts/cache-disable.sh`.

## Clone a Site

Use this workflow after setting up the local site. You need access to the remote WordPress site and an application password for a remote user. For a subfolder target such as `/somesite`, install the local site as multisite first.

1. Copy the example config from the repository root:

    ```bash
    cp .devcontainer/sites.example.json .devcontainer/sites.json
    ```

2. Edit `.devcontainer/sites.json`. Each entry in `mappings` pairs a remote `source_url` with a local `target` (the example uses `http://localhost:8080/somesite`). Set `username_env` and `application_password_env` to the *names* of environment variables holding the remote username and application password, not the credentials themselves. Set `keep_remote_media_urls` to `true` to reference remote media instead of copying it.

3. Export those variables in the terminal running Composer. The example expects `MUNICIPIO_CLONE_USERNAME` and `MUNICIPIO_CLONE_APPLICATION_PASSWORD`. Then run:

    ```bash
    composer devcontainer:clone
    ```

This runs `wp municipio clone-batch --config=.devcontainer/sites.json` using the mappings in your copied configuration.

## Developing a Package

Run this when you need to edit a `helsingborg-stad/*` or `municipio-se/*` package from source rather than use the installed release. The script removes installed packages, reinstalls them from the configured Composer repositories, then optionally reinstalls one selected package from source. **Commit or stash local changes inside installed package directories first:** the cleanup removes tracked and untracked changes there.

Interactive mode:

```bash
.devcontainer/scripts/setup-dev-package.sh
```

To skip prompts (for example, in a scripted environment):

```bash
# Reinstall packages without selecting one for source development
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

Package installation validates Composer files and runs `composer install --prefer-dist --no-interaction --ignore-platform-reqs`. If validation fails, the script removes `composer.lock` before installing; check changes to the lockfile afterward.

## Updating Sub-packages

`updateSubPackage.sh` finds installed packages blocking a dependency update, updates the existing dependency constraint, verifies the result, and can push a branch and create a GitHub pull request for each package.

```bash
.devcontainer/scripts/updateSubPackage.sh \
    --package='helsingborg-stad/wputilservice' \
    --version='^0.3'
```

Requirements are Composer, Git, and an authenticated GitHub CLI (`gh auth login`). The script only updates dependencies already declared by a package. It may discard local changes when reinstalling affected packages from source, so save those changes before running it.

For more information, see the [Dev Containers documentation](https://code.visualstudio.com/docs/devcontainers/containers).
