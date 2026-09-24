#!/usr/bin/env bash

#############################################################################
# Local Development Setup Script
# Sets up the local site from scratch (resets database and configuration)
#############################################################################

set -e  # Exit on error
set -u  # Exit on undefined variable

### LOAD ENVIRONMENT ###
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVCONTAINER_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$DEVCONTAINER_DIR")"
ENV_FILE="${DEVCONTAINER_DIR}/.env"

cd "$PROJECT_ROOT"

if [[ -f "$ENV_FILE" ]]; then
    set -a  # Automatically export all variables
    source "$ENV_FILE"
    set +a
else
    echo "Warning: $ENV_FILE not found. Using existing environment variables." >&2
fi

### CONFIGURATION ###
LOCAL_SITE_DOMAIN="localhost:8080"
LOCAL_SITE_URL="http://${LOCAL_SITE_DOMAIN}"

# Install as "single" or "multisite" (subfolder network). Override with SITE_TYPE env var.
SITE_TYPE="${SITE_TYPE:-}"

# WordPress admin/site defaults, overridable via .devcontainer/.env
SITE_TITLE="${SITE_TITLE:-Municipio Local}"
ADMIN_USER="${ADMIN_USER:-superadmin}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-superadmin}"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@example.com}"

# Standard plugins to activate after a fresh install (network-activated in multisite mode).
# ACF Pro is installed as an MU plugin and is active automatically.
REQUIRED_PLUGINS=("s3-uploads" "s3-local-index" "redis-cache" "litespeed-cache" "municipio-clone")

#############################################################################
# Helper Functions
#############################################################################

print_header() {
    echo ""
    echo "=========================================="
    echo "  $1"
    echo "=========================================="
}

print_success() {
    echo "✓ $1"
}

print_error() {
    echo "✗ ERROR: $1" >&2
}

print_info() {
    echo "→ $1"
}

print_warning() {
    echo "⚠️  $1"
}

# Retry a command a few times: freshly composer-installed plugin files can be
# momentarily invisible to wp-cli on the virtiofs-mounted workspace, which
# makes activation fail with e.g. "No plugins network activated."
run_with_retry() {
    local attempt
    for attempt in 1 2 3; do
        if "$@"; then
            return 0
        fi
        wp cache flush --allow-root --skip-plugins --skip-themes || true
        sleep 1
    done
    "$@"
}

# Confirm action with user
confirm_action() {
    local prompt="$1"
    local default="${2:-n}"

    while true; do
        read -p "$prompt [y/n] (default: $default): " choice
        choice=${choice:-$default}
        case "$choice" in
            y|Y|yes|Yes|YES) return 0 ;;
            n|N|no|No|NO) return 1 ;;
            *) echo "Please answer y or n" ;;
        esac
    done
}

# Check if setup has already been run
check_existing_setup() {
    local setup_detected=0

    if [ -f "./.htaccess" ]; then
        setup_detected=1
    fi

    if [ -d "./config" ] && [ "$(ls -A ./config 2>/dev/null)" ]; then
        setup_detected=1
    fi

    echo $setup_detected
}

# Remove multisite constants that wp-cli may have written directly to wp-config.php
# during previous installs. Multisite mode is controlled by config/multisite.php.
remove_root_multisite_config() {
    if [[ ! -f "./wp-config.php" ]]; then
        return
    fi

    php <<'PHP'
<?php
$path = 'wp-config.php';
$contents = file_get_contents($path);
$pattern = <<<'REGEX'
~
\n+\s*define\(\s*['"]WP_ALLOW_MULTISITE['"]\s*,\s*true\s*\)\s*;\s*\n
\s*define\(\s*['"]MULTISITE['"]\s*,\s*true\s*\)\s*;\s*\n
\s*define\(\s*['"]SUBDOMAIN_INSTALL['"]\s*,\s*(?:true|false)\s*\)\s*;\s*\n
(?:\s*\$base\s*=\s*['"][^'"]*['"]\s*;\s*\n)?
\s*define\(\s*['"]DOMAIN_CURRENT_SITE['"]\s*,\s*['"][^'"]+['"]\s*\)\s*;\s*\n
\s*define\(\s*['"]PATH_CURRENT_SITE['"]\s*,\s*['"][^'"]*['"]\s*\)\s*;\s*\n
\s*define\(\s*['"]SITE_ID_CURRENT_SITE['"]\s*,\s*\d+\s*\)\s*;\s*\n
\s*define\(\s*['"]BLOG_ID_CURRENT_SITE['"]\s*,\s*\d+\s*\)\s*;\s*\n
~x
REGEX;
$updated = preg_replace($pattern, "\n", $contents);

if ($updated !== $contents) {
    file_put_contents($path, $updated);
}
PHP
}

# Ask the user whether to install a single site or a subfolder multisite network
prompt_site_type() {
    case "$SITE_TYPE" in
        single|multisite) return ;;
        "") ;;
        *) print_error "SITE_TYPE must be 'single' or 'multisite'."; exit 1 ;;
    esac

    if [[ ! -t 0 ]]; then
        SITE_TYPE="multisite"
        return
    fi

    while true; do
        read -p "Install as (s)ingle site or (m)ultisite subfolder network? [s/m] (default: m): " choice
        choice=${choice:-m}
        case "$choice" in
            s|S|single) SITE_TYPE="single"; return ;;
            m|M|multisite) SITE_TYPE="multisite"; return ;;
            *) echo "Please answer s or m" ;;
        esac
    done
}

#############################################################################
# Main Script
#############################################################################

print_header "Local Development Setup"
echo "This will reset the database and configure the local site."
echo ""

# Check if setup has already been run
if [ "$(check_existing_setup)" -eq 1 ]; then
    print_warning "Setup appears to have been run previously."
    print_info "Running setup again will reset the database and overwrite config files."
    echo ""

    if ! confirm_action "Continue with setup?" "n"; then
        echo "Setup cancelled."
        exit 0
    fi
    echo ""
fi

prompt_site_type
print_info "Site type: ${SITE_TYPE}"

# Step 1: Add required config files
print_header "Adding Config Files"
print_info "Creating config directory..."
mkdir -p ./config
print_info "Removing stale multisite config..."
rm -f ./config/multisite.php
remove_root_multisite_config
print_info "Copying config-example files..."
if [[ "$SITE_TYPE" == "single" ]]; then
    find ./config-example -maxdepth 1 -type f ! -name 'multisite.php' -exec cp {} ./config \;
else
    cp ./config-example/* ./config
fi
print_info "Copying devcontainer wp-config files..."
if [[ "$SITE_TYPE" == "single" ]]; then
    find ./.devcontainer/config/wp-config -maxdepth 1 -type f ! -name 'multisite.php' -exec cp {} ./config \;
else
    cp ./.devcontainer/config/wp-config/* ./config
fi
print_success "Config files added"

# Step 2: Install packages
print_header "Installing Packages"
"$SCRIPT_DIR/setup-dev-package.sh" -y --skip-select
print_success "Packages installed"

# Step 3: Install WordPress
print_header "Installing WordPress (${SITE_TYPE})"
print_info "Resetting database..."
wp cache flush --allow-root --skip-plugins --skip-themes || true
wp db reset --yes --allow-root --skip-plugins --skip-themes

if [[ "$SITE_TYPE" == "multisite" ]]; then
    print_info "Running multisite network install..."
    wp core multisite-install \
        --url="${LOCAL_SITE_URL}" \
        --base=/ \
        --title="${SITE_TITLE}" \
        --admin_user="${ADMIN_USER}" \
        --admin_password="${ADMIN_PASSWORD}" \
        --admin_email="${ADMIN_EMAIL}" \
        --skip-email \
        --skip-plugins \
        --skip-themes \
        --allow-root
else
    print_info "Running single site install..."
    wp core install \
        --url="${LOCAL_SITE_URL}" \
        --title="${SITE_TITLE}" \
        --admin_user="${ADMIN_USER}" \
        --admin_password="${ADMIN_PASSWORD}" \
        --admin_email="${ADMIN_EMAIL}" \
        --skip-email \
        --skip-plugins \
        --skip-themes \
        --allow-root
fi
print_success "WordPress installed"

print_info "Setting home URL to site root..."
wp option update home "${LOCAL_SITE_URL}" --allow-root --url="${LOCAL_SITE_URL}" --quiet --skip-plugins --skip-themes

print_info "Activating required plugins..."
for plugin in "${REQUIRED_PLUGINS[@]}"; do
    # --skip-themes: municipio (the only theme present, loaded via WP_DEFAULT_THEME
    # fallback) hard-fails all wp-cli commands via cli_init until ACF is active.
    if [[ "$SITE_TYPE" == "multisite" ]]; then
        run_with_retry wp plugin activate "$plugin" --network --skip-themes --quiet --allow-root --url="${LOCAL_SITE_URL}"
    else
        run_with_retry wp plugin activate "$plugin" --skip-themes --quiet --allow-root --url="${LOCAL_SITE_URL}"
    fi
done

# Theme activation depends on ACF being active first
print_info "Activating municipio theme..."
if [[ "$SITE_TYPE" == "multisite" ]]; then
    run_with_retry wp theme enable municipio --network --activate --quiet --allow-root --url="${LOCAL_SITE_URL}"
else
    run_with_retry wp theme activate municipio --quiet --allow-root --url="${LOCAL_SITE_URL}"
fi
print_success "Site configured"

# Step 4: Add .htaccess
print_header "Adding .htaccess"
print_info "Copying .htaccess from devcontainer config..."
cp ./.devcontainer/config/.htaccess ./.htaccess
print_success ".htaccess added"

# Step 5: Set up cache directories
print_header "Setting Up Cache"
print_info "Creating blade-cache directory..."
mkdir -p ./wp-content/uploads/cache/blade-cache
print_info "Setting permissions on blade-cache..."
chmod -R 777 ./wp-content/uploads/cache/blade-cache
print_info "Creating fonts directory..."
mkdir -p ./wp-content/fonts
print_info "Setting permissions on fonts directory..."
chmod -R 777 ./wp-content/fonts
print_success "Cache directories configured"

# Step 6: Remove cached fonts
print_header "Cleaning Up"
print_info "Removing cached fonts..."
rm -rf ./wp-content/fonts/*
print_success "Cached fonts removed"

# Step 7: Copy mu-plugins
print_header "Setting Up Must-Use Plugins"
print_info "Copying mu-plugins from devcontainer config..."
mkdir -p ./wp-content/mu-plugins
cp ./.devcontainer/mu-plugins/* ./wp-content/mu-plugins
print_success "Must-Use Plugins set up"

# Step 8

# Final success message
print_header "Setup Complete! 🎉"
echo ""
echo "Your local site is now available at:"
echo "  http://${LOCAL_SITE_DOMAIN}"
echo ""
print_success "All done!"
