<?php
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

 $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? 'https://' : 'http://';
 $host = $_SERVER['HTTP_HOST'];

// Activate debug mode on all environments using ?debug flag. 
if (isset($_GET['debug'])) {
  define('WP_DEBUG', true);
}

if (!defined('WP_SITEURL')) {
  define('WP_SITEURL', $protocol . $host . '/wp');
}

if (!defined('WP_HOME')) {
  define('WP_HOME', $protocol . $host);
}

if (!defined('WP_ENVIRONMENT_TYPE')) {
  define('WP_ENVIRONMENT_TYPE', 'local');
}

if (!defined('IS_DEVCONTAINER')) {
  define('IS_DEVCONTAINER', true);
}