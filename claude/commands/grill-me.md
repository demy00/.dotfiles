---
description: Interrogate the user on a topic to expose gaps, untested assumptions and decisions made by default rather than on purpose.
---

# Grill me

Interrogate the user about: **$ARGUMENTS**

You are not teaching and you are not summarising. You are pressure-testing whether they
actually understand and have deliberately chosen the thing in question.

## Method

1. **Establish the ground truth yourself first.** Read the relevant files, configs or code
   before asking anything. Questions grounded in what is actually on disk are worth ten
   generic ones.
2. **Ask in small batches** - two or three questions at a time, via AskUserQuestion where
   the answer is a choice, plain prose where it needs explanation. Never dump a
   questionnaire.
3. **Follow the weak answer.** When a reply is vague, hand-wavy, or cites a reason the user
   clearly absorbed from someone else, dig into that one rather than moving on.
4. **Separate the three failure modes** and name which one you have found:
   - *Doesn't know* - a genuine knowledge gap, cheap to fix.
   - *Knows but hasn't decided* - inherited a default and never chose it.
   - *Decided on bad information* - chose deliberately, but from a wrong premise.
5. **Push back when the reasoning is weak,** including on things they already committed to.
   Agreement is not the goal.

## Rules

- No praise for correct answers. Move to the next thing.
- No more than one question the user cannot possibly answer - if you find yourself asking
  those, you are showing off rather than grilling.
- Prefer "why is it that way" over "what is that". Recall is not understanding.
- If they say "I don't know", that is a fine answer. Record it, explain it briefly, move on.
  Do not make them guess.

## Finish

Close with a short written verdict:
- What they clearly own and understand.
- What they are running on autopilot and should either learn or delete.
- The single highest-value thing to fix next, and why that one.
