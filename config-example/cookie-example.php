<?php

/**
 * Tell WordPress to save the cookie on the domain
 *
 * Replace '(#site_domain#)' with your domain. You may remove this row.
 *
 * @var bool
 */

if (strpos($_SERVER['HTTP_HOST'], "(#site_domain#)") !== false) {
    define('COOKIE_DOMAIN', "(#site_domain#)");
} else {
    define('COOKIE_DOMAIN', $_SERVER['HTTP_HOST']);
}
