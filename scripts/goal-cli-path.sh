#!/usr/bin/env bash
# Resolve goal CLI for smoke tests and skill fallbacks.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OPENCODE_GOAL="${OPENCODE_GOAL:-$HOME/Documents/opencode goal}"
GOAL_CLI_DIST="${OPENCODE_GOAL}/packages/goal-cli/dist/index.js"

cli_works() {
  local cmd="$1"
  $cmd --help >/dev/null 2>&1
}

local_goal_wrapper() {
  local wrapper="${TMPDIR:-/tmp}/goal-cli-local-${USER:-user}.sh"
  printf '#!/usr/bin/env bash\nexec node %q "$@"\n' "$GOAL_CLI_DIST" > "$wrapper"
  chmod +x "$wrapper"
  echo "$wrapper"
}

if command -v goal >/dev/null 2>&1 && cli_works goal; then
  echo "goal"
  exit 0
fi
if [[ -f "$GOAL_CLI_DIST" ]]; then
  wrapper="$(local_goal_wrapper)"
  if cli_works "$wrapper"; then
    echo "$wrapper"
    exit 0
  fi
fi
  exit 0
fi
if command -v cursor-goal >/dev/null 2>&1 && cli_works cursor-goal; then
  echo "cursor-goal"
  exit 0
fi

echo "error: no goal CLI found. Build opencode-goal: cd \"$OPENCODE_GOAL\" && npm run build" >&2
exit 1
