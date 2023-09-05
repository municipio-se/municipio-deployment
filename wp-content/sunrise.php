<?php 
  /*
  Dropin Name: sunrise.php
  Dropin URI:  https://getmunicipio.com
  Version:     1.0.0
  Author:      Sebastian Thulin
  Author URI:  https://getmunicipio.com
  */

  //Prevent direct access
  defined('ABSPATH') || exit;

  //Loads builtin vendor packages
  if(file_exists(ABSPATH . '../vendor/autoload.php')) {
    require_once ABSPATH . '../vendor/autoload.php';
  } else {
    die("<h1>Not installed</h1><p>Oops! Please run 'php build.php' in the root directory to install Municipio.</p>"); 
  }