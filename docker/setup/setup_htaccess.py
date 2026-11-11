#!/usr/bin/env python3
"""Create the document root .htaccess from the selected site template if missing.

OpenLiteSpeed's autoLoadHtaccess/RewriteFile reads the document root file, not
the templates in htaccess/. Existing rules and ownership are left untouched.
"""
from __future__ import annotations

import os
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parent.parent

LSCACHE_RULES = r"""# BEGIN LSCACHE
## LITESPEED WP CACHE PLUGIN - Do not edit the contents of this block! ##
<IfModule mod_rewrite.c>
RewriteEngine on
RewriteRule litespeed/debug/.*\.log$ - [F,L]
RewriteRule \.litespeed_conf\.dat - [F,L]
</IfModule>
<IfModule LiteSpeed>
CacheLookup on
RewriteRule .* - [E=Cache-Control:no-autoflush]

### marker ASYNC start ###
RewriteCond %{REQUEST_URI} /wp-admin/admin-ajax\.php
RewriteCond %{QUERY_STRING} action=async_litespeed
RewriteRule .* - [E=noabort:1]
### marker ASYNC end ###

### marker DROPQS start ###
CacheKeyModify -qs:fbclid
CacheKeyModify -qs:gclid
CacheKeyModify -qs:utm*
CacheKeyModify -qs:_ga
### marker DROPQS end ###

</IfModule>
## LITESPEED WP CACHE PLUGIN - Do not edit the contents of this block! ##
# END LSCACHE
# BEGIN NON_LSCACHE
## LITESPEED WP CACHE PLUGIN - Do not edit the contents of this block! ##
## LITESPEED WP CACHE PLUGIN - Do not edit the contents of this block! ##
# END NON_LSCACHE
"""


def env(name: str, default: str = "") -> str:
    """Read WP_CONF_<name>, falling back to <name>, then to default.

    Empty values count as unset, like bash's ${VAR:-default}.
    """
    return os.environ.get("WP_CONF_" + name) or os.environ.get(name) or default


def main() -> None:
    htaccess = ROOT_DIR / ".htaccess"
    if htaccess.exists() or htaccess.is_symlink():
        return

    allow_multisite = env("WP_ALLOW_MULTISITE", "false")
    subdomain = env("SUBDOMAIN_INSTALL", "false")
    enable_ls_cache = env("ENABLE_LS_CACHE", "false")

    if allow_multisite == "true":
        if subdomain == "true":
            selected = "htaccess/.htaccess-multisite-subdomain"
        else:
            selected = "htaccess/.htaccess-multisite-subfolder"
    else:
        selected = "htaccess/.htaccess"

    content = (ROOT_DIR / selected).read_bytes()
    if enable_ls_cache == "true":
        content = LSCACHE_RULES.encode() + content

    try:
        with htaccess.open("xb") as file:
            file.write(content)
    except FileExistsError:
        return
    os.chown(htaccess, 1000, 1000)


if __name__ == "__main__":
    main()
