<?php

declare(strict_types=1);

/**
 * Native environment variable parser and WP_CONF_EXTRA_ prefix autoloader.
 */
if (!function_exists('wp_conf_values')) {
    /**
     * WP_CONF_* values written by the container at startup (docker/wordpress/setup/setup.py)
     * to a file outside the document root. The web server does not pass the
     * container environment to PHP, so in the container this is where the
     * values come from. Empty when the file does not exist (e.g. local dev).
     *
     * @return array<string, string>
     */
    function wp_conf_values(): array
    {
        static $values = null;

        if ($values === null) {
            $file = dirname(__DIR__, 2) . '/wp-conf.php';
            $values = is_readable($file) ? (array) require $file : [];
        }

        return $values;
    }
}

if (!function_exists('env')) {
    /**
     * Get an environment variable with automatic type conversion and default value support.
     * Looks up WP_CONF_{$key} first, then falls back to {$key}. Values from
     * wp_conf_values() take precedence over the process environment.
     *
     * @param string $key
     * @param mixed $default
     * @return mixed
     */
    function env(string $key, mixed $default = null): mixed
    {
        $lookupKey = str_starts_with($key, 'WP_CONF_') ? $key : 'WP_CONF_' . $key;
        $value = wp_conf_values()[$lookupKey] ?? $_ENV[$lookupKey] ?? $_SERVER[$lookupKey] ?? getenv($lookupKey);

        if ($value === false || $value === null || $value === '') {
            $value = $_ENV[$key] ?? $_SERVER[$key] ?? getenv($key);
        }

        if ($value === false || $value === null || $value === '') {
            return $default;
        }

        if (!is_string($value)) {
            return $value;
        }

        return match (strtolower(trim($value))) {
            'true', '(true)'   => true,
            'false', '(false)' => false,
            'null', '(null)'   => null,
            'empty', '(empty)' => '',
            default            => is_numeric($value) ? (str_contains($value, '.') ? (float) $value : (int) $value) : $value,
        };
    }
}

/**
 * Autoload dynamic constants prefixed with WP_CONF_EXTRA_
 * E.g. WP_CONF_EXTRA_CUSTOM_API_KEY=secret => define('CUSTOM_API_KEY', 'secret')
 */
(static function (): void {
    $envVariables = array_merge($_ENV, $_SERVER, wp_conf_values());

    foreach ($envVariables as $key => $value) {
        if (str_starts_with($key, 'WP_CONF_EXTRA_')) {
            $constant = substr($key, 14); // strlen('WP_CONF_EXTRA_')
            if ($constant !== '' && !defined($constant)) {
                $parsed = env($key);
                if ($parsed !== null) {
                    define($constant, $parsed);
                }
            }
        }
    }
})();
