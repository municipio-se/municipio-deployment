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


class OpenLiteSpeedEnvironmentTests(unittest.TestCase):
    def create_php_ini_dir(self, root, lsphp="lsphp83", version="8.3"):
        ini_dir = root / lsphp / "etc" / "php" / version / "mods-available"
        ini_dir.mkdir(parents=True)
        return ini_dir

    def test_wordpress_settings_reach_lsphp_without_forwarding_other_secrets(self):
        with tempfile.TemporaryDirectory() as directory:
            config = Path(directory) / "httpd_config.conf"
            config.write_text("extProcessor lsphp{\n    type lsapi\n}\n")
            environment = {
                "TIDEWAYS_APIKEY": "tideways-secret",
                "TIDEWAYS_FUTURE_SETTING": "enabled",
                "WP_CONF_EXTRA_TIDEWAYS_APIKEY": "wordpress-secret",
                "WP_CONF_DB_NAME": "municipio",
                "TIDEWAYS_OTHER-INVALID": "not-forwarded",
                "UNRELATED_SECRET": "not-forwarded",
            }
            with patch.dict(os.environ, environment, clear=True), \
                 patch.object(setup, "OLS_CONF", config):
                setup.inject_ols_env()

            self.assertEqual(config.read_text(), (
                "extProcessor lsphp{\n"
                "    env WP_CONF_EXTRA_TIDEWAYS_APIKEY=wordpress-secret\n"
                "    env WP_CONF_DB_NAME=municipio\n"
                "    type lsapi\n"
                "}\n"
            ))

    def test_explicit_names_forward_other_environment_variables(self):
        with tempfile.TemporaryDirectory() as directory:
            config = Path(directory) / "httpd_config.conf"
            config.write_text("extProcessor lsphp{\n    type lsapi\n}\n")
            environment = {
                "OLS_PHP_ENV_VARS": "TIDEWAYS_APIKEY, OTHER_API_KEY, CUSTOM_SETTING, OTHER_API_KEY",
                "TIDEWAYS_APIKEY": "tideways-secret",
                "TIDEWAYS_FUTURE_SETTING": "not-forwarded",
                "OTHER_API_KEY": "secret",
                "CUSTOM_SETTING": "enabled",
                "UNRELATED_SECRET": "not-forwarded",
            }
            with patch.dict(os.environ, environment, clear=True), \
                 patch.object(setup, "OLS_CONF", config):
                setup.inject_ols_env()

            self.assertEqual(config.read_text(), (
                "extProcessor lsphp{\n"
                "    env TIDEWAYS_APIKEY=tideways-secret\n"
                "    env OTHER_API_KEY=secret\n"
                "    env CUSTOM_SETTING=enabled\n"
                "    type lsapi\n"
                "}\n"
            ))

    def test_php_ini_settings_are_written_without_forwarding_multiline_values(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            config = root / "httpd_config.conf"
            ini_dir = self.create_php_ini_dir(root, "lsphp84", "8.4")
            config.write_text("extProcessor lsphp{\n    type lsapi\n}\n")
            environment = {
                "PHP_INI_SETTINGS": "allow_url_include=0\nupload_max_filesize=64M",
            }
            with patch.dict(os.environ, environment, clear=True), \
                 patch.object(setup, "OLS_CONF", config), \
                 patch.object(setup, "LSWS_DIR", root):
                setup.inject_ols_env()
                self.assertNotIn("PHP_INI_SCAN_DIR", os.environ)

            self.assertEqual(
                (ini_dir / setup.PHP_INI_FILE).read_text(),
                "allow_url_include=0\nupload_max_filesize=64M\n",
            )
            self.assertEqual(config.read_text(), "extProcessor lsphp{\n    type lsapi\n}\n")

    def test_php_ini_settings_use_default_scan_directory_and_reject_invalid_lines(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            config = root / "httpd_config.conf"
            ini_dir = self.create_php_ini_dir(root)
            original = "extProcessor lsphp{\n    type lsapi\n}\n"
            config.write_text(original)

            with patch.dict(os.environ, {"PHP_INI_SETTINGS": "allow_url_include=0"},
                            clear=True), \
                 patch.object(setup, "OLS_CONF", config), \
                 patch.object(setup, "LSWS_DIR", root):
                setup.inject_ols_env()
                self.assertNotIn("PHP_INI_SCAN_DIR", os.environ)

            config.write_text(original)
            with patch.dict(os.environ, {
                "PHP_INI_SETTINGS": "allow_url_include=0\nunexpected config",
            }, clear=True), patch.object(setup, "OLS_CONF", config), \
                 patch.object(setup, "LSWS_DIR", root):
                with self.assertRaisesRegex(ValueError, "Invalid PHP ini directive"):
                    setup.inject_ols_env()

            self.assertEqual(config.read_text(), original)
            self.assertEqual((ini_dir / setup.PHP_INI_FILE).read_text(),
                             "allow_url_include=0\n")

    def test_php_ini_settings_fail_when_scan_directory_is_missing_or_ambiguous(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            with patch.dict(os.environ, {"PHP_INI_SETTINGS": "memory_limit=128M"},
                            clear=True), patch.object(setup, "LSWS_DIR", root):
                with self.assertRaisesRegex(RuntimeError, "found 0"):
                    setup.configure_php_ini()

                first = self.create_php_ini_dir(root)
                second = self.create_php_ini_dir(root, "lsphp84", "8.4")
                with self.assertRaisesRegex(RuntimeError, "found 2"):
                    setup.configure_php_ini()

            self.assertFalse((first / setup.PHP_INI_FILE).exists())
            self.assertFalse((second / setup.PHP_INI_FILE).exists())

    def test_invalid_or_missing_explicit_names_fail_setup(self):
        for names, environment in (
            ("MISSING_KEY", {}),
            ("INVALID-NAME", {"INVALID-NAME": "secret"}),
            ("CUSTOM_SETTING,", {"CUSTOM_SETTING": "enabled"}),
        ):
            with self.subTest(names=names), tempfile.TemporaryDirectory() as directory:
                config = Path(directory) / "httpd_config.conf"
                original = "extProcessor lsphp{\n    type lsapi\n}\n"
                config.write_text(original)
                with patch.dict(os.environ, {"OLS_PHP_ENV_VARS": names, **environment}, clear=True), \
                     patch.object(setup, "OLS_CONF", config):
                    with self.assertRaises(ValueError):
                        setup.inject_ols_env()
                self.assertEqual(config.read_text(), original)


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
