#!/bin/bash

set -e

# Configuration
DOMAIN="dev.local.municipio.tech"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CERT_KEY="$SCRIPT_DIR/franken.key"
CERT_CRT="$SCRIPT_DIR/franken.crt"
CADDYFILE="$SCRIPT_DIR/Caddyfile"
WEBROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Generate self-signed certificate if missing
if [ ! -f "$CERT_KEY" ] || [ ! -f "$CERT_CRT" ]; then
  echo "🔐 Generating self-signed certificate for $DOMAIN..."
  openssl req -x509 -newkey rsa:2048 -nodes \
    -keyout "$CERT_KEY" \
    -out "$CERT_CRT" \
    -days 365 \
    -subj "/CN=$DOMAIN"
else
  echo "✅ Existing certificate found."
fi

# Write Caddyfile with absolute paths
echo "📝 Writing Caddyfile..."
cat > "$CADDYFILE" <<EOF
https://$DOMAIN:443 {
    root * $WEBROOT
    php_fastcgi localhost:9000
    file_server
    tls $CERT_CRT $CERT_KEY
}
EOF

# Check /etc/hosts
if ! grep -q "$DOMAIN" /etc/hosts; then
  echo "⚠️  Domain not found in /etc/hosts. Add this line with sudo:"
  echo "127.0.0.1 $DOMAIN"
else
  echo "✅ $DOMAIN found in /etc/hosts."
fi

# Run FrankenPHP in full Caddy mode
echo "🚀 Starting FrankenPHP server for $DOMAIN"
exec frankenphp run --config "$CADDYFILE"