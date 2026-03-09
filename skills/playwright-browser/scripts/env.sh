#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE="$(cd "$SKILL_DIR/../.." && pwd)"

export HOME="${HOME:-/home/node}"
export PLAYWRIGHT_BROWSER_WORKSPACE="$WORKSPACE"
export PLAYWRIGHT_BROWSER_RUNTIME_DIR="$WORKSPACE/tools/playwright-browser-runtime"
export PLAYWRIGHT_BROWSER_ROOT="$PLAYWRIGHT_BROWSER_RUNTIME_DIR/root"
export PLAYWRIGHT_BROWSER_NODE_RUN="$WORKSPACE/tmp/playwright-browser-run"
export PLAYWRIGHT_BROWSER_FONT_DIR="$HOME/.local/share/fonts/openclaw-playwright"
export PLAYWRIGHT_BROWSER_FONTCONF="$PLAYWRIGHT_BROWSER_RUNTIME_DIR/fonts.conf"

mkdir -p "$PLAYWRIGHT_BROWSER_RUNTIME_DIR/cache/fontconfig" "$PLAYWRIGHT_BROWSER_NODE_RUN" "$PLAYWRIGHT_BROWSER_FONT_DIR"

cat > "$PLAYWRIGHT_BROWSER_FONTCONF" <<EOF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <dir>/usr/share/fonts</dir>
  <dir>/usr/local/share/fonts</dir>
  <dir>$PLAYWRIGHT_BROWSER_FONT_DIR</dir>
  <dir>$PLAYWRIGHT_BROWSER_ROOT/usr/share/fonts</dir>
  <cachedir>$PLAYWRIGHT_BROWSER_RUNTIME_DIR/cache/fontconfig</cachedir>
</fontconfig>
EOF

export LD_LIBRARY_PATH="$PLAYWRIGHT_BROWSER_ROOT/usr/lib/x86_64-linux-gnu:$PLAYWRIGHT_BROWSER_ROOT/usr/lib:$PLAYWRIGHT_BROWSER_ROOT/lib/x86_64-linux-gnu:$PLAYWRIGHT_BROWSER_ROOT/lib:${LD_LIBRARY_PATH:-}"
export FONTCONFIG_FILE="$PLAYWRIGHT_BROWSER_FONTCONF"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export LANG="${LANG:-C.UTF-8}"
export LC_ALL="${LC_ALL:-C.UTF-8}"
export NODE_PATH="$PLAYWRIGHT_BROWSER_NODE_RUN/node_modules${NODE_PATH:+:$NODE_PATH}"
export PATH="$PLAYWRIGHT_BROWSER_NODE_RUN/node_modules/.bin:$PATH"
export NPM_CONFIG_UPDATE_NOTIFIER=false
