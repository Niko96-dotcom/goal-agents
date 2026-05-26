# commandcode-goal

Codex-style **goal** skills for **Pi** and **Command Code**, sharing the same external workspace goal state used by [cursor-goal](https://github.com/Niko96-dotcom/cursor-goal) and [opencode-goal](https://github.com/Niko96-dotcom/opencode-goal).

## Install

```bash
# Install the shared CLI
npm install -g @nikomohr/goal-cli

# Or, for local development, build the sibling opencode-goal checkout
OPENCODE_GOAL="$HOME/Documents/opencode goal" npm run build:cli

# Install skills
cd commandcode-goal
npm run install:all
```

## Usage

| Agent | Invoke | Skill path |
|-------|--------|------------|
| **Pi** | `/goal` (extension) or `/skill:goal` | `pi-goal` extension + `~/.pi/agent/skills/goal` |
| **Command Code** | `/goal` or `/goal <objective>` | `~/.agents/skills/goal` |
| **Cursor** | `/goal` | `~/.cursor/skills/goal` |
| **OpenCode** | `/goal` (plugin) | `opencode-goal` package |

CLI (any workspace):

```bash
goal "my objective" --verify "npm test"
goal checkpoint --tool-calls 2
```

## Test

```bash
npm test              # CLI + skill install + agent smoke (cheap model)
npm run test:cli      # CLI only (no LLM)
GOAL_E2E_SKIP_AGENT=1 npm test   # skip pi/commandcode LLM calls
```

Cheap model defaults: `deepseek/deepseek-v4-flash`. Override:

```bash
GOAL_E2E_CC_MODEL=google/gemini-3.1-flash-lite GOAL_E2E_PI_MODEL=google/gemini-3.1-flash-lite npm test
```

## Related repos

- `~/cursor-goal-source/cursor-goal` — Cursor skill + `cursor-goal` CLI
- `~/Documents/opencode goal` — `goal-core`, `goal-cli`, OpenCode plugin
