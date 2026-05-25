#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

if ! command -v phpize >/dev/null 2>&1; then
  echo "ERROR: phpize not found. Install php-devel inside the container/build image." >&2
  exit 1
fi

php -v
phpize
./configure --enable-vld
make clean >/dev/null 2>&1 || true
make -j"$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
