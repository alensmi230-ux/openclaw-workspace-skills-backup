#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/env.sh"

if [[ $# -eq 0 || "${1:-}" == "--help" ]]; then
  cat <<'EOF'
Run an arbitrary command with the Playwright browser runtime environment loaded.

Examples:
  scripts/node-playwright.sh node /abs/path/to/script.js
  scripts/node-playwright.sh bash -lc 'node -e "console.log(require(\"playwright\").chromium)"'
EOF
  exit 0
fi

exec "$@"
