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

3. **Set up environment variables**  
    Copy `.devcontainer/.env.example` to `.devcontainer/.env` and fill in the required values.

4. **Reopen in Container**  
    Open the command palette (`Cmd+Shift+P` or `Ctrl+Shift+P`) and run:  
    `Dev Containers: Reopen in Container`

5. **Install PHP dependencies**  
    In the terminal, run:  
    `composer install`

6. **Install Node.js dependencies**  
    Run:  
    `php build.php --install-npm`

7. **Run setup script**
    In the terminal, run:
    `.devcontainer/scripts/setup.sh`

8. **Access the local site**
    Open your browser and navigate to your configured domain (default: [https://localhost:8443](https://localhost:8443)).

### Accessing the Local Site

- Navigate to your configured `LOCAL_SITE_DOMAIN` (default: [https://localhost:8443](https://localhost:8443)) in your browser.
- Accept the self-signed certificate warning if prompted.
- Default login credentials:
  - **Username:** `superadmin`
  - **Password:** `superadmin`

### Custom Domain Configuration

You can configure a custom domain and port by setting variables in `.devcontainer/.env`:

```bash
# Port-based (default)
LOCAL_SITE_DOMAIN=localhost:8443
LOCAL_SITE_PORT=8443

# Custom port
LOCAL_SITE_DOMAIN=localhost:9443
LOCAL_SITE_PORT=9443

# Custom domain (requires local DNS/hosts configuration)
LOCAL_SITE_DOMAIN=dev.example.com
LOCAL_SITE_PORT=443
```

**Important notes:**
- When changing `LOCAL_SITE_PORT`, you must also update `forwardPorts` and `portsAttributes` in `devcontainer.json` manually, as it doesn't support environment variables.
- When using a custom domain, configure your local DNS or `/etc/hosts` file to point to the container.
- After changing port configuration, rebuild the container for changes to take effect.

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
| `LOCAL_SITE_DOMAIN` | Local domain (default: `localhost:8443`) |

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
- After migration, access your site at `https://<LOCAL_SITE_DOMAIN>/<LOCAL_SITE_SLUG>`

---

For additional troubleshooting or advanced configuration, refer to the [Dev Containers documentation](https://code.visualstudio.com/docs/devcontainers/containers).
