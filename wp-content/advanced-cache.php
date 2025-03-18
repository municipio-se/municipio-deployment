<?php

/**
 * Load the composer autoloader
 */
if(file_exists(ABSPATH . '../vendor/autoload.php')) {
    require_once ABSPATH . '../vendor/autoload.php';
} else {
    die("<h1>Not installed</h1><p>Oops! Please run 'php build.php' in the root directory to install Municipio.</p>"); 
}