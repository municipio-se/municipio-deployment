<?php

/**
 * Memcache/Redis key salt
 * @var string
 */
define('WP_CACHE_KEY_SALT', md5(NONCE_KEY));

/**
 * Use redis.
 * @var bool
 */
define('WP_REDIS_DISABLED', false);
define('WP_REDIS_HOST', 'redis');
define('S3_UPLOADS_BUCKET', 'municipio');
define('S3_UPLOADS_KEY', 'minioadmin');
define('S3_UPLOADS_SECRET', 'minioadmin');
define('S3_UPLOADS_REGION', 'us-east-1');
define('S3_UPLOADS_CUSTOM_ENDPOINT', 'http://minio:9000');
define('S3_UPLOADS_BUCKET_URL', 'http://localhost:9000/municipio');

/**
 * Use memcached.
 * @var bool
 */
define('WP_USE_MEMCACHED', false);

/**
 * Blade cache path.
 */
define('BLADE_CACHE_PATH', dirname(__FILE__) . '/../wp-content/uploads/cache/blade-cache');
