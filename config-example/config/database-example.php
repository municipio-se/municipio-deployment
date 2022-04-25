<?php

// ** MySQL settings - You can get this info from your web host ** //

/** The name of the database for WordPress */
define('DB_NAME', '(#db_name#)');

/** MySQL database username */
define('DB_USER', '(#db_user#)');

/** MySQL database password */
define('DB_PASSWORD', '(#db_password#)');

/** MySQL hostname */
define('DB_HOST', '(#db_host#)');

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8mb4');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix  = '(#table_prefix#)'; //Should not be wp_ for improved security.
