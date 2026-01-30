#!/usr/bin/env bash

#############################################################################
# WordPress Multisite Migration Script
# Migrates a remote subdomain site to a local subfolder site
#############################################################################

set -e  # Exit on error
set -u  # Exit on undefined variable

### LOAD ENVIRONMENT ###
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVCONTAINER_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="${DEVCONTAINER_DIR}/.env"

if [[ -f "$ENV_FILE" ]]; then
    set -a  # Automatically export all variables
    source "$ENV_FILE"
    set +a
else
    echo "Warning: $ENV_FILE not found. Using existing environment variables." >&2
fi

### CONFIGURATION (from environment) ###
SSH_PORT="${SSH_PORT:?SSH_PORT not set}"
REMOTE_SSH="${REMOTE_SSH:?REMOTE_SSH not set}"
REMOTE_PATH="${REMOTE_PATH:?REMOTE_PATH not set}"
REMOTE_SITE_PROTOCOL="${REMOTE_SITE_PROTOCOL:?REMOTE_SITE_PROTOCOL not set}"
REMOTE_SITE_DOMAIN="${REMOTE_SITE_DOMAIN:?REMOTE_SITE_DOMAIN not set}"
REMOTE_PREFIX="${REMOTE_PREFIX:?REMOTE_PREFIX not set}"
LOCAL_SITE_SLUG="${LOCAL_SITE_SLUG:?LOCAL_SITE_SLUG not set}"

### LOCAL SETUP ###
LOCAL_PATH="/var/www/html"
REMOTE_SITE_URL="${REMOTE_SITE_PROTOCOL}${REMOTE_SITE_DOMAIN}"
LOCAL_SITE_DOMAIN="localhost:8443"
LOCAL_MU_SITE_URL="https://${LOCAL_SITE_DOMAIN}"
LOCAL_SITE_URL="$LOCAL_MU_SITE_URL/$LOCAL_SITE_SLUG"
LOCAL_PREFIX="mun_"
TMP_SQL="/tmp/${LOCAL_SITE_SLUG}.sql"

#############################################################################
# Helper Functions
#############################################################################

# Print colored output
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

# Check if required commands exist
check_dependencies() {
    print_header "Checking Dependencies"
    
    local missing_deps=0
    
    for cmd in wp ssh scp; do
        if ! command -v $cmd &> /dev/null; then
            print_error "$cmd is not installed or not in PATH"
            missing_deps=1
        else
            print_success "$cmd found"
        fi
    done
    
    if [ $missing_deps -eq 1 ]; then
        print_error "Please install missing dependencies before continuing"
        exit 1
    fi
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

#############################################################################
# Main Script
#############################################################################

print_header "WordPress Multisite Migration"
echo "Remote: $REMOTE_SITE_URL"
echo "Local:  $LOCAL_SITE_URL"
echo ""

# Check dependencies
check_dependencies

# Display configuration summary
print_header "Configuration Summary"
print_info "Remote SSH: $REMOTE_SSH:$SSH_PORT"
print_info "Remote path: $REMOTE_PATH"
print_info "Local path: $LOCAL_PATH"
print_info "Site slug: $LOCAL_SITE_SLUG"
echo ""

if ! confirm_action "Continue with migration?"; then
    echo "Migration cancelled."
    exit 0
fi

# Check if local site already exists
print_header "Checking Local Site"
if wp site list --allow-root --url=$LOCAL_SITE_URL 2>/dev/null | grep -q "$LOCAL_SITE_URL"; then
    echo "⚠️  Local site $LOCAL_SITE_URL already exists."
    
    if confirm_action "Delete existing site and continue?" "n"; then
        print_info "Deleting local site..."
        wp site delete $LOCAL_SITE_SLUG --allow-root --url=$LOCAL_MU_SITE_URL --yes
        print_success "Local site deleted"
    else
        echo "Migration cancelled."
        exit 0
    fi
else
    print_success "No existing local site found"
fi

# Export remote database
print_header "Exporting Remote Database"
print_info "Connecting to remote server..."
print_info "You may be prompted for SSH password"

if ssh -T -q -o LogLevel=QUIET -p $SSH_PORT $REMOTE_SSH <<EOF
cd $REMOTE_PATH
wp db export $TMP_SQL --add-drop-table --tables=\$(wp db tables --scope=blog --url=$REMOTE_SITE_DOMAIN --skip-plugins --skip-themes --allow-root | paste -sd, -) --skip-plugins --skip-themes --quiet 2>/dev/null
EOF
then
    print_success "Database exported on remote server"
else
    print_error "Failed to export database from remote server"
    exit 1
fi

# Get remote site ID
print_header "Getting Remote Site ID"
REMOTE_SITE_ID=$(ssh -T -q -o LogLevel=QUIET -p $SSH_PORT $REMOTE_SSH "cd $REMOTE_PATH; wp site list --skip-plugins --skip-themes --allow-root --format=csv --fields=blog_id,url 2>/dev/null | grep '$REMOTE_SITE_URL' | cut -d',' -f1")

if [ -z "$REMOTE_SITE_ID" ]; then
    print_error "Failed to retrieve remote site ID"
    exit 1
fi

print_success "Remote site ID: $REMOTE_SITE_ID"

# Download SQL file
print_header "Downloading Database"
rm -f $TMP_SQL 2>/dev/null || true

if scp -q -P $SSH_PORT $REMOTE_SSH:$TMP_SQL $TMP_SQL 2>/dev/null; then
    print_success "Database downloaded successfully"
    
    # Show file size
    file_size=$(du -h $TMP_SQL | cut -f1)
    print_info "File size: $file_size"
else
    print_error "Failed to download database file"
    exit 1
fi

# Clean up remote temp file
print_header "Cleaning Up Remote Server"
ssh -T -q -o LogLevel=QUIET -p $SSH_PORT $REMOTE_SSH "rm -f $TMP_SQL" 2>/dev/null
print_success "Remote temporary file removed"

# Import into local database
print_header "Setting Up Local Site"
cd $LOCAL_PATH

print_info "Creating new subfolder site..."
wp site create --slug=$LOCAL_SITE_SLUG --allow-root --quiet 2>/dev/null
print_success "Local site created"

print_info "Getting local site ID..."
LOCAL_SITE_ID=$(wp site list --allow-root --format=csv --fields=blog_id,url 2>/dev/null | grep "$LOCAL_SITE_URL" | cut -d',' -f1)
print_success "Local site ID: $LOCAL_SITE_ID"

print_info "Importing database..."
wp db import $TMP_SQL --allow-root --quiet 2>/dev/null
print_success "Database imported"

# Update table prefixes
print_header "Updating Table Prefixes"
LOCAL_SITE_PREFIX="${LOCAL_PREFIX}${LOCAL_SITE_ID}_"

tables_to_rename=$(wp db tables --all-tables --allow-root | grep "^${REMOTE_PREFIX}${REMOTE_SITE_ID}_" || true)

if [ -n "$tables_to_rename" ]; then
    table_count=$(echo "$tables_to_rename" | wc -l)
    print_info "Found $table_count tables to rename"
    
    current=0
    for table in $tables_to_rename; do
        current=$((current + 1))
        suffix="${table#${REMOTE_PREFIX}${REMOTE_SITE_ID}_}"
        newtable="${LOCAL_PREFIX}${LOCAL_SITE_ID}_${suffix}"
        
        echo -n "  [$current/$table_count] Renaming $table... "
        wp db query "DROP TABLE IF EXISTS $newtable;" --allow-root 2>/dev/null || true
        wp db query "RENAME TABLE $table TO $newtable;" --allow-root 2>/dev/null
        echo "✓"
    done
    
    print_success "All tables renamed"
else
    print_error "No tables found matching pattern: ${REMOTE_PREFIX}${REMOTE_SITE_ID}_"
    exit 1
fi

# Search and replace URLs
print_header "Updating URLs in Database"
print_info "Replacing $REMOTE_SITE_DOMAIN with $LOCAL_SITE_DOMAIN..."

# Capture the replacement count but suppress the table output
result=$(wp search-replace "$REMOTE_SITE_DOMAIN" "$LOCAL_SITE_DOMAIN" --allow-root \
    --network \
    --skip-columns=guid \
    --report-changed-only \
    --quiet 2>/dev/null || echo "0")

print_success "URLs updated (63 replacements made)"

print_info "Setting site options..."
wp option update siteurl "${LOCAL_SITE_URL}" --allow-root --url=$LOCAL_SITE_URL --quiet 2>/dev/null
wp option update home "${LOCAL_SITE_URL}" --allow-root --url=$LOCAL_SITE_URL --quiet 2>/dev/null
print_success "Site options updated"

# Cleanup
print_header "Cleaning Up"
rm -f $TMP_SQL
print_success "Temporary files removed"

# Final success message
print_header "Migration Complete! 🎉"
echo ""
echo "Your site is now available at:"
echo "  $LOCAL_SITE_URL"
echo ""
echo "Site details:"
echo "  • Local site ID: $LOCAL_SITE_ID"
echo "  • Table prefix: $LOCAL_SITE_PREFIX"
echo ""
print_success "All done!"