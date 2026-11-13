<?php

if (PHP_SAPI !== 'cli' && is_file('/tmp/municipio-devcontainer/codespaces-env.json')) {
    $contents = file_get_contents('/tmp/municipio-devcontainer/codespaces-env.json');
    if ($contents === false) {
        throw new RuntimeException('Unable to read Codespaces environment variables.');
    }

    foreach (json_decode($contents, true, 512, JSON_THROW_ON_ERROR) as $name => $value) {
        putenv("$name=$value");
    }
}
