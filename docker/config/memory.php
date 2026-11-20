<?php 

if (!function_exists('env')) {
    require_once __DIR__ . '/env.php';
}

/**
 * WordPress memory limit for front-end requests.
 *
 * WordPress raises PHP's memory_limit to this value on every request when it
 * is higher. By default it follows PHP's own memory_limit, which the runtime
 * image sets from PHP_MEMORY_LIMIT (default 256M), so PHP_MEMORY_LIMIT is the
 * single setting that decides how much memory a request may use. Set
 * WP_CONF_WP_MEMORY_LIMIT only to raise it for WordPress alone.
 *
 * The admin (and image processing) still uses WP_MAX_MEMORY_LIMIT, WordPress'
 * own default 256M, when that is higher.
 */

if (!defined('WP_MEMORY_LIMIT')) {
    define('WP_MEMORY_LIMIT', env('WP_MEMORY_LIMIT', ini_get('memory_limit') ?: '256M'));
}
