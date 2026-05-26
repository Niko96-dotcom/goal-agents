# goal-agents

One install for **`/goal`** on Cursor, OpenCode, Pi, and Command Code.

## Install everything

**Works on a fresh machine or an old folder** (clone, pull, then install):

```bash
curl -fsSL https://raw.githubusercontent.com/Niko96-dotcom/goal-agents/master/scripts/bootstrap.sh | bash
```

Installs to **`~/goal-agents`** (override with `GOAL_AGENTS_DIR=/path`).

Or manually:

```bash
git clone https://github.com/Niko96-dotcom/goal-agents.git goal-agents 2>/dev/null \
  || git -C goal-agents pull origin master
cd goal-agents
npm run install
```

`npm run install` **pulls latest `goal-agents` first**, then installs CLI + skills.

That runs:

1. **git pull** (when this folder is a clone)
2. **`install:cli`** — `goal` + `cursor-goal` from npm (with fallbacks)
3. **`install:all`** — skills/extensions for Cursor, Pi, Command Code

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
