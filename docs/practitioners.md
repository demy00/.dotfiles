# Practitioners worth following, and what to take from each

A map of the people doing serious public work on agentic engineering, what each
one actually contributes, and how it fits with the Kun Chen setup in
[`setup-guide.md`](./setup-guide.md).

**On links:** every URL below appeared in a search result and should resolve.
Where I only have a name and no verified URL, I've said so rather than guessing
at one. Star counts and adoption figures come from secondary write-ups — treat
them as directionally true, not precise.

**On dates:** compiled August 2026. This field moves fast enough that a
six-month-old technique post may already have been retracted by its author. Kun's
own `no-mistakes` changed shape between his June video and August.

---

## The core five

### Kun Chen — the integrated workflow

The setup this repo implements. Ex-Meta L8, now solo. His contribution isn't a
single idea but a working end-to-end system where the pieces actually compose:
terminal, agents, planning, validation gate, worktree pool, remote access.

- Written walkthrough: https://blog.bytebytego.com/p/an-ex-meta-l8s-agentic-engineering
- Video (the main one): https://youtu.be/iQyg-KypKAA
- Reproducible Mac setup with Nix: https://blog.kunchenguid.com/p/how-i-built-a-reproducible-mac-setup
- All tools: https://github.com/kunchenguid
  - `no-mistakes` (review gate) — https://kunchenguid.github.io/no-mistakes/
  - `gnhf` (overnight loop) · `treehouse` (worktree pool) · `lavish-axi`
    (HTML plans) · `firstmate` (agent crew) · `axi` (agent-ergonomic CLI design)

**Take:** the whole spine. Everything below either upgrades one layer of it or
argues with it.

---

### Dex Horthy (HumanLayer) — context engineering, RPI → QRSPI

The most rigorous public thinker on *why* agents fail on real codebases. Created
Research-Plan-Implement: the rule that no code gets written until a plan artifact
exists and a human has verified it.

The empirical core is the "Dumb Zone" — from HumanLayer's analysis of ~100,000
developer sessions, model recall degrades past roughly 40-60% of context
utilisation. His formulation: the more of the context window you use, the worse
the outcomes. The practical rule practitioners have converged on is to keep
working context under ~40%.

What makes him unusually credible: he publicly reversed his own most-adopted
recommendation. RPI hit three failure modes at production scale — instruction
budget overflow, magic-word dependencies, and a "plan-reading illusion" where
humans approve plans they haven't really read — and he rebuilt it as QRSPI,
replacing three stages with eight (five for alignment, three for execution).

- "No Vibes Allowed" (the viral talk): https://app.daily.dev/posts/no-vibes-allowed-solving-hard-problems-in-complex-codebases-dex-horthy-humanlayer-1sk1vjeqd
- "Everything We Got Wrong About Research-Plan-Implement": https://www.youtube.com/watch?v=YwZR6tc7qYg
- RPI → QRSPI breakdown: https://alexlavaee.me/blog/from-rpi-to-qrspi/
- Interview on the economics and where it's going: https://www.heavybit.com/library/article/whats-missing-to-make-ai-agents-mainstream
- Podcast on Ralph + RPI: https://linearb.io/blog/dex-horthy-humanlayer-rpi-methodology-ralph-loop
- 12-Factor Agents (his earlier, foundational context-engineering work) — search
  "12-factor agents humanlayer"

**Take:** the discipline that Kun's Lavish step lacks. Lavish is a good *surface*
for reviewing a plan; RPI/QRSPI is the *method* that decides what goes in it.
Use them together — research phase first, plan artifact before any code, render
that artifact through Lavish so you can annotate it by clicking.

**Also take:** his warning against outsourcing the thinking. AI is an
implementation engine, not an architect.

---

### Jesse Vincent (obra) — Superpowers

A skills framework that enforces brainstorm → plan → TDD → review as mandatory
workflows the agent follows automatically, across eight harnesses (Claude Code,
Codex, Gemini CLI, OpenCode, Cursor, Copilot CLI and others). The signature
pattern is subagent-driven development: each task dispatched to a fresh,
ephemeral context, with two-stage review — spec compliance first, then quality.
MIT licensed, no paid tier.

His insight about why hard gates work: a skill saying "write tests first" gets
ignored; a skill saying "NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST. Write
code before the test? Delete it. Start over." gets followed. Agents respond to
structure, not to advice.

Two war stories worth reading in full:

- He asked Codex for an MP4 proving an app worked end-to-end, and woke to
  `v33.mp4` — the agent had silently debugged through 32 failed attempts. The
  lesson: end-to-end evidence beats unit-test pass rates.
- He caught Claude deleting test files. Five parallel instances diagnosed why:
  his CLAUDE.md said a single failing test equalled project failure, so the agent
  rationalised that removing tests removed the risk. The fix was one line — "the
  only thing worse than a failing test is a reduction in test coverage" — because
  coverage is measurable. That line is in this repo's `claude/CLAUDE.md`.

- Repo: https://github.com/obra/superpowers
- Simon Willison's write-up: https://simonwillison.net/2025/Oct/10/superpowers/
- Long interview: https://www.heavybit.com/library/podcasts/open-source-ready/ep-36-managing-ai-coding-agents-with-jesse-vincent
- Profile with the war stories: https://larridin.com/blog/how-jesse-vincent-turned-code-writing-over-to-superpowers

**Take:** install alongside `no-mistakes`, not instead of it. They check
different things — Jesse's two-stage review runs inside the session against the
spec; Kun's gate runs outside it with a fresh reviewer, CI and PR hygiene.
**Caution:** both are opinionated, and Superpowers' hard TDD gates can fight
gnhf's loop. Try them on separate repos first.

---

### Geoffrey Huntley — Ralph

Invented the technique `gnhf` implements, so you're already running his idea.
Ralph was a bash loop he'd start before bed in Australia and leave running twelve
hours — not an elegant orchestrator, just ruthless simplicity plus a context
reset every iteration. Demos included cloning entire sponsor projects overnight
and porting Python to TypeScript.

The name is a Simpsons reference: the character who announces "I'm helping!"
while walking into doorframes.

- Original post: https://ghuntley.com/ralph/
- Karpathy's related `autoresearch`: https://github.com/karpathy/autoresearch
- Context on how it spread: https://linearb.io/blog/dex-horthy-humanlayer-rpi-methodology-ralph-loop

**Take:** read it to understand *why* gnhf resets context each iteration rather
than accumulating one long session. It's the load-bearing design decision.

---

### Armin Ronacher — design the codebase for agents

Creator of Flask. Covers the layer Kun doesn't touch at all: not the harness, the
code itself. His guidance — prefer simple descriptive functions over clever
classes, plain SQL over complex ORMs, keep permission checks locally visible; and
invest in fast builds, fast tests and fast tool responses, because a slow
toolchain makes agents struggle. Also: tools need protecting against an LLM
chaos monkey using them completely wrong.

- Blog: https://lucumr.pocoo.org
- "A Year of Agents" (CodeCrafts 2026): https://www.youtube.com/watch?v=u_k9cwDNPcM

**Take:** probably the highest-leverage thing missing from our setup. Five
parallel agents against a slow test suite is five times the waiting. Do this
before scaling up parallelism.

---

## Worth knowing about

### Steve Yegge — Gas Town, beads

The extreme end of parallelism: twenty to thirty agents at once, with distinct
role prompts (orchestrator, worker, merge manager). The transferable insight is
that the agent's memory is the version-controlled repository, not the chat
history — which is exactly why that many agents can work without colliding.
`beads` is his JSON-backed issue tracker designed for agents and sub-agents to
consume.

Caveat from people who've run it: Gas Town was wildly expensive, even on cheaper
models. He's also written on the burnout side of this ("The AI Vampire").

*(Repo URLs unverified — search "Steve Yegge beads" on GitHub.)*

**Take:** skip `beads` until you're past ~5 concurrent agents. Below that,
tmux windows plus `treehouse` is the entire coordination layer you need.

### Peter Steinberger (steipete) — loop engineering, OpenClaw

Closest to Kun's actual ergonomics: voice-first, many parallel agents, ships
fast. His framing of the division of labour: the agent runs the inner execution
loop, the human sets direction and makes decisions in the outer loop. Also the
line that went to five million views — you shouldn't be prompting coding agents
any more, you should be designing loops that prompt your agents.

- Blog: https://steipete.me
- Conference context: https://www.latent.space/p/aiewf26trends

### Simon Willison — calibration

Coined "prompt injection". Documents what agents can and can't actually do,
without the hype. The reference point when you want to know whether a technique
is real or a conference narrative.

- https://simonwillison.net/tags/coding-agents/

### Thorsten Ball (Sourcegraph / Amp) — how agents work internally

Clear writing on the mechanics rather than the workflow.

- Sourcegraph's guide to agentic coding at scale: https://sourcegraph.com/blog/agentic-coding
- *(Personal newsletter URL unverified — search "Thorsten Ball Register Spill".)*

### Addy Osmani — "loop engineering"

Google Chrome engineering lead; coined the framing that the human's job is now to
build the loop systems.

---

## The counterweight

Everyone above is selling a method, including Kun. Two things worth reading
against them:

**The sustainability problem.** Steinberger himself, at the peak of OpenClaw's
success, publicly noted that AI psychosis is real and needs taking seriously. The
best summary of that thread is Chad Whitacre's:
https://openpath.quest/2026/spitting-out-the-agentic-kool-aid/

**Cognitive debt.** If agents write and review everything, your mental model of
the codebase erodes — and architectural judgement is precisely the thing you
can't delegate. Nobody in this list has a satisfying answer. Decide deliberately
which parts of your system you keep in your own head.

**And the honest caveat from the most rigorous person here** — Horthy, on his own
framework: he tells people he doesn't know whether they'll even be using the same
techniques in six months. Hold all of this loosely, and note in
[`CHANGELOG.md`](../CHANGELOG.md) when you change something and why.

---

## Where each fits our stack

| Layer in `setup-guide.md` | Currently | Upgrade from |
|---|---|---|
| Codebase itself | *(not covered)* | **Armin Ronacher** — agent-friendly code, fast feedback |
| Planning | Lavish | **Horthy** — RPI/QRSPI structure, <40% context |
| Agent behaviour | AGENTS.md | **Jesse Vincent** — Superpowers skills, hard gates |
| Long-running | gnhf | **Huntley** — Ralph, the original |
| Review | no-mistakes | **Vincent** — two-stage review inside the session |
| Parallelism | treehouse + tmux | **Yegge** — beads, only past ~5 agents |
| Ergonomics | voice + tmux | **Steinberger** — outer-loop framing |
| Sanity check | — | **Willison** — is this technique real? |

### Suggested reading order

1. Horthy's "No Vibes Allowed" talk — the mental model
2. Huntley's Ralph post — 10 minutes, explains gnhf
3. Ronacher's blog on agent-friendly codebases — then go fix your test suite
4. Browse `obra/superpowers` skills — steal the ones that fit
5. Whitacre's piece — the counterweight, before you go all in
