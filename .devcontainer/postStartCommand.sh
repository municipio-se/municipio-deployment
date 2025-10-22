#!/bin/bash

# Start apache2
sudo service apache2 start > /dev/null 2>&1
echo "✅ Apache2 started."

# List exposed ports
echo ""
echo "🔌 Exposed ports:"
echo "WordPress: https://localhost:8443"
echo "phpMyAdmin: https://localhost:8080"