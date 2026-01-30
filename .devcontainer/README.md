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

7. **Run setup task**  
    Open the command palette and run the `setup` task.

8. **Access the local site**  
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
.devcontainer/migrate.sh
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

---

For additional troubleshooting or advanced configuration, refer to the [Dev Containers documentation](https://code.visualstudio.com/docs/devcontainers/containers).
