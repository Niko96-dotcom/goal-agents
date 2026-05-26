# goal-agents

One install for **`/goal`** on Cursor, OpenCode, Pi, and Command Code.

## Install everything

```bash
git clone https://github.com/Niko96-dotcom/goal-agents.git
cd goal-agents
npm run install
```

That runs:

1. **`install:cli`** — installs `goal` + `cursor-goal` (tries npm, then builds from GitHub)
2. **`install:all`** — installs skills/extensions for Cursor, Pi, Command Code

OpenCode plugin: [opencode-goal](https://github.com/Niko96-dotcom/opencode-goal) — [docs/opencode.md](docs/opencode.md)

## CLI only

```bash
npm run install:cli
```

Or manually:

```bash
npm install -g @nikomohr/goal-cli
```

Legacy alias package (also works):

```bash
npm install -g cursor-goal
```

## Per agent

| Agent | Command after install |
|-------|------------------------|
| Cursor | `/goal` |
| OpenCode | `/goal` (plugin) |
| Pi | `/goal` or `/skill:goal` |
| Command Code | `/goal` |

## Usage

```bash
goal "my objective" --verify "npm test"
goal status
goal checkpoint --tool-calls 2
```

Details: [docs/INSTALL.md](docs/INSTALL.md)

## Related repos

- [opencode-goal](https://github.com/Niko96-dotcom/opencode-goal) — goal-core, goal-cli, OpenCode plugin
- [cursor-goal](https://github.com/Niko96-dotcom/cursor-goal) — Cursor-focused CLI (also on npm)
