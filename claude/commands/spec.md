---
description: Write a pipeline spec for one unit of work, against the template and the rubric the gate will apply.
argument-hint: <what the spec should cover>
---

Load the `pipeline` skill, and the language skill named in this repo's `AGENTS.md`.

Write a spec for: **$ARGUMENTS**

Use `spec.template.md` from the `pipeline` skill directory. Fill every section - an empty section is
a claim that there is nothing to say, and the gate reads it that way.

Before writing, read the plan phase this belongs to and the code the spec touches. A spec written
without reading the code invents seams that do not exist.

## What the gate will block on

Write against these four, because they are the only things that can send this back:

1. **a missing requirement** - behaviour the goal implies that no requirement covers
2. **a contradiction** - two statements that cannot both hold
3. **an untestable criterion** - acceptance nobody could check objectively
4. **an unhandled critical edge case**

Everything else the gate finds becomes a note and does not block. So do not pad the spec defensively
against style opinions - write it to be *correct and checkable*, not to be unobjectionable.

## The two things most often got wrong

**Bindings.** Every requirement declares `e2e`, `integration` or `none`, and this decides what the
implementer tests. Set it deliberately: `e2e` means it is covered by a journey and gets no test of
its own; `integration` means one test at the seam for a failure e2e cannot see; `none` means nothing
writes a test. It is settled here and the implementer does not reopen it.

**Acceptance criteria.** "Works correctly" is untestable and will block. Write what an observer
would see: a value, a state, a rendered result, an error.

## Size

**Cap is 12 requirements.** Over twelve, split into sibling specs rather than compressing - splitting
is the designed outcome, not a failure.

When done, report the requirement count, the binding split, and anything you were unsure about
- then stop. The gate runs next, via `/spec-gate`.
