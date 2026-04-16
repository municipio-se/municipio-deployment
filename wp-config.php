<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://codex.wordpress.org/Editing_wp-config.php
 *
 * @package WordPress
 */

/**
 * Config files
 *
 * All declared configuration files are loaded if they exist.
 */
$configFiles = [
    'memory.php',
    'salts.php',
    'content.php',
    'database.php',
    'plugins.php',
    'update.php',
    'upload.php',
    'cron.php',
    'ad.php',
    'search.php',
    'sentry.php',
    'cookie.php',
    'cache.php',
    'scripts.php',
    'multisite.php',
    'developer.php',
    'tideways.php',
];

foreach ($configFiles as $configFile) {
    $configPath = __DIR__ . '/config/' . $configFile;

    if (file_exists($configPath)) {
        require_once $configPath;
    }
}

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if (!defined('ABSPATH')) {
    define('ABSPATH', dirname(__FILE__) . '/');
}

/**
 * Autoload Vendor files or display install instructions.
 */
if(file_exists(__DIR__ . '/vendor/autoload.php')) {
    require_once __DIR__ . '/vendor/autoload.php';
} else {
    die(file_get_contents(__DIR__ . '/install.html'));  
}

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
