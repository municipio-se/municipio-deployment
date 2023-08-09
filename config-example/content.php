<?php

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
 define('WP_DEFAULT_THEME', 'municipio');

/**
 * Limit number of post revisions per post
 * @var integer
 */
define('WP_POST_REVISIONS', 10);

/**
 * Set the autosave interval
 * @default: 60 seconds
 * @var integer
 */
define('AUTOSAVE_INTERVAL', 60);

/**
 * Change the time interval for how often the trash will empty itself
 * @default: 30 days
 * @var integer
 */
define('EMPTY_TRASH_DAYS', 30);

/**
 * Disable the WordPress theme/plugin editor
 */
define('DISALLOW_FILE_EDIT', true);
