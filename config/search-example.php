<?php

/**
 * Search configuration for Algolia Index.
 *
 * You may implement whatever search engine you want.
 * Below is a example of how you may configure Algolia.
 *
 * This is the recommended default search engine.
 * It requires a subscription, visit: algolia.com.
 */

define('ALGOLIAINDEX_APPLICATION_ID', '(#application_pool#)');
define('ALGOLIAINDEX_API_KEY', '(#private_key#)');
define('ALGOLIAINDEX_PUBLIC_API_KEY', '(#public_key#)'); //Used when client side search is enabled
define('ALGOLIAINDEX_INDEX_NAME', '(#site_slug#)');
