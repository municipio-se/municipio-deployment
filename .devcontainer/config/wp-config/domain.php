<?php

if (!function_exists('municipio_get_site_url')) {
    function municipio_get_site_url() {
        $codespaceName = getenv('CODESPACE_NAME');
        $forwardingDomain = getenv('GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN');

        if ($codespaceName && $forwardingDomain) {
            return "https://{$codespaceName}-80.{$forwardingDomain}";
        }

        foreach ([$_SERVER['HTTP_X_FORWARDED_HOST'] ?? '', $_SERVER['HTTP_HOST'] ?? ''] as $host) {
            if ($forwardingDomain && preg_match('/\A[a-z0-9-]+-80\.' . preg_quote($forwardingDomain, '/') . '\z/i', $host)) {
                return "https://{$host}";
            }
        }

        return 'http://localhost:8080';
    }
}
