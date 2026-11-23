<?php

if (!function_exists('env')) {
    require_once __DIR__ . '/env.php';
}

/**
 * Search configuration for Algolia Index.
 *
 * You may implement whatever search engine you want.
 * Below is a example of how you may configure Algolia.
 *
 * This is the recommended default search engine.
 * It requires a subscription, visit: algolia.com.
 */

/**
 * Search index provider configuration
 */
if (($searchIndexProvider = env('SEARCH_INDEX_PROVIDER', null)) !== null) {
    define('SEARCH_INDEX_PROVIDER', $searchIndexProvider);
}

/**
 * Typesense configuration
 */
if (($typesenseUrl = env('SEARCH_INDEX_TYPESENSE_API_URL', null)) !== null) {
    define('SEARCH_INDEX_TYPESENSE_API_URL', $typesenseUrl);
}
if (($typesenseKey = env('SEARCH_INDEX_TYPESENSE_API_KEY', null)) !== null) {
    define('SEARCH_INDEX_TYPESENSE_API_KEY', $typesenseKey);
}
if (($typesensePubKey = env('SEARCH_INDEX_TYPESENSE_PUBLIC_API_KEY', null)) !== null) {
    define('SEARCH_INDEX_TYPESENSE_PUBLIC_API_KEY', $typesensePubKey);
}
if (($typesenseColName = env('SEARCH_INDEX_TYPESENSE_COLLECTION_NAME', null)) !== null) {
    define('SEARCH_INDEX_TYPESENSE_COLLECTION_NAME', $typesenseColName);
}

/**
 * Algolia configuration
 */
if (($algoliaAppId = env('SEARCH_INDEX_ALGOLIA_APPLICATION_ID', null)) !== null) {
    define('SEARCH_INDEX_ALGOLIA_APPLICATION_ID', $algoliaAppId);
}
if (($algoliaApiKey = env('SEARCH_INDEX_ALGOLIA_API_KEY', null)) !== null) {
    define('SEARCH_INDEX_ALGOLIA_API_KEY', $algoliaApiKey);
}
if (($algoliaPubKey = env('SEARCH_INDEX_ALGOLIA_PUBLIC_API_KEY', null)) !== null) {
    define('SEARCH_INDEX_ALGOLIA_PUBLIC_API_KEY', $algoliaPubKey);
}
if (($algoliaIndexName = env('SEARCH_INDEX_ALGOLIA_INDEX_NAME', null)) !== null) {
    define('SEARCH_INDEX_ALGOLIA_INDEX_NAME', $algoliaIndexName);
}