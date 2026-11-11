<?php

if (!function_exists('env')) {
    require_once __DIR__ . '/env.php';
}

/**
 * Prevent script loading from crashing admin and customizer.
 * @see https://developer.wordpress.org/apis/wp-config-php/#disable-javascript-concatenation
 */
if (!defined('CONCATENATE_SCRIPTS')) {
    define('CONCATENATE_SCRIPTS', env('CONCATENATE_SCRIPTS', false));
}