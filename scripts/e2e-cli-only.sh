#!/usr/bin/env bash
# CLI-only smoke: goal lifecycle without LLM.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
GOAL_CMD="$(bash "$(dirname "$0")/goal-cli-path.sh")"
STATE_CREATED=""
if [[ -z "${GOAL_STATE_DIR:-}" ]]; then
  export GOAL_STATE_DIR="$(mktemp -d)"
  STATE_CREATED="$GOAL_STATE_DIR"
  trap '[[ -n "$STATE_CREATED" ]] && rm -rf "$STATE_CREATED"' EXIT
fi

run_goal() {
  # shellcheck disable=SC2086
  $GOAL_CMD "$@"
}

run_goal clear >/dev/null 2>&1 || true
echo "== set goal =="
run_goal 'e2e smoke: create marker file' --verify 'test -f .goal-e2e-marker'
status="$(run_goal status)"
echo "$status"
echo "$status" | grep -q 'active' || { echo "expected active"; exit 1; }

echo "== checkpoint CONTINUE =="
run_goal checkpoint --tool-calls 1 <<'EOF'
Created plan for marker file.
GOAL_STATUS: CONTINUE
GOAL_REASON: marker not written yet
EOF

echo "== write marker and checkpoint COMPLETE =="
touch .goal-e2e-marker
run_goal checkpoint --tool-calls 2 <<'EOF'
Wrote .goal-e2e-marker and ran verify.
GOAL_STATUS: COMPLETE
GOAL_REASON: verify command passed
EOF

final="$(run_goal status)"
echo "$final"
echo "$final" | grep -qi 'complete' || { echo "expected complete"; exit 1; }

rm -f .goal-e2e-marker
run_goal clear
echo "OK e2e-cli-only"
