#!/usr/bin/env bash
set -euo pipefail

CONF=/usr/local/lsws/conf/httpd_config.conf

# Replace the vendor's listeners and docker template with Municipio's HTTP-only
# listener and vhost. The vendor defaults include :8088, HTTPS, and a template
# with different server rules.
awk '
  {
    if (skip) {
      if ($0 ~ /^\}[[:space:]]*$/) skip = 0
      next
    }
    if ($0 ~ /^listener[[:space:]]+(Default|HTTP|HTTPS)[[:space:]]*\{[[:space:]]*$/) { skip = 1; next }
    if ($0 ~ /^vhTemplate[[:space:]]+(centralConfigLog|EasyRailsWithSuEXEC|docker)[[:space:]]*\{[[:space:]]*$/) { skip = 1; next }
    print
  }
' "$CONF" > "$CONF.new"
mv "$CONF.new" "$CONF"

cat >> "$CONF" <<'EOF'
listener HTTP {
  address                 *:80
  secure                  0
}

vhTemplate docker {
  templateFile            conf/templates/docker.conf
  listeners               HTTP
  note                    docker

  member localhost {
    vhDomain              localhost, *
  }
}
EOF

mkdir -p /var/www/vhosts/localhost/{html,logs}
chown -R 1000:1000 /var/www/vhosts/localhost/
