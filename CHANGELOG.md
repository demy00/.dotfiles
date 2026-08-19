# Changelog

Why the setup changed, not just what changed. Tooling in this space turns over
every few months - future-you needs the reasoning, not the diff.

Newest first. `docs/plan.md` holds the standing decisions; this file holds the
moments they changed.

## 2026-08-19

### Added
- This repo. `demy00/.dotfiles`, private, cloned to `~/.dotfiles`, ten symlinks
  live. The trigger had fired twice already: the Phase 0 cull was only
  recoverable because a tarball had been made by hand, and that tarball was
  itself sitting untracked.
- `~/.zshrc.local` and `~/.gitconfig.local`, untracked, holding everything
  machine-specific. **A fresh machine needs both written by hand before
  `install.sh` produces a working shell.** That cost is not yet in the setup
  guide.
- `MAX_THINKING_TOKENS=24000`.

### Changed
- `install.sh --check` now reports `SAME` / `DIFFERS` / `MISSING` / `RELINK`
  instead of a single `WRONG` - because "identical to the repo" and "real content
  that would be destroyed" need opposite reactions, and collapsing them made the
  dry-run unable to clear the real run.
- `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` 50 → 40. Worth recording *why this was
  believed to be a decision*: 50 was an `everything-claude-code` default that got
  copied in and rationalised afterwards with the Dumb Zone research. 40 is the
  first time the number has actually been chosen.
- Global Claude skills 14 → **0**. All fourteen were ECC-derived pattern
  documents and not one had ever been invoked. Cap is 5.
- Dropped the "never manually modify CHANGELOG.md" clause from
  `claude/CLAUDE.md`. It was written for auto-generated changelogs in code
  projects and was silently forbidding maintenance of *this* file, which is
  hand-kept by design. The auto-generated half of the rule stays.
- `wezterm.lua` keeps `default_prog` commented: plain shell, tmux on demand.

### Notes
- **Order matters and the plan had it backwards.** Writing the repo first and
  linking it second would have replaced a live 5,659-byte `zshrc` (oh-my-zsh,
  nvm, conda, gcloud, Android SDK, Rancher) with a 1,077-byte skeleton, taking
  nvm's node v20.19.4 with it - the version `no-mistakes` needs. Capture the
  machine into the repo first; refactor in a later commit.
- **`conda init` and Rancher Desktop rewrite their own blocks in `~/.zshrc`.**
  With that path symlinked into this repo, they would be editing tracked files
  unprompted. That, not privacy, is the hard reason for the `*.local` split, and
  it will apply to `claude/settings.json` the moment anything writes to it.
- `Brewfile` is **unrun**. It would install Tailscale, which `docs/plan.md`
  defers until its trigger fires.

## 2026-08-07

### Added
- `docs/DECISIONS.md`, 14 decisions from a structured grilling session.
  **Superseded 2026-08-11** and merged into `docs/plan.md`, which preserves the
  decision numbering so existing references still resolve.

### Changed
- Client-work gate design: `no-mistakes` cannot run without its push/PR steps
  (pipeline order is fixed), so client work runs it against a **private mirror
  repo** instead of the client's. Agents never push to client repos.
  **Superseded** - see D5. The mirror solved "access revoked at engagement end",
  which cannot happen in a co-owned org, and the axis it rested on (personal vs
  client) was the wrong split. Replaced by a local fresh-context reviewer.
- `gnhf` demoted from planned tool to installed-but-unverified: non-interactive
  usage appears to bill separately from subscription capacity. Needs checking.
  **Still unverified.**

## Earlier

Initial setup: WezTerm, tmux, Neovim, Claude Code. Global `claude/CLAUDE.md`.

`gnhf`, `no-mistakes`, `treehouse` and Tailscale + mosh were listed here as
installed. They are not - they sit behind explicit triggers in `docs/plan.md`,
and the Brewfile still carries Tailscale as though the decision had been made.

<!--
Template for future entries:

## YYYY-MM-DD
### Changed
- <what> - because <what went wrong or what you learned>
-->
