#!/usr/bin/env python3
"""Bootstraps WordPress against an empty database, respecting the same
WP_ALLOW_MULTISITE / SUBDOMAIN_INSTALL environment variables used by
setup_htaccess.py and wp-config. This is a no-op once WordPress
has already been installed, so it is safe to run on every container start.
"""
from __future__ import annotations

import subprocess
import sys
import time
from pathlib import Path

from setup_htaccess import env

ROOT_DIR = Path(__file__).resolve().parent.parent

MAX_TRIES = 10


def wp(*args: str, check: bool = True) -> int:
    """Run a WP-CLI command from the WordPress root and return its exit code.

    With check, a failing command exits this script with the same code.
    """
    code = subprocess.run(["runuser", "-u", "ubuntu", "--", "wp", *args], cwd=ROOT_DIR).returncode
    if check and code != 0:
        sys.exit(code)
    return code


def require(name: str, message: str, default: str = "") -> str:
    value = env(name, default)
    if not value:
        print(f"setup_install.py: {message}", file=sys.stderr)
        sys.exit(1)
    return value


def main() -> None:
    allow_multisite = env("WP_ALLOW_MULTISITE", "false")
    subdomain = env("SUBDOMAIN_INSTALL", "false")

    if wp("core", "is-installed", check=False) == 0:
        return

    tries = 0
    while wp("db", "check", check=False) != 0:
        tries += 1
        if tries >= MAX_TRIES:
            print(
                "setup_install.py: database never became reachable, aborting install.",
                file=sys.stderr,
            )
            sys.exit(1)
        time.sleep(2)

    admin_user = require(
        "WP_ADMIN_USER",
        "WP_ADMIN_USER (or WP_CONF_WP_ADMIN_USER) must be set to install WordPress",
    )
    admin_password = require(
        "WP_ADMIN_PASSWORD",
        "WP_ADMIN_PASSWORD (or WP_CONF_WP_ADMIN_PASSWORD) must be set to install WordPress",
    )
    admin_email = require(
        "WP_ADMIN_EMAIL",
        "WP_ADMIN_EMAIL (or WP_CONF_WP_ADMIN_EMAIL) must be set to install WordPress",
    )
    site_title = env("WP_SITE_TITLE", "WordPress")

    if allow_multisite == "true":
        install_url = require(
            "DOMAIN_CURRENT_SITE",
            "DOMAIN_CURRENT_SITE (or WP_CONF_DOMAIN_CURRENT_SITE) must be set to install a WordPress multisite network",
        )
    else:
        install_url = require(
            "WP_HOME",
            "WP_HOME (or WP_CONF_WP_HOME) must be set to install WordPress",
        )

    install_args = [
        f"--url={install_url}",
        f"--title={site_title}",
        f"--admin_user={admin_user}",
        f"--admin_password={admin_password}",
        f"--admin_email={admin_email}",
        "--skip-email",
    ]

    if allow_multisite == "true":
        if subdomain == "true":
            install_args.append("--subdomains")
        # Installs core, creates the network row in wp_site, and registers the
        # main site in wp_blogs in a single step (no manual "Network Setup" needed).
        wp("core", "multisite-install", *install_args)
    else:
        wp("core", "install", *install_args)

    wp("rewrite", "flush", "--hard")


if __name__ == "__main__":
    main()
