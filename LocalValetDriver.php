<?php

/**
 * Put this file in the root of your Wordpress site if you have Wordpress core
 * files installed inside a subdirectory. This helps valet rewrite the urls so
 * that you can access wp-admin for the main site and all subsites of a
 * multisite install.
 */

if (class_exists("BasicValetDriver")) {
  include __DIR__ . "/valet/LocalValetDriver3.php";
} elseif (class_exists("\Valet\Drivers\BasicValetDriver")) {
  include __DIR__ . "/valet/LocalValetDriver4.php";
} else {
  die("Could not find a compatible LocalValetDriver");
}
