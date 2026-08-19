# Agentic setup - decisions and execution plan

Sits alongside `agentic-setup-macos.md` (the Kun Chen walkthrough),
`practitioners.md` (who else to take from) and `readme.md` (the target dotfiles
repo spec).

**Read the reasoning, not just the choices.** The choices will look arbitrary in
six months without it. That is the whole reason this file exists.

**Status key:** `firm` = decided, don't relitigate without new information ·
`provisional` = decided on an assumption that still needs verifying ·
`superseded` = replaced, kept because the reasoning is instructive

---

## The axis

Everything below hangs off one question, and getting it wrong is what made the
two source documents incompatible.

**The split is: does anyone else read this code.**

| | `solo` | `shared` |
|---|---|---|
| Repos | `personal-finance`, scratch work | `owndivision`, `-frontend`, `-control-plane` |
| Posture | Kun's full setup: autonomous, gated, eventually parallel | You check the output. Always. |
| Agent may push | yes, through the gate | no |
| Review | `no-mistakes`, fresh reviewer, real PRs | fresh-context reviewer locally, then **you** open the PR |
| Overnight loops (`gnhf`) | yes | no |

The earlier split was `personal` vs `client`, on the theory that the binding
constraint was accountability to a paying customer. That was wrong about
`owndivision`, which is a two-person GitHub org (`owndivision/owndivision`) where
you are a principal and a direct committer - 14 of 20 commits on the frontend are
yours, pushed straight to origin. Erik is a co-committer, not a customer.

The consequences of fixing the axis are large enough to be worth stating
explicitly, because they delete work:

- **No mirror repository.** The private-mirror design solved "access revoked at
  engagement end". That cannot happen in an org you co-own.
- **No written consent per client.** There is no client. There is a conversation
  with Erik about what AI-assisted changes look like when they arrive, which is
  a real dependency but not a legal one.
- **The reason agents don't push to `shared` repos changes.** It is not
  defensibility. It is that a PR is the point where another human starts
  spending attention, and you want to have read the diff before you spend
  someone else's time on it.

If a genuine confidentiality-constrained client ever appears, most of the
`shared` profile needs rethinking rather than tuning. Note it and move.

---

## Ground truth, 2026-08-11

Checked on disk, not remembered. The previous plan drifted from reality within a
day and this section is the antidote.

| Claimed | Actual |
|---|---|
| `~/.dotfiles` private repo | does not exist |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` = `"40"` | still `"50"` |
| post-cull: 13 skills | 14 |
| `personal-finance` skeleton (D8) | **zero commits**, no code, but 8 `.claude/commands/` and 2 skills present (deleted them)|
| `owndivision-frontend` AGENTS.md | still nothing |
| dotfiles repo | exists only as `files/agentic-dotfiles.tar.gz`, inside a directory **untracked** in `stuff` |

Also true and load-bearing: there are **zero `.planning/` directories anywhere on
disk**. That is the same evidence used to convict GSD of never having been used,
and it currently convicts the nine planning/TDD/verify capabilities that survived
the cull.

`practitioners.md` still links to `./setup-guide.md`, which is really
`agentic-setup-macos.md`. Fixed by the rename in Phase 2.

---

## Phase 0 - the cull (DONE 2026-08-05)

Baseline, not work to repeat.

| | Before | After |
|---|---|---|
| Always-on context | ~19,311 tok | **~1,946 tok** |
| Agents | 61 | 13 |
| Skills | 116 | 13 (14 today) |
| Commands | 60 | 8 |
| Auto-loaded rules files | 10 | 1 (`context7.md`) |
| Hooks firing per tool call | 5 | 0 |

Removed all of GSD (33 agents, 67 skills, 9 hooks, statusline). Disabled the
`everything-claude-code` plugin, which duplicated ~180 capabilities already
copied into `~/.claude/`. Dropped every language rule and agent outside Python
and TypeScript.

Backup: `~/.claude/backups/pre-cull-20260805-212954.tar.gz` (1.6M). ECC remains
on disk at `~/.claude/plugins/marketplaces/` (124M), disabled but not deleted.

### What actually caused the pile (answered 2026-08-11)

The old plan called this "the one thing still unanswered" and guessed there had
been some friction driving the installs. There wasn't.

> I read about them and they looked impressive, but my friend tried them out
> before I could fully experiment and his feedback was bad, so I didn't go down
> that path and forgot they existed.

The mechanism was **read about it → impressed → install**, with no problem in
front of it. What stopped it was a peer's bad review, not any judgement of your
own. This is worse than the old plan assumed, and it changes what the plan has to
defend against: not a recurring friction that keeps demanding tools, but a
reflex with no brake.

The reflex fired again during the grilling session that produced this document -
a five-stage pipeline was proposed while `/plan`, `planner`, `architect`,
`tdd-workflow`, `tdd-guide`, `python-testing`, `verification-loop`, `/verify`,
`/code-review`, `code-reviewer` and `e2e-runner` were all installed and none had
ever been run. Third firing, first one observed live.

**D17 exists because of this.** It is the governing decision in this file.

---

## Decisions

Numbering preserved from `DECISIONS.md` so existing references still resolve.

### D1 - Two profiles: `solo` and `shared` · `firm`

A project is bootstrapped as one or the other, on the axis above. No third tier.

**Why:** three sets of rules is one more than gets reliably remembered, and a
middle tier becomes the default that quietly erodes the strict one. Two reduces
the bootstrap question to "does anyone else read this?", which is never answered
wrong.

**Consequence:** scratch projects carry slightly more ceremony than they need.
Accepted.

**Revisit when:** a repo genuinely fits neither - and then add a per-repo
override, not a third global tier.

### D2 - In `shared` repos, agents may commit locally but never push · `firm`

The agent's authority ends at a commit on a local branch, ideally in an isolated
worktree. Push, PR, and every word another human reads are yours.

**Why:** a PR is where a colleague starts spending attention. You want to have
read the diff before you spend theirs. Local commits are reversible, give
bisectable history and something to diff against, and keep the door open for
tools that commit per iteration.

**Consequence:** commit messages and PR descriptions are yours to write. That
friction is the point.

**In `solo` repos this does not apply** - the gate handles it, and there is
nobody downstream to protect.

### D3 - Enforced by deny rules + a pre-push hook · `provisional`

Per-repo permission deny rules in `.claude/settings.local.json`, plus a
`pre-push` hook, installed by the bootstrap step that asks which profile applies.

**Why:** "I instructed it not to push" is a hope, not a control. Deny rules stop
the attempt early and legibly; the hook is tool-agnostic and catches paths the
agent improvised.

Two Claude Code properties this leans on: project settings can be per-repo and
`.claude/settings.local.json` is git-ignored automatically; and permission rules
**merge** across scopes rather than overriding, so a deny defined anywhere stays
in force.

**Provisional because of an unsolved mechanical problem:** you push to
`owndivision` constantly. A `pre-push` hook that hard-fails blocks you too, and
git hooks cannot distinguish an agent-initiated push from yours. Options, none
chosen: fire the hook only inside `treehouse` worktrees; make it interactive so a
human at a TTY can confirm and a headless agent cannot; or accept `--no-verify`
as the human escape hatch and admit the control is a speed bump rather than a
wall. **Decide this before writing the hook, not after.**

**Rejected:** stripping push credentials from agent worktrees. Strongest control,
but the friction lands on every legitimate push. Held in reserve.

**Verify at build time:** exact deny-rule syntax against current Anthropic docs
rather than memory.

### D4 - Evidence is a fixed schema with an explicit "unverified" list · `firm`

Every gated change produces: what changed · what the fresh-context reviewer
found · what was executed end-to-end and observed · what was escalated and how it
was decided · **what remains unverified**.

**Why:** the last field is the one that does work. It tells you exactly what you
still have to check yourself, which is the difference between a gate that
delegates verification and one that only appears to. A record listing only
successes teaches you to trust output nobody checked.

**Rejected:** retaining full session transcripts. Noise around signal.

### D5 - Client gate against a private mirror · `superseded`

Replaced by **Phase 4**: a fresh-context reviewer run locally, no push, no PR, no
mirror.

**Kept because the reasoning is still instructive.** `no-mistakes`' pipeline
order is fixed and not configurable (intent → rebase → review → test → document →
lint → push → pr → ci); there is no local-only mode, and its sibling `firstmate`
has one but drops the independent reviewer, which is backwards. That constraint
is real and still applies to any future attempt to use `no-mistakes` on a repo
where PRs are expensive. What died with the axis correction is the mirror as the
*answer* to it: mirroring a co-owned org's code into a personal repo solves a
problem (access revoked at engagement end) that does not exist here, and creates
one that does.

### D6 - Finance app: Expo / React Native with a first-class web target · `firm`

**Why:** mobile is the worst case for agent-verifiable work - simulators, slow
builds, no equivalent of "open the page and click the button" - and the whole
gate design rests on an agent driving the real app and observing the result.
`react-native-web` gives a Playwright-drivable surface for the same components,
so the agent gets a fast loop while you still ship native.

**Consequence:** camera, OCR, notifications and secure storage genuinely differ
on device. Those go in `AGENTS.md` as an explicit "unverified on web" category,
feeding straight into D4's unverified field. Maestro for device flows.

### D7 - Local-first SQLite, bank sync behind an interface · `firm`

**Why:** your own data on your own device, no auth to build, and agents can seed
a fixture and run offline in milliseconds. Fast feedback is the difference
between agents that work and agents that flail, and the usual case for a backend
(multi-user, multi-device) doesn't apply.

**Known future break:** PSD2 and Revolut OAuth expect a redirect URI and a client
secret, and a client secret can't live in a mobile binary. A thin server will
eventually be needed for token exchange. Design for it now - bank sync behind an
interface with a fake implementation - but don't build it until integrating a
real bank. The fake is also what the agent tests against.

**To verify before building on it:** reading spending *from the phone* is heavily
restricted. iOS offers no API to read other apps' notifications or SMS; Android's
`NotificationListenerService` needs special permission and Play Store policy
limits its use. Bank APIs are the durable route.

### D8 - Build the skeleton first, review it line by line, then switch the gate on · `firm`

Expo app running on web and device, SQLite layer with a seeded fixture, one
Playwright test that opens the app and asserts something real, and the
`AGENTS.md` validation section written against that harness.

**Why:** a reviewer agent with nothing to review against approves almost
anything. Gating an empty repo produces the ceremony of validation with none of
the substance, which is worse than no gate because it feels safe. This is also
the code you are about to delegate your judgement to.

**Amended 2026-08-11:** build it *using the already-installed pipeline*
(`/plan` → `tdd-workflow` → `/verify`) rather than by hand, while still reading
every line yourself. Same skeleton, same line-by-line review, and it doubles as
the evidence run D17 requires. Building it by hand would leave the pipeline
question untested for another week.

### D9 - `gnhf` installed but not designed around · `provisional`

**Why:** every other component works on an interactive subscription. `gnhf`
drives agents headlessly, and non-interactive usage (Agent SDK, `claude -p`, CI,
third-party apps) reportedly draws from a separate monthly credit - $20 on Pro,
$100 on Max 5x, $200 on Max 20x - after which the subscription multiplier stops
protecting you. So a Max upgrade buys a lot of *interactive* headroom and
comparatively little for overnight loops: the thing you'd upgrade for is the
thing least covered.

**Provisional because:** those figures come from secondary write-ups, not
Anthropic; one source notes a related billing change was later paused. **Verify
against `/usage` and Anthropic's own pricing before committing money.**

**Plan:** one bounded experiment with a hard `--max-tokens`, on a `solo` repo
only, promoted to a regular tool only if the real bill matches expectations.

### D10 - Capacity goes to the gate, not throughput · `firm`

Fewer changes, all verified, rather than more changes spot-checked.

**Why:** the binding constraint is confidence in the output, not velocity. A
personal app has no deadline.

**The real risk:** an inconsistently applied gate is corrosive - it teaches you
to trust output that wasn't actually checked. If cost pressure ever makes you
gate selectively, make the rule explicit rather than letting it drift.

### D11 - Parallelism is for isolation, not throughput · `firm`

`treehouse` is in, but expect one or two concurrent agents for months.

**Why:** a single small greenfield codebase doesn't contain 5-10 genuinely
independent tasks; parallel agents would collide. Worktree isolation is still
worth it *sequentially* - clean state per task, no half-finished work in the way.
On `shared` repos it also gives D2 somewhere safe to put the local commits.

**Explicitly not a goal:** inventing work to justify parallel capacity.

### D12 - Full Neovim, WezTerm, tmux base · `firm`

All three from the start; vim is already known, so the usual learning-curve
objection doesn't apply. Neovim's job is deliberately narrow: browse files
(oil), review diffs (neogit), grep unfamiliar code (snacks). No LSP, completion
or formatter - the agent authors, you inspect.

### D13 - Dotfiles as a plain git repo with symlinks · `firm`

`install.sh` with an `ln -sfn` link table. Not Nix, not chezmoi, not Stow.

**Why:** lowest ceremony that still gives history, rollback and one place to
look. Whole mechanism readable in one file; fresh machine in about two minutes.

**Upgrade path when outgrown:** Nix + home-manager, where Kun himself landed.
Worth it for multiple machines, not before.

### D14 - RPI now, Superpowers later · `provisional`

Horthy's Research → Plan → Implement folds into the planning step immediately:
it's a way of working, costs nothing, and the underlying finding (recall degrades
past roughly 40-60% context utilisation) applies from day one.

Superpowers stays deferred. Its hard TDD gates on a greenfield repo with no test
suite would fight you, and they can conflict with `gnhf`'s loop. Revisit once the
D8 harness exists - and then per D17, only against a named failure.

### D15 - Agent vs skill is decided per stage, not uniformly · `firm` (new)

A subagent runs in **its own context window** and reports back a summary. A skill
loads instructions into the session already running. That single difference
decides which stages get which.

- **Fresh context earns its cost at review.** A reviewer that can see the
  reasoning which produced the code will rationalise it. This is the design
  principle underneath `no-mistakes`' external reviewer, Vincent's two-stage
  review, and Phase 4 below. Review stages are **agents**.
- **Authoring wants shared context.** Tests and the implementation they cover are
  one task; writing tests in a window that can't see the design discussion is
  worse, and a subagent round-trip per red-green cycle is slow and expensive for
  something invoked constantly. TDD is a **skill** (`/tdd`).
- Planning is genuinely arguable and currently unassigned. `planner` and
  `architect` are agents, `/plan` is a command. The first real run should settle
  it by observation.

**Why this is written down:** the original instinct was to convert everything to
skills for the slash-command ergonomics, which would have silently removed the
one property the review design depends on.

### D16 - Small batches enforced at plan time, with a readable plan as the backstop · `provisional`

The stated requirement, in your own words: examine the code in small batches, to
avoid accumulating techdebt and to review changes locally before a PR.

**Mechanism:** the planning stage outputs steps each sized to one reviewable
diff, and you review per step rather than per task.

**The known failure mode, and why the backstop exists:** Horthy's team found the
"plan-reading illusion" - humans approve plans they haven't really read - severe
enough that RPI was rebuilt into QRSPI with five alignment stages replacing one.
If the plan isn't genuinely read, decomposition produces the ceremony of small
batches and the reality of large ones.

**Backstop:** render the plan as a clickable artifact you annotate rather than
prose you skim. This **promotes `lavish-axi` out of the deferred list** onto the
critical path, because a stated requirement now depends on it. It is zero-install
(`npx`), so the cost of that promotion is nil.

**Provisional because** the backstop is still one human read, just a better-
rendered one. If oversized batches survive it, move the constraint downstream to
something mechanically checkable - a diff-size limit the agent must stop at.

### D17 - Nothing new gets built until what is installed has been run · `firm` (new, governing)

Before building, installing or adopting any workflow capability: run the
equivalent thing you already own, on one real task, and name what failed.

**Why:** see Phase 0's addendum. The install reflex has no natural brake, has
fired three times, and the only thing that ever stopped it was someone else's
opinion. Every trigger elsewhere in this file is downstream of this one - they
are all forms of "wait for the failure before buying the fix", and they are
worthless if this one isn't honoured.

**Concretely, right now:** `/plan`, `tdd-workflow` and `/verify` are installed
and have never run. The proposed planner → spec → test → implement → verify
pipeline is those three plus a spec step. Run them first. If they work, the
pipeline is finished. If they fail, the failure names what to build, and that
name is the only thing D17 accepts as a reason to build it.

**This also governs `~/.claude` size.** Cap the global set at 5 skills; a sixth
means removing one. A skill's body loads only when invoked, but its name and
`description` sit in the always-on index every turn, roughly 15-50 tokens each -
which is what 125 installed skills actually cost. Optimise the `description`
field, not the body. Anything stack-specific lives in `<repo>/.claude/skills/`
where it only surfaces in that repo.

---

## Do now (minutes, not phases)

1. **Commit `agentic-setup/` into `stuff`.** It is untracked. This file and the
   entire dotfiles skeleton exist only as loose files plus a tarball in an
   uncommitted directory, one `rm -rf` from unrecoverable. That is precisely the
   failure Phase 2 was written to prevent, currently live.
2. **`CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`: `"50"` → `"40"`** in
   `~/.claude/settings.json`. Reasoned through twice, never applied.
3. **Delete `personal-finance/.claude/commands/` and `skills/`.** Eight commands
   and two skills in a repo with zero commits, all pre-cull leftovers. The cull
   only swept `~/.claude`, not project directories.
4. **Decide `MAX_THINKING_TOKENS`.** Removed during the cull, currently
   uncapped. Was it a deliberate cost control?

### Autocompact: why 40

Originally 50, on the reasoning that agent performance degrades past 50-60%
context. `practitioners.md` supplied the underlying data - Horthy's analysis of
~100k developer sessions puts the "Dumb Zone" at 40-60% utilisation, and
practitioners converged on staying under ~40%. 50 sits inside the degradation
band; 40 sits below it.

**Caveat worth holding:** autocompact fires at a percentage of the *context
window*, whereas the Dumb Zone research measured *utilisation during a task*.
Related but not identical, so 40 is a well-motivated default rather than a
measured optimum. Revisit if compaction starts interrupting work.

---

## Phase 1 - the skeleton, built with what's installed

**This is the next action.** Everything else is downstream of what it reveals.

`personal-finance` has zero commits. Build the D8 skeleton - Expo running on web
and device, SQLite with a seeded fixture, one Playwright test that opens the app
and asserts something real - using `/plan` → `tdd-workflow` → `/verify` and
nothing else. Read every line yourself.

Two things happen at once: D8 gets its harness, and D17 gets its evidence run.

**Record as you go**, because this is the candidate list for everything in
Phase 6:

- which stage produced a step too large to review in one sitting (D16)
- where a stage wanted fresh context and didn't have it, or vice versa (D15)
- what the missing "spec" step would actually have caught
- whether `/verify` produced anything resembling D4's schema

**Done when:** the app runs on web, an agent can start it, drive it and observe
the result, `AGENTS.md`'s validation section is written against that harness, and
you have a written list of what the installed pipeline failed to do.

---

## Phase 2 - dotfiles repo

**Trigger:** already felt, twice. The cull was only recoverable because a tarball
was made by hand, and that tarball is currently untracked.

Create `~/.dotfiles` as a **private** GitHub repo. Private resolves the secrets
question outright, but keep the `*.local` discipline anyway so it can be made
public later without an audit.

```
~/.dotfiles/
├── install.sh              symlink bootstrap (idempotent, backs up what it replaces)
├── Brewfile                brew bundle
├── CHANGELOG.md            why things changed, not what
├── wezterm/wezterm.lua  →  ~/.wezterm.lua
├── tmux/tmux.conf       →  ~/.tmux.conf
├── nvim/init.lua        →  ~/.config/nvim/init.lua
├── claude/
│   ├── CLAUDE.md        →  ~/.claude/CLAUDE.md
│   ├── settings.json    →  ~/.claude/settings.json
│   ├── agents/          →  ~/.claude/agents
│   ├── commands/        →  ~/.claude/commands
│   └── skills/          →  ~/.claude/skills
├── git/gitconfig        →  ~/.gitconfig
├── zsh/zshrc            →  ~/.zshrc
├── templates/AGENTS.md     copied (not linked) into project repos
└── docs/
    ├── setup-guide.md      ← agentic-setup-macos.md, renamed
    ├── practitioners.md
    └── plan.md             ← this file
```

Steps:

1. `git init`, private remote, first commit before any symlinking.
2. Move the `agentic-setup/` files in, dropping the `.config` suffixes:
   `wezterm.lua.config` → `wezterm/wezterm.lua`, `tmux.conf.config` →
   `tmux/tmux.conf`, `nvim-init.lua.config` → `nvim/init.lua`,
   `AGENTS.template` → `templates/AGENTS.md`.
3. Fix the broken cross-links: `practitioners.md` points at `./setup-guide.md`
   and `../CHANGELOG.md`; both resolve after step 2.
4. Write `install.sh` with the `LINKS` table. **`ln -sfn`, not `ln -sf`** -
   without `-n`, when the destination is an existing symlink to a directory, `ln`
   follows it and creates the link *inside*, so a second run yields
   `~/.config/nvim/nvim`. Single most common dotfiles bug.
5. `install.sh --check` reports drift and changes nothing. Build this mode first
   and use it to dry-run the other.
6. Real files displaced by a link move once to `~/.dotfiles-backup/<timestamp>/`.
7. `files/agentic-dotfiles.tar.gz` already contains a working skeleton of most of
   this. Extract and compare rather than starting from nothing.

**Decide during execution:** whether `~/.claude/settings.json` is symlinked or
copied. No secrets today, but it is the file most likely to acquire
machine-specific paths - the old GSD hooks hardcoded
`/Users/demy00/.nvm/versions/node/v20.19.4/bin/node`, which would have broken on
any other machine. A `settings.local.json` split may be the better answer.

**Done when:** `git status` in `~/.dotfiles` reports config drift, and
`./install.sh --check` on a clean checkout reports zero differences.

---

## Phase 3 - AGENTS.md across the `shared` repos

**Trigger:** already felt. `owndivision-frontend` has a `.claude/` directory and
no instructions file at all.

`agentic-setup-macos.md` calls the "Validating your work" section the
highest-return hour in the whole setup, because every later layer assumes the
agent can prove a change works end-to-end before you see it. Without it, review
degrades into you reading diffs - the exact bottleneck the stack exists to
remove.

Vincent's `v33.mp4` story is the argument in one anecdote: he asked for an MP4
proving an app worked and got one only after the agent had silently debugged
through 32 failed attempts. Unit tests passing is not evidence.

| Repo | Has | Priority |
|---|---|---|
| `owndivision-frontend` | nothing | **1** - daily work, no instructions at all |
| `owndivision` | `CLAUDE.md` | **2** - needs the validation section |
| `owndivision-control-plane` | `CLAUDE.md` | 3 |
| `grid-bot-platform` | `CLAUDE.md` | 4 |
| `jarvis` | `AGENTS.md` + `CLAUDE.md` | reference - already done |

`personal-finance` is absent from this table because Phase 1 writes its
`AGENTS.md` against the harness it builds.

Per repo: write `AGENTS.md`, `ln -s AGENTS.md CLAUDE.md` so both harnesses read
one file. The validation section must answer concretely: how does an agent start
this app, log in, and drive the thing it just changed?

- **Frontend** - Playwright or a browser-control MCP, plus a seeded dev login.
  The CP/DP local-stack work from 2026-08-04 is the raw material: the auth flow
  that produced `unauthorized` and the CORS failure are exactly what needs
  writing down.
- **Python services** - fixtures and expected output; how to bring the stack up
  (`docker compose`), run migrations (`alembic`), reach a known-good state.

Also take Vincent's coverage line into `~/.claude/CLAUDE.md`:

> the only thing worse than a failing test is a reduction in test coverage

He added it after catching Claude deleting test files - his CLAUDE.md had said a
single failing test equalled project failure, so the agent removed the tests to
remove the risk. Coverage is measurable; "don't fail" is not.

**Done when:** in each repo, an agent given only `AGENTS.md` can start the app,
reach a logged-in state, and produce end-to-end evidence for a trivial change.

---

## Phase 4 - review, split by profile

**Trigger:** felt. Review currently happens in the session that wrote the code,
which is asking it to check its own homework - it assumes everything it did was
intended.

### 4a - `shared` repos: local fresh-context review

No tool, no push, no PR, nothing Erik sees. Dispatch the `code-reviewer` agent
against `git diff main...HEAD`. Per D15 this must stay an **agent**, because the
fresh window is the entire mechanism.

Strictly weaker than a real gate - no worktree isolation, no CI, no PR hygiene -
but it buys the actual design principle with none of the machinery, and it is
what D2 needs to be true before you open the PR yourself.

**Talk to Erik before this changes what lands in the shared repos.** Not a
formality: if AI-assisted PRs start arriving, he should know what review happened
first.

### 4b - `solo` repos: `no-mistakes`

The binary is vetted. The install script was read in full (85 lines: downloads a
release tarball, installs to `~/.no-mistakes/bin`, symlinks into `~/.local/bin`,
already on PATH so no `sudo`). Prerequisites confirmed: `gh` authenticated as
`demy00`, node v20.19.4, tmux/nvim/mosh/rg/fd present.

**Line 80 of the installer starts a persistent background daemon.** Know that
going in.

```sh
cd personal-finance
no-mistakes init
```

Then: `git checkout -b x` → agent works → skim the diff → `git push no-mistakes`
→ `no-mistakes` for the TUI. Only after Phase 1, per D8: a reviewer with nothing
to review against approves almost anything.

**Done when:** one PR has gone through the gate end to end on `personal-finance`,
you have seen at least one ask-user escalation and made the call, and one
`owndivision` change has been reviewed by a fresh-context reviewer before you
looked at it, with zero new PRs on the shared repo.

---

## Phase 5 - Ronacher's layer: make the codebase agent-friendly

**Trigger:** will be felt the moment Phase 7 starts. Five parallel agents against
a slow test suite is five times the waiting.

`practitioners.md` calls this "probably the highest-leverage thing missing" and
it is the layer Kun doesn't touch at all - not the harness, the code itself. It
ranks here only because it is weeks of work against Phase 3's hours, and because
it touches code shared with Erik.

Long-running background track, not a sprint:

1. **Measure first.** Time the full test suite in `owndivision` and
   `owndivision-frontend`. Time a cold `docker compose up` to a usable state.
   Without numbers this phase has no success criterion. **Start this in parallel
   with Phase 3** - it is measurement, not change.
2. **Fast feedback is the whole point.** Target a unit-test loop an agent can run
   in seconds, not minutes.
3. **Ronacher's code guidance:** simple descriptive functions over clever
   classes; plain SQL over deep ORM magic; permission checks locally visible
   rather than resolved through layers of indirection.
4. **Protect tools against an LLM chaos monkey** using them completely wrong.

**Done when:** the test suite time is a number you know, and it has dropped.

---

## Phase 6 - workflow capabilities, from evidence only

**Gated by D17.** The candidate set is the list Phase 1 produced, plus anything
Phase 4 escalations surface. Nothing else.

Method:

1. After each gate escalation or review finding, ask: *would a standing rule have
   prevented this?* That list, and only that list, is the candidate set.
2. Read the corresponding Superpowers skill for the *pattern*, then copy a
   trimmed version in. Vendoring beats installing the framework - you own the
   `description` text, which is the recurring cost.
3. Prefer hard gates over advice. Vincent's finding is that advice gets ignored
   and structure gets followed: *"write tests first"* loses, *"NO PRODUCTION CODE
   WITHOUT A FAILING TEST FIRST. Write code before the test? Delete it. Start
   over."* wins.
4. Cap the global set at 5 (D17). A sixth means removing one.
5. Assign agent vs skill per stage using D15, not by preference.

Two cautions carried forward: Superpowers' hard TDD gates **can fight `gnhf`'s
loop**, so keep them off any repo running unattended; and Vincent's two-stage
review runs *inside* the session against the spec while Kun's gate runs *outside*
with a fresh reviewer. Adopt the gate first so you can tell which one caught
what.

**Done when:** at most 5 global skills exist, each traceable to a specific
failure it prevented, and `~/.claude` always-on context is still under ~2,500
tokens.

---

## Phase 7 - parallelism: treehouse + tmux

**Trigger: not yet felt. Do not start before Phases 1, 4 and 5.**

Currently `acceptEdits` + `skipDangerousModePermissionPrompt` is set globally,
with `curl` and `npx` allowed - Kun's permissive posture, but with **neither** of
the two things that make it safe in his design: worktree isolation and a review
gate. Phase 4 supplies the gate; this phase supplies the isolation. Until both
exist, the permissiveness is running unbacked.

That is the reason to leave the permission settings alone rather than tightening
them: they are coherent with the destination, and tightening now then loosening
later is churn. The gap closes by adding the missing halves.

1. `curl -fsSL https://kunchenguid.github.io/treehouse/install.sh | sh` - read it
   first, as with `no-mistakes`.
2. Loop: `Ctrl-a c` → `treehouse` → start agent → move on.
3. tmux config already carries the load-bearing settings: `allow-rename on` +
   `automatic-rename off` let agent status land in the window name, which is what
   makes concurrent agents legible at a glance.

Per D11, expect one or two concurrent agents for months. The isolation is the
point, not the count.

**Done when:** agents have run concurrently in pooled worktrees without
colliding, and `shared`-repo agents commit inside a worktree rather than on your
working branch.

---

## Deferred, with explicit triggers

Nothing here gets installed before its trigger fires.

| Thing | Trigger |
|---|---|
| **gnhf** | A finished plan too large to babysit, on a `solo` repo. Hard `--max-tokens` on every unattended run until the burn rate is known (D9). |
| **Voice input** (OpenSuperWhisper) | Typing prompts becomes the bottleneck. Cheap, no dependencies, could be pulled forward any time. |
| **Tailscale + mosh** | You actually want to check on agents from your phone. |
| **beads** | Past ~5 concurrent agents. Below that, tmux windows plus `treehouse` is the entire coordination layer. |
| **Nix + home-manager** | A second machine, or `install.sh` stops being enough (D13). |

`lavish-axi` was here and has been **promoted to the critical path** by D16.

---

## Risks

- **Rebuilding the pile.** Highest risk in this file, and now understood: the
  install reflex has no natural brake and has fired three times, most recently
  during the session that wrote this document. D17 is the only control, and it is
  untested. `practitioners.md` names eight practitioners each with a framework;
  adopting all of them reproduces the state Phase 0 just undid.
- **Cognitive debt.** Named in every source document and none has an answer. If
  agents write and review everything, your model of the codebase erodes, and
  architectural judgement is the one thing that can't be delegated. Decide
  deliberately which parts of `owndivision` you keep in your head.
- **Cost.** Bound the first unattended runs.
- **Tooling churn.** `no-mistakes` changed shape between the June video and
  August. Horthy publicly reversed his own most-adopted framework and says he
  doesn't know whether these techniques survive six months. Read each repo's
  README rather than trusting this file.
- **Team friction.** The conversation with Erik is a real dependency, not a
  checkbox.

---

## Open questions

| Question | Settle by |
|---|---|
| Does the installed pipeline work? | Phase 1. Everything else waits on it. |
| How does the pre-push hook distinguish you from an agent? | Decide before writing it (D3) |
| Agent or skill for the planning stage? | Observe during Phase 1 (D15) |
| Real cost of non-interactive `gnhf` usage | `/usage` + Anthropic pricing docs before spending (D9) |
| Revolut / CIB PSD2 API feasibility | Read current API docs before designing sync (D7) |
| Can any spending data be read from the phone? | Prototype against platform restrictions first (D7) |
| Exact Claude Code deny-rule syntax | Verify against docs when writing the bootstrap (D3) |
| Does the gate stay affordable per change? | Measure after ~10 gated changes on `personal-finance` |

---

## Assumptions that would invalidate a lot

Stated plainly so they're falsifiable.

1. **Web E2E is representative enough.** If most bugs turn out to be
   device-specific, D6's fast loop is checking the wrong surface.
2. **The gate stays affordable.** If a gated change costs enough that you start
   skipping it, D10 collapses and the honest move is to redesign rather than
   quietly gate less.
3. **One project generates enough work.** If it doesn't, most of the parallelism
   and orchestration layer is scaffolding around a workflow you don't have yet.
4. **Erik is fine with it.** The `shared` profile assumes the objection is
   "unreviewed AI output", solvable by reviewing. If the objection is to agents
   at all, Phase 4a doesn't address it.

---

## Execution order

```
Do now    commit agentic-setup, autocompact 40, clean personal-finance/.claude   minutes
Phase 1   skeleton via the installed pipeline (D8 + D17 evidence)                 days
Phase 2   dotfiles repo                                                           ~half a day
Phase 3   AGENTS.md across shared repos, frontend first                           hours per repo
Phase 5   measure test-suite times           starts in parallel with Phase 3
Phase 4b  no-mistakes on personal-finance    after Phase 1
Phase 4a  local fresh-context review on owndivision
Phase 6   workflow capabilities              only from Phase 1 and 4 evidence
Phase 5   (continues - codebase work)
Phase 7   treehouse + parallelism            only after 1, 4 and 5 show results
```
