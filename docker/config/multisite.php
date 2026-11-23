<?php

if (!function_exists('env')) {
    require_once __DIR__ . '/env.php';
}

/**
 * Tell WordPress to be used as network
 */

if (!defined('WP_ALLOW_MULTISITE')) {
    define('WP_ALLOW_MULTISITE', env('WP_ALLOW_MULTISITE', false));
}

if (defined('WP_ALLOW_MULTISITE') && WP_ALLOW_MULTISITE) {
    if (!defined('MULTISITE')) {
        define('MULTISITE', true);
    }
    if (!defined('SUBDOMAIN_INSTALL')) {
        define('SUBDOMAIN_INSTALL', env('SUBDOMAIN_INSTALL', false));
    }
    if (!defined('DOMAIN_CURRENT_SITE') && ($domainCurrentSite = env('DOMAIN_CURRENT_SITE', null)) !== null) {
        define('DOMAIN_CURRENT_SITE', $domainCurrentSite);
    }
    if (!defined('PATH_CURRENT_SITE')) {
        define('PATH_CURRENT_SITE', env('PATH_CURRENT_SITE', '/'));
    }
    if (!defined('SITE_ID_CURRENT_SITE')) {
        define('SITE_ID_CURRENT_SITE', env('SITE_ID_CURRENT_SITE', 1));
    }
    if (!defined('BLOG_ID_CURRENT_SITE')) {
        define('BLOG_ID_CURRENT_SITE', env('BLOG_ID_CURRENT_SITE', 1));
    }
}