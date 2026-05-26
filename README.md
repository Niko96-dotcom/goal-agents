# goal-agents

Codex-style **`/goal`** for Cursor, OpenCode, Pi, and Command Code. Shared goal state via the **`goal`** / **`cursor-goal`** CLI ([cursor-goal on npm](https://www.npmjs.com/package/cursor-goal)).

| Agent | `/goal` | Install from this repo |
|-------|---------|-------------------------|
| **Cursor** | `/goal` | `npm run install:cursor` |
| **OpenCode** | `/goal` (plugin) | [opencode-goal](https://github.com/Niko96-dotcom/opencode-goal) — [docs/opencode.md](docs/opencode.md) |
| **Pi** | `/goal` or `/skill:goal` | `npm run install:pi` |
| **Command Code** | `/goal` | `npm run install:commandcode` |

Full steps: **[docs/INSTALL.md](docs/INSTALL.md)**

## Quick install

```bash
git clone https://github.com/Niko96-dotcom/goal-agents.git
cd goal-agents
npm install -g cursor-goal
npm run install:all
```

## CLI (any project)

```bash
goal "my objective" --verify "npm test"
goal status
goal checkpoint --tool-calls 2
```

## Test

```bash
npm run test:cli
npm test
GOAL_E2E_SKIP_AGENT=1 npm test
```

## Related repos

- [cursor-goal](https://github.com/Niko96-dotcom/cursor-goal)
- [opencode-goal](https://github.com/Niko96-dotcom/opencode-goal)
