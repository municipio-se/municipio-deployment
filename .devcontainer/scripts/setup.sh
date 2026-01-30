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
LOCAL_SITE_DOMAIN="localhost:8443"

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

# Step 1: Add required config files
print_header "Adding Config Files"
print_info "Creating config directory..."
mkdir -p ./config
print_info "Copying config-example files..."
cp ./config-example/* ./config
print_info "Copying devcontainer wp-config files..."
cp ./.devcontainer/config/wp-config/* ./config
print_success "Config files added"

# Step 2: Install packages
print_header "Installing Packages"
"$SCRIPT_DIR/setup-dev-package.sh" -y --skip-select
print_success "Packages installed"

# Step 3: Install ACF Pro plugin
print_header "Installing ACF Pro Plugin"

if [ -z "${MUNICIPIO_ACF_PRO_KEY:-}" ]; then
    print_error "MUNICIPIO_ACF_PRO_KEY is not set. Please set it in .devcontainer/.env"
    exit 1
fi

ACF_PLUGIN_DIR="/var/www/html/wp-content/plugins/advanced-custom-fields-pro"

if [ -d "$ACF_PLUGIN_DIR" ]; then
    print_success "ACF Pro is already installed"
else
    # Download ACF Pro
    if [ ! -d "/tmp/advanced-custom-fields-pro" ]; then
        print_info "Downloading ACF Pro..."
        ACF_URL="https://connect.advancedcustomfields.com/v2/plugins/download?s=web&p=pro&k=${MUNICIPIO_ACF_PRO_KEY}"
        curl -s -o /tmp/acf-pro.zip "$ACF_URL"
        print_info "Extracting archive..."
        unzip -q -o /tmp/acf-pro.zip -d /tmp
        rm -f /tmp/acf-pro.zip
    fi

    # Install ACF Pro
    if [ -d "/tmp/advanced-custom-fields-pro" ]; then
        print_info "Copying to plugins directory..."
        cp -r /tmp/advanced-custom-fields-pro "$ACF_PLUGIN_DIR"
        print_success "ACF Pro installed"
    else
        print_error "ACF Pro download failed"
        exit 1
    fi
fi

# Step 4: Import database
print_header "Importing Database"
print_info "Resetting database..."
wp db reset --quiet --yes --allow-root --url="${LOCAL_SITE_DOMAIN}"
print_info "Importing seed.sql..."
wp db import ./db/seed.sql --quiet --skip-plugins --skip-themes --allow-root --url="${LOCAL_SITE_DOMAIN}"
print_info "Running search-replace for local domain..."
wp search-replace dev.local.municipio.tech "${LOCAL_SITE_DOMAIN}" --quiet --skip-plugins --skip-themes --network --all-tables --allow-root --url="${LOCAL_SITE_DOMAIN}"
print_success "Database imported"

# Step 5: Add .htaccess
print_header "Adding .htaccess"
print_info "Copying .htaccess from devcontainer config..."
cp ./.devcontainer/config/.htaccess ./.htaccess
print_success ".htaccess added"

# Step 6: Set up cache directories
print_header "Setting Up Cache"
print_info "Creating blade-cache directory..."
mkdir -p ./wp-content/uploads/cache/blade-cache
print_info "Setting permissions on blade-cache..."
chmod -R 766 ./wp-content/uploads/cache/blade-cache
print_success "Cache directories configured"

# Step 7: Remove cached fonts
print_header "Cleaning Up"
print_info "Removing cached fonts..."
rm -rf ./wp-content/fonts
print_success "Cached fonts removed"

# Final success message
print_header "Setup Complete! 🎉"
echo ""
echo "Your local site is now available at:"
echo "  https://${LOCAL_SITE_DOMAIN}"
echo ""
print_success "All done!"
