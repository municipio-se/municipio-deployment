#!/usr/bin/env python3
"""Container entrypoint: prepares the configuration, installs WordPress if
needed, then hands over to the OpenLiteSpeed entrypoint."""
from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

import setup_htaccess
import setup_install

ROOT_DIR = Path(__file__).resolve().parent.parent
# Writes all OpenLiteSpeed and PHP runtime config (sizing, ini settings, the
# environment forwarded to web PHP). Lives in the OLS layer, docker/ols/.
OLS_CONFIGURE = "/usr/local/bin/ols-hbg-configure"
OLS_ENTRYPOINT = "/entrypoint.sh"
# WP_CONF_* values for WordPress, read by config/env.php. Outside the
# document root, so it can't be fetched over HTTP.
WP_CONF_FILE = ROOT_DIR.parent / "wp-conf.php"
# Owner of the webroot; lsphp and WP-CLI run as this user.
SITE_UID = SITE_GID = 1000

# PHP writes the file itself, so var_export() handles quoting of any value.
WRITE_WP_CONF = r"""
$values = array_filter(
    getenv(),
    static fn (string $name): bool => str_starts_with($name, 'WP_CONF_'),
    ARRAY_FILTER_USE_KEY
);
ksort($values);
file_put_contents(
    $argv[1],
    "<?php\n// Generated from WP_CONF_* variables at container start. Do not edit.\nreturn "
        . var_export($values, true) . ";\n"
);
"""


def write_wp_conf() -> None:
    """Write the WP_CONF_* environment variables to WP_CONF_FILE.

    WordPress reads its settings from this file instead of the web server's
    environment, so they never appear in getenv(), $_SERVER or phpinfo().
    """
    temporary = WP_CONF_FILE.with_name(f".{WP_CONF_FILE.name}.tmp")
    temporary.unlink(missing_ok=True)
    old_umask = os.umask(0o077)
    try:
        subprocess.run(["php", "-r", WRITE_WP_CONF, str(temporary)], check=True)
    finally:
        os.umask(old_umask)
    os.chown(temporary, SITE_UID, SITE_GID)
    os.chmod(temporary, 0o400)
    os.replace(temporary, WP_CONF_FILE)


def main() -> None:
    # Ensure no stale .env file exists in webroot
    (ROOT_DIR / ".env").unlink(missing_ok=True)

    # Configure PHP first, so WP-CLI below runs with the same PHP settings as
    # web requests.
    subprocess.run([OLS_CONFIGURE], check=True)

    # WordPress settings for web requests and WP-CLI.
    write_wp_conf()

    # Configure .htaccess rules
    setup_htaccess.main()

    # Bootstrap the WordPress installation
    setup_install.main()

    print("Configuration setup completed.")
    print("Starting litespeed.")

    # Flush before exec, or buffered output is lost when stdout isn't a tty.
    sys.stdout.flush()
    sys.stderr.flush()
    # The configuration above is current, so /entrypoint.sh can skip it.
    os.environ["OLS_HBG_CONFIGURED"] = "1"
    os.execv(OLS_ENTRYPOINT, [OLS_ENTRYPOINT, *sys.argv[1:]])


if __name__ == "__main__":
    main()
