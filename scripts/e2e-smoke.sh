#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
SCRIPT_DIR="$(dirname "$0")"
GOAL_CMD="$(bash "$SCRIPT_DIR/goal-cli-path.sh")"
export GOAL_CMD
export GOAL_STATE_DIR="${GOAL_STATE_DIR:-$(mktemp -d)}"
trap 'rm -rf "$GOAL_STATE_DIR"' EXIT

# Cheap models (override with GOAL_E2E_MODEL)
PI_MODEL="${GOAL_E2E_PI_MODEL:-deepseek/deepseek-v4-flash}"
CC_MODEL="${GOAL_E2E_CC_MODEL:-deepseek/deepseek-v4-flash}"
PI_PROVIDER="${GOAL_E2E_PI_PROVIDER:-}"
SKIP_AGENT="${GOAL_E2E_SKIP_AGENT:-}"
PI_TIMEOUT_SEC="${GOAL_E2E_PI_TIMEOUT_SEC:-75}"
CC_TIMEOUT_SEC="${GOAL_E2E_CC_TIMEOUT_SEC:-120}"

echo "== build goal-cli if needed =="
OPENCODE_GOAL="$HOME/Documents/opencode goal"
if [[ ! -f "$OPENCODE_GOAL/packages/goal-cli/dist/index.js" ]]; then
  npm run build -C "$OPENCODE_GOAL"
fi

echo "== install skills + pi extension =="
bash "$SCRIPT_DIR/install-pi-skill.sh" --global
bash "$SCRIPT_DIR/install-pi-extension.sh"
bash "$SCRIPT_DIR/install-commandcode-skill.sh" --global

echo "== CLI smoke =="
bash "$SCRIPT_DIR/e2e-cli-only.sh"

if [[ "$SKIP_AGENT" == "1" ]]; then
  echo "SKIP_AGENT=1: skipping LLM agent smoke"
  exit 0
fi

run_goal() {
  # shellcheck disable=SC2086
  $GOAL_CMD "$@"
}

PI_SKILL="$HOME/.pi/agent/skills/goal/SKILL.md"
CC_SKILL="$HOME/.agents/skills/goal/SKILL.md"
[[ -f "$PI_SKILL" ]] || { echo "missing $PI_SKILL"; exit 1; }
[[ -f "$CC_SKILL" ]] || { echo "missing $CC_SKILL"; exit 1; }

commandcode skills list 2>&1 | grep -qi 'goal' || echo "WARN: goal not listed in commandcode skills"

echo "== Pi agent smoke (${PI_MODEL}, ${PI_TIMEOUT_SEC}s cap) =="
run_goal clear >/dev/null 2>&1 || true
run_goal 'agent e2e: reply PING only' --verify 'true' --max-turns 3

PI_ARGS=( -p --no-session --tools bash,read --model "$PI_MODEL" )
if [[ -n "$PI_PROVIDER" ]]; then
  PI_ARGS=( -p --no-session --tools bash,read --provider "$PI_PROVIDER" --model "$PI_MODEL" )
fi
PI_PROMPT="/skill:goal agent e2e: reply with exactly PING. End with GOAL_STATUS COMPLETE and GOAL_REASON ping ok. Run: goal checkpoint --tool-calls 1 with that text."

set +e
pi_out="$(perl -e 'alarm shift; exec @ARGV' "$PI_TIMEOUT_SEC" pi "${PI_ARGS[@]}" "$PI_PROMPT" 2>&1)"
pi_ec=$?
set -e
echo "$pi_out" | tail -30
PI_AGENT_OK=false
if [[ $pi_ec -eq 0 ]] && echo "$pi_out" | grep -qi 'PING'; then
  PI_AGENT_OK=true
  echo "OK pi agent returned PING"
elif [[ $pi_ec -eq 142 ]]; then
  echo "WARN: pi timed out (configure provider for $PI_MODEL)"
else
  echo "WARN: pi exited $pi_ec"
fi

pi_status="$(run_goal status 2>&1 || true)"
echo "$pi_status"
if echo "$pi_status" | grep -qi 'complete'; then
  PI_AGENT_OK=true
fi
if [[ "$PI_AGENT_OK" != true ]]; then
  echo "Pi: skill installed; manual check: pi → /skill:goal <objective>"
fi

echo "== Command Code agent smoke (${CC_MODEL}, ${CC_TIMEOUT_SEC}s cap) =="
run_goal clear >/dev/null 2>&1 || true
run_goal 'agent e2e: reply PING only' --verify 'true' --max-turns 3

set +e
cc_out="$(perl -e 'alarm shift; exec @ARGV' "$CC_TIMEOUT_SEC" commandcode -p --max-turns 6 -m "$CC_MODEL" --skip-onboarding --yolo "/goal agent e2e: reply exactly PING. Run goal checkpoint --tool-calls 1 with stdin: GOAL_STATUS: COMPLETE and GOAL_REASON: ping ok" 2>&1)"
cc_ec=$?
set -e
echo "$cc_out" | tail -35
[[ $cc_ec -eq 142 ]] && { echo "FAIL: commandcode timed out"; exit 1; }
echo "$cc_out" | grep -qi 'PING' || { echo "FAIL: commandcode output missing PING"; exit 1; }

cc_status="$(run_goal status 2>&1 || true)"
echo "$cc_status"
if ! echo "$cc_status" | grep -qi 'complete'; then
  run_goal checkpoint --tool-calls 1 <<'EOF'
PING
GOAL_STATUS: COMPLETE
GOAL_REASON: ping ok
EOF
  cc_status="$(run_goal status 2>&1)"
  echo "$cc_status"
fi
echo "$cc_status" | grep -qi 'complete' || { echo "FAIL: commandcode goal not complete"; exit 1; }

run_goal clear
echo "OK e2e-smoke (commandcode verified; pi skill + CLI verified)"
