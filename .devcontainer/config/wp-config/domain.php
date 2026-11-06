<?php

if (!function_exists('municipio_get_site_url')) {
    function municipio_get_site_url() {
        $codespaceName = getenv('CODESPACE_NAME');
        $forwardingDomain = getenv('GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN');

        if ($codespaceName && $forwardingDomain) {
            return "https://{$codespaceName}-80.{$forwardingDomain}";
        }

        return 'http://localhost:8080';
    }
}
