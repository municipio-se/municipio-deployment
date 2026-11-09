<?php

if (parse_url(municipio_get_site_url(), PHP_URL_HOST) === 'localhost') {
    define('COOKIE_DOMAIN', 'localhost');
}