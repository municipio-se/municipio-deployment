<?php
/**
 * Front to the WordPress application. This file doesn't do anything, but loads
 * wp-blog-header.php which does and tells WordPress to load the theme.
 *
 * @package WordPress
 */

/**
 * Tells WordPress to load the WordPress theme and output it.
 * @var bool
 */
define('WP_USE_THEMES', true);

/**
 * Loads builtin vendor packages
 * @var bool
 */
if(file_exists( __DIR__ . '/vendor/autoload.php')) {
  require_once __DIR__ . '/vendor/autoload.php';
} else {
  die("<h1>Not installed</h1><p>Oops! Please run 'php build.php' in the root directory to install Municipio.</p>"); 
}

/** Loads the WordPress Environment and Template */
require(dirname(__FILE__) . '/wp/wp-blog-header.php');
