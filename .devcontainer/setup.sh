#!/bin/bash

# Warn if .env file is not present
if [ ! -f .devcontainer/.env ]; then
  echo "⛔️ WARNING: .devcontainer/.env file not found. Please create one based on .env.example and restart the container."
  exit 1
else
    echo "✅ .devcontainer/.env file is present."
fi

# Read variables from .env file into environment
export $(egrep -v '^#' .devcontainer/.env | xargs)

# Warn if variable MUNICIPIO_ACF_PRO_KEY is not set or empty
if [ -z "$MUNICIPIO_ACF_PRO_KEY" ]; then
  echo "⛔️ WARNING: MUNICIPIO_ACF_PRO_KEY is not set. Please set it in .env and restart the container."
  exit 1
else
  echo "✅ MUNICIPIO_ACF_PRO_KEY is set."
fi

# Warn if variable MUNICIPIO_GITHUB_TOKEN is not set or empty
if [ -z "$MUNICIPIO_GITHUB_TOKEN" ]; then
  echo "⛔️ WARNING: MUNICIPIO_GITHUB_TOKEN is not set. Please set it in .env and restart the container."
  exit 1
else
    echo "✅ MUNICIPIO_GITHUB_TOKEN is set."
fi

# Create a .npmrc file with this content in the user home directory
> ~/.npmrc
echo "@helsingborg-stad:registry=https://npm.pkg.github.com" > ~/.npmrc
echo "//npm.pkg.github.com/:_authToken=${MUNICIPIO_GITHUB_TOKEN}" >> ~/.npmrc
echo "✅ .npmrc file is created."

# Set the GitHub token for Composer
composer config github-oauth.github.com $MUNICIPIO_GITHUB_TOKEN
echo "✅ Composer GitHub token is set."

# Symlink the current directory to /var/www/html
sudo chmod a+x "$(pwd)" && sudo rm -rf /var/www/html && sudo ln -s "$(pwd)" /var/www/html
echo "✅ Symlink created from $(pwd) to /var/www/html"

# Start apache2
sudo service apache2 start > /dev/null 2>&1
echo "✅ Apache2 started."

# List exposed ports
echo ""
echo "🔌 Exposed ports:"
echo "WordPress: https://localhost:8433"
echo "phpMyAdmin: https://localhost:8080"
