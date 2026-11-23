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


def main() -> None:
    # Ensure no stale .env file exists in webroot
    (ROOT_DIR / ".env").unlink(missing_ok=True)

    # Configure PHP first, so WP-CLI below runs with the same PHP settings as
    # web requests. /entrypoint.sh runs it again; it is idempotent.
    subprocess.run([OLS_CONFIGURE], check=True)

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
