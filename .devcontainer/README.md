# Municipio Deployment Dev Container

This guide provides instructions for setting up and working with the Municipio Deployment Dev Container.

## Prerequisites

- [Docker](https://www.docker.com/)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## Getting Started

1. **Clone the repository**
    `git clone <repository-url>`

2. **Open the repository in VS Code**

3. **Reopen in Container**
    Open the command palette (`Cmd+Shift+P` or `Ctrl+Shift+P`) and run:
    `Dev Containers: Reopen in Container`

4. **Configure environment variables**
    The container will auto-create `.devcontainer/.env` from `.env.example` on first start.
    Edit `.devcontainer/.env` and fill in the required values:
    - `MUNICIPIO_ACF_PRO_KEY` - Required for ACF Pro plugin
    - `MUNICIPIO_GITHUB_TOKEN` - Required for private npm/composer packages

5. **Run setup script**
    In the terminal, run:
    `.devcontainer/scripts/setup.sh`

6. **Access the local site**
    Open your browser and navigate to [https://localhost:8443](https://localhost:8443).

### Accessing the Local Site

- Navigate to [https://localhost:8443](https://localhost:8443) in your browser.
- Accept the self-signed certificate warning if prompted.
- Default login credentials:
  - **Username:** `superadmin`
  - **Password:** `superadmin`

## Working with Packages in the Container

To develop or debug specific Composer packages within the container:

- **Reinstall a package from source:**  
  `composer reinstall <vendor>/<package> --prefer-source`

- **Open a package in a new VS Code window:**  
  `code <path-to-package>`

- **Install package dependencies:**  
  In the package directory, run:  
  - `composer install`  
  - `npm install` (if applicable)

## Running the Setup Script

The `setup.sh` script configures your local development environment from scratch. It will reset the database and apply all necessary configuration.

```bash
.devcontainer/scripts/setup.sh
```

The script will:

1. **Add config files** - Copies configuration from `config-example/` and `.devcontainer/config/wp-config/`
2. **Install ACF Pro** - Downloads and installs the ACF Pro plugin using your license key
3. **Import database** - Resets the database and imports `db/seed.sql`
4. **Add .htaccess** - Copies the `.htaccess` file for URL rewriting
5. **Clean up** - Removes cached fonts

**Note:** This script requires `MUNICIPIO_ACF_PRO_KEY` to be set in `.devcontainer/.env`.

## Migrating a Remote Site

The `migrate.sh` script migrates a remote WordPress subdomain multisite to your local subfolder multisite setup.

### Configuration

Before running the migration, configure the required environment variables in `.devcontainer/.env`:

| Variable | Description |
|----------|-------------|
| `SSH_PORT` | SSH port for remote server |
| `REMOTE_SSH` | SSH connection string (user@host) |
| `REMOTE_PATH` | WordPress installation path on remote |
| `REMOTE_SITE_PROTOCOL` | Protocol of remote site (`http://` or `https://`) |
| `REMOTE_SITE_DOMAIN` | Domain of remote site to migrate |
| `REMOTE_PREFIX` | Database table prefix on remote |
| `LOCAL_SITE_SLUG` | Slug for the local subfolder site |

See `.env.example` for a template.

### Running the Migration

```bash
.devcontainer/scripts/migrate.sh
```

The script will:

1. **Check dependencies** - Verifies `wp`, `ssh`, and `scp` are available
2. **Export remote database** - Connects via SSH and exports site tables
3. **Download database** - Transfers the SQL file to local machine
4. **Create local site** - Creates a new subfolder site in the local multisite
5. **Import database** - Imports the remote database tables
6. **Rename tables** - Updates table prefixes to match local site ID
7. **Update URLs** - Replaces remote domain with local domain in database

### Notes

- You may be prompted for your SSH password/key passphrase
- If the local site already exists, you'll be asked whether to delete it
- The script requires SSH access to the remote server
- After migration, access your site at `https://localhost:8443/<LOCAL_SITE_SLUG>`

## Documentation for setup-dev-package.sh Script
The `setup-dev-package.sh` script is a utility designed to streamline the development process by providing a clean and efficient development environment. It automates the process of downloading an editable version of the selected plugin. All other plugins in the environment will be reset to their production release versions. This ensures that only the selected plugin is in a development state, avoiding unnecessary builds for untouched packages.

### Features
- **Environment Setup**: Automatically configures the development environment with necessary dependencies.
- **Cleanup**: Ensures the development environment remains clean by removing uncommitted files and resetting configurations as needed.
- **Automation**: Simplifies repetitive tasks, allowing developers to focus on coding rather than setup.
- **Compatibility**: Works seamlessly with the existing project structure and dependencies.
- **Scriptable**: Supports command-line flags for non-interactive use in CI/CD or other scripts.

### Usage

**Interactive mode** (default):
```bash
.devcontainer/scripts/setup-dev-package.sh
```

**Non-interactive mode** (for automation):
```bash
# Clean and install only, skip package selection
.devcontainer/scripts/setup-dev-package.sh -y --skip-select

# Specify a package directly
.devcontainer/scripts/setup-dev-package.sh -y -p helsingborg-stad/municipio

# Skip opening the editor
.devcontainer/scripts/setup-dev-package.sh -y -p helsingborg-stad/municipio --no-editor
```

### Options

| Flag | Description |
|------|-------------|
| `-y, --yes` | Skip confirmation prompt |
| `-s, --skip-select` | Skip package selection (only clean and install) |
| `-p, --package <name>` | Specify package name directly |
| `-e, --editor <cmd>` | Editor command (default: `code`) |
| `--no-editor` | Don't open editor after setup |
| `-h, --help` | Show help message |

### Sub-scripts

The script is composed of modular sub-scripts in `.devcontainer/scripts/dev-package/`:

| Script | Purpose |
|--------|---------|
| `clean-packages.sh` | Removes vendor, plugins, mu-plugins, and themes |
| `install-packages.sh` | Runs `composer install --prefer-dist` |
| `select-dev-package.sh` | Lists packages and reinstalls selected one from source |

These can be run individually if needed.

### Notes
- Ensure you have the necessary permissions to execute the script. You may need to run `chmod +x .devcontainer/scripts/setup-dev-package.sh` to make it executable.
- Review the script contents to understand its operations and ensure it aligns with your development requirements.
- For troubleshooting or customization, refer to the script's inline comments or contact the project maintainers.

By using the `setup-dev-package.sh` script, developers can save time and maintain a consistent development workflow across the team.

---

For additional troubleshooting or advanced configuration, refer to the [Dev Containers documentation](https://code.visualstudio.com/docs/devcontainers/containers).
