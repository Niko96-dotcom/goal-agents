#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="${ROOT}/skills/cursor/goal"
GLOBAL=false
TARGET=""

usage() {
  cat <<'EOF'
Install the goal skill for Cursor.

Usage:
  install-cursor-skill.sh [--global] [target-dir]

  --global, -g    Install to ~/.cursor/skills/goal
  target-dir      Install to <target-dir>/.cursor/skills/goal (default: $PWD)
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
  DEST="${HOME}/.cursor/skills/goal"
else
  DEST="${TARGET:-$PWD}/.cursor/skills/goal"
fi

mkdir -p "$(dirname "$DEST")"
rm -rf "$DEST"
cp -R "$SOURCE" "$DEST"
echo "Installed Cursor goal skill to $DEST"
echo "Invoke in Cursor with: /goal  or  /goal <objective>"
