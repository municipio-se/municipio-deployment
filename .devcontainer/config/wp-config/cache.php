<?php

$devcontainerCacheEnabled = file_exists(__DIR__ . '/.cache-enabled');

define('WP_CACHE', $devcontainerCacheEnabled);

/**
 * Memcache/Redis key salt
 * @var string
 */
define('WP_CACHE_KEY_SALT', md5(NONCE_KEY));

/**
 * Use redis.
 * @var bool
 */
define('WP_REDIS_DISABLED', !$devcontainerCacheEnabled);
define('WP_REDIS_HOST', 'redis');

/**
 * Use memcached.
 * @var bool
 */
define('WP_USE_MEMCACHED', false);

/**
 * Blade cache path.
 */
define('BLADE_CACHE_PATH', dirname(__FILE__) . '/../wp-content/uploads/cache/blade-cache');
