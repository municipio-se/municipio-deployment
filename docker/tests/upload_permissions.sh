#!/usr/bin/env bash
# Check writable upload and cache directories in a built Municipio image.
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: bash $0 <municipio-image>" >&2
  exit 1
fi

docker run --rm --user 1000:1000 --entrypoint sh "$1" -eu -c '
  test -w wp-content/uploads || { echo "uploads is not writable by the site user" >&2; exit 1; }
  mkdir -p wp-content/uploads/2099/01
  printf "test\n" > wp-content/uploads/2099/01/upload.txt
  test -w wp-content/uploads/cache/blade-cache || { echo "blade-cache is not writable by the site user" >&2; exit 1; }
'
echo "Upload and cache directories are writable"
