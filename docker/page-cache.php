<?php
/**
 * Plugin Name: Municipio page cache
 * Description: Purges the container's page cache when content changes, and adds `wp page-cache flush`.
 *
 * Caddy caches anonymous page responses in Redis (see docker/Caddyfile). This
 * plugin deletes a site's cached pages directly in Redis, so a purge reaches
 * every replica and also works from WP-CLI and cron containers.
 *
 * Shipped by docker/Dockerfile; active only when PAGE_CACHE_REDIS is set.
 */

namespace Municipio\PageCache;

if (!defined('ABSPATH') || getenv('PAGE_CACHE_REDIS') === false || getenv('PAGE_CACHE_REDIS') === '') {
    return;
}

/**
 * Sites (blog IDs) whose pages should be purged when the request ends.
 * Saving one post fires several hooks, so purges are collected and run once.
 *
 * @var array<int, true>
 */
$GLOBALS['municipio_page_cache_purge'] = [];

function schedule(?int $blogId = null): void
{
    static $registered = false;

    $GLOBALS['municipio_page_cache_purge'][$blogId ?? get_current_blog_id()] = true;

    if (!$registered) {
        $registered = true;
        add_action('shutdown', __NAMESPACE__ . '\\run', 0);
    }
}

function run(): void
{
    $blogIds = array_keys($GLOBALS['municipio_page_cache_purge']);
    $GLOBALS['municipio_page_cache_purge'] = [];

    foreach ($blogIds as $blogId) {
        purgeSite($blogId);
    }
}

function connect(): ?\Redis
{
    static $redis = null;

    if ($redis !== null) {
        return $redis;
    }

    $address = (string) getenv('PAGE_CACHE_REDIS');
    $port    = 6379;
    if (preg_match('/^(.+):(\d+)$/', $address, $m)) {
        [, $address, $port] = $m;
    }

    try {
        $client = new \Redis();
        $client->connect($address, (int) $port, 2.0);

        $password = (string) getenv('PAGE_CACHE_REDIS_PASSWORD');
        if ($password !== '') {
            $client->auth($password);
        }

        $db = getenv('PAGE_CACHE_REDIS_DB');
        $client->select($db === false || $db === '' ? 1 : (int) $db);
        $client->setOption(\Redis::OPT_SCAN, \Redis::SCAN_RETRY);

        return $redis = $client;
    } catch (\Throwable $e) {
        error_log('Municipio page cache: cannot connect to Redis: ' . $e->getMessage());
        return null;
    }
}

/**
 * Deletes every cached page under a site's address. Souin's keys look like
 * "GET-http-www.example.com-/news/?page=2", so the site's host and path
 * select its pages. On a subfolder network, purging the main site (path "/")
 * also purges the other sites on the same host.
 */
function purgeSite(int $blogId): int
{
    $home = wp_parse_url(get_home_url($blogId, '/'));
    if (empty($home['host'])) {
        return 0;
    }

    $host = $home['host'] . (isset($home['port']) ? ':' . $home['port'] : '');
    $path = rtrim($home['path'] ?? '', '/') . '/';

    $deleted = 0;
    foreach (array_unique([$host, $home['host']]) as $candidate) {
        $deleted += deleteMatching('*-' . escapeGlob($candidate) . '-' . escapeGlob($path) . '*');
    }

    return $deleted;
}

function purgeAll(): bool
{
    $redis = connect();

    try {
        return $redis !== null && $redis->flushDB();
    } catch (\Throwable $e) {
        error_log('Municipio page cache: flush failed: ' . $e->getMessage());
        return false;
    }
}

function deleteMatching(string $pattern): int
{
    $redis = connect();
    if ($redis === null) {
        return 0;
    }

    $deleted  = 0;
    $iterator = null;

    try {
        while (($keys = $redis->scan($iterator, $pattern, 1000)) !== false) {
            if ($keys) {
                $deleted += (int) $redis->unlink($keys);
            }
        }
    } catch (\Throwable $e) {
        error_log('Municipio page cache: purge failed: ' . $e->getMessage());
    }

    return $deleted;
}

function escapeGlob(string $value): string
{
    return addcslashes($value, '*?[]\\');
}

/*
 * When to purge.
 */

// Publishing, unpublishing, trashing and scheduled posts going live.
add_action('transition_post_status', function (string $new, string $old, \WP_Post $post): void {
    if (($new === 'publish' || $old === 'publish') && !wp_is_post_revision($post)) {
        schedule();
    }
}, 10, 3);

// Updates to published content, including menu items, attachments and
// Modularity modules, and comment counts.
add_action('clean_post_cache', function (int $postId, \WP_Post $post): void {
    if (wp_is_post_revision($post) || wp_is_post_autosave($post)) {
        return;
    }
    if ($post->post_status === 'publish' || $post->post_type === 'attachment') {
        schedule();
    }
}, 10, 2);

foreach (['edited_term', 'delete_term', 'wp_update_nav_menu', 'wp_delete_nav_menu', 'customize_save_after', 'switch_theme'] as $hook) {
    add_action($hook, fn () => schedule());
}

// ACF options pages.
add_action('acf/save_post', function ($postId): void {
    if (!is_numeric($postId)) {
        schedule();
    }
});

// Site settings and widgets that appear on every page.
add_action('updated_option', function (string $option): void {
    static $options = [
        'blogname', 'blogdescription', 'show_on_front', 'page_on_front', 'page_for_posts',
        'posts_per_page', 'permalink_structure', 'site_icon', 'WPLANG', 'date_format', 'time_format',
        'sidebars_widgets',
    ];

    if (
        in_array($option, $options, true)
        || str_starts_with($option, 'widget_')
        || str_starts_with($option, 'theme_mods_')
        || str_starts_with($option, 'options_')
    ) {
        schedule();
    }
});

if (defined('WP_CLI') && WP_CLI) {
    /**
     * Purges the page cache.
     *
     * ## OPTIONS
     *
     * [--network]
     * : Purge every site's pages, not just the current site's (--url).
     *
     * ## EXAMPLES
     *
     *     wp page-cache flush
     *     wp page-cache flush --url=https://example.com/subsite/
     *     wp page-cache flush --network
     *
     * @when after_wp_load
     */
    \WP_CLI::add_command('page-cache flush', function (array $args, array $assoc): void {
        if (!empty($assoc['network'])) {
            purgeAll() ? \WP_CLI::success('Purged all cached pages.') : \WP_CLI::error('The page cache could not be purged.');
            return;
        }

        if (connect() === null) {
            \WP_CLI::error('Cannot connect to the page cache Redis server.');
        }

        \WP_CLI::success(sprintf('Purged %d cached entries for %s.', purgeSite(get_current_blog_id()), home_url('/')));
    });
}
