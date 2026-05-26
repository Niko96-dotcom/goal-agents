#!/usr/bin/env bash
# Clone or update goal-agents, then npm run install. Safe to re-run.
set -euo pipefail

REPO="https://github.com/Niko96-dotcom/goal-agents.git"
BRANCH="${GOAL_AGENTS_BRANCH:-master}"
ROOT="${GOAL_AGENTS_DIR:-$(pwd)/goal-agents}"

# If already inside a goal-agents checkout, use it.
if [[ -f package.json ]] && grep -q '"name": "goal-agents"' package.json 2>/dev/null; then
  ROOT="$(pwd)"
fi

if [[ -d "${ROOT}/.git" ]]; then
  echo "Updating ${ROOT}..."
  git -C "${ROOT}" fetch origin "${BRANCH}" 2>/dev/null || git -C "${ROOT}" fetch origin master
  git -C "${ROOT}" pull --ff-only origin "${BRANCH}" 2>/dev/null \
    || git -C "${ROOT}" pull --ff-only origin master
else
  if [[ -e "${ROOT}" ]]; then
    echo "error: ${ROOT} exists but is not a git repo. Move it aside or set GOAL_AGENTS_DIR." >&2
    exit 1
  fi
  echo "Cloning into ${ROOT}..."
  git clone --branch "${BRANCH}" --depth 1 "${REPO}" "${ROOT}"
fi

cd "${ROOT}"
if ! npm run install 2>/dev/null; then
  echo "Checkout may be stale; pulling again..."
  git pull --ff-only origin "${BRANCH}" 2>/dev/null || git pull --ff-only origin master
  npm run install
fi
