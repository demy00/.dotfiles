---
description: Run the cross-family spec gate, then the human review pass. A spec reaches the implementer only when both approve.
argument-hint: <path to spec.md>
---

Load the `pipeline` skill.

Gate the spec at: **$ARGUMENTS**

## 1. The machine pass

```sh
python3 ~/.claude/skills/pipeline/gate.py $ARGUMENTS
```

It calls a model from a **different family** than the one that wrote the spec, collects findings,
and derives the verdict from the closed set of four blocking reasons. No model decides the verdict.

**The gate fails closed, and you must not work around it.** If it exits non-zero because the key is
missing, the model is unreachable, the response was unparseable, or the family matched - report that
and stop. Do not review the spec yourself instead and call it gated. A gate that silently degrades
still reports approval, which is worse than having none.

Exit codes: `0` approved · `1` blocked, with findings · `2` the gate could not run.

On **blocked**: give the blocking findings to the spec-writer, fix, re-run. Notes are recorded in
the spec's known-open list and do **not** block - do not fix them to get through.

## 2. The human pass

Only after the machine pass approves.

Walk the user through the spec with `grill-me` if it is installed - **one question at a time**,
waiting for each answer. The failure mode this exists to prevent is the plan-reading illusion:
people approve specs they have skimmed, and a spec approved unread makes every downstream gate
theatre.

Ask about:

- each requirement's **binding**, and whether it is right
- the acceptance criteria that would be hardest to check objectively
- the **out-of-scope** list - is anything there that the user assumed was in
- the edge cases section - is it a real list or an empty gesture
- the **unverified** section - what genuinely cannot be tested here

On approval, set `review_status: approved` and `spec_gate: approved` in the frontmatter.

**Both must be approved before the implementer starts.** Report which stage approved, when, and any
notes carried forward.
