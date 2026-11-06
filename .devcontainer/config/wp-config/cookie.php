<?php

if (!getenv('CODESPACE_NAME')) {
    define('COOKIE_DOMAIN', 'localhost');
}