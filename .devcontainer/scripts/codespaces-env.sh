#!/usr/bin/env bash
set -eu

directory=/tmp/municipio-devcontainer
mkdir -p "$directory"
chmod 755 "$directory"
temporary_file=$(mktemp "$directory/codespaces-env.XXXXXX")
trap 'rm -f "$temporary_file"' EXIT

php -n -r '
    $env = [];
    foreach (["CODESPACE_NAME", "GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN"] as $name) {
        $value = getenv($name);
        if ($value !== false && $value !== "") {
            $env[$name] = $value;
        }
    }
    echo json_encode($env, JSON_THROW_ON_ERROR);
' > "$temporary_file"
chmod 644 "$temporary_file"
mv -f "$temporary_file" "$directory/codespaces-env.json"
