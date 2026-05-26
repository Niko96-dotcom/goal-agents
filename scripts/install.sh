#!/usr/bin/env bash
# Full install: sync this repo, then CLI + agent skills/extensions.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

sync_repo() {
  [[ -d .git ]] || return 0
  grep -q '"name": "goal-agents"' package.json 2>/dev/null || return 0

  local branch="${GOAL_AGENTS_BRANCH:-master}"
  if git symbolic-ref -q HEAD >/dev/null 2>&1; then
    branch="$(git symbolic-ref --short HEAD)"
  fi

  echo "Syncing goal-agents (${branch})..."
  git fetch origin "${branch}" 2>/dev/null || git fetch origin master 2>/dev/null || true
  if git pull --ff-only origin "${branch}" 2>/dev/null; then
    :
  elif git pull --ff-only origin master 2>/dev/null; then
    :
  else
    echo "warning: could not fast-forward; using current files" >&2
  fi
}

sync_repo
bash "${ROOT}/scripts/install-cli.sh"
npm run install:all
