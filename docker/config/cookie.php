<?php

if (!function_exists('env')) {
    require_once __DIR__ . '/env.php';
}

/**
 * Tell WordPress to save the cookie on the domain. 
 * Supports any domain.
 * @var bool
 */

if (!function_exists('getCurrentTopDomain')) {
    function getCurrentTopDomain($host) {
        $hostParts = explode('.', $host);
        if (is_array($hostParts) && 1 < count($hostParts)) {
            $hostParts = array_reverse($hostParts);
            return implode(
                ".",
                [
                    $hostParts[1],
                    $hostParts[0]
                ]
            );
        }
        return false;
    }
}

if (($cookieDomain = env('COOKIE_DOMAIN', null)) !== null) {
    define('COOKIE_DOMAIN', $cookieDomain);
} elseif ($cookieHost = isset($_SERVER['HTTP_HOST']) ? $_SERVER['HTTP_HOST'] : false) {
    if ($topDomain = getCurrentTopDomain($cookieHost)) {
        define('COOKIE_DOMAIN', "." . $topDomain);
    }
}