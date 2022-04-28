<?php

/**
 * Tell WordPress to be used as network
 */

define('WP_ALLOW_MULTISITE', true);

// Run the multisite network install via wp-admin and paste your settings here
// Note: Don't forget to update the .htaccess as well

/*
Example: Multisite subdomain.

define('WP_ALLOW_MULTISITE', true);
define('MULTISITE', true);
define('SUBDOMAIN_INSTALL', true);
define('DOMAIN_CURRENT_SITE', 'municipio.se');
define('PATH_CURRENT_SITE', '/');
define('SITE_ID_CURRENT_SITE', 1);
define('BLOG_ID_CURRENT_SITE', 1);
*/
