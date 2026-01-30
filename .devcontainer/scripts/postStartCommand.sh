#!/bin/bash

# Load environment variables
if [ -f .devcontainer/.env ]; then
    set -a
    source .devcontainer/.env
    set +a
fi

LOCAL_SITE_DOMAIN="${LOCAL_SITE_DOMAIN:-localhost:8443}"

# Export LOCAL_SITE_DOMAIN to Apache environment
echo "export LOCAL_SITE_DOMAIN=${LOCAL_SITE_DOMAIN}" | sudo tee /etc/apache2/conf-available/local-env.conf > /dev/null
echo "PassEnv LOCAL_SITE_DOMAIN" | sudo tee -a /etc/apache2/conf-available/local-env.conf > /dev/null
sudo a2enconf local-env > /dev/null 2>&1

# Start apache2
export LOCAL_SITE_DOMAIN
sudo -E service apache2 start > /dev/null 2>&1
echo "✅ Apache2 started."

# List exposed ports
echo ""
echo "🔌 Exposed ports:"
echo "WordPress: https://${LOCAL_SITE_DOMAIN}"
echo "phpMyAdmin: https://localhost:8080"
