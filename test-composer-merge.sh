#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
test_dir="$(mktemp -d)"
trap 'rm -rf "$test_dir"' EXIT
cp "$script_dir/composer-local-merge.php" "$test_dir/"
cp "$script_dir/build-pre.php" "$test_dir/"
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
test "$(php composer-local-merge.php manifest)" = composer.json
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
if php composer-local-merge.php validate --no-check-publish; then
    echo "Validation unexpectedly accepted a missing local lock" >&2
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
test "$(php composer-local-merge.php manifest)" = .composer-local.generated.json
php composer-local-merge.php show example/override --format=json | php -r '$package=json_decode(stream_get_contents(STDIN), true); exit($package["name"] === "example/override" ? 0 : 1);'
php composer-local-merge.php config vendor-dir --absolute | grep -q '/vendor$'
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
if php composer-local-merge.php reinstall example/override --no-interaction --no-progress; then
    echo "Reinstall unexpectedly accepted changed repositories" >&2
    exit 1
fi
if php composer-local-merge.php prohibits example/override 3.0.0; then
    echo "Blocker query unexpectedly accepted changed repositories" >&2
    exit 1
fi
cp original-local.json composer.local.json
cmp .composer-local.generated.lock original-local.lock

# The shared GitHub deployment action runs the legacy pre/install/post steps.
touch github-env
GITHUB_ENV="$test_dir/github-env" php composer-local-merge.php pre-install
grep -qx 'COMPOSER=.composer-local.generated.json' github-env
GITHUB_ENV="$test_dir/github-env" php build-pre.php
test "$(tail -1 github-env)" = 'COMPOSER=.composer-local.generated.json'
if GITHUB_ENV= php build-pre.php; then
    echo "Legacy build preparation unexpectedly ran outside GitHub Actions" >&2
    exit 1
fi
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

# Select and reinstall a package declared only in the local development requirements.
mkdir -p "$test_dir/dev-project/package"
cd "$test_dir/dev-project/package"
git init -q -b main
cat > composer.json <<'JSON'
{"name":"helsingborg-stad/local-dev-test","version":"1.0.0","type":"library"}
JSON
git add composer.json
git -c user.name='Composer Test' -c user.email='composer-test@example.invalid' commit -qm 'Create fixture package'
cd "$test_dir/dev-project"
cp "$script_dir/composer-local-merge.php" .
cp "$script_dir/.devcontainer/scripts/dev-package/select-dev-package.sh" .
cat > composer.json <<'JSON'
{
  "name": "example/dev-project",
  "description": "Development selection fixture",
  "license": "MIT",
  "repositories": [{"packagist.org": false}],
  "require": {},
  "extra": {"installer-paths": {}},
  "scripts": {
    "dev-test": "bash select-dev-package.sh --package helsingborg-stad/local-dev-test --no-editor ."
  }
}
JSON
cat > composer.local.json <<'JSON'
{
  "repositories": [{"type": "path", "url": "package", "options": {"symlink": true}}],
  "require-dev": {"helsingborg-stad/local-dev-test": "1.0.0"}
}
JSON
php composer-local-merge.php update --no-interaction --no-progress
bash "$script_dir/.devcontainer/scripts/dev-package/select-dev-package.sh" \
    --package helsingborg-stad/local-dev-test --no-editor "$test_dir/dev-project"
composer dev-test
if bash "$script_dir/.devcontainer/scripts/dev-package/select-dev-package.sh" \
    --package helsingborg-stad/missing --no-editor "$test_dir/dev-project"; then
    echo "Selecting an undeclared package unexpectedly succeeded" >&2
    exit 1
fi

# The root blocker query must use the combined manifest, not just composer.json.
mkdir "$test_dir/bin"
cat > "$test_dir/bin/gh" <<'SH'
#!/usr/bin/env bash
test "$1" = auth && test "$2" = status
SH
chmod +x "$test_dir/bin/gh"
PATH="$test_dir/bin:$PATH" bash "$script_dir/.devcontainer/scripts/updateSubPackage.sh" \
    --package=helsingborg-stad/local-dev-test --version=2.0.0 \
    <<< 'n' > blocker-output.log
if ! grep -q 'example/dev-project' blocker-output.log; then
    echo "The blocker query omitted the local root requirement" >&2
    cat blocker-output.log >&2
    exit 1
fi

# The updater also supports a child project without the deployment wrapper.
cd "$test_dir/dev-project/package"
PATH="$test_dir/bin:$PATH" bash "$script_dir/.devcontainer/scripts/updateSubPackage.sh" \
    --package=example/missing --version=2.0.0 > "$test_dir/child-blocker-output.log"
grep -q 'No blockers found' "$test_dir/child-blocker-output.log"

echo "Composer local integration tests passed."
