<?php

if (!function_exists('env')) {
    require_once __DIR__ . '/env.php';
}

/**
 * Tell WordPress to load from local wp-content, and not vendor wp.
 */
define('WP_CONTENT_DIR', dirname(dirname(__FILE__)) . '/wp-content');
if($contentHost = isset($_SERVER['HTTP_HOST']) ? $_SERVER['HTTP_HOST'] : false) {
  define('WP_CONTENT_URL', 'http://' . $contentHost . '/wp-content');
}

/**
 * Use municipio as default theme.
 * @var string
 */
if (!defined('WP_DEFAULT_THEME')) {
    define('WP_DEFAULT_THEME', env('WP_DEFAULT_THEME', 'municipio'));
}

/**
 * Limit number of post revisions per post
 * @var integer
 */
if (!defined('WP_POST_REVISIONS')) {
    define('WP_POST_REVISIONS', env('WP_POST_REVISIONS', 10));
}

/**
 * Set the autosave interval
 * @default: 60 seconds
 * @var integer
 */
if (!defined('AUTOSAVE_INTERVAL')) {
    define('AUTOSAVE_INTERVAL', env('AUTOSAVE_INTERVAL', 60));
}

/**
 * Change the time interval for how often the trash will empty itself
 * @default: 30 days
 * @var integer
 */
if (!defined('EMPTY_TRASH_DAYS')) {
    define('EMPTY_TRASH_DAYS', env('EMPTY_TRASH_DAYS', 30));
}

/**
 * Disable the WordPress theme/plugin editor
 */
if (!defined('DISALLOW_FILE_EDIT')) {
    define('DISALLOW_FILE_EDIT', env('DISALLOW_FILE_EDIT', true));
}
