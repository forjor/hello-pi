#!/usr/bin/env bash
# Remove the Pi devcontainer image (and any running containers from it).
# Usage: ./clean.sh [--rebuild]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REBUILD=false

RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "${GRN}✓ $*${NC}"; }
warn() { echo -e "${YLW}⚠ $*${NC}"; }
die()  { echo -e "${RED}✗ $*${NC}" >&2; exit 1; }

for arg in "$@"; do
  case "$arg" in
    --rebuild) REBUILD=true ;;
    *) die "Unknown flag: $arg" ;;
  esac
done

echo "── Prerequisites ─────────────────────────────────────"
command -v docker &>/dev/null || die "Docker not found."
docker info &>/dev/null       || die "Docker daemon is not running."
ok "Docker"

echo ""
echo "── Cleaning devcontainer ─────────────────────────────"

LABEL_FILTER="label=devcontainer.local_folder=$SCRIPT_DIR"

CONTAINERS=$(docker ps -aq --filter "$LABEL_FILTER")
if [[ -n "$CONTAINERS" ]]; then
  warn "Stopping and removing containers..."
  # shellcheck disable=SC2086
  docker rm -f $CONTAINERS
  ok "Containers removed"
else
  ok "No running containers"
fi

IMAGES=$(docker images -q --filter "$LABEL_FILTER")
if [[ -n "$IMAGES" ]]; then
  warn "Removing image(s)..."
  # shellcheck disable=SC2086
  docker rmi -f $IMAGES
  ok "Image(s) removed"
else
  ok "No devcontainer image found (already clean)"
fi

if "$REBUILD"; then
  echo ""
  echo "── Rebuilding ────────────────────────────────────────"
  exec "$SCRIPT_DIR/start.sh"
fi
