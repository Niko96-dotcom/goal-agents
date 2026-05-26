---
name: goal
description: Run or manage a Codex-style persistent goal loop in Command Code chat using the goal CLI. Use for /goal, goal pause, goal resume, goal clear, durable objectives, verification loops, and evidence-based completion.
---

# Goal Skill (Command Code)

Use this skill when the user invokes `/goal` or asks for a Codex-style persistent goal loop.

**Run the loop in this Command Code chat session.** You are the agent. Do not spawn external agent APIs.

Use the local `goal` CLI (or `cursor-goal`) for durable state, verification, and checkpoint accounting.

Resolve the CLI as the first working command:

```bash
goal status 2>/dev/null || cursor-goal status 2>/dev/null || node "$GOAL_CLI" status
```

If neither `goal` nor `cursor-goal` is on PATH, set `GOAL_CLI` to a built `@nikomohr/goal-cli` entrypoint and use `node "$GOAL_CLI"`.

## Command mapping

- `/goal` → `goal status`.
- `/goal <objective>` → set state, then work the goal in this chat.
- `/goal pause` → `goal pause`.
- `/goal resume` → `goal resume`, then continue in this chat.
- `/goal clear` → `goal clear`.
- `/goal edit <objective>` → `goal` with new objective (set via CLI), then continue.

When setting a goal from the CLI:

```bash
goal "<objective>" --verify "npm test"
```

If the objective names verification, pass `--verify`. Otherwise infer a safe command when obvious.

## Checkpoint loop (each turn)

1. Load active goal with `goal status`. If missing on `/goal <objective>`, set it with `goal`.
2. If status is not `active`, report status and stop unless the user asked to resume.
3. Optionally run `goal prompt` for the formatted continuation contract.
4. Make **one bounded checkpoint** of concrete progress with normal Command Code tools.
5. End your response with exactly:

```text
GOAL_STATUS: COMPLETE | CONTINUE | BLOCKED
GOAL_REASON: <one short evidence-based sentence>
```

6. Record the checkpoint (bash needs `--yolo` or `--permission-mode auto-accept` in non-interactive Command Code):

```bash
goal checkpoint --tool-calls <n>
```

Pipe your final assistant text on stdin when needed.

7. If still `active`, continue in follow-up turns until `complete`, `blocked`, `budget_limited`, or the user pauses.

## Operating contract

- Treat the goal text as both the starting prompt and the completion criteria.
- Prefer small, auditable changes over sweeping rewrites.
- Use repository evidence: files, diffs, tests, command output, artifacts.
- Do not declare complete unless verification passed or you justify why it no longer applies.
- If blocked, use `GOAL_STATUS: BLOCKED`.
- Default to at most 8 checkpoints unless state sets a different budget.

## Safety

- Do not run destructive verification unless explicitly requested.
- Do not expose secrets.
