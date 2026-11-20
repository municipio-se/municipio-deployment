#!/usr/bin/env python3
"""Container entrypoint: prepares the configuration, installs WordPress if
needed, then hands over to the OpenLiteSpeed entrypoint."""
from __future__ import annotations

import os
import re
import subprocess
import sys
from pathlib import Path

import setup_htaccess
import setup_install

ROOT_DIR = Path(__file__).resolve().parent.parent
OLS_CONFIGURE = "/usr/local/bin/ols-hbg-configure"
OLS_ENTRYPOINT = "/entrypoint.sh"

WP_CONF_NAME = re.compile(r"WP_CONF_[A-Za-z0-9_]+")


def forward_wp_conf_env() -> None:
    """Add every WP_CONF_* variable to OLS_PHP_ENV_VARS, so web PHP sees them
    in addition to any names listed explicitly."""
    names = [name for name in re.split(r"[,\s]+", os.environ.get("OLS_PHP_ENV_VARS", "")) if name]
    names += sorted(
        name for name in os.environ
        if WP_CONF_NAME.fullmatch(name) and name not in names
    )
    if names:
        os.environ["OLS_PHP_ENV_VARS"] = ",".join(names)


def configure_ols() -> None:
    """Apply the base image's runtime configuration (OLS tuning, lsphp env,
    PHP_INI_SETTINGS, PHP_EXTENSIONS) now, so the WP-CLI steps below see the
    same PHP settings as web requests. /entrypoint.sh runs it again; it is
    idempotent."""
    forward_wp_conf_env()
    code = subprocess.run([OLS_CONFIGURE]).returncode
    if code != 0:
        sys.exit(code)


def main() -> None:
    # Ensure no stale .env file exists in webroot
    (ROOT_DIR / ".env").unlink(missing_ok=True)

    configure_ols()

    # Configure .htaccess rules
    setup_htaccess.main()

    # Bootstrap the WordPress installation
    setup_install.main()

    print("Configuration setup completed.")
    print("Starting litespeed.")

    # Flush before exec, or buffered output is lost when stdout isn't a tty.
    sys.stdout.flush()
    sys.stderr.flush()
    os.execv(OLS_ENTRYPOINT, [OLS_ENTRYPOINT, *sys.argv[1:]])


if __name__ == "__main__":
    main()
