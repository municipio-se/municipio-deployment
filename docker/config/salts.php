<?php

declare(strict_types=1);

if (!function_exists('env')) {
    require_once __DIR__ . '/env.php';
}

/**
 * WordPress Authentication Unique Keys and Salts.
 *
 * Can be configured via environment variables (AUTH_KEY, SECURE_AUTH_KEY, etc.).
 * If not provided, stable fallback salts are derived from the database configuration.
 */
$salts = [
    'AUTH_KEY',
    'SECURE_AUTH_KEY',
    'LOGGED_IN_KEY',
    'NONCE_KEY',
    'AUTH_SALT',
    'SECURE_AUTH_SALT',
    'LOGGED_IN_SALT',
    'NONCE_SALT',
];

foreach ($salts as $salt) {
    if (!defined($salt)) {
        $defaultSalt = hash('sha256', (string) env('DB_NAME', '') . (string) env('DB_PASSWORD', '') . $salt);
        define($salt, env($salt, $defaultSalt));
    }
}
