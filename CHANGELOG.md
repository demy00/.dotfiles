# Changelog

Why the setup changed, not just what changed. Tooling in this space turns over
every few months — future-you needs the reasoning, not the diff.

## Unreleased

### Added
- Initial setup: WezTerm, tmux, Neovim, Claude Code, gnhf, no-mistakes,
  treehouse, Tailscale + mosh.
- Global `claude/CLAUDE.md` with the test-coverage rule borrowed from Jesse
  Vincent's failure case.

### Notes
- `no-mistakes` changed from a post-hoc `no-mistakes -y` command (as shown in
  Kun's June 2026 video) to a `git push no-mistakes` gate. Docs here follow the
  current form.

<!--
Template for future entries:

## YYYY-MM-DD
### Changed
- <what> — because <what went wrong or what you learned>
-->

## 2026-08-07
### Added
- `docs/DECISIONS.md` — 14 decisions from a structured grilling session.

### Changed
- Client-work gate design: `no-mistakes` cannot run without its push/PR steps
  (pipeline order is fixed), so client work runs it against a **private mirror
  repo** instead of the client's. Agents never push to client repos.
- `gnhf` demoted from planned tool to installed-but-unverified: non-interactive
  usage appears to bill separately from subscription capacity. Needs checking.
