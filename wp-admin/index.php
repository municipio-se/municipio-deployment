<?php

/**
 * Redirect to real wp-admin page
 */

$path           = '/wp/wp-admin/';
$queryString    = !empty($_GET) ? '?' . http_build_query($_GET) : '';

header('Location:  ' . $path . $queryString);
die;
