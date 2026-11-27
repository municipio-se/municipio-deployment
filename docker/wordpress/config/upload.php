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

/**
 * S3 Settings
 */
if(!defined('S3_UPLOADS_CUSTOM_ENDPOINT')) {
    define('S3_UPLOADS_CUSTOM_ENDPOINT', env('S3_UPLOADS_CUSTOM_ENDPOINT', null));
}

if(!defined('S3_UPLOADS_KEY')) {
    define('S3_UPLOADS_KEY', env('S3_UPLOADS_KEY', null)); 
}

if(!defined('S3_UPLOADS_SECRET')) {
    define('S3_UPLOADS_SECRET', env('S3_UPLOADS_SECRET', null));
}

if(!defined('S3_UPLOADS_BUCKET')) {
    define('S3_UPLOADS_BUCKET', env('S3_UPLOADS_BUCKET', null)); 
}

if(!defined('S3_UPLOADS_REGION')) {
    define('S3_UPLOADS_REGION', env('S3_UPLOADS_REGION', null));
}

if(!defined('S3_UPLOADS_BUCKET_URL')) {
    define('S3_UPLOADS_BUCKET_URL', env('S3_UPLOADS_BUCKET_URL', null));
}

if(!defined('FS_METHOD')) {
    define('FS_METHOD', env('FS_METHOD', 'direct'));
}