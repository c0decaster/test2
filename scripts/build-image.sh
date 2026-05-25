#!/usr/bin/env bash
set -euo pipefail

ENGINE="${CONTAINER_ENGINE:-}"
if [ -z "$ENGINE" ]; then
  if command -v podman >/dev/null 2>&1; then ENGINE=podman; elif command -v docker >/dev/null 2>&1; then ENGINE=docker; else echo "ERROR: install podman or docker" >&2; exit 1; fi
fi

IMAGE="${IMAGE:-vld-sourceguardian-centos10}"
$ENGINE build -f Containerfile.centos10 -t "$IMAGE" .
echo "Built image: $IMAGE"
