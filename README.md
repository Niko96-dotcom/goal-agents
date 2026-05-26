# goal-agents

Codex-style **`/goal`** for every agent harness in this stack. Shared workspace state (`.goal/current.json`) via [goal-cli](https://github.com/Niko96-dotcom/opencode-goal/tree/main/packages/goal-cli) / `cursor-goal`.

| Agent | `/goal` | Install from this repo |
|-------|---------|-------------------------|
| **Cursor** | `/goal` | `npm run install:cursor` → `~/.cursor/skills/goal` |
| **OpenCode** | `/goal` (plugin) | [opencode-goal](https://github.com/Niko96-dotcom/opencode-goal) — see [docs/opencode.md](docs/opencode.md) |
| **Pi** | `/goal` (extension) or `/skill:goal` | `npm run install:pi` → skill + [pi-goal](extensions/pi-goal) |
| **Command Code** | `/goal` | `npm run install:commandcode` → `~/.agents/skills/goal` |

## Quick install

```bash
git clone https://github.com/Niko96-dotcom/goal-agents.git
cd goal-agents

# Shared CLI (pick one)
npm install -g @nikomohr/goal-cli
# or: npm install -g cursor-goal

npm run install:all   # cursor + pi + commandcode skills/extensions
```

## CLI (any project)

```bash
goal "my objective" --verify "npm test"
goal status
goal checkpoint --tool-calls 2
goal pause | resume | clear
```

## Test

```bash
npm run test:cli
npm test                    # + agent smoke (deepseek/deepseek-v4-flash for CC)
GOAL_E2E_SKIP_AGENT=1 npm test
```

## Related repos

- [cursor-goal](https://github.com/Niko96-dotcom/cursor-goal) — Cursor-first CLI + skill source
- [opencode-goal](https://github.com/Niko96-dotcom/opencode-goal) — goal-core, goal-cli, OpenCode plugin
