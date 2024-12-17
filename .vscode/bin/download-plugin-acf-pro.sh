#!/bin/bash
# Download ACF PRO to /tmp folder
KEY=$1
ACF_URL="https://connect.advancedcustomfields.com/v2/plugins/download?s=web&p=pro&k=${KEY}"

# Do the following steps only if the key is not empty
if [ -z "$KEY" ]
then
    echo "ACF PRO key is empty"
    exit 1
fi

# Do the following steps only if is not already installed
if [ -d "/tmp/advanced-custom-fields-pro" ]
then
    echo "ACF PRO is already installed"
    exit 0
fi

curl -o /tmp/acf-pro.zip ${ACF_URL}
# Unzip to plugins folder
unzip -o /tmp/acf-pro.zip -d /tmp
# Remove zip file
rm -f /tmp/acf-pro.zip


