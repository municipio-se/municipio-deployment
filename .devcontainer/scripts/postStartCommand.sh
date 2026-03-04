#!/bin/bash

# Start apache2
sudo service apache2 start > /dev/null 2>&1
echo "✅ Apache2 started."

# List exposed ports
echo ""
echo "🔌 Exposed ports:"
echo "WordPress: http://localhost:8080"
echo "phpMyAdmin: http://localhost:8090"
