# Install

## One command (recommended)

Clone **or** update, then install (safe to re-run):

```bash
curl -fsSL https://raw.githubusercontent.com/Niko96-dotcom/goal-agents/master/scripts/bootstrap.sh | bash
```

## Already cloned?

`npm run install` runs `git pull` automatically on current repos.

If you see **Missing script: "install"**, the checkout predates that script — pull once, then install:

```bash
cd goal-agents
git pull origin master
npm run install
```

## What gets installed

| Piece | Result |
|-------|--------|
| CLI | `goal` and `cursor-goal` on your PATH |
| Cursor | `~/.cursor/skills/goal` |
| Pi | `~/.pi/agent/skills/goal` + `pi-goal` extension (`/goal`) |
| Command Code | `~/.agents/skills/goal` |
| OpenCode | Separate — see [opencode.md](./opencode.md) |

## CLI install order (`npm run install:cli`)

1. `npm install -g @nikomohr/goal-cli` ([npm](https://www.npmjs.com/package/@nikomohr/goal-cli))
2. Else `npm install -g cursor-goal` + symlink `goal` → `cursor-goal`
3. Else clone [opencode-goal](https://github.com/Niko96-dotcom/opencode-goal), build, `npm install -g ./packages/goal-cli`

## Do not paste shell comments into npm

Bad (can error with `EINVALIDTAGNAME`):

```bash
npm install -g @nikomohr/goal-cli   # comment here
```

Good:

```bash
npm install -g cursor-goal
```
