---
id: R<phase>.<spec>
title: <one line, what this delivers>
work_kind: greenfield | migration | refactor
spec_gate: pending | approved
review_status: pending | approved
---

# <title>

## Goal

One paragraph. What is true after this ships that is not true now. Written so someone who has not
read the plan understands why this exists.

## Out of scope

What a reader might reasonably assume is included and is not. This section prevents more rework than
the goal does.

## Requirements

Each gets a stable id and a binding. **Cap: 12. Over twelve, split into sibling specs.**

`binding:` decides what gets tested - `e2e` (covered by a journey, no test of its own),
`integration` (one test at the seam, for a failure e2e cannot see), `none` (nothing writes a test).

### R<phase>.<spec>.1 - <short name>
- **binding:** e2e | integration | none
- **Behaviour:** what the system does, observably. Not how.
- **Acceptance:** how you know it is true. Must be checkable by someone who did not write it.

### R<phase>.<spec>.2 - <short name>
- **binding:**
- **Behaviour:**
- **Acceptance:**

## Seams

The public boundary each requirement is observed at. This is what the implementer writes tests
against, and agreeing it here is why they do not renegotiate it later.

| Requirement | Seam |
|---|---|
| R…1 | |

## Edge cases

The ones that are handled, and how. An unhandled critical edge case is one of the four things that
blocks at the gate - so an empty section here is a claim, not an omission.

## Known-open notes

Filled by the gate. Notes never block; the implementer reads them once before starting.

## Unverified

What this spec cannot prove by automated test, and why - device-only behaviour, external services,
anything needing a human. **Silence is not "none".** Write `none` explicitly if there is nothing.
