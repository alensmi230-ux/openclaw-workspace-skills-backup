#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
XR="$SCRIPT_DIR/xreach.sh"

if ! "$XR" --version >/dev/null 2>&1; then
  echo "status: missing"
  echo "fix: run $SCRIPT_DIR/ensure-xreach.sh"
  exit 1
fi

version="$($XR --version 2>/dev/null | head -n 1 || true)"
echo "status: installed"
echo "version: ${version:-unknown}"

"$XR" auth check >/tmp/xreach-auth-check.out 2>/tmp/xreach-auth-check.err || true

if grep -qi 'not authenticated' /tmp/xreach-auth-check.out; then
  echo "auth: not-configured"
  cat /tmp/xreach-auth-check.out
  echo "hint: run '$XR auth browsers' or '$XR auth extract --browser chrome --profile Default'"
else
  echo "auth: configured"
  [ -s /tmp/xreach-auth-check.out ] && cat /tmp/xreach-auth-check.out
  [ -s /tmp/xreach-auth-check.err ] && cat /tmp/xreach-auth-check.err
fi
