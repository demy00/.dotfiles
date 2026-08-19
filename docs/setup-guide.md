# Agentic engineering setup — macOS

Implementation of the workflow from Kun Chen's *L8 Principal's Agentic Engineering Workflow*
(video: youtu.be/iQyg-KypKAA; written version: blog.bytebytego.com/p/an-ex-meta-l8s-agentic-engineering).

**Scope:** the complete setup — WezTerm, tmux and Neovim as the terminal base, plus the
full agent, planning, validation and parallelism stack.

**One thing to know before you start:** `no-mistakes` has changed since the video was
recorded. The video shows `no-mistakes -y` as a command you run after the agent finishes.
The current design is a **git push gate**: you `git push no-mistakes` and the pipeline runs
on the pushed branch, then you open a TUI to act on findings. This guide uses the current
form. If you follow the video literally at that step, it won't match.

A second caution: several of these tools install via `curl … | sh`. Read the script first
if that matters to you — the URLs are given below so you can `curl` them to a file and look.

---

## Order of work

The layers build on each other, but the payoff is not evenly distributed. Layer 1 is
ergonomics — real, but it compounds slowly and mostly through muscle memory. Layer 4a
(no-mistakes) is where the actual quality leverage is. If you find yourself running out of
appetite partway through, get 1a, 2 and 4a working and come back for the rest; a beautiful
terminal with no review gate is the wrong half to have finished.

| Layer | What | Rough time |
|---|---|---|
| 0 | Prereqs | 15 min |
| 1a | tmux | 30 min + a week of muscle memory |
| 1b | WezTerm | 10 min |
| 1c | Neovim | 30 min + ongoing |
| 2 | Agent harness, AGENTS.md, voice | 1 hr |
| 3 | Lavish (planning), gnhf (long runs) | 45 min |
| 4 | no-mistakes, treehouse, remote access | 1–2 hrs |

---

## Layer 0 — Prereqs

```sh
# Homebrew, if you don't have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install tmux neovim git node gh mosh ripgrep fd
brew install --cask wezterm
brew install --cask font-jetbrains-mono-nerd-font
gh auth login          # required by no-mistakes for opening PRs and watching CI
node --version         # must be >= 20 for gnhf and the npx tools
```

You also want a repo to practise on. Don't do this on something you care about for the
first run — the gate opens real PRs.

---

## Layer 1a — tmux

Copy the provided `tmux.conf` to `~/.tmux.conf`, then:

```sh
tmux new -s main
# inside tmux: Ctrl-a r   to reload after any edit
```

### Why this config and not the default

Three settings in it are doing the real work; the rest is comfort.

**`allow-rename on` + `automatic-rename off`.** Claude Code and Codex broadcast their
status (working / done / waiting for you) as a terminal title escape sequence. These two
settings let that land in the tmux window name instead of being overwritten with "node".
This is the single detail that makes running 5–10 agents survivable: you glance at the
status bar and see who needs you. Without it you're switching tabs to check on people.

**`monitor-activity on`.** Windows with new output get highlighted. An agent that just
finished lights up.

**`escape-time 0`.** The 500ms default makes ESC feel broken in any vim-mode editor. You'll
want this when you add Neovim later, and it costs nothing now.

### The motions to drill

Learn these five before adding anything else. Everything downstream assumes you can do them
without thinking.

| Keys | Does |
|---|---|
| `Ctrl-a c` | new window (= one task) |
| `Ctrl-a 1`…`9` | jump to window N |
| `Ctrl-a Space` | back to previous window |
| `Ctrl-a \|` / `Ctrl-a -` | split pane vertical / horizontal |
| `Ctrl-a d` | detach (session keeps running) |

`tmux attach -t main` gets you back in. That detach/attach property is what Layer 4c turns
into phone access — nothing extra required on the tmux side.

**Convention that pays off later:** one tmux *window* per task, not per project. The window
title becomes the agent's status line.

---

## Layer 1b — WezTerm

Copy the provided `wezterm.lua` to `~/.wezterm.lua`. It reloads automatically on save.

Run as a **single frameless window** — no tabs, no title bar, no status line. That looks
austere for a reason: tmux already owns sessions, tabs, panes and status, and having two
systems that both manage tabs is how you end up with agents hidden in a WezTerm tab you
forgot about. WezTerm's only job here is to draw text quickly and correctly.

Three details in the config worth knowing:

- **`default_prog` launches straight into `tmux new-session -A -s main`.** Opening the
  terminal puts you back in your workspace with every agent still running. Comment it out
  if you'd rather land in a plain shell.
- **WezTerm's own `Cmd-T` / `Cmd-W` / `Cmd-D` are explicitly disabled** so they can't
  shadow tmux.
- **`term = "wezterm"`** pairs with the `terminal-overrides` line in `tmux.conf` for
  truecolor.

Why WezTerm over Ghostty, Kitty or iTerm2: it's fast, deeply configurable in Lua, and
behaves identically on macOS, Linux and Windows — which matters if you're ever forced onto
another machine. Nothing else in this document depends on it, so if you already have a
terminal you like, keep it and just make sure truecolor and a Nerd Font work.

---

## Layer 1c — Neovim

Copy the provided `nvim-init.lua` to `~/.config/nvim/init.lua`, then launch `nvim`. It
bootstraps lazy.nvim and installs everything on first run — give it a minute.

```sh
mkdir -p ~/.config/nvim
cp nvim-init.lua ~/.config/nvim/init.lua
nvim
```

### The obvious question: why an editor at all, if agents write the code?

Because you still need to *look* at things — examine the file system, review a diff, make a
one-line fix rather than spending a round-trip explaining it. This config is built for
exactly those three jobs and nothing else. **There's no LSP, no completion, no formatter,
no debugger.** That's deliberate: the agent handles authoring, so the usual IDE apparatus is
weight you'd carry without using. Add it back if you find yourself genuinely missing it.

### The three plugins from the video

**oil.nvim** — a directory becomes an editable buffer. Renaming a file is editing a line;
deleting is `dd`; creating is typing a new name. `-` opens the parent directory of whatever
file you're in, which becomes the motion you use constantly when orienting yourself in code
you didn't write.

**neogit** (+ diffview) — the review surface. `<leader>gg` for status, and `<leader>gm` for
the one that matters: the whole branch diffed against main. This is the five-second sanity
check before the gate, where you're not reading for correctness — the reviewer agent does
that — but checking the agent didn't wander off in a completely wrong direction. That's
usually obvious at a glance.

**snacks.nvim** — the picker. `<leader>ff` files, `<leader>fg` grep, `<leader>fs` changed
files. Grep is the one you'll lean on hardest, because you're constantly answering "where
does this thing the agent mentioned actually live?"

I've added three things beyond the video: gitsigns (inline hunk markers — `]h` / `[h` to
walk changes), treesitter (syntax highlighting; bare Neovim looks rough without it), and
which-key (press `<leader>` and wait to see bindings). That last one matters more than it
sounds: you'll be in the agent pane far more than in the editor, so the keymaps won't stay
in your fingers the way they would if you lived here.

### Learning curve, honestly

If you've never used vim, this is the steepest part of the whole document and the one with
the slowest payoff. It's also the most optional — none of Layers 2–4 depend on it. A
reasonable path: run `vimtutor` once (30 min), then use this config only for reviewing
diffs at first, and let editing come later. If after a fortnight it still feels like
friction rather than fluency, drop it and open diffs in whatever editor you already know.
The workflow doesn't care.

---

## Layer 2 — Agent harness, AGENTS.md, voice

### 2a. Harness

The video uses Claude Code for Anthropic models and OpenCode for everything else, and is
deliberate about *not* using vendor-specific conveniences like auto-managed memory — so
that switching models costs nothing. Worth honouring: every tool below is agent-agnostic,
and that's not an accident.

```sh
npm install -g @anthropic-ai/claude-code
# and/or
brew install opencode        # or: npm i -g opencode-ai
```

### 2b. AGENTS.md — do not skip this

Use the provided `AGENTS.template.md`. Copy it into a repo as `AGENTS.md` and fill it in.
If you use Claude Code too: `ln -s AGENTS.md CLAUDE.md`.

The section that matters is **"Validating your work"**. The entire autonomous loop rests on
the agent proving a change works end-to-end before you see it. The failure mode the video
calls out explicitly: every unit test passes and the product is still broken. If your
AGENTS.md can't tell the agent how to actually drive the app, everything in Layer 4 degrades
back into you reading diffs.

Concretely, for a web app that means giving the agent a way to open the running app and
click things (Playwright, or a browser-control MCP), plus a seeded dev login. For a CLI,
fixtures and expected output. Budget real time on this per repo — it's the highest-return
hour in the whole setup.

### 2c. Prompting habits

Three failure modes, worth internalising because no tool fixes them:

1. **Asking for an action, not an outcome.** "Rename this variable" finishes in four seconds
   and hands control back to you — you're still the bottleneck. "Audit this module's naming
   against <convention doc> and fix it" runs for twenty minutes and leaves the convention
   in the session context.
2. **Not explaining why.** Without the rationale the agent can't propose something better
   than what you asked for, and can't generalise the rule next time.
3. **Taking back control.** When the agent gets something wrong, the instinct is to fix it
   yourself. That's the same trap as a tech lead who rewrites the junior's PR. Instead:
   have the agent reflect and append the lesson to the `## Learnings` section of AGENTS.md.

Plan quality determines how long an agent can run unattended. A one-line prompt buys you
minutes of autonomy; a real plan buys hours. That's the whole economic argument for Layer 3.

### 2d. Voice input

```sh
# OpenSuperWhisper — free, runs Whisper turbo v3 large locally
# https://github.com/starmel/OpenSuperWhisper
```

Download from the repo's releases, bind a hotkey, done. Also fine: macOS built-in dictation
(worse), or Wispr Flow / Superwhisper (paid, better UX).

You talk 3–4× faster than you type, and prompts are the one input you now produce all day.
This is a smaller change than it sounds like technically and a bigger one than it sounds
like in practice.

---

## Layer 3 — Planning and long-running work

### 3a. Lavish — interactive HTML plans

No install needed.

```
# in your agent session, instead of "write a plan in a markdown file":
draft a technical plan for <feature> using npx lavish-axi
```

The agent renders the plan as an interactive HTML page and opens it in your browser, styled
to match your project. You then **click elements on the page and annotate them directly** —
"make this a floating overlay above the + button" — rather than writing a paragraph
describing which element you meant.

Why bother, when you could just talk to the agent: an interactive session pulls you back in
every few minutes and the actual plan ends up scattered across a wall of terminal text
that's painful to give targeted feedback on. Concentrating the ambiguity into one planning
artifact up front is what lets you hand off and walk away — which is the prerequisite for
running things in parallel at all.

Repo: github.com/kunchenguid/lavish-axi

### 3b. gnhf — overnight orchestrator

```sh
npm install -g gnhf
```

Run from inside a git repo with a **clean working tree**:

```sh
gnhf "fully implement the plan in docs/plan.md"

# bounded — do this for your first few runs
gnhf "reduce complexity without changing functionality" \
     --max-iterations 10 \
     --max-tokens 5000000

# parallel, isolated worktrees
gnhf --worktree "implement feature X" &
gnhf --worktree "add tests for module Y" &
```

Mechanics: it breaks the objective into steps, each running in a **fresh context window**
seeded with a common base plus `notes.md` learnings from prior iterations. Each successful
iteration is its own commit; failures `git reset --hard` and the next attempt takes the
failure into account. Three consecutive failures aborts. You wake up to a `gnhf/<slug>`
branch of clean commits and a notes file.

Useful flags: `--agent claude|codex|opencode|copilot|pi|rovodev`, `--stop-when "<natural
language condition>"`, `--current-branch --push` for a branch you're watching live.
Config lives at `~/.gnhf/config.yml`. Telemetry off with `GNHF_TELEMETRY=0`.

**Set `--max-tokens` on every unattended run** until you have a feel for the burn rate.

Three situations it's actually for:
- implementing a large finished plan
- moving a measurable metric ("increase test coverage", "cut startup latency") — anything
  where each iteration can be scored
- offline experiment sweeps where you have an evaluator

Repo: github.com/kunchenguid/gnhf

---

## Layer 4 — Validation, parallelism, remote

### 4a. no-mistakes — the review gate  ← highest value in this document

```sh
curl -fsSL https://raw.githubusercontent.com/kunchenguid/no-mistakes/main/docs/install.sh | sh
cd your-repo
no-mistakes init
```

`init` sets up a `no-mistakes` git remote pointing at a local gate repo, and installs a
`/no-mistakes` skill so your agent can drive the gate itself. Then:

```sh
git checkout -b my-branch
# ...agent does the work...
git push no-mistakes            # pipeline starts
no-mistakes                     # opens the TUI for the active run
```

The pipeline runs in a **disposable worktree** (your working copy stays put): review →
test → docs → lint → push → open PR → watch CI and auto-fix failures. In the TUI, findings
come in two flavours — auto-fix ones are applied for you, and ask-user ones are judgement
calls you approve, fix or skip.

Three design choices in it are worth understanding, because they're the reasons it works
and you'd want to replicate them even if you used a different tool:

1. **The reviewer runs in a fresh context window.** Reviewing in the session that wrote the
   code is asking someone to check their own homework — it assumes everything it did was
   intended.
2. **Ambiguous, product-changing decisions escalate to you.** Auto-fixing every finding
   lets the agent drift somewhere you never wanted.
3. **End-to-end evidence is forced.** This is where your AGENTS.md validation section gets
   cashed in.

The claim from the author's own stats: 68% of AI-generated PRs had a problem that would
otherwise have landed. Treat that as his number on his codebase, not a guarantee — but the
direction is right, and it's the reason this layer beats the planning layer for priority.

Before pushing, still eyeball the diff yourself — `<leader>gm` in Neovim, or
`git diff main...HEAD --stat` then skim. Agents occasionally go in a completely wrong
direction and it's obvious in five seconds.

Docs: kunchenguid.github.io/no-mistakes · Repo: github.com/kunchenguid/no-mistakes

### 4b. treehouse — worktree pool

```sh
curl -fsSL https://kunchenguid.github.io/treehouse/install.sh | sh
```

```sh
cd myproject
treehouse        # drops you into a ready worktree subshell
# ...work...
exit             # worktree returns to the pool
```

Parallel agents in one directory step on each other. Plain `git worktree` solves that but
adds its own overhead — where to put them, which are free, whether deps are installed,
whether `.env` is there. treehouse maintains a **pool**: it reuses an idle worktree with
dependencies and build cache already warm, detects in-use ones, and syncs to the latest
default branch before handing it over. Worktrees use detached HEAD, so no branch-name
collisions.

`treehouse prune` cleans up merged idle ones. `treehouse get --lease` reserves one as a
persistent home.

**The parallel loop:** `Ctrl-a c` for a new tmux window → `treehouse` → start the agent →
move on. Five to ten at once is the stated working range; agent status in the tab titles
(Layer 1) is what makes that legible.

Repo: github.com/kunchenguid/treehouse

### 4c. Remote control

```sh
brew install --cask tailscale     # then sign in on Mac and phone
# System Settings → General → Sharing → Remote Login: ON
brew install mosh
```

On your phone: an SSH client (Termius, Blink on iOS; Termux on Android), connect over the
Tailscale IP, then `tmux attach -t main`. Same windows, same agents, same half-typed
command.

Use `mosh` rather than plain `ssh` from mobile — it's built for terminal state over flaky
connections, which is exactly what cellular is.

Why not Claude Code's or Codex's own remote feature: they're per-vendor and agent-only. You
want a real terminal so you can also run `treehouse`, `gnhf` and the gate, and you want one
workflow across every harness.

---

## The daily loop, assembled

1. Describe the task by voice.
2. If it's complex — `npx lavish-axi` plan, iterate in the browser until the ambiguity is
   gone. If it's a big chunk of work, hand the finished plan to `gnhf`.
3. `Ctrl-a c` → `treehouse` → next task, in parallel.
4. Agent finishes → skim the diff → `git push no-mistakes` → act on escalations in the TUI
   → clean PR with a Testing section.
5. Away from the desk → SSH in from the phone, attach to tmux.

---

## Honest caveats

- **This is one person's setup, tuned to solo work on his own repos.** Kun says so himself.
  On a team with mandatory human review, the no-mistakes gate becomes a pre-review filter,
  not a replacement for review — and the PR volume it enables can make you the person
  flooding everyone else's queue.
- **Cognitive debt is a real objection** and was raised in the article's own comments
  without a satisfying answer. If agents write and review everything, your mental model of
  the codebase erodes, and architectural judgement is exactly what you can't delegate. Worth
  deciding deliberately which parts of your codebase you keep in your head.
- **Cost.** 5–10 parallel agents plus overnight gnhf runs is a real bill. Bound your first
  runs.
- **Tooling churn.** The video is from June 2026 and `no-mistakes` already changed shape.
  Check each repo's README rather than trusting any guide, including this one.
- **Don't install all of it at once.** Each tool removes one specific friction. If you
  haven't personally felt the friction yet, you won't use the tool and it'll rot.
