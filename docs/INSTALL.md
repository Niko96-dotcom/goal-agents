# Install

## Already cloned? Update first

If `goal-agents` already exists and `npm run install` says **Missing script: "install"**, the folder is an old checkout:

```bash
cd goal-agents
git pull origin master
npm run install
```

If that fails, replace the folder:

```bash
cd ~
mv goal-agents goal-agents.old
git clone https://github.com/Niko96-dotcom/goal-agents.git
cd goal-agents
npm run install
```

## One command (recommended)

```bash
git clone https://github.com/Niko96-dotcom/goal-agents.git
cd goal-agents
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
