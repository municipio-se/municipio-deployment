<?php 

if (!function_exists('env')) {
    require_once __DIR__ . '/env.php';
}

/**
 * Active Directory integration configuration.
 */
if (($adIntegrationUrl = env('AD_INTEGRATION_URL', null)) !== null) {
    define('AD_INTEGRATION_URL', $adIntegrationUrl);
}
if (($adUpdateName = env('AD_UPDATE_NAME', null)) !== null) {
    define('AD_UPDATE_NAME', $adUpdateName);
}
if (($adUpdateEmail = env('AD_UPDATE_EMAIL', null)) !== null) {
    define('AD_UPDATE_EMAIL', $adUpdateEmail);
}
if (($adSavePassword = env('AD_SAVE_PASSWORD', null)) !== null) {
    define('AD_SAVE_PASSWORD', $adSavePassword);
}
if (($adRandomPassword = env('AD_RANDOM_PASSWORD', null)) !== null) {
    define('AD_RANDOM_PASSWORD', $adRandomPassword);
}
if (($adUserDomain = env('AD_USER_DOMAIN', null)) !== null) {
    define('AD_USER_DOMAIN', $adUserDomain); // What your emails are ending with
}