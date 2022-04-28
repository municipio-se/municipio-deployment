<?php

/**
 * Error reporting configuration.
 *
 * Municipio uses sentry if available to
 * collect and report errors.
 *
 */

/**
 * Turn on sentry error reporting
 * @var string
 */

define('WP_SENTRY_PHP_DSN', '(#sentry_dsn#)');
define('WP_SENTRY_BROWSER_DSN', WP_SENTRY_PHP_DSN);

/**
 * Set environment
 */
define('WP_SENTRY_ENV', 'production');

/**
 * Set level of error reporting
 * @var string
 */
define('WP_SENTRY_ERROR_TYPES', E_ALL & ~E_DEPRECATED & ~E_NOTICE & ~E_USER_DEPRECATED);

/**
 * Send personal information to sentry, let sentry clean it.
 * This is tecnically not needed, but will increase data quality.
 * Should not be used with cloud installs of sentry.
 * @var bool
 */
define('WP_SENTRY_SEND_DEFAULT_PII', true);

/**
 * Enable and set a level of performance tracing in browser.
 */
define('WP_SENTRY_BROWSER_TRACES_SAMPLE_RATE', 0.3);
