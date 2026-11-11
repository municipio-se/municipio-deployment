<!-- SHIELDS -->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![License][license-shield]][license-url]

<p>
  <a href="https://github.com/municipio-se/municipio-deployment">
    <img src="images/municipio.svg" alt="Logo" width="300">
  </a>
</p>
<h3>Municipio (Standard) - Deployment</h3>
<p>
  Simplified deployment of Municipio
  <br />
  <a href="https://github.com/municipio-se/municipio-deployment/issues">Report Bug</a>
  ·
  <a href="https://github.com/municipio-se/municipio-deployment/issues">Request Feature</a>
</p>

## About Municipio (Standard) - Deployment
This repository simplifies the deployment for users of Municpio. Simply fork this repository and setup deployment details for your hosting environment and deploy whenever it suits you. 

This will ensure that deployments can be made by fetching the upstream of the forked repository without any technical knowledge. Guide on how to fetch a upstream repo with github user interface can be found here: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/syncing-a-fork.

## Quick start
1. Fork this repository. Enable github workflows on your newly created repository (gihub disables them due to security reasons on forks).
2. Setup deployment details according to the tables below (source:  https://github.com/helsingborg-stad/municipio-deploy/tree/master/4.0).
3. Update to upstream, whenever you want to update your production enviroment with the latest version of Municipio.

## Container image

The `docker/` directory contains the optional runnable container image and its release workflows. Release candidates are built from eligible semver-titled pull requests; final images are built directly from unprefixed semver source tags. Images publish to `ghcr.io/${{ github.repository }}`, giving each fork its own image path. Configure `ACF_PRO_KEY`, `DOCKERHUB_USERNAME`, and `DOCKERHUB_TOKEN` to enable builds. See the [container image guide](docker/README.md) for tag conventions, permissions, fork setup, and local builds.

## Adding custom dependencies
You may add your own dependencies in the `composer.local.json` file. Add packages to the `require` or `require-dev` sections as needed. You can also add custom `repositories` entries (VCS, package, path, etc.) for packages that are not available on Packagist or wpackagist:

```json
{
  "name": "municipio-se/municipio-deployment-custom",
  "license": "MIT",
  "description": "Additions for your own install of Municipio.",
  "repositories": [
    {
      "type": "vcs",
      "url": "https://github.com/your-org/your-private-plugin"
    }
  ],
  "require": {
    "vendor/package": "^1.0"
  },
  "require-dev": {
    "vendor/dev-package": "^2.0"
  }
}
```

### How it works
Run Composer through the wrapper from the project root:

```bash
php composer-local-merge.php install
```

When `composer.local.json` has no `repositories`, `require`, or `require-dev` entries, the wrapper uses `composer.json` and `composer.lock` as usual. Otherwise, it generates the ignored `.composer-local.generated.json` **before** starting Composer. Local requirements override root constraints for the same package; local repositories take priority over root repositories. Only these three sections are merged.

The combined manifest uses a separate `.composer-local.generated.lock`. To create it or update dependencies after changing either manifest, run:

```bash
php composer-local-merge.php update
git add composer.local.json .composer-local.generated.lock
```

Commit the local lock file in your fork. Installs validate it and fail if it is missing or out of date; they do not resolve new versions implicitly. The original `composer.json` and `composer.lock` are never temporarily modified. Updating local dependencies does not update the upstream lock: maintain `composer.lock` on a branch without local overrides, then update the local lock after merging upstream changes.

The wrapper also accepts `validate`, `show`, `reinstall`, `prohibits`, and `config`, and passes Composer options through, for example `php composer-local-merge.php install --no-dev`. Its `manifest` command prints the selected manifest path. It does not support `composer require`: edit the local requirements and run `update` instead. Do not set `COMPOSER` or change the working directory through wrapper options. Composer hooks reject direct `install` and `update` when local overrides exist; `--no-scripts` bypasses that protection and must not be used to install the root project directly. The `pin-all-latest` script also requires a branch without local overrides, because it updates the upstream manifest and lock.

The Docker and devcontainer builds use the wrapper. The shared GitHub deployment action versions 4.1 and 4.2 support it through their pre-install and post-install steps and `GITHUB_ENV`. Version 4.0 does not run those steps; deployments using it must switch to 4.2 or explicitly run the wrapper. The legacy `build-pre.php` entry point now delegates to the GitHub Actions pre-install step instead of deleting the root lock. Older interrupted runs may have left `.composer-merge-active` and `composer.*.bkup` files: inspect them and restore the original files before upgrading this script.

The Composer local workflow is tested in GitHub Actions on pull requests and pushes to `master`. To run the same offline integration tests locally, use `bash test-composer-merge.sh` with PHP and Composer 2 installed. The tests use temporary fixture packages; they do not install the application's production dependencies.

You may also add plugins locally to your server with the folder name of the plugin prefixed with "local_". Normally they would be removed during the deploy to ensure one source of truth, however the deploy script will respect the "local_" prefix and keep them. 

## Parameters
Add the following secrets to your github repository secrets section (https://docs.github.com/en/actions/security-guides/encrypted-secrets). We do recommend that you assign these secrets locally to your repository. You can however use organization level secret to everything except the path if you determine that they will persist. 

### Configuration - Production
Used for branch names: production, master

| Secret name                     | Description                                                                  | Required |
|---------------------------------|------------------------------------------------------------------------------|----------|
| DEPLOY_REMOTE_HOST_PROD         | Host domain or ip                                                            | true     |
| DEPLOY_REMOTE_PORT_PROD         | SSH port for deployment (defaults to 22 if not specified)                    | false    |
| DEPLOY_REMOTE_PATH_PROD         | Host deployment path                                                         | true     |
| DEPLOY_REMOTE_BACKUP_DIR_PROD   | Host rsync backup path                                                       | true     |
| DEPLOY_REMOTE_USER_PROD         | Host deploy ssh user name (In sudoers with nopassword enabled)               | true     |
| DEPLOY_KEY_PROD                 | Host deploy ssh user key (Private part of ssh key)                           | true     |
| WEB_SERVER_USER_PROD            | Host web server user                                                         | true     |
| PHP_VERSION                     | What version of PHP that should be used (target env, build)                  | true     |
| GITHUB_TOKEN                    | Github token for github npm package usage, use built in secrets.GITHUB_TOKEN | true     |
| ACF_PRO_KEY                     | Advanced Custom Fields Pro Composer key, used to install ACF Pro packages.   | true     |

### Configuration - Stage
Used for branch names: stage, beta, test

| Secret name                     | Description                                                                  | Required |
|---------------------------------|------------------------------------------------------------------------------|----------|
| DEPLOY_REMOTE_HOST_STAGE        | Host domain or ip                                                            | true     |
| DEPLOY_REMOTE_PORT_STAGE        | SSH port for deployment (defaults to 22 if not specified)                    | false    |
| DEPLOY_REMOTE_PATH_STAGE        | Host deployment path                                                         | true     |
| DEPLOY_REMOTE_BACKUP_DIR_STAGE  | Host rsync backup path                                                       | true     |
| DEPLOY_REMOTE_USER_STAGE        | Host deploy ssh user name (In sudoers with nopassword enabled)               | true     |
| DEPLOY_KEY_STAGE                | Host deploy ssh user key (Private part of ssh key)                           | true     |
| WEB_SERVER_USER_STAGE           | Host web server user                                                         | true     |
| PHP_VERSION                     | What version of PHP that should be used (target env, build)                  | true     |
| GITHUB_TOKEN                    | Github token for github npm package usage, use built in secrets.GITHUB_TOKEN | true     |
| ACF_PRO_KEY                     | Advanced Custom Fields Pro Composer key, used to install ACF Pro packages.   | true     |

## Additional Setup
A fully functional website will not be automatically created when this deployment script has been executed. Some local site configuration has to be created in the a ./config/ folder on the the local machine. This is basically a wp-config.php split in multiple files for a better overview of the configuration.

All neccesary configuration-example files can be found in the ./config-example folder in this repository. All files ending in -example.php is optional. To use them, simply remove the '-example' extenstion.

The configuration files should be reviewed in full in order to configure the site to your likings. 

## Contribution
You may contribute to this repository if you feel that anything is missing. Simply send a pull request, and we will review it as soon as possible. 

## Suggested target environment
We do suggest that you include the following softare on the target machine.

- Litespeed (prefered option) / NGINX / Apache
- PHP ^8.3
- Rsync (required for deployment)
- MySQL or MariaDB
- Caddy as a Reverse Proxy (ssl termination etc)

### Optional addons
Municipio runs better with these additional packages, applications and settings. 

- Redis (highly encouraged)
- Imagic (highly encouraged)
- OpCache (highly encouraged)
- S3 Compatible Object storage (Tested with Swift)

### Adding a package
Add custom packages in `composer.local.json` and update and commit the combined lock as described in [Adding custom dependencies](#adding-custom-dependencies). Upstream dependencies belong in `composer.json` and its `composer.lock`.

### Resources
What resources you should give the machine is highly individual depending on your anticipated amount of traffic. But let each PHP process have at least 512MB memory to allocate. This high amount is due to some image processing being made in runtime. 

### Known issues
- Municipio platform do not perform well in highly virtualized platforms sutch as Virtouzzo or Docker containers due to lack in efficiency of disk access. 

## License
Distributed under the [MIT License][license-url].

## Acknowledgements
- [othneildrew Best README Template](https://github.com/othneildrew/Best-README-Template)


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/municipio-se/municipio-deployment.svg?style=flat-square
[contributors-url]: https://github.com/municipio-se/municipio-deployment/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/municipio-se/municipio-deployment.svg?style=flat-square
[forks-url]: https://github.com/municipio-se/municipio-deployment/network/members
[stars-shield]: https://img.shields.io/github/stars/municipio-se/municipio-deployment.svg?style=flat-square
[stars-url]: https://github.com/municipio-se/municipio-deployment/stargazers
[issues-shield]: https://img.shields.io/github/issues/municipio-se/municipio-deployment.svg?style=flat-square
[issues-url]: https://github.com/municipio-se/municipio-deployment/issues
[license-shield]: https://img.shields.io/github/license/municipio-se/municipio-deployment.svg?style=flat-square
[license-url]: https://raw.githubusercontent.com/municipio-se/municipio-deployment/master/LICENSE
