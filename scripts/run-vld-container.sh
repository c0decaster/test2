#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'HELP'
Usage inside container:
  run-vld-container.sh /work/file.php [extra php args]

Host example:
  podman run --rm \
    -v "$PWD:/work:Z" \
    -v "/path/to/sourceguardian:/opt/sourceguardian:Z,ro" \
    vld-sourceguardian-centos10 \
    /work/protected.php

Environment:
  SG_LOADER_DIR=/opt/sourceguardian
  VLD_SG_OFFSET=0x211010
  VLD_SG_REQUIRE_LOADER=0|1

The SourceGuardian loader is expected to be mounted into the container.
The host does not need php-devel, gcc, make, or SourceGuardian installed.
HELP
}

if [ "${1:-}" = "--help" ] || [ $# -lt 1 ]; then
  show_help
  exit 0
fi

TARGET="$1"
shift || true

if [ ! -f "$TARGET" ]; then
  echo "ERROR: target file not found: $TARGET" >&2
  exit 1
fi

SG_LOADER_DIR="${SG_LOADER_DIR:-/opt/sourceguardian}"
SG_REQUIRE="${VLD_SG_REQUIRE_LOADER:-0}"
SG_OFFSET="${VLD_SG_OFFSET:-0x211010}"
ZEND_LOADER_ARG=""

if [ -d "$SG_LOADER_DIR" ]; then
  PHP_API="$(php -i | awk -F'=> ' '/^PHP Extension Build/ {print $2; exit}' || true)"
  PHP_MAJOR_MINOR="$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;' 2>/dev/null || true)"
  LOADER="$(find "$SG_LOADER_DIR" -type f \( -name 'ixed.*.lin' -o -name 'ixed.*.so' -o -name '*SourceGuardian*.so' \) | sort | head -n 1 || true)"
  if [ -n "$LOADER" ]; then
    ZEND_LOADER_ARG="-dzend_extension=$LOADER"
    echo "Using SourceGuardian loader: $LOADER" >&2
  else
    echo "Warning: no SourceGuardian loader found in $SG_LOADER_DIR" >&2
  fi
else
  echo "Warning: SourceGuardian directory not mounted: $SG_LOADER_DIR" >&2
fi

exec php \
  $ZEND_LOADER_ARG \
  -dvld.active=1 \
  -dvld.execute=0 \
  -dvld.sg_decode=1 \
  -dvld.sg_offset="$SG_OFFSET" \
  -dvld.sg_require_loader="$SG_REQUIRE" \
  -dvld.dump_paths=0 \
  "$@" \
  "$TARGET"
