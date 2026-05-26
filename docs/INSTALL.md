# Install

## 1. Clone this repo

```bash
git clone https://github.com/Niko96-dotcom/goal-agents.git
cd goal-agents
```

## 2. Install the goal CLI

**Recommended** (published on npm):

```bash
npm install -g cursor-goal
```

This installs both `cursor-goal` and `goal` on your PATH.

**Alternative** — build from [opencode-goal](https://github.com/Niko96-dotcom/opencode-goal):

```bash
git clone https://github.com/Niko96-dotcom/opencode-goal.git
cd opencode-goal
npm install && npm run build
npm link -C packages/goal-cli
```

Or use the helper script from this repo:

```bash
bash scripts/install-cli.sh
```

## 3. Install agent skills / extensions

```bash
npm run install:all
```

Per agent:

| Agent | Command |
|-------|---------|
| Cursor | `npm run install:cursor` |
| Pi | `npm run install:pi` |
| Command Code | `npm run install:commandcode` |
| OpenCode | See [opencode.md](./opencode.md) |

## Troubleshooting

### `EINVALIDTAGNAME` / package `"#"`

Do **not** paste comment lines into `npm install`. Run only:

```bash
npm install -g cursor-goal
```

Not `npm install -g @nikomohr/goal-cli` (not published) and not lines containing `#`.

### `goal: command not found`

Install the CLI (step 2) or ensure `$(npm prefix -g)/bin` is on your PATH.
