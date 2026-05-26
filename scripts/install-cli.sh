#!/usr/bin/env bash
set -euo pipefail

if command -v cursor-goal >/dev/null 2>&1; then
  echo "cursor-goal already installed: $(command -v cursor-goal)"
  cursor-goal --help 2>&1 | head -1 || true
  exit 0
fi

if command -v goal >/dev/null 2>&1; then
  echo "goal already installed: $(command -v goal)"
  goal --help 2>&1 | head -1 || true
  exit 0
fi

echo "Installing cursor-goal globally (provides goal + cursor-goal binaries)..."
npm install -g cursor-goal
echo "Done. Try: goal status  or  cursor-goal status"
