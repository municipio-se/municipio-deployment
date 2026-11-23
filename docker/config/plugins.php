<?php

if (!function_exists('env')) {
    require_once __DIR__ . '/env.php';
}

/**
 * Turn off admin panel for ACF.
 * @var bool
 */
if (!defined('ACF_LITE')) {
    define('ACF_LITE', env('ACF_LITE', true));
}