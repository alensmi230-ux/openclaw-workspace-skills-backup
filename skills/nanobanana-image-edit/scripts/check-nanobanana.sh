#!/usr/bin/env bash
set -euo pipefail

CFG="${NANOBANANA_PROVIDER_CONFIG:-/home/node/.openclaw/workspace/.openclaw/local/nanobanana-providers.json}"
PY="/home/node/.openclaw/workspace/skills/nanobanana-image-edit/scripts/nanobanana_provider.py"

if [ -f "$PY" ]; then
  echo "runtime: installed"
else
  echo "runtime: missing"
  exit 1
fi

if [ -f "$CFG" ]; then
  echo "config: present"
  python3 - <<PY
import json
p="$CFG"
obj=json.load(open(p))
print('config_path:', p)
print('default_provider:', obj.get('default_provider'))
for name, cfg in obj.get('providers', {}).items():
    key = cfg.get('api_key', '')
    masked = (key[:6] + '...' + key[-4:]) if len(key) >= 14 else ('set' if key else 'missing')
    print(f'provider: {name} url={cfg.get("base_url")} key={masked}')
PY
else
  echo "config: missing"
  echo "hint: create $CFG"
  exit 1
fi
