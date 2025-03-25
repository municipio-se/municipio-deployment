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

require_once __DIR__ . '/config/memory.php';
require_once __DIR__ . '/config/salts.php';
require_once __DIR__ . '/config/content.php';
require_once __DIR__ . '/config/database.php';
require_once __DIR__ . '/config/plugins.php';
require_once __DIR__ . '/config/update.php';
require_once __DIR__ . '/config/upload.php';
require_once __DIR__ . '/config/cron.php';

/**
 * Active directory configuration
 *
 * Configuration for the active directory login functionality
 */
if (file_exists(__DIR__ . '/config/ad.php')) {
    require_once __DIR__ . '/config/ad.php';
}

/**
 * Search concfiguration
 *
 * Configuration for the search functionality
 */
if (file_exists(__DIR__ . '/config/search.php')) {
    require_once __DIR__ . '/config/search.php';
}

/**
 * Sentry error tracking.
 *
 * Configuration for the error tracking functionality
 */
if (file_exists(__DIR__ . '/config/sentry.php')) {
    require_once __DIR__ . '/config/sentry.php';
}

/**
 * Cookie settings
 *
 * To enable this site as a multisite please rename the config/cookie-example.php file to
 * cookie.php, then go ahead and edit the configurations
 */
if (file_exists(__DIR__ . '/config/cookie.php')) {
    require_once __DIR__ . '/config/cookie.php';
}

/**
 * Cache settings
 *
 * To enable this site as a multisite please rename the config/cache-example.php file to
 * cache.php, then go ahead and edit the configurations
 */
if (file_exists(__DIR__ . '/config/cache.php')) {
    require_once __DIR__ . '/config/cache.php';
}

/**
 * Script settings
 */
if (file_exists(__DIR__ . '/config/scripts.php')) {
    require_once __DIR__ . '/config/scripts.php';
}

/**
 * Multisite settings
 *
 * To enable this site as a multisite please rename the config/multisite-example.php file to
 * multisite.php, then go ahead and edit the configurations
 */
if (file_exists(__DIR__ . '/config/multisite.php')) {
    require_once __DIR__ . '/config/multisite.php';
}

/**
 * Developer settings
 *
 * You can create a file called "developer.php" in the config dir and
 * put your dev-stuff and overrides inside.
 */
if (file_exists(__DIR__ . '/config/developer.php')) {
    require_once __DIR__ . '/config/developer.php';
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
