#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="/home/node/.openclaw/workspace"
INSTALL_DIR="$WORKSPACE/tools/xreach"

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

if [ ! -f package.json ]; then
  npm init -y >/dev/null 2>&1
fi

npm install xreach-cli

"$INSTALL_DIR/node_modules/.bin/xreach" --help >/dev/null

echo "xreach ready at: $INSTALL_DIR/node_modules/.bin/xreach"
