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

  //Detect if we are running in a local docker devcontainer
  if( defined('IS_DEVCONTAINER') && constant('IS_DEVCONTAINER') ) {

    add_filter('pre_get_site_by_path', 'localEnvPreGetSiteByPath', 10, 5);
    add_filter('home_url', 'replaceDomain', 10, 4);
    add_filter('admin_url', 'replaceDomain' ,10, 4);
    add_filter('includes_url', 'replaceDomain' ,100, 3);

    function localEnvPreGetSiteByPath($pre, $domain, $path, $segments, $paths) {
      if( $domain === $_SERVER['HTTP_HOST'] ) {
        // Get multisite domain from db
        global $wpdb;
        $domainInDb = $wpdb->get_var( "SELECT domain FROM {$wpdb->blogs} LIMIT 1" );
    
        $pre = get_site_by_path($domainInDb, $segments, $paths);
    
        if( is_a($pre, 'WP_Site') ) {
          $pre->domain = $domain;
        }
      }
      return $pre;
    }
    
    function replaceDomain($url) {
      global $wpdb;
      $old_domain = $wpdb->get_var( "SELECT domain FROM {$wpdb->blogs} LIMIT 1" );
      $new_domain = $_SERVER['HTTP_HOST'];
    
      if (strpos($url, $old_domain) !== false) {
          $url = str_replace($old_domain, $new_domain, $url);
          $url = str_replace('http://', '', $url);
          $url = str_replace('https://', '', $url);
          
          $protocol = isset($_SERVER['HTTPS']) ? 'https://' : 'http://';
          $url = $protocol . $url;
      }

      return $url;
    }
  }