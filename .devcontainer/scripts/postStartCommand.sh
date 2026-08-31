#!/bin/bash

# Start apache2
service apache2 start
echo "✅ Apache2 started."

# List exposed ports
echo ""
echo "🔌 Exposed ports:"
echo "WordPress: http://localhost:8080"
echo "phpMyAdmin: http://localhost:8090"

# Check SSH key availability so users know early if migrate.sh will fail.
echo ""
if ls /home/vscode/.ssh/id_rsa /home/vscode/.ssh/id_ed25519 /home/vscode/.ssh/produktion /home/vscode/.ssh/cloudnet_sebastian /home/vscode/.ssh/helsingborg-io 2>/dev/null | grep -q .; then
    echo "✅ SSH keys mounted from host."
else
    echo "⚠️  No SSH key files found in /home/vscode/.ssh"
    echo "   Rebuild/reopen the devcontainer so your host ~/.ssh is mounted."
    echo "   Migration (composer devcontainer:migrate) will not work until this is fixed."
fi
