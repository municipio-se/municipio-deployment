#!/usr/bin/env bash

#############################################################################
# WordPress Multisite Migration Script
# Migrates a remote subdomain site to a local subfolder site
#############################################################################

set -Eeuo pipefail  # Exit on error, undefined variable, or pipeline failure

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
CDN_DOMAIN="${CDN_DOMAIN:?CDN_DOMAIN not set}"

### LOCAL SETUP ###
LOCAL_PATH="/var/www/html"
LOCAL_SITE_DOMAIN="localhost:8080"
LOCAL_MU_SITE_URL="http://${LOCAL_SITE_DOMAIN}"
LOCAL_PREFIX="mun_"
DEBUG_MIGRATE="${DEBUG_MIGRATE:-0}"
AUTO_CONFIRM=0

create_temp_log() {
    mktemp "/tmp/migrate-debug.XXXXXX" 2>/dev/null || mktemp -t migrate-debug
}

ERROR_LOG="$(create_temp_log)"

# Supports either a scalar value (comma-separated supported) or a bash array.
parse_env_list() {
    local var_name="$1"
    local out_name="$2"

    local values=()
    if declare -p "$var_name" 2>/dev/null | grep -q '^declare -a '; then
        eval "values=(\"\${${var_name}[@]}\")"
    else
        local raw_value="${!var_name}"
        IFS=',' read -r -a values <<< "$raw_value"
    fi

    local normalized=()
    local item
    for item in "${values[@]}"; do
        item="${item#${item%%[![:space:]]*}}"
        item="${item%${item##*[![:space:]]}}"
        if [[ -n "$item" ]]; then
            normalized+=("$item")
        fi
    done

    eval "$out_name=()"
    local normalized_item
    for normalized_item in "${normalized[@]}"; do
        eval "$out_name+=(\"$normalized_item\")"
    done
}

slugify() {
    local value="$1"
    local slug
    slug="$(printf '%s' "$value" | tr '[:upper:]' '[:lower:]' | sed -E 's#[^a-z0-9]+#-#g; s#(^-+|-+$)##g')"
    if [[ -z "$slug" ]]; then
        slug="site"
    fi
    printf '%s' "$slug"
}

array_contains() {
    local needle="$1"
    shift

    local item
    for item in "$@"; do
        if [[ "$item" == "$needle" ]]; then
            return 0
        fi
    done

    return 1
}

extract_domain_from_url() {
    local url="$1"
    local domain="$url"

    domain="${domain#http://}"
    domain="${domain#https://}"
    domain="${domain%%/*}"
    domain="${domain%%:*}"

    printf '%s' "$domain"
}

resolve_wildcard_sites() {
    local remote_sites_csv
    if ! remote_sites_csv="$(ssh -T -q -o LogLevel=QUIET -p "$SSH_PORT" "$REMOTE_SSH" \
        "cd $REMOTE_PATH; wp site list --skip-plugins --skip-themes --allow-root --format=csv --fields=blog_id,url 2>/dev/null")"; then
        echo "ERROR: Failed to list remote sites for wildcard configuration" >&2
        exit 1
    fi

    REMOTE_SITE_DOMAINS=()
    LOCAL_SITE_SLUGS=()

    local blog_id
    local site_url
    local remote_domain
    local domain_slug
    local base_slug
    local candidate_slug
    local suffix

    while IFS=',' read -r blog_id site_url; do
        if [[ -z "$blog_id" || "$blog_id" == "blog_id" || -z "$site_url" ]]; then
            continue
        fi

        remote_domain="$(extract_domain_from_url "$site_url")"
        if [[ -z "$remote_domain" ]]; then
            continue
        fi

        domain_slug="$(slugify "$remote_domain")"
        base_slug="remote-${blog_id}-${domain_slug}"
        candidate_slug="$base_slug"
        suffix=1
        while [[ ${#LOCAL_SITE_SLUGS[@]} -gt 0 ]] && array_contains "$candidate_slug" "${LOCAL_SITE_SLUGS[@]}"; do
            candidate_slug="${base_slug}-${suffix}"
            suffix=$((suffix + 1))
        done

        REMOTE_SITE_DOMAINS+=("$remote_domain")
        LOCAL_SITE_SLUGS+=("$candidate_slug")
    done <<< "$remote_sites_csv"

    if [[ ${#REMOTE_SITE_DOMAINS[@]} -eq 0 ]]; then
        echo "ERROR: Wildcard configuration returned no remote sites" >&2
        exit 1
    fi
}

REMOTE_SITE_DOMAINS=()
LOCAL_SITE_SLUGS=()
parse_env_list "REMOTE_SITE_DOMAIN" "REMOTE_SITE_DOMAINS"
parse_env_list "LOCAL_SITE_SLUG" "LOCAL_SITE_SLUGS"

remote_wildcard=0
local_wildcard=0
if [[ ${#REMOTE_SITE_DOMAINS[@]} -eq 1 && "${REMOTE_SITE_DOMAINS[0]}" == "*" ]]; then
    remote_wildcard=1
fi
if [[ ${#LOCAL_SITE_SLUGS[@]} -eq 1 && "${LOCAL_SITE_SLUGS[0]}" == "*" ]]; then
    local_wildcard=1
fi

if [[ $remote_wildcard -ne $local_wildcard ]]; then
    echo "ERROR: Use wildcard for both REMOTE_SITE_DOMAIN and LOCAL_SITE_SLUG" >&2
    echo "Example: REMOTE_SITE_DOMAIN=* and LOCAL_SITE_SLUG=*" >&2
    exit 1
fi

if [[ $remote_wildcard -eq 1 ]]; then
    resolve_wildcard_sites
fi

if [ ${#REMOTE_SITE_DOMAINS[@]} -eq 0 ]; then
    print_error "REMOTE_SITE_DOMAIN has no usable values"
    exit 1
fi

if [ ${#LOCAL_SITE_SLUGS[@]} -eq 0 ]; then
    print_error "LOCAL_SITE_SLUG has no usable values"
    exit 1
fi

if [ ${#REMOTE_SITE_DOMAINS[@]} -ne ${#LOCAL_SITE_SLUGS[@]} ]; then
    print_error "REMOTE_SITE_DOMAIN and LOCAL_SITE_SLUG must have the same number of values"
    print_info "REMOTE_SITE_DOMAIN count: ${#REMOTE_SITE_DOMAINS[@]}"
    print_info "LOCAL_SITE_SLUG count: ${#LOCAL_SITE_SLUGS[@]}"
    exit 1
fi

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

print_debug() {
    if [[ "$DEBUG_MIGRATE" == "1" ]]; then
        echo "DEBUG: $1"
    fi
}

cleanup_error_log() {
    rm -f "$ERROR_LOG"
}

die() {
    local message="$1"
    local exit_code="${2:-1}"

    print_error "$message"
    if [[ -s "$ERROR_LOG" ]]; then
        echo ""
        echo "--- command output ---" >&2
        cat "$ERROR_LOG" >&2
        echo "----------------------" >&2
    fi

    cleanup_error_log
    exit "$exit_code"
}

on_error() {
    local exit_code="$?"
    local line_no="$1"
    local command="$2"

    if [[ $exit_code -ne 0 ]]; then
        die "Migration failed at line $line_no while running: $command" "$exit_code"
    fi
}

run_step() {
    local description="$1"
    shift
    local exit_code=0

    : > "$ERROR_LOG"
    print_debug "Running step: $description"
    if ! "$@" >"$ERROR_LOG" 2>&1; then
        exit_code=$?
        die "Step failed: $description" "$exit_code"
    fi

    if [[ "$DEBUG_MIGRATE" == "1" && -s "$ERROR_LOG" ]]; then
        cat "$ERROR_LOG"
    fi
    : > "$ERROR_LOG"
}

trap 'cleanup_error_log' EXIT
trap 'on_error "$LINENO" "$BASH_COMMAND"' ERR

# Check if required commands exist
check_dependencies() {
    print_header "Checking Dependencies"
    
    local missing_deps=0
    
    for cmd in wp ssh scp; do
        if ! command -v "$cmd" &> /dev/null; then
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

    if [[ "$AUTO_CONFIRM" == "1" ]]; then
        print_info "Auto-confirmed: $prompt"
        return 0
    fi
    
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

parse_cli_args() {
    SCRIPT_ACTION="run"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --no-interaction)
                AUTO_CONFIRM=1
                ;;
            clear-cache)
                SCRIPT_ACTION="clear-cache"
                ;;
            *)
                print_error "Unknown argument: $1"
                echo "Usage: $0 [clear-cache] [--no-interaction]" >&2
                exit 1
                ;;
        esac
        shift
    done
}

get_local_site_id() {
    local site_slug="$1"
    local site_path="/${site_slug}/"
    local site_list

    site_list="$(wp site list --allow-root --format=csv --fields=blog_id,domain,path 2>/dev/null || true)"
    awk -F',' -v domain="$LOCAL_SITE_DOMAIN" -v path="$site_path" '
        $2 == domain && $3 == path { print $1; exit }
    ' <<< "$site_list" || true
}

get_local_site_record() {
    local site_id="$1"
    local site_list

    site_list="$(wp site list --allow-root --format=csv --fields=blog_id,domain,path,url 2>/dev/null || true)"
    awk -F',' -v site_id="$site_id" '
        $1 == site_id { print $0; exit }
    ' <<< "$site_list" || true
}

get_file_mtime() {
    local file_path="$1"

    if stat -f %m "$file_path" >/dev/null 2>&1; then
        stat -f %m "$file_path"
    else
        stat -c %Y "$file_path"
    fi
}

#############################################################################
# Main Script
#############################################################################
migrate_site() {

    local remote_site_domain="$1"
    local local_site_slug="$2"
    local migration_index="$3"
    local migration_total="$4"

    local remote_site_url="${REMOTE_SITE_PROTOCOL}${remote_site_domain}"
    local local_site_url="$LOCAL_MU_SITE_URL/$local_site_slug"
    local tmp_sql="/tmp/${local_site_slug}.sql"
    local cache_dir="$SCRIPT_DIR/db-cache"
    local cache_file="$cache_dir/${local_site_slug}.sql"
    local cache_ttl=3600 # 1 hour

    # Metadata file for cache
    local cache_meta_file="$cache_dir/${local_site_slug}.meta"

    # Initialize to avoid unbound variable errors
    local REMOTE_SITE_ID=""
    local REMOTE_SITE_URL_CANONICAL=""
    local REMOTE_UPLOAD_URL_PATH=""

    print_header "Migration $migration_index/$migration_total"
    echo "Remote: $remote_site_url"
    echo "Local:  $local_site_url"
    echo ""

    # Check if local site already exists
    print_header "Checking Local Site"
    local existing_site_id
    local existing_site_record
    local existing_site_domain
    local existing_site_path
    local existing_site_url
    existing_site_id="$(get_local_site_id "$local_site_slug")"

    if [[ -n "$existing_site_id" ]]; then
        existing_site_record="$(get_local_site_record "$existing_site_id")"
        IFS=',' read -r _ existing_site_domain existing_site_path existing_site_url <<< "$existing_site_record"

        echo "⚠️  Local site $local_site_url already exists."
        print_info "Existing site ID: $existing_site_id"
        print_info "Existing site domain/path: ${existing_site_domain}${existing_site_path}"
        print_info "Existing site stored URL: ${existing_site_url:-unknown}"
        if [[ -n "$existing_site_url" && "$existing_site_url" != "$local_site_url" && "$existing_site_url" != "$local_site_url/" ]]; then
            print_info "Stored URL differs from the local URL, likely due to a previous partial import."
        fi

        if confirm_action "Delete existing site and continue?" "n"; then
            print_info "Deleting local site ID $existing_site_id (${existing_site_domain}${existing_site_path})..."
            run_step "Delete existing local site $local_site_url" \
                wp site delete "$existing_site_id" --allow-root --url="$LOCAL_MU_SITE_URL" --yes
            print_success "Local site deleted"
        else
            echo "Migration cancelled."
            exit 0
        fi
    else
        print_success "No existing local site found"
    fi

    # Export remote database or use cache
    print_header "Exporting/Fetching Remote Database"
    mkdir -p "$cache_dir"
    local use_cache=0
    if [ -f "$cache_file" ]; then
        local now=$(date +%s)
        local file_time
        file_time="$(get_file_mtime "$cache_file")"
        if [ $((now - file_time)) -lt $cache_ttl ]; then
            use_cache=1
        fi
    fi

    if [ $use_cache -eq 1 ]; then
        print_info "Using cached database for $local_site_slug (less than 1 hour old)."
        print_info "To clear cache, run: ./migrate.sh clear-cache"
        run_step "Copy cached database from $cache_file" cp "$cache_file" "$tmp_sql"
        if [ -f "$cache_meta_file" ]; then
            # shellcheck disable=SC1090
            source "$cache_meta_file"
        else
            print_error "Cache metadata file missing: $cache_meta_file"
            exit 1
        fi
    else
        print_info "Connecting to remote server..."
        print_info "You may be prompted for SSH password"

        if ssh -T -q -o LogLevel=QUIET -p "$SSH_PORT" "$REMOTE_SSH" \
            "cd $REMOTE_PATH && wp db export $tmp_sql --add-drop-table --tables=\$(wp db tables --scope=blog --url=$remote_site_domain --skip-plugins --skip-themes --allow-root | paste -sd, -) --skip-plugins --skip-themes --quiet 2>/dev/null"
        then
            print_success "Database exported on remote server"
        else
            print_error "Failed to export database from remote server"
            exit 1
        fi

        # Get remote site ID
        print_header "Getting Remote Site ID"
        local remote_site_record
        remote_site_record=$(ssh -T -q -o LogLevel=QUIET -p "$SSH_PORT" "$REMOTE_SSH" \
            "cd $REMOTE_PATH; wp site list --skip-plugins --skip-themes --allow-root --format=csv --fields=blog_id,url 2>/dev/null | awk -F',' -v domain='$remote_site_domain' 'NR > 1 { normalized = \$2; sub(/^https?:\\/\\//, \"\", normalized); sub(/\\/.*/, \"\", normalized); if (normalized == domain) { print \$1 \",\" \$2; exit } }'")
        REMOTE_SITE_ID="${remote_site_record%%,*}"
        if [[ "$remote_site_record" == *,* ]]; then
            REMOTE_SITE_URL_CANONICAL="${remote_site_record#*,}"
        fi
        if [[ -z "$REMOTE_SITE_URL_CANONICAL" ]]; then
            REMOTE_SITE_URL_CANONICAL="$remote_site_url"
        fi
        print_header "Getting Remote Upload URL Path"
        REMOTE_UPLOAD_URL_PATH=$(ssh -T -q -o LogLevel=QUIET -p "$SSH_PORT" "$REMOTE_SSH" "cd $REMOTE_PATH; wp option get upload_url_path --url=$REMOTE_SITE_URL_CANONICAL --allow-root --skip-plugins --skip-themes 2>/dev/null")

        if [ -z "$REMOTE_SITE_ID" ]; then
            print_error "Failed to retrieve remote site ID"
            exit 1
        fi

        print_success "Remote site ID: $REMOTE_SITE_ID"
        print_info "Canonical remote URL: $REMOTE_SITE_URL_CANONICAL"
        # Save metadata for cache
        echo "REMOTE_SITE_ID=\"$REMOTE_SITE_ID\"" > "$cache_meta_file"
        echo "REMOTE_UPLOAD_URL_PATH=\"$REMOTE_UPLOAD_URL_PATH\"" >> "$cache_meta_file"

        # Download SQL file
        print_header "Downloading Database"
        rm -f "$tmp_sql" 2>/dev/null || true

        if scp -q -P "$SSH_PORT" "$REMOTE_SSH:$tmp_sql" "$tmp_sql" 2>/dev/null; then
            print_success "Database downloaded successfully"

            # Show file size
            file_size=$(du -h "$tmp_sql" | cut -f1)
            print_info "File size: $file_size"
            run_step "Update cache file $cache_file" cp "$tmp_sql" "$cache_file"
            print_info "Database cached for 1 hour at $cache_file"
        else
            print_error "Failed to download database file"
            exit 1
        fi

        # Clean up remote temp file
        print_header "Cleaning Up Remote Server"
        ssh -T -q -o LogLevel=QUIET -p "$SSH_PORT" "$REMOTE_SSH" "rm -f $tmp_sql" 2>/dev/null
        print_success "Remote temporary file removed"
    fi

    # Import into local database
    print_header "Setting Up Local Site"
    cd "$LOCAL_PATH"

    print_info "Creating new subfolder site..."
    existing_site_id="$(get_local_site_id "$local_site_slug")"
    if [[ -n "$existing_site_id" ]]; then
        existing_site_record="$(get_local_site_record "$existing_site_id")"
        IFS=',' read -r _ existing_site_domain existing_site_path existing_site_url <<< "$existing_site_record"
        print_info "Site $local_site_url already exists with site ID $existing_site_id. Reusing ${existing_site_domain}${existing_site_path}."
    else
        run_step "Create local site $local_site_url" \
            wp site create --slug="$local_site_slug" --allow-root --quiet
        print_success "Local site created"
    fi

    print_info "Getting local site ID..."
    LOCAL_SITE_ID=$(wp site list --allow-root --format=csv --fields=blog_id,url 2>/dev/null | grep "$local_site_url" | cut -d',' -f1)
    if [[ -z "$LOCAL_SITE_ID" ]]; then
        die "Failed to determine local site ID for $local_site_url"
    fi
    print_success "Local site ID: $LOCAL_SITE_ID"

    print_info "Importing database..."
    run_step "Import database from $tmp_sql" wp db import "$tmp_sql" --allow-root --quiet
    print_success "Database imported"

    # Update table prefixes
    print_header "Updating Table Prefixes"
    LOCAL_SITE_PREFIX="${LOCAL_PREFIX}${LOCAL_SITE_ID}_"
    if [ "$REMOTE_SITE_ID" = "1" ]; then
        REMOTE_SITE_PREFIX="${REMOTE_PREFIX}"
    else
        REMOTE_SITE_PREFIX="${REMOTE_PREFIX}${REMOTE_SITE_ID}_"
    fi

    tables_to_rename=$(wp db tables --all-tables --allow-root | grep "^${REMOTE_SITE_PREFIX}" || true)

    if [ -n "$tables_to_rename" ]; then
        table_count=$(echo "$tables_to_rename" | wc -l)
        print_info "Found $table_count tables to rename"

        current=0
        for table in $tables_to_rename; do
            current=$((current + 1))
            suffix="${table#${REMOTE_SITE_PREFIX}}"
            newtable="${LOCAL_SITE_PREFIX}${suffix}"

            echo -n "  [$current/$table_count] Renaming $table... "
            wp db query "DROP TABLE IF EXISTS $newtable;" --allow-root 2>/dev/null || true
            run_step "Rename table $table to $newtable" \
                wp db query "RENAME TABLE $table TO $newtable;" --allow-root
            echo "✓"
        done

        print_success "All tables renamed"
    else
        print_error "No tables found matching pattern: ${REMOTE_SITE_PREFIX}"
        exit 1
    fi

    # Search and replace URLs
    print_header "Updating URLs in Database"
    print_info "Replacing $remote_site_domain with $LOCAL_SITE_DOMAIN/$local_site_slug..."

    run_step "Replace $remote_site_domain in the database" \
        wp search-replace "$remote_site_domain" "$LOCAL_SITE_DOMAIN/$local_site_slug" --allow-root \
            --network \
            --skip-plugins --skip-themes \
            --quiet

    print_info "Replacing $CDN_DOMAIN with $LOCAL_SITE_DOMAIN..."
    run_step "Replace CDN domain $CDN_DOMAIN in the database" \
        wp search-replace "$CDN_DOMAIN" "$LOCAL_SITE_DOMAIN" --allow-root \
            --url="$LOCAL_SITE_DOMAIN/$local_site_slug" \
            --skip-plugins --skip-themes \
            --quiet

    print_info "Replacing https:// with http:// for local site..."
    run_step "Normalize the local site protocol" \
        wp search-replace "https://$LOCAL_SITE_DOMAIN/$local_site_slug" "http://$LOCAL_SITE_DOMAIN/$local_site_slug" --allow-root \
            --network \
            --url="$LOCAL_SITE_DOMAIN/$local_site_slug" \
            --skip-plugins --skip-themes \
            --quiet

    run_step "Restore uploads URLs for $CDN_DOMAIN" \
        wp search-replace "$LOCAL_SITE_DOMAIN/uploads" "$CDN_DOMAIN/uploads" --allow-root \
            --network \
            --url="$LOCAL_SITE_DOMAIN/$local_site_slug" \
            --skip-plugins --skip-themes \
            --quiet

    print_success "URLs updated"

    print_info "Setting site options..."
    run_step "Update siteurl for $local_site_url" \
        wp option update siteurl "${local_site_url}" --allow-root --url="$local_site_url" --quiet --skip-plugins --skip-themes
    run_step "Update home for $local_site_url" \
        wp option update home "${local_site_url}" --allow-root --url="$local_site_url" --quiet --skip-plugins --skip-themes
    run_step "Store remote_site_id for $local_site_url" \
        wp option update remote_site_id "${REMOTE_SITE_ID}" --allow-root --url="$local_site_url" --quiet --skip-plugins --skip-themes
    run_step "Update upload_url_path for $local_site_url" \
        wp option update upload_url_path "${REMOTE_UPLOAD_URL_PATH}" --allow-root --url="$local_site_url" --quiet --skip-plugins --skip-themes
    if ! wp option get remote_cdn_domain --allow-root --url="$local_site_url" --quiet --skip-plugins --skip-themes >/dev/null 2>&1; then
        run_step "Add remote_cdn_domain for $local_site_url" \
            wp option add remote_cdn_domain "${CDN_DOMAIN}" --autoload=no --allow-root --url="$local_site_url" --quiet --skip-plugins --skip-themes
    else
        run_step "Update remote_cdn_domain for $local_site_url" \
            wp option update remote_cdn_domain "${CDN_DOMAIN}" --allow-root --url="$local_site_url" --quiet --skip-plugins --skip-themes
    fi

    print_success "Site options updated"

    print_info "Turn off plugins that may cause issues with local development..."
    if ! wp plugin deactivate force-ssl s3-uploads s3-local-index --allow-root --url="$local_site_url" --quiet --skip-plugins --skip-themes >/dev/null 2>&1; then
        print_info "Plugin deactivation skipped or failed for $local_site_url"
    fi

    # Cleanup
    print_header "Cleaning Up"
    rm -f "$tmp_sql"
    print_success "Temporary files removed"

    # Final success message
    print_header "Migration Complete!"
    echo ""
    echo "Your site is now available at:"
    echo "  $local_site_url"
    echo ""
    echo "Site details:"
    echo "  • Local site ID: $LOCAL_SITE_ID"
    echo "  • Table prefix: $LOCAL_SITE_PREFIX"
    echo ""
    print_success "Migration $migration_index/$migration_total finished"
}


parse_cli_args "$@"

# Clear cache option
if [[ "$SCRIPT_ACTION" == "clear-cache" ]]; then
    cache_dir="$SCRIPT_DIR/db-cache"
    if [ -d "$cache_dir" ]; then
        rm -rf "$cache_dir"/*
        echo "Database cache cleared ($cache_dir)"
    else
        echo "No cache directory found ($cache_dir)"
    fi
    exit 0
fi

print_header "WordPress Multisite Migration"
print_info "Configured migrations: ${#REMOTE_SITE_DOMAINS[@]}"

index=0
for remote_site_domain in "${REMOTE_SITE_DOMAINS[@]}"; do
    local_site_slug="${LOCAL_SITE_SLUGS[$index]}"
    print_info "Pair $((index + 1)): ${remote_site_domain} -> ${local_site_slug}"
    index=$((index + 1))
done
echo ""

# Check dependencies
check_dependencies

# Display configuration summary
print_header "Configuration Summary"
print_info "Remote SSH: $REMOTE_SSH:$SSH_PORT"
print_info "Remote path: $REMOTE_PATH"
print_info "Local path: $LOCAL_PATH"
echo ""

if ! confirm_action "Continue with migration?"; then
    echo "Migration cancelled."
    exit 0
fi

index=0
for remote_site_domain in "${REMOTE_SITE_DOMAINS[@]}"; do
    local_site_slug="${LOCAL_SITE_SLUGS[$index]}"
    migrate_site "$remote_site_domain" "$local_site_slug" "$((index + 1))" "${#REMOTE_SITE_DOMAINS[@]}"
    index=$((index + 1))
done

print_header "All Migrations Complete"
print_success "Finished ${#REMOTE_SITE_DOMAINS[@]} migration(s)"
print_success "Finished ${#REMOTE_SITE_DOMAINS[@]} migration(s)"