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

---

For additional troubleshooting or advanced configuration, refer to the [Dev Containers documentation](https://code.visualstudio.com/docs/devcontainers/containers).
