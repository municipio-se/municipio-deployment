<?php

/**
 * Tell WordPress to be used as network
 */

// Local site domain (fixed for devcontainer)
$LOCAL_SITE_URL = parse_url(municipio_get_site_url());
$LOCAL_SITE_DOMAIN = $LOCAL_SITE_URL['host']
	. (isset($LOCAL_SITE_URL['port']) ? ':' . $LOCAL_SITE_URL['port'] : '');

define('WP_ALLOW_MULTISITE', true);
define('MULTISITE', true);
define('SUBDOMAIN_INSTALL', false);
define('PATH_CURRENT_SITE', '/');
define('SITE_ID_CURRENT_SITE', 1);
define('BLOG_ID_CURRENT_SITE', 1);
define('DOMAIN_CURRENT_SITE', $LOCAL_SITE_DOMAIN);
