#!/usr/bin/env bash

#############################################################################
# Dev Container Status Script
# Prints a concise startup summary without exposing secret values.
#############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVCONTAINER_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$DEVCONTAINER_DIR")"
ENV_FILE="$DEVCONTAINER_DIR/.env"

INHERITED_GH_TOKEN="${GH_TOKEN:-}"
INHERITED_ACF_PRO_KEY="${ACF_PRO_KEY:-}"

if [ -f "$ENV_FILE" ]; then
    set -a
    source "$ENV_FILE"
    set +a
fi

if [ -n "$INHERITED_GH_TOKEN" ]; then
    GH_TOKEN="$INHERITED_GH_TOKEN"
fi

if [ -n "$INHERITED_ACF_PRO_KEY" ]; then
    ACF_PRO_KEY="$INHERITED_ACF_PRO_KEY"
fi

MISSING_CONFIG=()

RESET=""
BOLD=""
CYAN=""
GREEN=""
YELLOW=""
RED=""

if [ -t 1 ] && [ "${TERM:-dumb}" != "dumb" ] && [ -z "${NO_COLOR:-}" ] && command -v tput >/dev/null 2>&1; then
    RESET="$(tput sgr0)"
    BOLD="$(tput bold)"
    CYAN="$(tput setaf 6)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    RED="$(tput setaf 1)"
fi

if [ -z "${GH_TOKEN:-}" ]; then
    MISSING_CONFIG+=("GH_TOKEN - GitHub personal access token with read:packages scope")
fi

if [ -z "${ACF_PRO_KEY:-}" ]; then
    MISSING_CONFIG+=("ACF_PRO_KEY - Required for ACF Pro packages")
fi

printf '\n%s%s==========================================%s\n' "$BOLD" "$CYAN" "$RESET"
printf '%s%s  Municipio dev container%s\n' "$BOLD" "$CYAN" "$RESET"
printf '%s%s==========================================%s\n\n' "$BOLD" "$CYAN" "$RESET"

if [ ! -f "$ENV_FILE" ]; then
    printf '%s⚠️  .devcontainer/.env has not been created yet.%s\n' "$YELLOW" "$RESET"
    printf '   It will be copied from .env.example during postCreateCommand.\n\n'
fi

if [ ${#MISSING_CONFIG[@]} -gt 0 ]; then
    printf '%s%s⚠ Configuration needed:%s\n\n' "$BOLD" "$YELLOW" "$RESET"
    for item in "${MISSING_CONFIG[@]}"; do
        printf '  %s•%s %s\n' "$RED" "$RESET" "$item"
    done
    printf '\n%sSet these in .devcontainer/.env for local dev containers, or as Codespaces repository secrets.%s\n' "$YELLOW" "$RESET"
else
    printf '%s✓ Package credentials are configured.%s\n' "$GREEN" "$RESET"
fi

printf '\n%s%sUseful commands:%s\n' "$BOLD" "$CYAN" "$RESET"
printf '  %s•%s composer devcontainer:reset   Set up or reset WordPress\n' "$CYAN" "$RESET"
printf '  %s•%s composer dev                  Develop a package\n' "$CYAN" "$RESET"
printf '  %s•%s .devcontainer/scripts/status.sh Show this status again\n' "$CYAN" "$RESET"
printf '\n%s🌐%s Local site: http://localhost:8080\n' "$GREEN" "$RESET"
printf '%s📖%s Guide: %s/.devcontainer/README.md\n\n' "$GREEN" "$RESET" "$PROJECT_ROOT"