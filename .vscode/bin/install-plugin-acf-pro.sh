#!/bin/bash

if [ -d "/var/www/html/wp-content/plugins/advanced-custom-fields-pro" ]
then
    echo "ACF PRO is already installed"
    exit 0
fi

if [ ! -d "/tmp/advanced-custom-fields-pro" ]
then
    echo "ACF PRO is not available in the tmp folder"
    exit 1
fi

# Copy ACF PRO to plugins folder
cp -r /tmp/advanced-custom-fields-pro /var/www/html/wp-content/plugins/advanced-custom-fields-pro