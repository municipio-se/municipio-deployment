<?php

define('FS_CHMOD_FILE', 0644);
define('FS_CHMOD_DIR', 0755);
define('FS_METHOD', 'direct');

/**
* Allow unfiltered uploads.
* This should not be used in production.
*/

define('ALLOW_UNFILTERED_UPLOADS', false);

/**
 * S3 Uploads configuration.
 */
define('S3_UPLOADS_BUCKET', 'municipio');
define('S3_UPLOADS_KEY', 'minioadmin');
define('S3_UPLOADS_SECRET', 'minioadmin');
define('S3_UPLOADS_REGION', 'us-east-1');
define('S3_UPLOADS_CUSTOM_ENDPOINT', 'http://minio:9000');
define('S3_UPLOADS_BUCKET_URL', 'http://localhost:9000/municipio');

/**
* Set upload max file size. This may
* also be changed in configuration of the machine.
*/

/*
@ini_set('upload_max_size', '256M');
@ini_set('post_max_size', '256M');
*/
