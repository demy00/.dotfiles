---
name: pipeline
description: The plan-build-verify feature pipeline - spec, quality gate, test-first build, cross-family verification, then the tests lock. Use when building any non-trivial feature, or when asked to write a spec, run a gate, or verify a phase.
---

# pipeline - plan, build, verify

A feature moves through five stages. Each one produces an artifact the next one reads, and two of
them can send it backwards.

```
analyse -> plan -> [ spec -> GATE -> build ]* -> VERIFY -> lock
```

The two capitalised stages are the whole point. Everything else is scaffolding around them.

## Language independence

**This skill contains no language, framework or tool names, and must not acquire any.**

Every stage that needs to run something asks the repo, not this file. Each repo's `AGENTS.md`
declares its own values:

```markdown
## Pipeline
- language skill: <name of the skill holding this stack's idioms>
- test:     <command that runs the unit suite>
- coverage: <command that reports coverage, and where thresholds are enforced>
- e2e:      <command, plus how to bring the stack up first>
- lint:     <command>
- source:   <root>
- tests:    <where they live and how they are named>
```

If a repo has no such block, **stop and write one** before running a stage that needs it. Guessing
the test command is how a pipeline reports success on a suite it never ran.

Deeper knowledge - idioms, mocking rules, the runner's traps - lives in that repo's language skill
(`typescript`, `expo`, `vitest`, …), loaded by name from the `language skill:` line.

## Stage 1-2: analyse and plan

Agents, because each wants a clean window: `task-analyst` establishes scope, `solution-architect`
writes the approach, `implementation-planner` orders it into phases. A phase is a slice that can be
verified on its own.

## Stage 3: the spec

One spec per unit of work, from `spec.template.md` in this directory.

Every requirement gets a stable id (`R<phase>.<spec>.<n>`) and a **binding**, which decides what
gets tested:

| `binding:` | The implementer writes |
|---|---|
| `e2e` | **no test of its own** - covered by the journey it is grouped into, with other `e2e` ids on that path |
| `integration` | **one test** at the seam, driving a failure an e2e cannot see |
| `none` | **nothing** - a type checker, CI or nothing at all enforces it |

The binding is settled at the gate and is **not the implementer's to reopen.** Writing a test the
binding does not call for is the same defect as skipping one it does.

**Requirement cap: 12.** Over twelve, the spec **splits** into siblings. It is never rejected for
size - a rejection for being too big is one more thing for a spec to grow around.

## Stage 4: the gate

The quality wall. **One machine pass, then one human.**

Exactly **four things block**:

1. a missing requirement
2. a contradiction
3. an untestable acceptance criterion
4. an unhandled critical edge case

**Everything else is a note.** Notes never block; they go in the spec's known-open list and the
implementer reads them once. This closed set is what stops review becoming an infinite improvement
loop - if a finding is not one of those four, the spec is approved *and* the finding is recorded.

The machine pass runs on a **different model family** from whoever wrote the spec. That
decorrelation is the mechanism, not a detail: a model reviewing its own family's output shares its
blind spots. See `gate.py` in this directory.

**The gate fails closed.** No key, unreachable model, unparseable verdict, or a same-family model
all stop the run. A gate that degrades silently is worse than no gate, because it still reports
approval.

Then the human pass: `/spec-review` reads it with `grill-me`, one question at a time, and sets
`review_status: approved`.

A spec reaches the implementer only when **both** are approved. That wall is also what pre-agrees
the seams the tests will be written at.

## Stage 5: build

Test-first, one vertical slice at a time - see the `tdd` skill. The implementer writes **both** the
tests and the code, which is why stage 6 exists.

## Stage 6: verify, then lock

The `verifier` agent, in a **fresh context** and on a **different model family** from the
implementer. It does three things:

1. runs the suite and checks coverage against each requirement's binding
2. **reviews the tests themselves** - tautological, implementation-coupled, or missing-negative
   tests fail *even when green*
3. returns a verdict with findings

This is the only outside judgement the suite gets. It routes back for a code defect, a gamed test,
or a coverage gap, and it is capped at **3 attempts** before the finding must be carried, waived or
escalated.

**On pass, the tests lock.** After that nobody weakens them: a later gate may demand *added* tests,
never weakened ones. Weakening a locked test requires re-verification.

## Break-glass

`GATE_BYPASS="<reason>"` is the only override. It is never silent - it is logged, shown, and
recorded against the phase. A reason is prose and it is required.

## The rules that are easy to skip and shouldn't be

- **Silence is not "none".** A phase that carries nothing forward says so explicitly.
- **The only thing worse than a failing test is a reduction in coverage.** Never delete or weaken a
  test to make a suite green.
- **A green unit suite is not evidence a feature works.** Evidence means the thing was driven and
  the outcome observed. What could not be driven gets listed as unverified, by name.
- **Report what was not checked.** A record listing only successes teaches you to trust output
  nobody verified.

## Attribution

The stage shape, the closed blocking set, the binding table, the requirement cap and
locked-after-verify are adapted from `szobonyaerik/agentic-avengers` (MIT). This version is
deliberately smaller: no mutation gate, no codemap, no metrics, no ship gate, and no hooks - each of
those returns only when something fails without it.
