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

## Adding custom dependencies
You may add your own dependencies in composer.local.json file. This file is automatically read in build. We have made it a separate file to avoid merge conflicts. When you have modified the composer.local.json; the deploy script will remove the composer lockfile automatically. This may cause a less performant deploy. 

You may also add plugins locally to your server with the folder name of the plugin prefixed with "local_". Normally they would be removed during the deploy to enshure one source of truth, however the deploy script will respect the "local_" string and keep them. 

## Parameters
Add the following secrets to your github repository secrets section (https://docs.github.com/en/actions/security-guides/encrypted-secrets). We do recommend that you assign these secrets locally to your repository. You can however use organization level secret to everything except the path if you determine that they will persist. 

### Configuration - Production
Used for branch names: production, master

| Secret name                     | Description                                                                  | Required |
|---------------------------------|------------------------------------------------------------------------------|----------|
| DEPLOY_REMOTE_HOST_PROD         | Host domain or ip                                                            | true     |
| DEPLOY_REMOTE_PATH_PROD         | Host deployment path                                                         | true     |
| DEPLOY_REMOTE_BACKUP_DIR_PROD   | Host rsync backup path                                                       | true     |
| DEPLOY_REMOTE_USER_PROD         | Host deploy ssh user name (In sudoers with nopassword enabled)               | true     |
| DEPLOY_KEY_PROD                 | Host deploy ssh user key (Private part of ssh key)                           | true     |
| WEB_SERVER_USER_PROD            | Host web server user                                                         | true     |
| PHP_VERSION                     | What version of PHP that should be used (target env, build)                  | true     |
| GITHUB_TOKEN                    | Github token for github npm package usage, use built in secrets.GITHUB_TOKEN | true     |
| ACF URL                         | A url where a zip-file with ACF PRO can be found (ACF provides a url).       | true     |

### Configuration - Stage
Used for branch names: stage, beta, test

| Secret name                     | Description                                                                  | Required |
|---------------------------------|------------------------------------------------------------------------------|----------|
| DEPLOY_REMOTE_HOST_STAGE        | Host domain or ip                                                            | true     |
| DEPLOY_REMOTE_PATH_STAGE        | Host deployment path                                                         | true     |
| DEPLOY_REMOTE_BACKUP_DIR_STAGE  | Host rsync backup path                                                       | true     |
| DEPLOY_REMOTE_USER_STAGE        | Host deploy ssh user name (In sudoers with nopassword enabled)               | true     |
| DEPLOY_KEY_STAGE                | Host deploy ssh user key (Private part of ssh key)                           | true     |
| WEB_SERVER_USER_STAGE           | Host web server user                                                         | true     |
| PHP_VERSION                     | What version of PHP that should be used (target env, build)                  | true     |
| GITHUB_TOKEN                    | Github token for github npm package usage, use built in secrets.GITHUB_TOKEN | true     |
| ACF URL                         | A url where a zip-file with ACF PRO can be found (ACF provides a url).       | true     |

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
If you want to add a package, register it using Composer as usual (see the Composer require command: https://getcomposer.org/doc/03-cli.md#require-r).
In some cases, Composer may fail due to dependency conflicts caused by leftover local cache or build artifacts. If this happens, run the composer update-lockfile command. This will execute Composer inside an isolated container and automatically clear any leftover residue from previous runs. The lockfile MUST be committed in all cases. 

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
