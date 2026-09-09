#!/usr/bin/env bash

set -u

# ============================================================
# Configuration / state
# ============================================================

PACKAGE=""
VERSION=""
AUTO_APPROVE=false

SUCCESSFUL=()
FAILED=()
SKIPPED=()
BLOCKERS=()

# ============================================================
# Help
# ============================================================

usage() {
    cat <<EOF
Usage:
  $0 --package='helsingborg-stad/wputilservice' --version='^0.3'

Options:
  --package   Existing Composer dependency to update.
  --version   Target Composer version constraint.
  -h, --help  Show this help.

Example:
  $0 \
    --package='helsingborg-stad/wputilservice' \
    --version='^0.3'
EOF
}

# ============================================================
# Helpers
# ============================================================

strip_ansi() {
    sed $'s/\033\\[[0-9;]*m//g'
}

safe_slug() {
    echo "$1" \
        | tr '/' '-' \
        | tr -cd '[:alnum:]._-'
}

find_composer_root() {
    local dir
    dir="$(pwd)"

    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/composer.json" ]]; then
            echo "$dir"
            return 0
        fi

        dir="$(dirname "$dir")"
    done

    return 1
}

detect_default_branch() {
    local repo="$1"
    local branch=""

    branch=$(
        git -C "$repo" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null \
            | sed 's#^refs/remotes/origin/##' \
            || true
    )

    if [[ -n "$branch" ]]; then
        echo "$branch"
        return 0
    fi

    if git -C "$repo" show-ref \
        --verify \
        --quiet refs/remotes/origin/main; then

        echo "main"
        return 0
    fi

    if git -C "$repo" show-ref \
        --verify \
        --quiet refs/remotes/origin/master; then

        echo "master"
        return 0
    fi

    return 1
}

dependency_section() {
    local composer_json="$1"
    local package="$2"

    php -r '
        $file = $argv[1];
        $package = $argv[2];

        $json = json_decode(file_get_contents($file), true);

        if (!is_array($json)) {
            exit(2);
        }

        if (
            isset($json["require"]) &&
            array_key_exists($package, $json["require"])
        ) {
            echo "require";
            exit(0);
        }

        if (
            isset($json["require-dev"]) &&
            array_key_exists($package, $json["require-dev"])
        ) {
            echo "require-dev";
            exit(0);
        }

        exit(1);
    ' "$composer_json" "$package"
}

dependency_constraint() {
    local composer_json="$1"
    local package="$2"

    php -r '
        $file = $argv[1];
        $package = $argv[2];

        $json = json_decode(file_get_contents($file), true);

        if (!is_array($json)) {
            exit(2);
        }

        foreach (["require", "require-dev"] as $section) {
            if (
                isset($json[$section]) &&
                array_key_exists($package, $json[$section])
            ) {
                echo $json[$section][$package];
                exit(0);
            }
        }

        exit(1);
    ' "$composer_json" "$package"
}

local_blockers() {
    local root="$1"
    local package="$2"

    find "$root" \
        -type d -name vendor -prune \
        -o -type f -name composer.json -print0 \
        | while IFS= read -r -d '' composer_json; do
            php -r '
                $file = $argv[1];
                $package = $argv[2];
                $json = json_decode(file_get_contents($file), true);

                if (!is_array($json) || empty($json["name"])) {
                    exit(0);
                }

                foreach (["require", "require-dev"] as $section) {
                    if (
                        isset($json[$section]) &&
                        array_key_exists($package, $json[$section])
                    ) {
                        echo $json["name"] . "\n";
                        exit(0);
                    }
                }
            ' "$composer_json" "$package"
        done
}

local_package_path() {
    local root="$1"
    local package="$2"

    find "$root" \
        -type d -name vendor -prune \
        -o -type f -name composer.json -print0 \
        | while IFS= read -r -d '' composer_json; do
            if [[ "$(php -r '
                $json = json_decode(file_get_contents($argv[1]), true);
                echo is_array($json) && ($json["name"] ?? "") === $argv[2]
                    ? "yes"
                    : "no";
            ' "$composer_json" "$package")" == "yes" ]]; then
                dirname "$composer_json"
                return 0
            fi
        done
}

print_summary() {
    echo
    echo "============================================================"
    echo "Summary"
    echo "============================================================"
    echo

    if [[ ${#SUCCESSFUL[@]} -gt 0 ]]; then
        echo "Pull requests created:"
        echo

        for item in "${SUCCESSFUL[@]}"; do
            echo "  ✓ $item"
        done

        echo
    fi

    if [[ ${#FAILED[@]} -gt 0 ]]; then
        echo "Failed:"
        echo

        for item in "${FAILED[@]}"; do
            echo "  ✗ $item"
        done

        echo
    fi

    if [[ ${#SKIPPED[@]} -gt 0 ]]; then
        echo "Skipped:"
        echo

        for item in "${SKIPPED[@]}"; do
            echo "  ⊘ $item"
        done

        echo
    fi

    echo "Created: ${#SUCCESSFUL[@]}"
    echo "Failed:  ${#FAILED[@]}"
    echo "Skipped: ${#SKIPPED[@]}"
    echo
}

fail_package() {
    local blocker="$1"
    local reason="$2"

    echo
    echo "ERROR: $reason"
    echo

    FAILED+=("$blocker — $reason")
}

# ============================================================
# Parse arguments
# ============================================================

for arg in "$@"; do
    case "$arg" in

        --package=*)
            PACKAGE="${arg#*=}"
            PACKAGE="${PACKAGE%\"}"
            PACKAGE="${PACKAGE#\"}"
            PACKAGE="${PACKAGE%\'}"
            PACKAGE="${PACKAGE#\'}"
            ;;

        --version=*)
            VERSION="${arg#*=}"
            VERSION="${VERSION%\"}"
            VERSION="${VERSION#\"}"
            VERSION="${VERSION%\'}"
            VERSION="${VERSION#\'}"
            ;;

        --help|-h)
            usage
            exit 0
            ;;

        *)
            echo "Unknown argument: $arg"
            echo
            usage
            exit 1
            ;;
    esac
done

if [[ -z "$PACKAGE" || -z "$VERSION" ]]; then
    usage
    exit 1
fi

# ============================================================
# Required tools
# ============================================================

for cmd in composer git gh php; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: Required command not found: $cmd"
        exit 1
    fi
done

if ! gh auth status >/dev/null 2>&1; then
    echo "ERROR: GitHub CLI is not authenticated."
    echo
    echo "Run:"
    echo
    echo "  gh auth login"
    echo
    exit 1
fi

# ============================================================
# Find Composer project root
# ============================================================

PROJECT_ROOT="$(find_composer_root)" || {
    echo "ERROR: Could not find composer.json in the current or any parent directory."
    exit 1
}

cd "$PROJECT_ROOT" || exit 1

# ============================================================
# Project configuration
# ============================================================

VENDOR_DIR="$(composer config vendor-dir --absolute)"

SAFE_PACKAGE="$(safe_slug "$PACKAGE")"
SAFE_VERSION="$(safe_slug "$VERSION")"

WORK_BRANCH="update/${SAFE_PACKAGE}-${SAFE_VERSION}"

echo
echo "============================================================"
echo "Composer blocker updater"
echo "============================================================"
echo
echo "Project root:  $PROJECT_ROOT"
echo "Package:       $PACKAGE"
echo "Version:       $VERSION"
echo "Work branch:   $WORK_BRANCH"
echo "Vendor dir:    $VENDOR_DIR"
echo

# ============================================================
# Find blockers
# ============================================================

echo "Finding blockers..."
echo

BLOCKER_OUTPUT="$(
    composer prohibits "$PACKAGE" "$VERSION" 2>&1 || true
)"

echo "$BLOCKER_OUTPUT"
echo

# ------------------------------------------------------------
# Extract blockers
#
# Composer wraps long dependency names in narrow terminals. The flat output's
# first column still starts each blocker row with a package name and version.
# ------------------------------------------------------------

while IFS= read -r blocker; do
    if [[ -n "$blocker" ]]; then
        BLOCKERS+=("$blocker")
    fi
done < <(
    echo "$BLOCKER_OUTPUT" \
        | strip_ansi \
    | grep -E '^[[:space:]]*[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+[[:space:]]+[0-9]' \
    | grep -Eo '[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+' \
        | grep -v "^${PACKAGE}$" \
        | sort -u
)

if [[ ${#BLOCKERS[@]} -eq 0 ]]; then
    while IFS= read -r blocker; do
        if [[ -n "$blocker" && "$blocker" != "$PACKAGE" ]]; then
            BLOCKERS+=("$blocker")
        fi
    done < <(
        local_blockers "$PROJECT_ROOT" "$PACKAGE" \
            | sort -u
    )
fi

if [[ ${#BLOCKERS[@]} -eq 0 ]]; then
    echo "No blockers found for:"
    echo
    echo "  $PACKAGE $VERSION"
    echo
    exit 0
fi

# ============================================================
# Show blocker list
# ============================================================

echo "============================================================"
echo "Detected blockers"
echo "============================================================"
echo

for blocker in "${BLOCKERS[@]}"; do
    echo "  - $blocker"
done

echo
echo "Total: ${#BLOCKERS[@]}"
echo

read -r -p "Continue? [y/N] " answer

if [[ ! "$answer" =~ ^[Yy]$ ]]; then
    exit 0
fi

# ============================================================
# Process blockers
# ============================================================

for i in "${!BLOCKERS[@]}"; do

    BLOCKER="${BLOCKERS[$i]}"
    NUMBER=$((i + 1))

    echo
    echo "============================================================"
    echo "[$NUMBER/${#BLOCKERS[@]}] $BLOCKER"
    echo "============================================================"
    echo

    PACKAGE_PATH="$(
        composer show --path "$BLOCKER" 2>/dev/null \
            | sed -n "s#^[[:space:]]*${BLOCKER}[[:space:]]*##p" \
            | head -n 1
    )"

    if [[ -z "$PACKAGE_PATH" ]]; then
        PACKAGE_PATH="$(local_package_path "$PROJECT_ROOT" "$BLOCKER")"
    fi

    if [[ -z "$PACKAGE_PATH" ]]; then
        PACKAGE_PATH="${VENDOR_DIR}/${BLOCKER}"
    fi

    if [[ -d "$PACKAGE_PATH/.git" ]]; then
        echo "Resetting Git package before reinstall:"
        echo
        git -C "$PACKAGE_PATH" reset --hard HEAD
        git -C "$PACKAGE_PATH" clean -fd
        echo
    fi

    # --------------------------------------------------------
    # Reinstall package as source
    # --------------------------------------------------------

    echo "Reinstalling package as source..."
    echo

    if ! composer reinstall \
        "$BLOCKER" \
        --prefer-source \
        --ignore-platform-reqs \
        --no-interaction; then

        fail_package "$BLOCKER" "composer reinstall failed"
        continue
    fi

    if [[ ! -d "$PACKAGE_PATH" ]]; then
        fail_package \
            "$BLOCKER" \
            "package directory not found: $PACKAGE_PATH"

        continue
    fi

    if [[ ! -d "$PACKAGE_PATH/.git" ]]; then
        fail_package \
            "$BLOCKER" \
            "package was not installed as a Git source checkout"

        continue
    fi

    if [[ ! -f "$PACKAGE_PATH/composer.json" ]]; then
        fail_package \
            "$BLOCKER" \
            "composer.json not found in package"

        continue
    fi

    # --------------------------------------------------------
    # Fetch repository
    # --------------------------------------------------------

    echo
    echo "Fetching repository..."
    echo

    if ! git -C "$PACKAGE_PATH" fetch origin --tags --prune; then
        fail_package "$BLOCKER" "git fetch failed"
        continue
    fi

    # --------------------------------------------------------
    # Detect default branch
    # --------------------------------------------------------

    DEFAULT_BRANCH="$(detect_default_branch "$PACKAGE_PATH" || true)"

    if [[ -z "$DEFAULT_BRANCH" ]]; then
        fail_package "$BLOCKER" "could not detect default branch"
        continue
    fi

    echo "Default branch:"
    echo
    echo "  $DEFAULT_BRANCH"
    echo

    # --------------------------------------------------------
    # Checkout default branch
    # --------------------------------------------------------

    if git -C "$PACKAGE_PATH" show-ref \
        --verify \
        --quiet \
        "refs/heads/$DEFAULT_BRANCH"; then

        if ! git -C "$PACKAGE_PATH" checkout "$DEFAULT_BRANCH"; then
            fail_package \
                "$BLOCKER" \
                "could not checkout $DEFAULT_BRANCH"

            continue
        fi

    else

        if ! git -C "$PACKAGE_PATH" checkout \
            -b "$DEFAULT_BRANCH" \
            "origin/$DEFAULT_BRANCH"; then

            fail_package \
                "$BLOCKER" \
                "could not create local $DEFAULT_BRANCH"

            continue
        fi
    fi

    # --------------------------------------------------------
    # Reset to latest origin/default
    # --------------------------------------------------------

    if ! git -C "$PACKAGE_PATH" reset \
        --hard \
        "origin/$DEFAULT_BRANCH"; then

        fail_package \
            "$BLOCKER" \
            "could not reset $DEFAULT_BRANCH"

        continue
    fi

    if ! git -C "$PACKAGE_PATH" clean -fd; then
        fail_package "$BLOCKER" "git clean failed"
        continue
    fi

    # --------------------------------------------------------
    # Verify dependency already exists
    # --------------------------------------------------------

    DEPENDENCY_SECTION="$(
        dependency_section \
            "$PACKAGE_PATH/composer.json" \
            "$PACKAGE" \
            || true
    )"

    if [[ -z "$DEPENDENCY_SECTION" ]]; then
        fail_package \
            "$BLOCKER" \
            "$PACKAGE does not exist in require or require-dev"

        continue
    fi

    echo "Dependency found in:"
    echo
    echo "  $DEPENDENCY_SECTION"
    echo

        CURRENT_VERSION="$(
        dependency_constraint \
            "$PACKAGE_PATH/composer.json" \
            "$PACKAGE" \
            || true
    )"

    if [[ "$CURRENT_VERSION" == "$VERSION" ]]; then
        echo "Dependency already uses the requested constraint:"
        echo
        echo "  $PACKAGE: $CURRENT_VERSION"
        echo

        SKIPPED+=("$BLOCKER — dependency already aligned")

        continue
    fi

    # --------------------------------------------------------
    # Create/reset update branch
    # --------------------------------------------------------

    if git -C "$PACKAGE_PATH" show-ref \
        --verify \
        --quiet \
        "refs/heads/$WORK_BRANCH"; then

        git -C "$PACKAGE_PATH" branch \
            -D "$WORK_BRANCH" \
            >/dev/null 2>&1 \
            || true
    fi

    if ! git -C "$PACKAGE_PATH" checkout \
        -b "$WORK_BRANCH"; then

        fail_package \
            "$BLOCKER" \
            "could not create work branch"

        continue
    fi

    echo "Created branch:"
    echo
    echo "  $WORK_BRANCH"
    echo

    # --------------------------------------------------------
    # Update composer.json
    # --------------------------------------------------------

    echo "Updating Composer constraint:"
    echo
    echo "  $PACKAGE"
    echo "  -> $VERSION"
    echo

    COMPOSER_REQUIRE_ARGS=(
        require
        --no-update
        --no-interaction
    )

    if [[ "$DEPENDENCY_SECTION" == "require-dev" ]]; then
        COMPOSER_REQUIRE_ARGS+=(--dev)
    fi

    COMPOSER_REQUIRE_ARGS+=(
        --
        "${PACKAGE}:${VERSION}"
    )

    if ! (
        cd "$PACKAGE_PATH" &&
        composer "${COMPOSER_REQUIRE_ARGS[@]}"
    ); then
        fail_package \
            "$BLOCKER" \
            "composer require --no-update failed"

        continue
    fi

    # --------------------------------------------------------
    # Update dependency + lockfile
    # --------------------------------------------------------

    echo
    echo "Updating dependency and lock file..."
    echo

    if ! (
        cd "$PACKAGE_PATH" &&
        composer update \
            --with-all-dependencies \
            --ignore-platform-reqs \
            --no-interaction \
            -- \
            "$PACKAGE"
    ); then
        fail_package \
            "$BLOCKER" \
            "composer update failed"

        continue
    fi

    # --------------------------------------------------------
    # Validate install
    # --------------------------------------------------------

    echo
    echo "Validating composer install..."
    echo

    if ! (
        cd "$PACKAGE_PATH" &&
        composer install \
            --ignore-platform-reqs \
            --no-interaction
    ); then
        fail_package \
            "$BLOCKER" \
            "composer install failed"

        continue
    fi

    # --------------------------------------------------------
    # Validate Composer configuration
    # --------------------------------------------------------

    echo
    echo "Validating composer.json..."
    echo

    if ! (
        cd "$PACKAGE_PATH" &&
        composer validate \
            --no-interaction
    ); then
        fail_package \
            "$BLOCKER" \
            "composer validate failed"

        continue
    fi

    # --------------------------------------------------------
    # Show change summary
    # --------------------------------------------------------

    echo
    echo "============================================================"
    echo "Changes for $BLOCKER"
    echo "============================================================"
    echo

    echo "Updated dependency:"
    echo
    echo "  $PACKAGE: $CURRENT_VERSION -> $VERSION"
    echo
    echo "Changed files:"
    echo

    while IFS= read -r changed_file; do
        if [[ -n "$changed_file" ]]; then
            echo "  - $changed_file"
        fi
    done < <(
        git -C "$PACKAGE_PATH" diff --name-only
        git -C "$PACKAGE_PATH" diff --cached --name-only
    | sort -u
    )

    echo

    # --------------------------------------------------------
    # Nothing changed
    # --------------------------------------------------------

    if git -C "$PACKAGE_PATH" diff --quiet && \
       git -C "$PACKAGE_PATH" diff --cached --quiet; then

        echo "No changes detected."

        SKIPPED+=("$BLOCKER — no changes")

        continue
    fi

    # --------------------------------------------------------
    # User action
    # --------------------------------------------------------

    ACTION=""

    if [[ "$AUTO_APPROVE" == true ]]; then

        ACTION="p"

    else

        echo "Action:"
        echo
        echo "  [p] Push + create PR"
        echo "  [s] Skip"
        echo "  [a] Push this and automatically approve remaining packages"
        echo "  [q] Quit"
        echo

        read -r -p "> " ACTION
    fi

    case "$ACTION" in

        p|P)
            ;;

        a|A)
            AUTO_APPROVE=true
            ;;

        s|S|"")
            echo
            echo "Skipping $BLOCKER."

            SKIPPED+=("$BLOCKER")

            continue
            ;;

        q|Q)
            echo
            echo "Stopping."

            print_summary

            exit 0
            ;;

        *)
            echo
            echo "Unknown action. Skipping."

            SKIPPED+=("$BLOCKER")

            continue
            ;;
    esac

    # --------------------------------------------------------
    # Commit changes
    # --------------------------------------------------------

    COMMIT_MESSAGE="Update ${PACKAGE} constraint to ${VERSION}"

    echo
    echo "Creating commit..."
    echo
    echo "  $COMMIT_MESSAGE"
    echo

    git -C "$PACKAGE_PATH" add composer.json

    if [[ -f "$PACKAGE_PATH/composer.lock" ]]; then
        git -C "$PACKAGE_PATH" add composer.lock
    fi

    if ! git -C "$PACKAGE_PATH" commit \
        -m "$COMMIT_MESSAGE"; then

        fail_package \
            "$BLOCKER" \
            "git commit failed"

        continue
    fi

    # --------------------------------------------------------
    # Push work branch
    # --------------------------------------------------------

    echo
    echo "Pushing branch:"
    echo
    echo "  $WORK_BRANCH"
    echo

    if ! git -C "$PACKAGE_PATH" push \
        --force-with-lease \
        -u origin "$WORK_BRANCH"; then

        fail_package \
            "$BLOCKER" \
            "git push failed"

        continue
    fi

    # --------------------------------------------------------
    # Pull request
    # --------------------------------------------------------

    PR_TITLE="Update ${PACKAGE} to ${VERSION}"

    PR_BODY="$(cat <<EOF
## Summary

Updates the \`${PACKAGE}\` dependency constraint to \`${VERSION}\`.

## Changes

- Updated the existing \`${PACKAGE}\` dependency constraint to \`${VERSION}\`
- Updated \`composer.lock\` where applicable
- Ran \`composer update ${PACKAGE} --with-all-dependencies\`
- Ran \`composer install\`
- Ran \`composer validate\`

This change removes this package as a blocker for upgrading \`${PACKAGE}\` to \`${VERSION}\`.
EOF
)"

    echo
    echo "Creating GitHub pull request..."
    echo

    PR_URL="$(
        cd "$PACKAGE_PATH" &&
        gh pr create \
            --base "$DEFAULT_BRANCH" \
            --head "$WORK_BRANCH" \
            --title "$PR_TITLE" \
            --body "$PR_BODY" \
            2>&1
    )"

    PR_EXIT=$?

    if [[ $PR_EXIT -ne 0 ]]; then

        echo "$PR_URL"

        fail_package \
            "$BLOCKER" \
            "GitHub PR creation failed"

        continue
    fi

    echo
    echo "✓ PR created:"
    echo
    echo "  $PR_URL"
    echo

    SUCCESSFUL+=("$BLOCKER — $PR_URL")
done

# ============================================================
# Final summary
# ============================================================

print_summary