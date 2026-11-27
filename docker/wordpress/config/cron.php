<?php

if (!function_exists('env')) {
    require_once __DIR__ . '/env.php';
}

/**
 * Disable wp-cron
 *
 * Note: When disable wp-cron, you must run it by
 * cron on your local machine periodically. Recommended
 * way of doint this is by wp-cli. Please
 *
 * Documentation: https://developer.wordpress.org/cli/commands/cron/event/run/
 *
 * @var bool
 */
if (!defined('DISABLE_WP_CRON')) {
    define('DISABLE_WP_CRON', env('DISABLE_WP_CRON', true));
}