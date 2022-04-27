<?php

/**
 * Redirect to real wp-login page
 */

$path           = '/wp/wp-login.php';
$queryString    = !empty($_GET) ? '?' . http_build_query($_GET) : '';

header('Location:  ' . $path . $queryString);
die;
