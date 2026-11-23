<?php 

if (!function_exists('env')) {
    require_once __DIR__ . '/env.php';
}

/**
 * WordPress memory limit. This setting should be as
 * low as possible to enshure that site runs smoothly.
 *
 * Default value is intentionally 'high' to avoid
 * crashes in setup process. A good value for production
 * may be as low as 128M but will vary.
 *
 */

if (!defined('WP_MEMORY_LIMIT')) {
    define('WP_MEMORY_LIMIT', env('WP_MEMORY_LIMIT', '512M'));
}