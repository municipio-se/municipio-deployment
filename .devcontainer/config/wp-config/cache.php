<?php

/**
 * Use local varnish server.
 * @var string
 */
define('VHP_VARNISH_IP', '127.0.0.1');

/**
 * Memcache/Redis key salt
 * @var string
 */
define('WP_CACHE_KEY_SALT', md5(NONCE_KEY));

/**
 * Use redis.
 * @var bool
 */
define('WP_REDIS_DISABLED', true);
define('WP_REDIS_HOST', 'redis');

/**
 * Use memcached.
 * @var bool
 */
define('WP_USE_MEMCACHED', false);


/**
 * Nginx helper, cache path.
 */
define('RT_WP_NGINX_HELPER_CACHE_PATH', '/var/lib/nginx/fastcgi_cache/');

/**
 * Blade cache path.
 */
define('BLADE_CACHE_PATH', dirname(__FILE__) . '/../wp-content/uploads/cache/blade-cache');
