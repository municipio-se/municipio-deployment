<?php 

if (!function_exists('env')) {
    require_once __DIR__ . '/env.php';
}

/**
 * WordPress memory limit.
 *
 * Defaults to the PHP memory_limit the server already applies (set by
 * PHP_MEMORY_LIMIT in the OLS layer, docker/ols). WordPress raises
 * memory_limit to WP_MEMORY_LIMIT when it is higher, which would break the
 * server's sizing of PHP children by memory, so the two stay equal unless
 * WP_CONF_WP_MEMORY_LIMIT is set explicitly.
 */

if (!defined('WP_MEMORY_LIMIT')) {
    define('WP_MEMORY_LIMIT', env('WP_MEMORY_LIMIT', ini_get('memory_limit') ?: '512M'));
}