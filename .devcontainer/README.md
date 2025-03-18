# Municipio Deployment Dev Container

Instructions for running the Municipio Deployment Dev Container.

## Prerequisites
* Docker
* VS Code

## Getting started
1. Clone the repository.
1. Open the repository in VS Code.
1. Copy `.devcontainer/.env.example` to `.devcontainer/.env` and fill in the required values.
1. Open the command palette (Cmd+Shift+P) and run `Remote-Containers: Reopen in Container`.
1. Run `composer install --install-npm` in the terminal.
1. Run `php build.php` in the terminal.
1. Open the command palette (Cmd+Shift+P) and run task `setup`.
1. Open the browser and navigate to `https://localhost:8443` to view your local site.

## Accessing the local site
* `username: superadmin`
* `password: superadmin`