---
name: tdd
description: The implementer's red-green loop - one seam, one failing test, the minimal code to pass, repeat. Use whenever implementing a spec or fixing a bug. Never write the whole suite up front.
---

# tdd - the red-green loop

You author **both the tests and the code**, in a **vertical** loop: one seam → one failing test →
just enough code to pass it → repeat.

Never write the whole suite up front. A suite written before any code is a design document that has
never been executed, and it will be wrong in ways you only discover after committing to it.

Language-agnostic by design. The repo's `AGENTS.md` says how to run tests; its language skill
(`typescript`, `expo`, `vitest`, …) says how to write them idiomatically. This file is the procedure.

## Seams

A **seam** is the public boundary you observe behaviour at, without reaching inside.

In this pipeline the seams are **already agreed in the spec** - each requirement's acceptance
criteria define observable behaviour, and the spec's interfaces name the boundary. You do not
renegotiate them mid-implementation.

**If a boundary is genuinely untestable as written, the spec is wrong.** Stop and route it back.
Do not invent a seam, and do not reach into internals to get a test to pass.

## Read `binding:` before writing any test

| `binding:` | Write |
|---|---|
| `e2e` | **nothing of its own** - add the id to the journey covering that path |
| `integration` | **one test** at the seam, for a failure e2e cannot see: concurrency, fault injection, migration |
| `none` | **nothing** |

One journey covers many `e2e` requirements. Do not fork a journey per requirement - that trade was
made deliberately. A red journey tells you which journey broke rather than which line, and that is
the cost of not having several hundred near-duplicate tests.

**Traceability:** every requirement with `binding: e2e` or `integration` appears in at least one
mapping row, and every test names the ids it covers. A requirement with no row and no
`binding: none` is a coverage gap, and the verifier will route it back.

## The loop

1. **Pick one slice** - the smallest vertical behaviour a requirement calls for. Not a layer, not a
   file. A thing the system can do.
2. **Write one failing test** at the seam. Run it. **Watch it fail.**
   A test you never saw fail is a test you have no evidence tests anything.
3. **Check it failed for the right reason.** A typo'd import also goes red.
4. **Write the minimum code to pass.** Not the design you have in mind - the minimum.
5. **Run it. Watch it pass.**
6. **Refactor** with the test green, if it needs it.
7. **Repeat.**

Commit at green, not mid-slice.

## Three modes, set by the kind of work

- **greenfield** - red → green per slice, at the requirement's seam.
- **migration** - **parity first.** The existing suite is the contract: record its baseline, run it
  against the migrated code, and add characterisation tests only at genuine gaps on critical seams.
- **refactor** - **baseline first, behaviour unchanged.** The migration procedure without a port. An
  intentional behaviour change is not a refactor - it is greenfield work with its own requirement.

## The three anti-patterns the verifier fails you for

These fail **even on a green suite**. They are the reason an independent reviewer exists at all.

1. **Tautological** - asserts the mock was called with what you just passed it, or restates the
   implementation. It passes when the feature is broken.
2. **Implementation-coupled** - asserts on internals, private state, call counts, or the shape of
   something the user never sees. It fails when you rename things and passes when behaviour breaks.
3. **Missing-negative** - only the happy path. No invalid input, no failure mode, no boundary. Most
   production defects live exactly where these tests aren't.

Ask of every test you write: **if I broke this behaviour deliberately, would this test go red?**
If not, it is not a test.

## After verification

The tests **lock**. Later gates may demand *added* tests; nobody weakens an existing one. If a
locked test genuinely encodes wrong behaviour, that is a spec amendment and re-verification - not an
edit.

## Attribution

Adapted from Matt Pocock's skills collection (`skills/engineering/tdd`, MIT), which reached this via
`klm-agentic-pipeline` and then `szobonyaerik/agentic-avengers`. This version drops the
pipeline-specific machinery - subprocess markers, the evidence sidecar, phase bookkeeping - and
keeps the loop, the seams, the bindings and the anti-patterns.
