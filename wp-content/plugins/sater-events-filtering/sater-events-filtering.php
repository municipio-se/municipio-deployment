<?php

/**
 * Plugin Name: Säter Events Filtering
 * Description: Handles category and date filtering logic for the events archive page. Filters events by evenemangskategorier taxonomy and uses start_datum/slut_datum meta fields for date filtering.
 * Version: 1.1.0
 * Author: Jovica Bumbulovic
 */

if (!defined('ABSPATH')) {
    exit;
}

final class Sater_Events_Filtering
{
    public function __construct()
    {
        // Ensure Municipio archive filters are visible on event archive
        add_filter('Municipio/Archive/showFilter', [$this, 'forceShowFilters'], 20);

        add_filter('query_vars', [$this, 'registerQueryVar']);
        add_action('pre_get_posts', [$this, 'handleEventDateFiltering'], 20);
        add_action('pre_get_posts', [$this, 'applyFilter'], 999);
        add_filter('Municipio/archive/tax_query', [$this, 'mergeTaxQuery'], 99, 2);
        add_filter('Municipio/archive/date_filter', [$this, 'skipEventDateFilter'], 10, 3);
        
        // UI elements removed - filter logic kept
    }

    public function forceShowFilters($enabled)
    {
        if (!is_admin() && is_post_type_archive('event')) {
            return true;
        }
        return $enabled;
    }

    public function registerQueryVar(array $vars): array
    {
        $vars[] = 'evenemangskategorier';
        $vars[] = 'from';
        $vars[] = 'to';
        return $vars;
    }

    /**
     * Handle event date filtering at the query level
     * Filters events using start_datum/slut_datum meta fields instead of post dates
     * 
     * @param WP_Query $query
     * @return void
     */
    public function handleEventDateFiltering($query)
    {
        // Only run on main query for events archive
        if (is_admin() || !$query->is_main_query() || !is_post_type_archive('events')) {
            return;
        }
        
        $from = get_query_var('from', false);
        if (!$from && isset($_GET['from']) && !empty($_GET['from'])) {
            $from = sanitize_text_field($_GET['from']);
        }
        
        $to = get_query_var('to', false);
        if (!$to && isset($_GET['to']) && !empty($_GET['to'])) {
            $to = sanitize_text_field($_GET['to']);
        }
        
        if (!$from && !$to) {
            return;
        }
        
        // Convert dates
        $fromDate = $from ? date('Y-m-d', strtotime($from)) : null;
        $toDate = $to ? date('Y-m-d', strtotime($to)) : null;
        
        // Remove any existing meta_query to prevent the 1970 issue
        $query->set('meta_query', []);
        
        // Build clean meta query for event dates
        $metaQuery = ['relation' => 'AND'];
        
        if ($fromDate && $toDate) {
            // Events that overlap with the date range
            $metaQuery[] = [
                'key' => 'start_datum',
                'value' => $toDate,
                'compare' => '<=',
                'type' => 'DATE'
            ];
            $metaQuery[] = [
                'relation' => 'OR',
                [
                    'key' => 'slut_datum',
                    'value' => $fromDate,
                    'compare' => '>=',
                    'type' => 'DATE'
                ],
                [
                    'key' => 'slut_datum',
                    'compare' => 'NOT EXISTS'
                ]
            ];
        } elseif ($fromDate) {
            // Events that end on or after the from date
            $metaQuery[] = [
                'relation' => 'OR',
                [
                    'key' => 'slut_datum',
                    'value' => $fromDate,
                    'compare' => '>=',
                    'type' => 'DATE'
                ],
                [
                    'key' => 'slut_datum',
                    'compare' => 'NOT EXISTS'
                ]
            ];
        } elseif ($toDate) {
            // Events that start on or before the to date
            $metaQuery[] = [
                'key' => 'start_datum',
                'value' => $toDate,
                'compare' => '<=',
                'type' => 'DATE'
            ];
        }
        
        $query->set('meta_query', $metaQuery);
        
        // Disable the default post_date filtering for events
        $query->set('date_query', []);
    }

    /**
     * Prevent Municipio's posts_where date filtering from interfering with events
     * This ensures compatibility if PostFilters.php is reverted
     * Strips out post_date conditions from WHERE clause for events archive
     * 
     * @param string $where Modified WHERE clause with date conditions
     * @param string|null $from From date
     * @param string|null $to To date
     * @return string WHERE clause without date conditions for events
     */
    public function skipEventDateFilter($where, $from, $to)
    {
        if (is_post_type_archive('events')) {
            global $wpdb;
            // Remove post_date date filtering conditions that were added by doPostDateFiltering
            // These look like: AND (wp_posts.post_date >= '2024-01-01' AND wp_posts.post_date <= '2024-12-31')
            $pattern = '/\s+AND\s*\(\s*' . preg_quote($wpdb->posts, '/') . '\.post_date\s*(>=|<=)\s*[\'"]?[0-9-]+[\'"]?\s*(?:\s+AND\s+' . preg_quote($wpdb->posts, '/') . '\.post_date\s*(>=|<=)\s*[\'"]?[0-9-]+[\'"]?)?\s*\)/i';
            $where = preg_replace($pattern, '', $where);
            return $where;
        }
        return $where;
    }

    public function mergeTaxQuery($taxQuery, $query)
    {
        // Check both post types - the archive might be 'events' but query might be 'event'
        $postType = $query->get('post_type');
        $isEventArchive = is_post_type_archive('event') || 
                         is_post_type_archive('events') ||
                         ($postType && (is_array($postType) ? in_array('event', $postType) || in_array('events', $postType) : in_array($postType, ['event', 'events'])));
        
        if (!$isEventArchive) {
            return $taxQuery;
        }
        
        // Handle array of categories
        $slugs = isset($_GET['evenemangskategorier']) ? (array)$_GET['evenemangskategorier'] : [];
        $slugs = array_filter(array_map('sanitize_title', $slugs));
        
        if (empty($slugs)) {
            return $taxQuery;
        }
        
        // Ensure taxQuery is an array with proper structure
        if (!is_array($taxQuery)) {
            $taxQuery = [];
        }
        
        // Ensure relation is set
        if (!isset($taxQuery['relation'])) {
            $taxQuery['relation'] = 'AND';
        }
        
        // Add our taxonomy filter
        $taxQuery[] = [
            'taxonomy' => 'evenemangskategorier',
            'field'    => 'slug',
            'terms'    => $slugs,
            'operator' => 'IN',
        ];
        
        return $taxQuery;
    }

    public function applyFilter($q)
    {
        // Check if we're on events archive - check both singular and plural
        $isEventArchive = !is_admin() && $q->is_main_query() && 
                          (is_post_type_archive('event') || is_post_type_archive('events'));
        
        if (!$isEventArchive) {
            return;
        }
        
        // Ensure post type is set correctly - use 'events' since that's what's in DB
        $currentPostType = $q->get('post_type');
        if (empty($currentPostType) || (!is_array($currentPostType) && !in_array($currentPostType, ['event', 'events']))) {
            // Try to detect which one
            if (is_post_type_archive('events')) {
                $q->set('post_type', 'events');
            } elseif (is_post_type_archive('event')) {
                $q->set('post_type', 'event');
            } else {
                // Default to both
                $q->set('post_type', ['event', 'events']);
            }
        }
        
        // Handle array of categories
        $slugs = isset($_GET['evenemangskategorier']) ? (array)$_GET['evenemangskategorier'] : [];
        $slugs = array_filter(array_map('sanitize_title', $slugs));
        
        if (!empty($slugs)) {
            $existingTaxQuery = $q->get('tax_query');
            $taxQuery = is_array($existingTaxQuery) ? $existingTaxQuery : [];
            
            // Ensure relation is set
            if (!isset($taxQuery['relation'])) {
                $taxQuery['relation'] = 'AND';
            }
            
            // Add our taxonomy filter
            $taxQuery[] = [
                'taxonomy' => 'evenemangskategorier',
                'field'    => 'slug',
                'terms'    => $slugs,
                'operator' => 'IN',
            ];
            
            $q->set('tax_query', $taxQuery);
        }
    }

}

new Sater_Events_Filtering();

