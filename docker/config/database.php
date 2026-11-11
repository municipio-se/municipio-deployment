<?php

if (!function_exists('env')) {
    require_once __DIR__ . '/env.php';
}

// ** MySQL settings - You can get this info from your web host ** //

/** The name of the database for WordPress */
if (!defined('DB_NAME')) {
    define('DB_NAME', env('DB_NAME', 'municipio'));
}

/** MySQL database username */
if (!defined('DB_USER')) {
    define('DB_USER', env('DB_USER', 'municipio'));
}

/** MySQL database password */
if (!defined('DB_PASSWORD')) {
    define('DB_PASSWORD', env('DB_PASSWORD', 'municipio'));
}

/** MySQL hostname */
if (!defined('DB_HOST')) {
    define('DB_HOST', env('DB_HOST', 'localhost'));
}

/** Database Charset to use in creating database tables. */
if (!defined('DB_CHARSET')) {
    define('DB_CHARSET', env('DB_CHARSET', 'utf8mb4'));
}

/** The Database Collate type. Don't change this if in doubt. */
if (!defined('DB_COLLATE')) {
    define('DB_COLLATE', env('DB_COLLATE', 'utf8_general_ci'));
}

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix  = env('DB_TABLE_PREFIX', 'wp_'); //Should not be wp_ for improved security.
