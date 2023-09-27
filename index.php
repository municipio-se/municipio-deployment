<?php
/**
 * Name:              Municipio
 * URI:               https://getmunicipio.com
 * Description:       Main installable for Municipio.
 * Version:           1.0.0
 * Author:            Sebastian Thulin
 * Author URI:        https://github.com/helsingborg-stad
 * License:           MIT
 * License URI:       https://opensource.org/licenses/MIT
 */

/**
 * Tells WordPress to load the WordPress theme and output it.
 * @var bool
 */

define('WP_USE_THEMES', true);

/**
 * Loads the WordPress Environment and Template
 */
require(dirname(__FILE__) . '/wp/wp-blog-header.php');
