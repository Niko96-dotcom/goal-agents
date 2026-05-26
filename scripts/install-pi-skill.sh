#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="${ROOT}/skills/pi/goal"
GLOBAL=false
TARGET=""

usage() {
  cat <<'EOF'
Install the goal skill for Pi.

Usage:
  install-pi-skill.sh [--global] [target-dir]

  --global, -g    Install to ~/.pi/agent/skills/goal
  target-dir      Install to <target-dir>/.pi/skills/goal (default: $PWD)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --global|-g) GLOBAL=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) TARGET="$1"; shift ;;
  esac
done

if [[ ! -f "${SOURCE}/SKILL.md" ]]; then
  echo "error: missing ${SOURCE}/SKILL.md" >&2
  exit 1
fi

if [[ "$GLOBAL" == true ]]; then
  DEST="${HOME}/.pi/agent/skills/goal"
else
  DEST="${TARGET:-$PWD}/.pi/skills/goal"
fi

mkdir -p "$(dirname "$DEST")"
rm -rf "$DEST"
cp -R "$SOURCE" "$DEST"
echo "Installed Pi goal skill to $DEST"
echo "Invoke in Pi with: /skill:goal  or  /skill:goal <objective>"
