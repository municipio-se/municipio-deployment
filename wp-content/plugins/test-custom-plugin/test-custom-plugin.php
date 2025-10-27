<?php
/**
 * Plugin Name:       Test Custom Plugin
 * Description:       A simple test plugin with assets to verify build process
 * Version:           1.0.0
 * Author:            Jovica
 * License:           MIT
 * Text Domain:       test-custom-plugin
 */

// Protect against direct file access
if (!defined('WPINC')) {
    die;
}

define('TEST_CUSTOM_PLUGIN_PATH', plugin_dir_path(__FILE__));
define('TEST_CUSTOM_PLUGIN_URL', plugins_url('', __FILE__));
define('TEST_CUSTOM_PLUGIN_VERSION', '1.0.0');

// Load the built assets
$manifestPath = TEST_CUSTOM_PLUGIN_PATH . 'dist/manifest.json';

if (file_exists($manifestPath)) {
    $manifest = json_decode(file_get_contents($manifestPath), true);
    
    // Enqueue CSS
    if (isset($manifest['css/test-custom-plugin.css'])) {
        wp_enqueue_style(
            'test-custom-plugin',
            TEST_CUSTOM_PLUGIN_URL . '/dist/' . $manifest['css/test-custom-plugin.css'],
            [],
            TEST_CUSTOM_PLUGIN_VERSION
        );
    }
    
    // Enqueue JS
    if (isset($manifest['js/test-custom-plugin.js'])) {
        wp_enqueue_script(
            'test-custom-plugin',
            TEST_CUSTOM_PLUGIN_URL . '/dist/' . $manifest['js/test-custom-plugin.js'],
            [],
            TEST_CUSTOM_PLUGIN_VERSION,
            true
        );
    }
}

// Add admin notice on admin dashboard
add_action('admin_notices', function() {
    ?>
    <div class="notice notice-success is-dismissible">
        <p><strong>Test Custom Plugin</strong> is active! ✅ The build process worked.</p>
    </div>
    <?php
});

// Add a simple front-end action
add_action('wp_footer', function() {
    ?>
    <div id="test-custom-plugin-message">
        <p>Hello from Test Custom Plugin! 🎉</p>
    </div>
    <?php
});

