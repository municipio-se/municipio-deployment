#!/bin/bash
set -e

DOMAIN="dev.local.municipio.tech"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEBROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CADDYFILE="$SCRIPT_DIR/Caddyfile"

CERT_KEY=""
CERT_CRT=""

# Detect macOS
IS_MACOS=false
if [[ "$(uname)" == "Darwin" ]]; then
  IS_MACOS=true
fi

function generate_self_signed_cert() {
  echo "🔐 Generating self-signed certificate for $DOMAIN..."
  CERT_KEY="$SCRIPT_DIR/franken.key"
  CERT_CRT="$SCRIPT_DIR/franken.crt"

  openssl req -x509 -newkey rsa:2048 -nodes \
    -keyout "$CERT_KEY" \
    -out "$CERT_CRT" \
    -days 365 \
    -subj "/CN=$DOMAIN"
}

function trust_self_signed_cert_mac() {
  if $IS_MACOS; then
    echo "🔐 Adding self-signed certificate to macOS System keychain (requires sudo)..."
    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "$CERT_CRT"
    echo "✅ Certificate trusted in System keychain."
  else
    echo "⚠️ Auto-trust is only supported on macOS. Please manually trust $CERT_CRT in your OS."
  fi
}

function install_mkcert_if_missing() {
  if ! command -v mkcert >/dev/null 2>&1; then
    echo "⚠️ mkcert not found. Installing with Homebrew..."
    if ! command -v brew >/dev/null 2>&1; then
      echo "❌ Homebrew is required to install mkcert but not found. Please install Homebrew first: https://brew.sh/"
      return 1
    fi
    brew install mkcert
    brew install nss # optional, for Firefox support
    echo "✅ mkcert installed."
  fi
  return 0
}

function generate_mkcert_cert() {
  echo "🔐 Generating mkcert trusted certificate for $DOMAIN..."
  CERT_CRT="$SCRIPT_DIR/$DOMAIN.pem"
  CERT_KEY="$SCRIPT_DIR/$DOMAIN-key.pem"

  mkcert -install
  mkcert "$DOMAIN"
}

function ensure_domain_in_hosts() {
  DOMAIN_IP=$(dig +short "$DOMAIN" | grep -E '^127\.0\.0\.1$|^::1$' || true)
  if [[ -z "$DOMAIN_IP" ]]; then
    echo "📝 Adding $DOMAIN to /etc/hosts (requires sudo)..."
    sudo cp /etc/hosts /etc/hosts.bak
    if ! grep -q "$DOMAIN" /etc/hosts; then
      echo "127.0.0.1 $DOMAIN" | sudo tee -a /etc/hosts > /dev/null
      echo "✅ Added $DOMAIN to /etc/hosts"
    else
      echo "⚠️ $DOMAIN present in /etc/hosts but not resolving to 127.0.0.1 or ::1"
    fi
  else
    echo "✅ $DOMAIN already resolves to $DOMAIN_IP"
  fi
}

function install_frankenphp_if_missing() {
  if ! command -v frankenphp >/dev/null 2>&1; then
    echo "⚠️ FrankenPHP not found. Installing..."
    if ! command -v go >/dev/null 2>&1; then
      echo "❌ Go is required to install FrankenPHP but was not found."
      echo "Please install Go first: https://go.dev/dl/"
      exit 1
    fi
    GO111MODULE=on go install github.com/brefphp/frankenphp/cmd/frankenphp@latest
    export PATH="$PATH:$(go env GOPATH)/bin"
    echo "✅ FrankenPHP installed."
  else
    echo "✅ FrankenPHP found."
  fi
}

# Ensure frankenphp is installed
install_frankenphp_if_missing

# Main logic preferring mkcert
if command -v mkcert >/dev/null 2>&1; then
  generate_mkcert_cert
elif install_mkcert_if_missing; then
  generate_mkcert_cert
else
  generate_self_signed_cert
  if $IS_MACOS; then
    trust_self_signed_cert_mac
  fi
fi

# Write Caddyfile with absolute cert/key paths
echo "📝 Writing Caddyfile..."
cat > "$CADDYFILE" <<EOF
https://$DOMAIN:443 {
    root * $WEBROOT
    php_fastcgi localhost:9000
    file_server
    tls $CERT_CRT $CERT_KEY
}
EOF

ensure_domain_in_hosts

echo "🚀 Starting FrankenPHP server for $DOMAIN"
exec frankenphp run --config "$CADDYFILE"