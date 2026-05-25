#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

EXT_DIR="$(php-config --extension-dir)"
INI_DIR="${PHP_INI_SCAN_DIR:-/etc/php.d}"
SG_OFFSET="${VLD_SG_OFFSET:-0x211010}"

mkdir -p "$EXT_DIR" "$INI_DIR"

if [ -f modules/vld.so ]; then
  cp -f modules/vld.so "$EXT_DIR/vld.so"
else
  echo "ERROR: modules/vld.so was not built. Run scripts/build-extension.sh first." >&2
  exit 1
fi

cat > "$INI_DIR/99-vld-sourceguardian.ini" <<INI
extension=vld.so
vld.active=0
vld.execute=1
vld.sg_decode=0
vld.sg_offset=${SG_OFFSET}
vld.sg_require_loader=0
INI

php -m | grep -q '^vld$' && echo "vld installed: $EXT_DIR/vld.so"
