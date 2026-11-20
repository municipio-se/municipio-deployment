<?php
/**
 * WordPress configuration for the container image.
 *
 * Every environment variable named WP_CONF_<NAME> defines the PHP constant
 * <NAME>, so any WordPress or plugin constant can be set without changing this
 * file, e.g. WP_CONF_WP_DEBUG=true defines WP_DEBUG. The values "true",
 * "false", "null" and numbers are converted to their PHP types.
 *
 * Constants that are not set fall back to the defaults below.
 */

if (!defined('ABSPATH')) {
    http_response_code(403);
    exit;
}

/**
 * Settings used only by the entrypoint to install WordPress. They are not
 * defined as constants, so the admin password is not exposed to PHP code.
 */
$installOnly = ['WP_ADMIN_USER', 'WP_ADMIN_PASSWORD', 'WP_ADMIN_EMAIL', 'WP_SITE_TITLE'];

foreach (getenv() as $name => $value) {
    if (!str_starts_with($name, 'WP_CONF_')) {
        continue;
    }

    $constant = substr($name, strlen('WP_CONF_'));
    // Earlier images required WP_CONF_EXTRA_<NAME> for custom constants.
    if (str_starts_with($constant, 'EXTRA_')) {
        $constant = substr($constant, strlen('EXTRA_'));
    }

    if ($constant === '' || defined($constant) || in_array($constant, $installOnly, true)) {
        continue;
    }

    define($constant, match (strtolower(trim($value))) {
        'true'  => true,
        'false' => false,
        'null'  => null,
        default => is_numeric($value) ? $value + 0 : $value,
    });
}

$defaults = [
    // Database
    'DB_NAME'                    => 'municipio',
    'DB_USER'                    => 'municipio',
    'DB_PASSWORD'                => 'municipio',
    'DB_HOST'                    => 'localhost',
    'DB_CHARSET'                 => 'utf8mb4',
    'DB_COLLATE'                 => 'utf8_general_ci',
    'DB_TABLE_PREFIX'            => 'wp_',

    // Content
    'WP_DEFAULT_THEME'           => 'municipio',
    'WP_POST_REVISIONS'          => 10,
    'AUTOSAVE_INTERVAL'          => 60,
    'EMPTY_TRASH_DAYS'           => 30,
    'DISALLOW_FILE_EDIT'         => true,
    'ALLOW_UNFILTERED_UPLOADS'   => false,
    'UPLOAD_MAX_FILESIZE'        => '64M',
    'CONCATENATE_SCRIPTS'        => false,
    'ACF_LITE'                   => true,

    // Runtime
    'WP_MEMORY_LIMIT'            => '512M',
    'DISABLE_WP_CRON'            => true,
    'AUTOMATIC_UPDATER_DISABLED' => true,
    'WP_REDIS_DISABLED'          => false,
    'WP_USE_MEMCACHED'           => false,

    // Multisite
    'WP_ALLOW_MULTISITE'         => false,
];

foreach ($defaults as $constant => $value) {
    defined($constant) || define($constant, $value);
}

if (WP_ALLOW_MULTISITE) {
    defined('MULTISITE') || define('MULTISITE', true);
    defined('SUBDOMAIN_INSTALL') || define('SUBDOMAIN_INSTALL', false);
    defined('PATH_CURRENT_SITE') || define('PATH_CURRENT_SITE', '/');
    defined('SITE_ID_CURRENT_SITE') || define('SITE_ID_CURRENT_SITE', 1);
    defined('BLOG_ID_CURRENT_SITE') || define('BLOG_ID_CURRENT_SITE', 1);
}

/**
 * TLS is terminated in front of the container. Trust the proxy's scheme so
 * WordPress builds https URLs and does not loop on admin redirects.
 */
if (($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https') {
    $_SERVER['HTTPS'] = 'on';
}

/**
 * wp-content lives in the webroot, outside the WordPress core in /wp.
 */
define('WP_CONTENT_DIR', __DIR__ . '/wp-content');

$host = $_SERVER['HTTP_HOST'] ?? null;
if ($host === null && defined('WP_HOME')) {
    // WP-CLI and cron have no request host.
    define('WP_CONTENT_URL', rtrim(WP_HOME, '/') . '/wp-content');
} elseif ($host !== null) {
    $scheme = ($_SERVER['HTTPS'] ?? '') === 'on' ? 'https' : 'http';
    define('WP_CONTENT_URL', "{$scheme}://{$host}/wp-content");

    // Share login cookies across subdomains of the requested domain,
    // e.g. ".example.com" for "www.example.com".
    $hostname = (string) parse_url("//{$host}", PHP_URL_HOST);
    $labels   = explode('.', $hostname);
    if (!defined('COOKIE_DOMAIN') && count($labels) > 1 && !filter_var($hostname, FILTER_VALIDATE_IP)) {
        define('COOKIE_DOMAIN', '.' . implode('.', array_slice($labels, -2)));
    }
}

/**
 * Authentication keys and salts. Set WP_CONF_AUTH_KEY etc. in production; the
 * fallback is stable across restarts but derived from the database credentials.
 */
foreach (['AUTH_KEY', 'SECURE_AUTH_KEY', 'LOGGED_IN_KEY', 'NONCE_KEY', 'AUTH_SALT', 'SECURE_AUTH_SALT', 'LOGGED_IN_SALT', 'NONCE_SALT'] as $salt) {
    defined($salt) || define($salt, hash('sha256', DB_NAME . DB_PASSWORD . $salt));
}
defined('WP_CACHE_KEY_SALT') || define('WP_CACHE_KEY_SALT', md5(NONCE_KEY));

$table_prefix = DB_TABLE_PREFIX;

unset($installOnly, $name, $value, $constant, $defaults, $host, $hostname, $scheme, $labels, $salt);

require_once __DIR__ . '/vendor/autoload.php';
require_once ABSPATH . 'wp-settings.php';
