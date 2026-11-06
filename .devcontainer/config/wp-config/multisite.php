<?php

/**
 * Tell WordPress to be used as network
 */

// Local site domain (fixed for devcontainer)
$LOCAL_SITE_URL = municipio_get_site_url();

define('WP_ALLOW_MULTISITE', true);
define('MULTISITE', true);
define('SUBDOMAIN_INSTALL', false);
define('PATH_CURRENT_SITE', '/');
define('SITE_ID_CURRENT_SITE', 1);
define('BLOG_ID_CURRENT_SITE', 1);
define('DOMAIN_CURRENT_SITE', $LOCAL_SITE_URL);
