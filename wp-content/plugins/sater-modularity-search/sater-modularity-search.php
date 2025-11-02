<?php
/**
 * Plugin Name: Säter Modularity Search
 * Description: Enables Modularity modules (mod-fileslist, mod-inlaylist, etc.) to appear in search results by overriding their exclude_from_search setting.
 * Version: 1.0.0
 * Author: Jovica Bumbulovic
 */

if (!defined('ABSPATH')) {
    exit;
}

/**
 * Include pages and news in search, but exclude Modularity modules
 * This ensures search returns actual pages (not building blocks) that users can actually visit
 */
add_action('pre_get_posts', function($query) {
    // Only modify the main search query on the frontend
    if (!is_admin() && $query->is_main_query() && $query->is_search()) {
        // Define which post types should be searchable
        // Include pages and news, but exclude modules (mod-*)
        $searchable_types = ['page', 'news'];
        
        // Set the post types to search
        $query->set('post_type', $searchable_types);
    }
}, 999); // High priority to run after other modifications

