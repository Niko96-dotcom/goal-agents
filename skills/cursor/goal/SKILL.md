---
name: goal
description: Run or manage a Codex-style persistent goal loop in Cursor Agent chat using goal or cursor-goal checkpoint helpers. Use for /goal, /goal pause, /goal resume, /goal clear, /goal edit, durable objectives, verification loops, and evidence-based completion. No Agent SDK or API key required.
disable-model-invocation: true
---

# Goal Skill (Cursor)

Use this skill when the user invokes `/goal` or asks for a Codex-style persistent goal loop.

**Run the loop in this Cursor chat session.** You are the agent. Do not spawn `@cursor/sdk` or external agent APIs.

Use `goal` or `cursor-goal` for durable state, verification, and checkpoint accounting.

## Command mapping

- `/goal` → `goal status` or read `.goal/current.json`.
- `/goal <objective>` → set state, then work the goal in this chat.
- `/goal pause` | `/goal resume` | `/goal clear` | `/goal edit <objective>` → matching CLI subcommands.

```bash
goal "<objective>" --verify "npm test"
```

## Checkpoint loop (each turn)

1. Load active goal (`goal status`). If missing on `/goal <objective>`, set with `goal`.
2. If status is not `active`, report and stop unless the user asked to resume.
3. Optionally run `goal prompt` for the continuation contract.
4. Make **one bounded checkpoint** of concrete progress.
5. End your response with exactly:

```text
GOAL_STATUS: COMPLETE | CONTINUE | BLOCKED
GOAL_REASON: <one short evidence-based sentence>
```

6. Record: `goal checkpoint --tool-calls <n>` (pipe assistant text on stdin if needed).
7. Continue while `active` until `complete`, `blocked`, `budget_limited`, or user pauses.

## Safety

- No destructive verification unless explicitly requested.
- Do not expose secrets.
