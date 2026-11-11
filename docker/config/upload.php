<?php

if (!function_exists('env')) {
    require_once __DIR__ . '/env.php';
}

/**
* Allow unfiltered uploads.
* This should not be used in production.
*/

if (!defined('ALLOW_UNFILTERED_UPLOADS')) {
    define('ALLOW_UNFILTERED_UPLOADS', env('ALLOW_UNFILTERED_UPLOADS', false));
}

/**
* Set upload max file size. This may
* also be changed in configuration of the machine.
*/
if (!defined('UPLOAD_MAX_FILESIZE')) {
    define('UPLOAD_MAX_FILESIZE', env('UPLOAD_MAX_FILESIZE', '64M'));
}