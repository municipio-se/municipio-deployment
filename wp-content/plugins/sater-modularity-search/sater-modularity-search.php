<?php
/**
 * Plugin Name: Sater Modularity Search
 * Description: Enables Modularity modules (mod-fileslist, mod-inlaylist, etc.) to appear in search results by overriding their exclude_from_search setting.
 * Version: 1.0.0
 * Author: Jovica Bumbulovic
 */

if (!defined('ABSPATH')) {
    exit;
}

/**
 * Override Modularity modules to allow them in search results
 * This filter runs when post types are registered and allows us to modify the arguments
 */
add_filter('register_post_type_args', function($args, $post_type) {
    // Check if this is a Modularity module post type (they all start with "mod-")
    if (strpos($post_type, 'mod-') === 0) {
        // Force modules to be included in search results
        $args['exclude_from_search'] = false;
        
        // Also ensure they're publicly queryable so search can find them
        $args['publicly_queryable'] = true;
    }
    
    return $args;
}, 999, 2); // Priority 999 to run after Modularity's registration

/**
 * Additionally, ensure modules aren't excluded during search queries
 * This provides extra protection against the dynamic exclusion in ModuleManager.php
 */
add_action('pre_get_posts', function($query) {
    // Only modify the main search query on the frontend
    if (!is_admin() && $query->is_main_query() && $query->is_search()) {
        // Get the current post types being searched
        $post_types = $query->get('post_type');
        
        // If no specific post types are set, WordPress searches all searchable types
        // We don't need to do anything special - just ensure modules aren't excluded
        
        // If specific post types are set, make sure we include module types
        if (empty($post_types) || $post_types === 'any') {
            // Get all registered post types
            $all_post_types = get_post_types(['public' => true, 'exclude_from_search' => false], 'names');
            
            // Add Modularity module post types
            $module_types = get_post_types(['_builtin' => false], 'names');
            foreach ($module_types as $type) {
                if (strpos($type, 'mod-') === 0) {
                    $all_post_types[] = $type;
                }
            }
            
            // Set the post types to search
            if (!empty($all_post_types)) {
                $query->set('post_type', array_unique($all_post_types));
            }
        }
    }
}, 999); // High priority to run after other modifications

