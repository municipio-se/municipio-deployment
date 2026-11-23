<?php

if (!function_exists('env')) {
    require_once __DIR__ . '/env.php';
}

/**
* Tell WordPress not to update anything.
* Updates should be done by github actions.
* @var bool
*/

if (!defined('AUTOMATIC_UPDATER_DISABLED')) {
    define('AUTOMATIC_UPDATER_DISABLED', env('AUTOMATIC_UPDATER_DISABLED', true));
}
