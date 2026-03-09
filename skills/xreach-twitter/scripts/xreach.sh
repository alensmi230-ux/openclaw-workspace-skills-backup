#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="/home/node/.openclaw/workspace"
LOCAL_BIN="$WORKSPACE/tools/xreach/node_modules/.bin/xreach"

if [ -x "$LOCAL_BIN" ]; then
  exec "$LOCAL_BIN" "$@"
fi

if command -v xreach >/dev/null 2>&1; then
  exec xreach "$@"
fi

echo "xreach not installed." >&2
echo "Run: $WORKSPACE/skills/xreach-twitter/scripts/ensure-xreach.sh" >&2
exit 127
