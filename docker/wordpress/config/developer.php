<?php

if (!function_exists('env')) {
    require_once __DIR__ . '/env.php';
}

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the Codex.
 *
 * @link https://codex.wordpress.org/Debugging_in_WordPress
 */

if (($wpDebug = env('WP_DEBUG', null)) !== null) {
    define('WP_DEBUG', (bool) $wpDebug);
}

// Activate debug mode on all environments using ?debug flag.
if (isset($_GET['debug']) && !defined('WP_DEBUG')) {
    define('WP_DEBUG', true);
}

if (($wpSiteUrl = env('WP_SITEURL', null)) !== null) {
    define('WP_SITEURL', $wpSiteUrl);
}

if (($wpHome = env('WP_HOME', null)) !== null) {
    define('WP_HOME', $wpHome);
}
