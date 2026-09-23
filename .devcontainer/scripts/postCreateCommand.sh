#!/bin/bash

#############################################################################
# Post Create Command Script
# Runs after the devcontainer is created to configure the environment
#############################################################################

MISSING_CONFIG=()

# Codespaces secrets and variables inherited by the container take precedence
# over values in the local configuration file.
INHERITED_GH_TOKEN="${GH_TOKEN:-}"
INHERITED_ACF_PRO_KEY="${ACF_PRO_KEY:-}"

# Create .env file from example if not present
if [ ! -f .devcontainer/.env ]; then
    echo "→ .devcontainer/.env file not found, creating from .env.example..."
    cp .devcontainer/.env.example .devcontainer/.env
    echo "✓ Created .devcontainer/.env from .env.example"
    echo "  Please edit .devcontainer/.env with your configuration values."
    echo ""
fi

# Read variables from .env file into environment
if [ -f .devcontainer/.env ]; then
    set -a
    source .devcontainer/.env
    set +a
fi

if [ -n "$INHERITED_GH_TOKEN" ]; then
    GH_TOKEN="$INHERITED_GH_TOKEN"
fi

if [ -n "$INHERITED_ACF_PRO_KEY" ]; then
    ACF_PRO_KEY="$INHERITED_ACF_PRO_KEY"
fi

# Check required variables and configure what we can
echo "Checking configuration..."
echo ""

# Check GH_TOKEN
if [ -z "$GH_TOKEN" ]; then
    echo "⚠️  GH_TOKEN is not set"
    MISSING_CONFIG+=("GH_TOKEN - GitHub personal access token with read:packages scope")
else
    echo "✓ GH_TOKEN is set"

    # Create .npmrc file
    > ~/.npmrc
    echo "@helsingborg-stad:registry=https://npm.pkg.github.com" > ~/.npmrc
    echo "//npm.pkg.github.com/:_authToken=${GH_TOKEN}" >> ~/.npmrc
    echo "✓ .npmrc file configured"

    # Set the GitHub token for Composer
    composer config github-oauth.github.com $GH_TOKEN 2>/dev/null
    echo "✓ Composer GitHub token configured"
fi

# Check ACF_PRO_KEY
if [ -z "$ACF_PRO_KEY" ]; then
    echo "⚠️  ACF_PRO_KEY is not set"
    MISSING_CONFIG+=("ACF_PRO_KEY - Required for ACF Pro packages")
else
    echo "✓ ACF_PRO_KEY is set"

    # Set the ACF Pro Composer credentials
    composer config --global --auth http-basic.connect.advancedcustomfields.com "$ACF_PRO_KEY" http://localhost
    echo "✓ ACF Pro Composer credentials configured"
fi

echo ""

# Show summary if there are missing configurations
if [ ${#MISSING_CONFIG[@]} -gt 0 ]; then
    echo ""
    echo "=========================================="
    echo "  Configuration Required"
    echo "=========================================="
    echo ""
    echo "The following variables need to be set in .devcontainer/.env:"
    echo ""
    for item in "${MISSING_CONFIG[@]}"; do
        echo "  • $item"
    done
else
    echo ""
    echo "✓ All configuration complete!"
fi
