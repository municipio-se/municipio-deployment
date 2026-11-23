import os
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import call, patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "setup"))

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
    def test_missing_file_uses_selected_template_and_cache_rules(self):
        cases = [
            ({}, ".htaccess", False),
            ({"WP_CONF_WP_ALLOW_MULTISITE": "true", "WP_CONF_SUBDOMAIN_INSTALL": "true"},
             ".htaccess-multisite-subdomain", False),
            ({"WP_CONF_WP_ALLOW_MULTISITE": "true"},
             ".htaccess-multisite-subfolder", False),
            ({"WP_CONF_ENABLE_LS_CACHE": "true"}, ".htaccess", True),
        ]
        for environment, selected, cache_enabled in cases:
            with self.subTest(environment=environment), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                templates = root / "htaccess"
                templates.mkdir()
                for name in (".htaccess", ".htaccess-multisite-subdomain",
                             ".htaccess-multisite-subfolder"):
                    (templates / name).write_bytes(name.encode())

                with patch.dict(os.environ, environment, clear=True), \
                     patch.object(setup_htaccess, "ROOT_DIR", root), \
                     patch.object(setup_htaccess.os, "chown") as chown:
                    setup_htaccess.main()

                expected = (setup_htaccess.LSCACHE_RULES.encode() if cache_enabled else b"")
                self.assertEqual((root / ".htaccess").read_bytes(), expected + selected.encode())
                chown.assert_called_once_with(root / ".htaccess", 1000, 1000)

    def test_existing_file_is_unchanged_when_settings_change(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            htaccess = root / ".htaccess"
            htaccess.write_bytes(b"custom plugin rules")
            htaccess.chmod(0o600)

            environment = {
                "WP_CONF_WP_ALLOW_MULTISITE": "true",
                "WP_CONF_SUBDOMAIN_INSTALL": "true",
                "WP_CONF_ENABLE_LS_CACHE": "true",
            }
            with patch.dict(os.environ, environment, clear=True), \
                 patch.object(setup_htaccess, "ROOT_DIR", root), \
                 patch.object(setup_htaccess.os, "chown") as chown:
                setup_htaccess.main()

            self.assertEqual(htaccess.read_bytes(), b"custom plugin rules")
            self.assertEqual(htaccess.stat().st_mode & 0o777, 0o600)
            chown.assert_not_called()


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
        self.assertEqual(wp.call_args_list[3], call("rewrite", "flush", "--hard"))


if __name__ == "__main__":
    unittest.main()
