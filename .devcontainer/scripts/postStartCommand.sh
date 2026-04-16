#!/bin/bash

# Start apache2
service apache2 start
echo "✅ Apache2 started."

# List exposed ports
echo ""
echo "🔌 Exposed ports:"
echo "WordPress: http://localhost:8080"
echo "phpMyAdmin: http://localhost:8090"
