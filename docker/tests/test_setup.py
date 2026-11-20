import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import call, patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "setup"))

import setup
import setup_htaccess
import setup_install


class OpenLiteSpeedConfigurationTests(unittest.TestCase):
    def test_wp_conf_names_are_added_to_explicit_names(self):
        environment = {
            "OLS_PHP_ENV_VARS": "TIDEWAYS_APIKEY, OTHER_API_KEY WP_CONF_DB_NAME",
            "TIDEWAYS_APIKEY": "tideways-secret",
            "OTHER_API_KEY": "secret",
            "WP_CONF_DB_NAME": "municipio",
            "WP_CONF_EXTRA_TIDEWAYS_APIKEY": "wordpress-secret",
            "WP_CONFIGURATION": "not-forwarded",
            "UNRELATED_SECRET": "not-forwarded",
        }
        with patch.dict(os.environ, environment, clear=True):
            setup.forward_wp_conf_env()
            self.assertEqual(
                os.environ["OLS_PHP_ENV_VARS"],
                "TIDEWAYS_APIKEY,OTHER_API_KEY,WP_CONF_DB_NAME,WP_CONF_EXTRA_TIDEWAYS_APIKEY",
            )

    def test_no_names_leaves_variable_unset(self):
        with patch.dict(os.environ, {"UNRELATED_SECRET": "x"}, clear=True):
            setup.forward_wp_conf_env()
            self.assertNotIn("OLS_PHP_ENV_VARS", os.environ)

    def test_configure_runs_base_image_script_with_forwarded_names(self):
        seen = {}

        def run(command):
            seen["command"] = command
            seen["names"] = os.environ.get("OLS_PHP_ENV_VARS")
            return subprocess.CompletedProcess(command, 0)

        with patch.dict(os.environ, {"WP_CONF_DB_NAME": "municipio"}, clear=True), \
             patch.object(setup.subprocess, "run", side_effect=run):
            setup.configure_ols()

        self.assertEqual(seen, {"command": [setup.OLS_CONFIGURE], "names": "WP_CONF_DB_NAME"})

    def test_configure_failure_stops_startup_with_its_exit_code(self):
        with patch.dict(os.environ, {}, clear=True), \
             patch.object(setup.subprocess, "run",
                          return_value=subprocess.CompletedProcess([], 1)):
            with self.assertRaises(SystemExit) as raised:
                setup.configure_ols()
        self.assertEqual(raised.exception.code, 1)

    def test_main_configures_before_wordpress_setup_and_then_execs_entrypoint(self):
        calls = []
        with tempfile.TemporaryDirectory() as directory, \
             patch.object(setup, "ROOT_DIR", Path(directory)), \
             patch.object(setup, "configure_ols", side_effect=lambda: calls.append("configure")), \
             patch.object(setup.setup_htaccess, "main", side_effect=lambda: calls.append("htaccess")), \
             patch.object(setup.setup_install, "main", side_effect=lambda: calls.append("install")), \
             patch.object(setup.os, "execv", side_effect=lambda *a: calls.append("exec")), \
             patch.object(setup.sys, "argv", ["setup.py"]):
            setup.main()
        self.assertEqual(calls, ["configure", "htaccess", "install", "exec"])


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
