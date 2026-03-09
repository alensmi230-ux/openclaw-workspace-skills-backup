#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/env.sh"

SMOKE=0
if [[ "${1:-}" == "--smoke" ]]; then
  SMOKE=1
fi

echo "runtime_dir=$PLAYWRIGHT_BROWSER_RUNTIME_DIR"
echo "node_run=$PLAYWRIGHT_BROWSER_NODE_RUN"

echo -n "playwright_version="
( cd "$PLAYWRIGHT_BROWSER_NODE_RUN" && npx playwright --version ) || echo "missing"

echo "browser_binary=$(find "$HOME/.cache/ms-playwright" -path '*chrome-headless-shell-linux64/chrome-headless-shell' | head -n1)"
echo -n "zh_font="; fc-match 'Noto Sans CJK SC' || fc-match 'sans:lang=zh-cn' || true
echo -n "emoji_font="; fc-match 'Noto Color Emoji' || fc-match 'emoji' || true

if [[ $SMOKE -eq 1 ]]; then
  OUT="/tmp/playwright-browser-smoke.png"
  "$SCRIPT_DIR/playwright.sh" screenshot --browser=chromium https://example.com "$OUT" >/tmp/playwright-browser-smoke.log 2>&1
  echo "smoke_screenshot=$OUT"
fi
