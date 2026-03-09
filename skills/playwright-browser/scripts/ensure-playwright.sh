#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/env.sh"

usage() {
  cat <<'EOF'
Prepare a no-root Playwright runtime inside the workspace.

What it does:
  - downloads Debian runtime libraries into the workspace with apt-get download
  - extracts libraries/fonts into tools/playwright-browser-runtime/root
  - installs Playwright locally into tmp/playwright-browser-run
  - downloads Chromium with Playwright
  - refreshes font cache so Chinese + emoji render correctly

Usage:
  scripts/ensure-playwright.sh [--smoke]
EOF
}

SMOKE=0
if [[ "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi
if [[ "${1:-}" == "--smoke" ]]; then
  SMOKE=1
fi

command -v apt-get >/dev/null || { echo 'apt-get is required for the no-root Debian setup' >&2; exit 1; }
command -v dpkg-deb >/dev/null || { echo 'dpkg-deb is required' >&2; exit 1; }
command -v npm >/dev/null || { echo 'npm is required' >&2; exit 1; }
command -v fc-cache >/dev/null || { echo 'fontconfig (fc-cache) is required' >&2; exit 1; }

APT_STATE="$PLAYWRIGHT_BROWSER_RUNTIME_DIR/apt/lists"
APT_ARCHIVES="$PLAYWRIGHT_BROWSER_RUNTIME_DIR/apt/cache/archives"
DEBS="$PLAYWRIGHT_BROWSER_RUNTIME_DIR/debs"
ROOT="$PLAYWRIGHT_BROWSER_ROOT"

mkdir -p "$APT_STATE/partial" "$APT_ARCHIVES/partial" "$DEBS" "$ROOT" "$PLAYWRIGHT_BROWSER_FONT_DIR"

apt-get -o Dir::State::lists="$APT_STATE" -o Dir::Cache::archives="$APT_ARCHIVES" -o APT::Get::List-Cleanup=0 update

packages=(
  libnspr4 libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2
  libdbus-1-3 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2
  libgbm1 libasound2 libatspi2.0-0 libxshmfence1 libglib2.0-0 libgtk-3-0
  libpango-1.0-0 libcairo2 libx11-6 libx11-xcb1 libxcb1 libxext6 libxrender1
  libxcursor1 libxi6 libxinerama1 libxtst6 ca-certificates fonts-liberation
  libwayland-client0 libwayland-cursor0 libwayland-egl1 libwayland-server0
  fonts-noto-cjk fonts-noto-color-emoji
)

(
  cd "$DEBS"
  apt-get -o Dir::State::lists="$APT_STATE" -o Dir::Cache::archives="$APT_ARCHIVES" -o APT::Get::List-Cleanup=0 download "${packages[@]}"
)

for deb in "$DEBS"/*.deb; do
  dpkg-deb -x "$deb" "$ROOT"
done

find "$ROOT/usr/share/fonts" -type f \( -iname '*.ttf' -o -iname '*.ttc' -o -iname '*.otf' \) -exec ln -sf {} "$PLAYWRIGHT_BROWSER_FONT_DIR"/ \;
fc-cache -f "$PLAYWRIGHT_BROWSER_FONT_DIR" >/dev/null 2>&1 || true

if [[ ! -f "$PLAYWRIGHT_BROWSER_NODE_RUN/package.json" ]]; then
  ( cd "$PLAYWRIGHT_BROWSER_NODE_RUN" && npm init -y >/dev/null 2>&1 )
fi

if [[ ! -f "$PLAYWRIGHT_BROWSER_NODE_RUN/node_modules/playwright/package.json" ]]; then
  ( cd "$PLAYWRIGHT_BROWSER_NODE_RUN" && PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 npm install playwright >/dev/null 2>&1 )
fi

( cd "$PLAYWRIGHT_BROWSER_NODE_RUN" && npx playwright install chromium >/dev/null )

if [[ $SMOKE -eq 1 ]]; then
  "$SCRIPT_DIR/check-playwright.sh" --smoke
else
  "$SCRIPT_DIR/check-playwright.sh"
fi
