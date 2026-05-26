#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EXT="${ROOT}/extensions/pi-goal"

if [[ ! -f "${EXT}/extensions/goal.ts" ]]; then
  echo "error: missing pi-goal extension at ${EXT}" >&2
  exit 1
fi

echo "Installing pi-goal extension..."
pi install "${EXT}" -l

echo "Installed. In Pi, use: /goal status  or  /goal \"<objective>\""
