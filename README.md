# Municipio Deployment
This repository simplifies the deplyment for third party users of Municpio. Simply fork this repository and setup deployment detials for your hosting environment and deploy-by-merge whenever it suites you. 

This will enshure that deployments can be made by fetching the upstream of the forked repository without any technical knowledge. Guide on hot to fetch a upstream repo with github user interface can be found here: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/syncing-a-fork.

## How it works
1. Fork this repository.
2. Setup deployment details according to the tables below (source:  https://github.com/helsingborg-stad/municipio-deploy/tree/master/3.0).
3. Update to upstream, whenever you want to update your production enviroment with the latest version of Municipio.

## Parameters
Add the folowing secrets to your github repository secrets section (https://docs.github.com/en/actions/security-guides/encrypted-secrets). We do recommend that you assign these secrets locally to your repository. You can however use organization level secret to evrything except the path, if you determine that they will persist. 

### Configuration - Production
Used for branch names: production, master

| Secret name                     | Description                                                                  | Required |
|---------------------------------|------------------------------------------------------------------------------|----------|
| DEPLOY_REMOTE_HOST_PROD         | Host domain or ip                                                            | true     |
| DEPLOY_REMOTE_PATH_PROD         | Host deployment path                                                         | true     |
| DEPLOY_REMOTE_BACKUP_DIR_PROD   | Host rsync backup path                                                       | true     |
| DEPLOY_REMOTE_USER_PROD         | Host deploy ssh user name                                                    | true     |
| DEPLOY_KEY_PROD                 | Host deploy ssh user key                                                     | true     |
| WEB_SERVER_USER_PROD            | Host web server user                                                         | true     |
| GITHUB_TOKEN                    | Github token for github npm package usage, use built in secrets.GITHUB_TOKEN | true     |
| ACF URL                         | A url where a zip-file with ACF PRO can be found (ACF provides a url).       | true     |

### Configuration - Stage
Used for branch names: stage, beta, test

| Secret name                     | Description                                                                  | Required |
|---------------------------------|------------------------------------------------------------------------------|----------|
| DEPLOY_REMOTE_HOST_STAGE        | Host domain or ip                                                            | true     |
| DEPLOY_REMOTE_PATH_STAGE        | Host deployment path                                                         | true     |
| DEPLOY_REMOTE_BACKUP_DIR_STAGE  | Host rsync backup path                                                       | true     |
| DEPLOY_REMOTE_USER_STAGE        | Host deploy ssh user name                                                    | true     |
| DEPLOY_KEY_STAGE                | Host deploy ssh user key                                                     | true     |
| WEB_SERVER_USER_STAGE           | Host web server user                                                         | true     |
| GITHUB_TOKEN                    | Github token for github npm package usage, use built in secrets.GITHUB_TOKEN | true     |
| ACF URL                         | A url where a zip-file with ACF PRO can be found (ACF provides a url).       | true     |