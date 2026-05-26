#!/usr/bin/env bash
# Install goal + cursor-goal CLI globally (npm registry or GitHub fallback).
set -euo pipefail

has_cli() {
  command -v goal >/dev/null 2>&1 && command -v cursor-goal >/dev/null 2>&1
}

if has_cli; then
  echo "Already installed:"
  echo "  goal:         $(command -v goal)"
  echo "  cursor-goal:  $(command -v cursor-goal)"
  exit 0
fi

install_goal_shim() {
  if command -v goal >/dev/null 2>&1; then
    return 0
  fi
  if ! command -v cursor-goal >/dev/null 2>&1; then
    return 1
  fi
  local prefix bin
  prefix="$(npm prefix -g 2>/dev/null)" || return 1
  bin="${prefix}/bin"
  if [[ -w "$bin" ]]; then
    ln -sf cursor-goal "${bin}/goal"
    echo "Linked ${bin}/goal -> cursor-goal"
    return 0
  fi
  return 1
}

try_npm_goal_cli() {
  echo "Trying npm install -g @nikomohr/goal-cli..."
  if npm install -g @nikomohr/goal-cli; then
    return 0
  fi
  return 1
}

try_npm_cursor_goal() {
  echo "Trying npm install -g cursor-goal..."
  if npm install -g cursor-goal; then
    install_goal_shim || true
    return 0
  fi
  return 1
}

try_github_build() {
  local tmp repo="https://github.com/Niko96-dotcom/opencode-goal.git"
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN
  echo "Building CLI from ${repo}..."
  git clone --depth 1 "$repo" "$tmp"
  (cd "$tmp" && npm ci && npm run build)
  npm install -g "${tmp}/packages/goal-cli"
}

if try_npm_goal_cli && has_cli; then
  :
elif try_npm_cursor_goal && command -v cursor-goal >/dev/null 2>&1; then
  :
elif try_github_build && has_cli; then
  :
else
  echo "error: could not install goal CLI." >&2
  echo "Try manually:" >&2
  echo "  npm install -g @nikomohr/goal-cli" >&2
  echo "  npm install -g cursor-goal" >&2
  exit 1
fi

install_goal_shim || true

echo "Installed:"
command -v goal >/dev/null 2>&1 && echo "  goal:         $(command -v goal)"
command -v cursor-goal >/dev/null 2>&1 && echo "  cursor-goal:  $(command -v cursor-goal)"
goal status 2>&1 | head -3 || cursor-goal status 2>&1 | head -3 || true
