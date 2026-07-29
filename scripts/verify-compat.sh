#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "$REPO_ROOT"

git diff --check
git diff --quiet -- upstream/open-webui
git diff --cached --quiet -- upstream/open-webui

WEBUI_SECRET_KEY="${WEBUI_SECRET_KEY:-verify-placeholder}" docker compose config --quiet
WEBUI_SECRET_KEY="${WEBUI_SECRET_KEY:-verify-placeholder}" docker compose -f docker-compose.yml -f docker-compose.local.yml config --quiet

test -f upstream/open-webui/package.json
test -f upstream/open-webui/backend/open_webui/config.py
test -f upstream/open-webui/docker-compose.yaml
test -f docker-compose.yml

latest_split="$(
  git log --grep='git-subtree-dir: upstream/open-webui' --format=%B -n 1 |
    sed -n 's/^git-subtree-split: //p' |
    tail -n 1
)"

test -n "$latest_split"
test "$(git rev-parse "${latest_split}^{tree}")" = "$(git rev-parse HEAD:upstream/open-webui)"

for ui_anchor in \
  sidebar-webui-name \
  sidebar \
  message-input-container \
  input-menu-button \
  controls-container \
  bubble-menu \
  floating-menu \
  splash-screen \
  auth-page; do
  if ! rg -q "id=\"${ui_anchor}\"" upstream/open-webui/src; then
    echo "Missing upstream UI anchor required by IndieArk branding: ${ui_anchor}" >&2
    exit 1
  fi
done

if command -v python >/dev/null 2>&1; then
  python scripts/verify-branding-assets.py
elif command -v python3 >/dev/null 2>&1; then
  python3 scripts/verify-branding-assets.py
else
  echo "Python is required to verify the branding bootstrap." >&2
  exit 1
fi

rg -n "open-webui_open-webui|HOST_PORT:-3000|OPEN_WEBUI_IMAGE:-ghcr.io/open-webui/open-webui:main|upstream/open-webui|git-subtree-split" \
  README.md UPSTREAMS.md docs plans docker-compose.yml >/dev/null

echo "Compatibility verification passed."
