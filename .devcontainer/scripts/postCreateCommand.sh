#!/bin/bash

#############################################################################
# Post Create Command Script
# Runs after the devcontainer is created to configure the environment
#############################################################################

MISSING_CONFIG=()

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

# Check required variables and configure what we can
echo "Checking configuration..."
echo ""

# Check MUNICIPIO_ACF_PRO_KEY
if [ -z "$MUNICIPIO_ACF_PRO_KEY" ]; then
    echo "⚠️  MUNICIPIO_ACF_PRO_KEY is not set"
    MISSING_CONFIG+=("MUNICIPIO_ACF_PRO_KEY - Required for ACF Pro plugin installation")
else
    echo "✓ MUNICIPIO_ACF_PRO_KEY is set"
fi

# Check MUNICIPIO_GITHUB_TOKEN
if [ -z "$MUNICIPIO_GITHUB_TOKEN" ]; then
    echo "⚠️  MUNICIPIO_GITHUB_TOKEN is not set"
    MISSING_CONFIG+=("MUNICIPIO_GITHUB_TOKEN - Required for npm and composer packages")
else
    echo "✓ MUNICIPIO_GITHUB_TOKEN is set"

    # Create .npmrc file
    > ~/.npmrc
    echo "@helsingborg-stad:registry=https://npm.pkg.github.com" > ~/.npmrc
    echo "//npm.pkg.github.com/:_authToken=${MUNICIPIO_GITHUB_TOKEN}" >> ~/.npmrc
    echo "✓ .npmrc file configured"

    # Set the GitHub token for Composer
    composer config github-oauth.github.com $MUNICIPIO_GITHUB_TOKEN 2>/dev/null
    echo "✓ Composer GitHub token configured"
fi

echo ""

# Always create symlink to /var/www/html
sudo chmod a+x "$(pwd)" && sudo rm -rf /var/www/html && sudo ln -s "$(pwd)" /var/www/html
echo "✓ Symlink created: $(pwd) → /var/www/html"

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
