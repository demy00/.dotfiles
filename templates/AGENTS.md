# AGENTS.md

<!--
Copy this to the root of each repo as AGENTS.md (symlink CLAUDE.md -> AGENTS.md
if you also use Claude Code, so both harnesses read one file).

The single highest-leverage section here is "Validating your work". Kun's whole
workflow rests on the agent being able to prove a change works end-to-end
before a human ever looks at it. If the agent can only run unit tests, the
autonomous pipeline degrades into you reading diffs again.

Delete every heading you don't have a real answer for. A vague instruction is
worse than no instruction — it gets pattern-matched into confident nonsense.
-->

## What this project is

<!-- 2-4 sentences. What it does, who uses it, what "good" means here.
     This is the "why" that lets the agent make judgement calls you'd agree with. -->

## Stack and layout

- Language / runtime:
- Framework:
- Package manager:
- Entry point:
- Key directories:
  - `src/…` —
  - `tests/…` —

## Commands

```sh
# install deps
# run dev server
# run tests
# run a single test
# lint
# typecheck
# build
```

## Validating your work  ← the important one

Before reporting a task complete you MUST exercise the real application, not
only the test suite. Unit tests passing is necessary but not sufficient.

**How to run the app end-to-end:**

```sh
# exact command(s) to start the app locally, incl. any env setup
```

**How to drive it:**

<!-- e.g. "Use the Playwright MCP / `npx playwright` to open localhost:3000,
     log in with the seeded dev account (dev@example.com / password in .env.example),
     and interact with the feature."
     For a CLI: "run the binary against fixtures/sample-input.json and diff the output."
     For an API: "curl the endpoint and assert on the response shape." -->

**Evidence to produce:**

- A short description of what you actually did to exercise the change
- Command output, screenshots, or response bodies proving the new behaviour
- Confirmation that the previous behaviour still works (what you regression-checked)

Put this in the PR description under a `## Testing` heading.

## Conventions

- Naming:
- Error handling:
- Logging:
- State management:
- Anything the codebase does that looks wrong but is deliberate:

## Do not

<!-- Hard boundaries. Be specific — "don't touch X without asking" beats "be careful". -->

- Don't modify `…` without asking.
- Don't add a dependency without asking.
- Don't reformat files you weren't asked to change.
- Don't commit anything under `…`.

## Escalate to me, don't decide alone

<!-- Ambiguity that is genuinely product judgement, not engineering judgement.
     This list is what keeps the autonomous loop from drifting somewhere you hate. -->

- Any user-visible copy or UX change not specified in the task
- Schema or API contract changes
- Anything that changes what the product does, vs. how it does it

## Learnings

<!-- Append here when the agent gets something wrong. Rather than fixing the
     mistake yourself, tell the agent to reflect and write the lesson into this
     section. This is the "give feedback instead of taking back control" habit —
     it's what makes the agent better next session instead of you being the
     bottleneck forever. -->
