<?php

/**
 * Tell WordPress to be used as network
 */
define('WP_ALLOW_MULTISITE', true);

if (defined('WP_ALLOW_MULTISITE') && WP_ALLOW_MULTISITE) {
  define('MULTISITE', true);
  define('SUBDOMAIN_INSTALL', false);
  define('PATH_CURRENT_SITE', '/');
  define('SITE_ID_CURRENT_SITE', 1);
  define('BLOG_ID_CURRENT_SITE', 1);
  define('DOMAIN_CURRENT_SITE', $_SERVER['HTTP_HOST'] ?? '');
}
