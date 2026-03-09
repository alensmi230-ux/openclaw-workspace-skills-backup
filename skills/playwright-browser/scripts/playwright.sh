#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/env.sh"

if [[ "${1:-}" == "--help-wrapper" ]]; then
  cat <<'EOF'
Use this wrapper after running ensure-playwright.sh once.

Examples:
  scripts/playwright.sh --version
  scripts/playwright.sh screenshot --browser=chromium https://example.com /tmp/example.png
  scripts/playwright.sh install chromium
EOF
  exit 0
fi

cd "$PLAYWRIGHT_BROWSER_NODE_RUN"
exec npx playwright "$@"
