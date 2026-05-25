#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 protected_file.php [sourceguardian_loader_dir]" >&2
  exit 1
fi

ENGINE="${CONTAINER_ENGINE:-}"
if [ -z "$ENGINE" ]; then
  if command -v podman >/dev/null 2>&1; then ENGINE=podman; elif command -v docker >/dev/null 2>&1; then ENGINE=docker; else echo "ERROR: install podman or docker" >&2; exit 1; fi
fi

IMAGE="${IMAGE:-vld-sourceguardian-centos10}"
TARGET="$1"
SG_DIR="${2:-$PWD/sourceguardian}"
TARGET_ABS="$(realpath "$TARGET")"
WORK_DIR="$(dirname "$TARGET_ABS")"
WORK_FILE="$(basename "$TARGET_ABS")"

SELINUX_SUFFIX=":Z"
if [ "$ENGINE" = "docker" ]; then
  SELINUX_SUFFIX=""
fi

$ENGINE run --rm \
  -v "$WORK_DIR:/work${SELINUX_SUFFIX}" \
  -v "$SG_DIR:/opt/sourceguardian${SELINUX_SUFFIX},ro" \
  -e VLD_SG_OFFSET="${VLD_SG_OFFSET:-0x211010}" \
  -e VLD_SG_REQUIRE_LOADER="${VLD_SG_REQUIRE_LOADER:-0}" \
  "$IMAGE" "/work/$WORK_FILE"
