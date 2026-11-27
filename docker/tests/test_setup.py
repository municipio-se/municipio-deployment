import os
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import call, patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "wordpress" / "setup"))

import setup
import setup_htaccess
import setup_install


class StartupOrderTests(unittest.TestCase):
    def test_php_is_configured_before_wordpress_setup_and_server_start(self):
        order = []
        with patch.object(setup.subprocess, "run",
                          side_effect=lambda args, check: order.append(args[0])) as run, \
             patch.object(setup, "write_wp_conf", side_effect=lambda: order.append("wp-conf")), \
             patch.object(setup_htaccess, "main", side_effect=lambda: order.append("htaccess")), \
             patch.object(setup_install, "main", side_effect=lambda: order.append("install")), \
             patch.dict(setup.os.environ, {}, clear=False), \
             patch.object(setup.os, "execv",
                          side_effect=lambda path, args: order.append((path, setup.os.environ.get("OLS_HBG_CONFIGURED")))), \
             patch.object(setup, "ROOT_DIR", Path(tempfile.mkdtemp())):
            setup.main()

        run.assert_called_once_with([setup.OLS_CONFIGURE], check=True)
        # /entrypoint.sh is told the configuration is current, so it doesn't redo it.
        self.assertEqual(order, [setup.OLS_CONFIGURE, "wp-conf", "htaccess", "install", (setup.OLS_ENTRYPOINT, "1")])


class HtaccessSetupTests(unittest.TestCase):
    FLAVORS = ("single-site", "multisite-subdomain", "multisite-subfolder")
    # The flavor files in the repository (copied to htaccess/ in the image).
    REPO_HTACCESS = Path(__file__).resolve().parents[1] / "wordpress" / "htaccess"

    def run_setup(self, root, environment):
        with patch.dict(os.environ, environment, clear=True), \
             patch.object(setup_htaccess, "ROOT_DIR", root), \
             patch.object(setup_htaccess.os, "chown") as chown:
            setup_htaccess.main()
        return chown

    def make_root(self, directory):
        root = Path(directory)
        (root / "htaccess").mkdir()
        for name in self.FLAVORS:
            (root / "htaccess" / f"{name}.htaccess").write_text(name)
        return root

    def test_flavor_is_selected_from_multisite_settings(self):
        cases = [
            ({}, "single-site"),
            ({"WP_CONF_WP_ALLOW_MULTISITE": "false", "WP_CONF_SUBDOMAIN_INSTALL": "true"}, "single-site"),
            ({"WP_CONF_WP_ALLOW_MULTISITE": "true"}, "multisite-subfolder"),
            ({"WP_CONF_WP_ALLOW_MULTISITE": "true", "WP_CONF_SUBDOMAIN_INSTALL": "false"}, "multisite-subfolder"),
            ({"WP_CONF_WP_ALLOW_MULTISITE": "true", "WP_CONF_SUBDOMAIN_INSTALL": "true"}, "multisite-subdomain"),
            ({"WP_ALLOW_MULTISITE": "true", "SUBDOMAIN_INSTALL": "true"}, "multisite-subdomain"),
        ]
        for environment, expected in cases:
            with self.subTest(environment=environment), tempfile.TemporaryDirectory() as directory:
                root = self.make_root(directory)
                chown = self.run_setup(root, environment)
                htaccess = root / ".htaccess"
                self.assertEqual(htaccess.read_text(), expected)
                self.assertEqual(htaccess.stat().st_mode & 0o777, 0o644)
                chown.assert_called_once_with(root / ".htaccess.tmp", 0, 0)
                self.assertFalse((root / ".htaccess.tmp").exists())

    def test_existing_file_and_symlink_are_replaced_on_every_start(self):
        for kind in ("file", "symlink"):
            with self.subTest(kind=kind), tempfile.TemporaryDirectory() as directory:
                root = self.make_root(directory)
                htaccess = root / ".htaccess"
                if kind == "file":
                    htaccess.write_text("rules edited by a plugin")
                    htaccess.chmod(0o600)
                else:
                    (root / "elsewhere").write_text("keep me")
                    htaccess.symlink_to(root / "elsewhere")

                self.run_setup(root, {"WP_CONF_WP_ALLOW_MULTISITE": "true"})

                self.assertFalse(htaccess.is_symlink())
                self.assertEqual(htaccess.read_text(), "multisite-subfolder")
                self.assertEqual(htaccess.stat().st_mode & 0o777, 0o644)
                if kind == "symlink":
                    self.assertEqual((root / "elsewhere").read_text(), "keep me")

    def test_repository_flavors_hold_only_the_wordpress_block(self):
        # Rules shared by all site types belong in docker/ols/config/vhost.conf,
        # so each flavor file is comments plus exactly one WordPress block.
        for name in self.FLAVORS:
            with self.subTest(flavor=name):
                text = (self.REPO_HTACCESS / f"{name}.htaccess").read_text()
                self.assertEqual(text.count("# BEGIN "), 1, name)
                start = text.index("# BEGIN WordPress\n")
                self.assertTrue(text.endswith("# END WordPress\n"), name)
                before = [line for line in text[:start].splitlines() if line.strip()]
                self.assertTrue(all(line.startswith("#") for line in before),
                                f"{name}.htaccess has rules outside the WordPress block; "
                                "move rules shared by all site types to vhost.conf")


class InstallationSetupTests(unittest.TestCase):
    def test_installed_site_does_not_flush_rewrite_rules(self):
        with patch.object(setup_install, "wp", return_value=0) as wp:
            setup_install.main()

        wp.assert_called_once_with("core", "is-installed", check=False)

    def test_first_install_still_flushes_rewrite_rules(self):
        environment = {
            "WP_HOME": "https://example.test",
            "WP_ADMIN_USER": "admin",
            "WP_ADMIN_PASSWORD": "password",
            "WP_ADMIN_EMAIL": "admin@example.test",
        }
        with patch.dict(os.environ, environment, clear=True), \
             patch.object(setup_install, "wp", side_effect=[1, 0, 0, 0]) as wp:
            setup_install.main()

        self.assertEqual(wp.call_args_list[0:2], [
            call("core", "is-installed", check=False),
            call("db", "check", check=False),
        ])
        self.assertEqual(wp.call_args_list[2].args[:2], ("core", "install"))
        self.assertEqual(wp.call_args_list[3], call("rewrite", "flush"))


if __name__ == "__main__":
    unittest.main()
