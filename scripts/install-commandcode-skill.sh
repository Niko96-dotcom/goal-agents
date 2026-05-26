#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="${ROOT}/skills/commandcode/goal"
GLOBAL=false
TARGET=""

usage() {
  cat <<'EOF'
Install the goal skill for Command Code.

Usage:
  install-commandcode-skill.sh [--global] [target-dir]

  --global, -g    Install to ~/.agents/skills/goal (Command Code global skills)
  target-dir      Install to <target-dir>/.agents/skills/goal (default: $PWD)
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
  DEST="${HOME}/.agents/skills/goal"
  mkdir -p "${HOME}/.commandcode/skills"
  rm -rf "${HOME}/.commandcode/skills/goal"
  cp -R "$SOURCE" "${HOME}/.commandcode/skills/goal"
else
  DEST="${TARGET:-$PWD}/.agents/skills/goal"
fi

mkdir -p "$(dirname "$DEST")"
rm -rf "$DEST"
cp -R "$SOURCE" "$DEST"
echo "Installed Command Code goal skill to $DEST"
echo "Invoke in Command Code with: /goal  or  /goal <objective>"
