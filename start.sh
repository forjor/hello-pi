#!/usr/bin/env bash
# One-shot: start the Pi devcontainer and drop into a shell.
# Run from the project root on macOS.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "${GRN}✓ $*${NC}"; }
warn() { echo -e "${YLW}⚠ $*${NC}"; }
die()  { echo -e "${RED}✗ $*${NC}" >&2; exit 1; }

echo "── Prerequisites ─────────────────────────────────────"

command -v docker &>/dev/null || die "Docker not found. Install Docker Desktop: https://www.docker.com/products/docker-desktop/"
docker info &>/dev/null       || die "Docker daemon is not running. Start Docker Desktop first."
ok "Docker"

if ! command -v devcontainer &>/dev/null; then
  warn "devcontainer CLI not found — installing via npm..."
  command -v npm &>/dev/null || die "npm not found. Install Node.js (https://nodejs.org) then re-run."
  npm install -g @devcontainers/cli
fi
ok "devcontainer CLI ($(devcontainer --version))"

# ~/.pi on the host is bind-mounted into the container so saved pi credentials carry in.
PI_DIR="$HOME/.pi"
[[ -d "$PI_DIR" ]] || { warn "$PI_DIR not found — creating it."; mkdir -p "$PI_DIR"; }
ok "~/.pi exists"

echo ""
echo "── Starting devcontainer ─────────────────────────────"
devcontainer up --workspace-folder "$SCRIPT_DIR"

echo ""
echo "── Connecting ────────────────────────────────────────"
echo "Inside the container: export a provider key, then \`make hello\`."
exec devcontainer exec --workspace-folder "$SCRIPT_DIR" zsh
