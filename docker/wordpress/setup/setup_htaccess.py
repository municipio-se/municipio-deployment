#!/usr/bin/env python3
"""Install the document root .htaccess for this site type.

The files in htaccess/ are complete and static; one is copied over the
document root's .htaccess on every container start, so the site always runs
exactly the rules in the repository. The copy is owned by root and not
writable by WordPress or plugins: OpenLiteSpeed only reads the root
.htaccess when the server starts, so runtime edits would not apply anyway.
"""
from __future__ import annotations

import os
import shutil
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parent.parent


def env(name: str, default: str = "") -> str:
    """Read WP_CONF_<name>, falling back to <name>, then to default.

    Empty values count as unset, like bash's ${VAR:-default}.
    """
    return os.environ.get("WP_CONF_" + name) or os.environ.get(name) or default


def flavor() -> str:
    """Name of the .htaccess flavor for WP_ALLOW_MULTISITE / SUBDOMAIN_INSTALL."""
    if env("WP_ALLOW_MULTISITE", "false") != "true":
        return "single-site"
    if env("SUBDOMAIN_INSTALL", "false") == "true":
        return "multisite-subdomain"
    return "multisite-subfolder"


def main() -> None:
    source = ROOT_DIR / "htaccess" / f"{flavor()}.htaccess"
    target = ROOT_DIR / ".htaccess"
    temporary = target.with_name(".htaccess.tmp")

    shutil.copyfile(source, temporary)
    os.chown(temporary, 0, 0)
    os.chmod(temporary, 0o644)
    # Atomic replace; also replaces a symlink or a plugin-edited file.
    os.replace(temporary, target)
    print(f"setup_htaccess.py: installed {source.name} as .htaccess")


if __name__ == "__main__":
    main()
