#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
test_dir="$(mktemp -d)"
trap 'rm -rf "$test_dir"' EXIT
cp "$script_dir/composer-local-merge.php" "$test_dir/"
cd "$test_dir"
export COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_DISABLE_NETWORK=1
unset COMPOSER

cat > composer.json <<'JSON'
{
  "name": "example/project",
  "description": "Offline integration test",
  "license": "MIT",
  "repositories": [
    {"type": "package", "package": {"name": "example/base", "version": "1.0.0", "type": "metapackage"}},
    {"type": "package", "package": {"name": "example/override", "version": "1.0.0", "type": "metapackage"}},
    {"packagist.org": false}
  ],
  "require": {"example/base": "1.0.0", "example/override": "1.0.0"},
  "scripts": {
    "pre-install-cmd": "php composer-local-merge.php guard",
    "pre-update-cmd": "php composer-local-merge.php guard",
    "pin-test": ["php composer-local-merge.php guard", "touch pin-ran"]
  }
}
JSON
printf '{"require": {}}\n' > composer.local.json

# An empty local manifest must use the normal Composer lock.
php composer-local-merge.php update --no-interaction --no-progress
test -f composer.lock
test ! -e .composer-local.generated.json
cp composer.json original.json
cp composer.lock original.lock
php composer-local-merge.php install --no-interaction --no-progress
cmp composer.lock original.lock
touch github-env
GITHUB_ENV="$test_dir/github-env" php composer-local-merge.php pre-install
composer install --no-interaction --no-progress
GITHUB_ENV="$test_dir/github-env" php composer-local-merge.php post-install
tail -1 github-env | grep -qx 'COMPOSER='
rm github-env

cat > composer.local.json <<'JSON'
{
  "repositories": [
    {"type": "package", "package": {"name": "example/override", "version": "2.0.0", "type": "metapackage"}},
    {"type": "package", "package": {"name": "example/dev", "version": "1.0.0", "type": "metapackage"}}
  ],
  "require": {"example/override": "2.0.0"},
  "require-dev": {"example/dev": "1.0.0"}
}
JSON

# Direct Composer and a wrapper install without the local lock must fail.
if composer install --no-interaction --no-progress; then
    echo "Direct Composer unexpectedly accepted local overrides" >&2
    exit 1
fi
if composer update --no-interaction --no-progress; then
    echo "Direct Composer update unexpectedly accepted local overrides" >&2
    exit 1
fi
if composer run pin-test; then
    echo "Pin command unexpectedly accepted local overrides" >&2
    exit 1
fi
test ! -e pin-ran
if php composer-local-merge.php install --no-interaction --no-progress; then
    echo "Install unexpectedly succeeded without a local lock" >&2
    exit 1
fi
cmp composer.json original.json
cmp composer.lock original.lock

# Update resolves both sets of requirements, giving local repositories priority.
php composer-local-merge.php update --no-interaction --no-progress
test -f .composer-local.generated.lock
COMPOSER=.composer-local.generated.json composer show --locked example/override | grep -q '2.0.0'
COMPOSER=.composer-local.generated.json composer show --locked example/dev | grep -q '1.0.0'
cp .composer-local.generated.lock original-local.lock
cp composer.local.json original-local.json
php composer-local-merge.php install --no-interaction --no-progress
cmp .composer-local.generated.lock original-local.lock
cmp composer.json original.json
cmp composer.lock original.lock
php composer-local-merge.php install --no-dev --no-interaction --no-progress
if composer show example/dev >/dev/null 2>&1; then
    echo "Dev dependency was installed with --no-dev" >&2
    exit 1
fi
php composer-local-merge.php install --no-interaction --no-progress
composer show example/dev >/dev/null

# A repository-only change also invalidates the combined lock.
php -r '$data = json_decode(file_get_contents("composer.local.json")); $data->repositories[] = (object) ["type" => "package", "package" => (object) ["name" => "example/extra", "version" => "1.0.0", "type" => "metapackage"]]; file_put_contents("composer.local.json", json_encode($data));'
if php composer-local-merge.php install --no-interaction --no-progress; then
    echo "Install unexpectedly accepted changed repositories" >&2
    exit 1
fi
cp original-local.json composer.local.json
cmp .composer-local.generated.lock original-local.lock

# The shared GitHub deployment action runs the legacy pre/install/post steps.
touch github-env
GITHUB_ENV="$test_dir/github-env" php composer-local-merge.php pre-install
grep -qx 'COMPOSER=.composer-local.generated.json' github-env
COMPOSER=.composer-local.generated.json composer install --no-interaction --no-progress
GITHUB_ENV="$test_dir/github-env" COMPOSER=.composer-local.generated.json php composer-local-merge.php post-install
tail -1 github-env | grep -qx 'COMPOSER='
COMPOSER= composer validate --no-check-publish --no-check-all
cmp composer.json original.json
cmp composer.lock original.lock

# An out-of-date local lock must fail rather than silently omit dependencies.
cat > composer.local.json <<'JSON'
{"require": {"example/base": "2.0.0"}}
JSON
if php composer-local-merge.php install --no-interaction --no-progress; then
    echo "Install unexpectedly accepted an incompatible local lock" >&2
    exit 1
fi
cmp composer.json original.json
cmp composer.lock original.lock
cmp .composer-local.generated.lock original-local.lock

# Repository-only overrides still select the local manifest.
cat > composer.local.json <<'JSON'
{"repositories": [{"type": "package", "package": {"name": "example/extra", "version": "1.0.0", "type": "metapackage"}}]}
JSON
php composer-local-merge.php update --no-interaction --no-progress
php composer-local-merge.php install --no-interaction --no-progress
php -r '$manifest = json_decode(file_get_contents(".composer-local.generated.json")); if (!isset($manifest->repositories->{"local-0"})) { exit(1); }'
cmp composer.json original.json
cmp composer.lock original.lock

# Invalid configuration and failed resolution leave both original files intact.
printf '{"require": []}\n' > composer.local.json
if php composer-local-merge.php update --no-interaction --no-progress; then
    echo "Invalid local requirements were accepted" >&2
    exit 1
fi
printf '{"repositories": null}\n' > composer.local.json
if php composer-local-merge.php update --no-interaction --no-progress; then
    echo "Invalid local repositories were accepted" >&2
    exit 1
fi
printf '{"require": {"example/missing": "1.0.0"}}\n' > composer.local.json
if php composer-local-merge.php update --no-interaction --no-progress > missing-dependency.log 2>&1; then
    echo "Missing dependency unexpectedly resolved" >&2
    cat missing-dependency.log >&2
    exit 1
fi
if ! grep -q 'example/missing' missing-dependency.log; then
    echo "Update failed for an unexpected reason" >&2
    cat missing-dependency.log >&2
    exit 1
fi
cmp composer.json original.json
cmp composer.lock original.lock
touch .composer-merge-active
if php composer-local-merge.php update --no-interaction --no-progress; then
    echo "An interrupted legacy merge was ignored" >&2
    exit 1
fi
echo "Composer local integration tests passed."
