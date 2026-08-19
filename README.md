# agentic-dotfiles

My agentic engineering setup, version-controlled. Terminal, editor, agent
instructions, and the tooling that lets several coding agents work in parallel
without stepping on each other.

Based on [Kun Chen's workflow](https://blog.bytebytego.com/p/an-ex-meta-l8s-agentic-engineering),
with additions from other practitioners — see [`docs/practitioners.md`](docs/practitioners.md).

## Install

```sh
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles
./install.sh --brew          # symlink everything + install Homebrew packages
```

Then the things Homebrew doesn't carry:

```sh
npm i -g @anthropic-ai/claude-code gnhf
curl -fsSL https://raw.githubusercontent.com/kunchenguid/no-mistakes/main/docs/install.sh | sh
curl -fsSL https://kunchenguid.github.io/treehouse/install.sh | sh
gh auth login
```

Machine-local bits that must **not** be committed:

```sh
printf '[user]\n\tname = Your Name\n\temail = you@example.com\n' > ~/.gitconfig.local
touch ~/.zshrc.local
```

Full walkthrough with explanations: [`docs/setup-guide.md`](docs/setup-guide.md).

## What's here

```
├── install.sh              symlink bootstrap (idempotent, backs up what it replaces)
├── Brewfile                everything installable via `brew bundle`
├── wezterm/wezterm.lua  →  ~/.wezterm.lua
├── tmux/tmux.conf       →  ~/.tmux.conf
├── nvim/                →  ~/.config/nvim
├── claude/
│   ├── CLAUDE.md        →  ~/.claude/CLAUDE.md      global agent instructions
│   ├── settings.json    →  ~/.claude/settings.json  (machine-specific in settings.local.json)
│   ├── agents/          →  ~/.claude/agents         subagents, one file each
│   ├── commands/        →  ~/.claude/commands       slash commands
│   └── skills/          →  ~/.claude/skills         reusable agent skills
├── git/gitconfig        →  ~/.gitconfig             (identity in ~/.gitconfig.local)
├── zsh/zshrc            →  ~/.zshrc                 (overrides in ~/.zshrc.local)
├── templates/AGENTS.md     copy into each project repo
└── docs/
    ├── plan.md             every choice, why, and what would make it wrong
    ├── setup-guide.md      how to build the whole thing, and why
    └── practitioners.md    who else is worth reading, with links
```

### The stack these configs serve

| Tool | Job |
|---|---|
| WezTerm | one frameless window; draws text, nothing else |
| tmux | sessions, windows, panes — one window per task |
| Neovim | browse files (oil), review diffs (neogit), grep (snacks) |
| Claude Code / OpenCode | the agents |
| [lavish-axi](https://github.com/kunchenguid/lavish-axi) | plans as clickable HTML instead of prose |
| [gnhf](https://github.com/kunchenguid/gnhf) | overnight loop; fresh context per iteration |
| [no-mistakes](https://github.com/kunchenguid/no-mistakes) | review gate — `git push no-mistakes` |
| [treehouse](https://github.com/kunchenguid/treehouse) | pooled worktrees, one per parallel agent |
| Tailscale + mosh | attach to the same tmux session from a phone |

## How the symlinking works

`install.sh` reads a `LINKS` table — repo path on the left, home path on the
right — and creates each link with `ln -sfn`. The table is the source of truth
for what this repo controls; add a line when you add a config.

**Why `-n` matters.** With `ln -sf`, if the destination is an existing symlink
*to a directory*, `ln` follows it and creates the new link **inside** that
directory. Run the installer twice and you get `~/.config/nvim/nvim`. The `-n`
flag makes `ln` treat the existing symlink as a file and replace it, which is
what you actually meant. This is the single most common dotfiles bug.

The script is safe to re-run. Real files in the way get moved once to
`~/.dotfiles-backup/<timestamp>/` before being replaced; links already pointing
here are left alone.

```sh
./install.sh --check    # report drift, change nothing
```

Since everything is a symlink, editing `~/.tmux.conf` edits the file in this
repo. `git status` here tells you what you've changed since the last commit —
which is the whole point.

## Adding something new

1. Move the real file into the repo: `mv ~/.foorc foo/foorc`
2. Add `"foo/foorc:$HOME/.foorc"` to `LINKS` in `install.sh`
3. `./install.sh`
4. Commit

## Conventions

- **Never commit secrets.** Identity, tokens and machine-specific paths go in
  `*.local` files, which `.gitignore` excludes. Assume this repo will be public
  one day even if it isn't today.
- **Note why, not just what.** When you change a config because an agent did
  something dumb, write the reason in the commit message. Six months from now
  the reason is the only part you'll want.
- **One change per commit.** You will eventually need to bisect which config
  change broke your workflow.

## Why a git repo and not something heavier

Plain repo + symlinks is the lowest-ceremony thing that gives you history,
rollback, and a single place to look. It works on a fresh machine in about two
minutes and you can read the entire mechanism in one file.

If you outgrow it, the upgrade path is **Nix + home-manager** — declarative,
genuinely reproducible, and what Kun himself moved to
([his write-up](https://blog.kunchenguid.com/p/how-i-built-a-reproducible-mac-setup)).
It's a real learning curve and worth it only if you're managing several machines
or you're tired of "works on mine". Middle options if you want more structure
without Nix: [chezmoi](https://www.chezmoi.io) (templating, secrets, multi-machine)
or GNU Stow (symlinking only, less code than `install.sh`).

Start here. Move when the pain is real.
