<?php

/*
Plugin Name:    Migrate Uploads URL
Description:    Migrate uploads URL to CDN. For use only in development environment when the remote site is configured to use a CDN for uploads.
Version:        1.0
Author:         Thor Brink
*/

add_filter('upload_dir', function ($uploads) {
    static $remoteSiteId = null;
    $localSiteId = get_current_blog_id();
    $localSiteUrl = get_site_url($localSiteId);
    $uploadUrlPath = get_option('upload_url_path');
    $remoteCdnDomain = get_option('remote_cdn_domain');
    $uploadUrlPathDomain = parse_url($uploadUrlPath, PHP_URL_HOST);

    if ($remoteSiteId === null) {
        $remoteSiteId = get_option('remote_site_id');
    }

    if (!is_numeric($remoteSiteId)) {
        return $uploads;
    }

    if($remoteSiteId === "1") {
        $uploads['url'] = str_replace('sites/' . $localSiteId . '/', '', $uploads['url']);
        $uploads['baseurl'] = str_replace('sites/' . $localSiteId . '/', '', $uploads['baseurl']);
    }

    $uploads['subdir'] = '';
    $uploads['url'] = str_replace('sites/' . $localSiteId, 'sites/' . $remoteSiteId, $uploads['url']);
    $uploads['url'] = str_replace('wp-content/uploads', 'uploads', $uploads['url']);
    $uploads['baseurl'] = str_replace('sites/' . $localSiteId, 'sites/' . $remoteSiteId, $uploads['baseurl']);
    $uploads['baseurl'] = str_replace('wp-content/uploads', 'uploads', $uploads['baseurl']);

    if (!empty($remoteCdnDomain)) {
        $uploads['url'] = str_replace($uploadUrlPathDomain . '/uploads', $remoteCdnDomain . '/uploads', $uploads['url']);
        $uploads['url'] = str_replace($localSiteUrl, 'https://' . $remoteCdnDomain, $uploads['url']);    
        $uploads['baseurl'] = str_replace($uploadUrlPathDomain . '/uploads', $remoteCdnDomain . '/uploads', $uploads['url']);
        $uploads['baseurl'] = str_replace($localSiteUrl, 'https://' . $remoteCdnDomain, $uploads['baseurl']);
    }

    // Possibly remove year/month subdirectories from the path, url and baseurl if they exist
    $uploads['path'] = str_replace('/' . date('Y') . '/' . date('m'), '', $uploads['path']);
    $uploads['url'] = str_replace('/' . date('Y') . '/' . date('m'), '', $uploads['url']);
    $uploads['baseurl'] = str_replace('/' . date('Y') . '/' . date('m'), '', $uploads['baseurl']);

    return $uploads;
});