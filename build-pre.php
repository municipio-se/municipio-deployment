#!/usr/bin/env php
<?php

declare(strict_types=1);

/**
 * Legacy GitHub Actions entry point for preparing the local Composer manifest.
 */
if (PHP_SAPI !== 'cli') {
    exit(1);
}

$process = proc_open(
    [PHP_BINARY, __DIR__ . '/composer-local-merge.php', 'pre-install'],
    [STDIN, STDOUT, STDERR],
    $pipes,
    __DIR__
);

if (!is_resource($process)) {
    fwrite(STDERR, "Could not start the Composer local preparation script.\n");
    exit(1);
}

exit(proc_close($process));
