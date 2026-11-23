#!/usr/bin/env bash
set -euo pipefail

CONF=/usr/local/lsws/conf/httpd_config.conf

# Strip OLS-shipped defaults: the :8088 Default listener plus the two
# vhTemplates that reference it. They are inert for our use case and would
# only confuse downstream images that FROM this one.
awk '
  {
    if (skip) {
      if ($0 ~ /^\}[[:space:]]*$/) skip = 0
      next
    }
    if ($0 ~ /^listener Default[[:space:]]*\{[[:space:]]*$/)              { skip = 1; next }
    if ($0 ~ /^vhTemplate centralConfigLog[[:space:]]*\{[[:space:]]*$/)   { skip = 1; next }
    if ($0 ~ /^vhTemplate EasyRailsWithSuEXEC[[:space:]]*\{[[:space:]]*$/) { skip = 1; next }
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
