<?php

/**
 * Tell WordPress to save the cookie on the domain. 
 * Supports any domain.
 * @var bool
 */

 if($cookieHost = isset($_SERVER['HTTP_HOST']) ? $_SERVER['HTTP_HOST'] : false) {
    if($cookieHost = getCurrentTopDomain($cookieHost)) {
        define('COOKIE_DOMAIN', "." . $cookieHost);
    }
}

function getCurrentTopDomain($host) {
    $hostParts = explode('.', $host);
    if(is_array($hostParts) && 1 < count($hostParts)) {
        $hostParts = array_reverse($hostParts);
        return implode(
            ".",
            [
             	$hostParts[1],
                $hostParts[0]
            ]
	);
    }
    return false;
}
