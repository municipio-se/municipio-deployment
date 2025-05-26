<?php

  /*
  Plugin Name:    Disable XMLRPC
  Description:    Disables XML-RPC in WordPress.
  Version:        1.0
  Author:         Sebastian Thulin
  */

  add_filter('xmlrpc_enabled', '__return_false');