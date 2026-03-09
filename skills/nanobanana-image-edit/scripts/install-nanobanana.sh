#!/usr/bin/env bash
set -euo pipefail

echo "This skill no longer requires the upstream nanobanana binary for API calls."
echo "It uses the local Python runtime at:"
echo "  /home/node/.openclaw/workspace/skills/nanobanana-image-edit/scripts/nanobanana_provider.py"
echo
CFG="${NANOBANANA_PROVIDER_CONFIG:-/home/node/.openclaw/workspace/.openclaw/local/nanobanana-providers.json}"
echo "Expected provider config: $CFG"
