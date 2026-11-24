<?php

if (!function_exists('env')) {
    require_once __DIR__ . '/env.php';
}

/**
* Memcache/Redis key salt
* @var string
*/
if (!defined('WP_CACHE_KEY_SALT')) {
    define('WP_CACHE_KEY_SALT', md5(defined('NONCE_KEY') ? NONCE_KEY : 'salt'));
}

/**
 * Use redis.
 * @var bool
 */
if (!defined('WP_REDIS_DISABLED')) {
    define('WP_REDIS_DISABLED', env('WP_REDIS_DISABLED', false));
}

/**
 * Redis hostname.
 * @var string
 */
if (!defined('WP_REDIS_HOST') && ($redisHost = env('REDIS_HOST', null)) !== null) {
    define('WP_REDIS_HOST', $redisHost);
}

/**
 * Redis connection scheme ("tcp" or "unix"). Set to "unix" together with
 * WP_REDIS_PATH to connect over a shared socket file instead of TCP.
 * @var string
 */
if (!defined('WP_REDIS_SCHEME') && ($redisScheme = env('REDIS_SCHEME', null)) !== null) {
    define('WP_REDIS_SCHEME', $redisScheme);
}

/**
 * Redis unix socket path, only used when WP_REDIS_SCHEME is "unix".
 * @var string
 */
if (!defined('WP_REDIS_PATH') && ($redisPath = env('REDIS_PATH', null)) !== null) {
    define('WP_REDIS_PATH', $redisPath);
}

/**
 * Use memcached.
 * @var bool
 */
if (!defined('WP_USE_MEMCACHED')) {
    define('WP_USE_MEMCACHED', env('WP_USE_MEMCACHED', false));
}
