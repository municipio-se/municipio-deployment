<?php 

/**
 * WordPress memory limit. This setting should be as
 * low as possible to enshure that site runs smoothly.
 *
 * Default value is intentionally 'high' to avoid
 * crashes in setup process. A good value for production
 * may be as low as 128M but will vary.
 *
 */

define('WP_MEMORY_LIMIT', '512M');
