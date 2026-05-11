# Phase 7 Prompt — Final Synthesis

This is the final phase. Pool only what works. Produce one coherent plan.

## Context

**Main Quest:** {{MAIN_QUEST}}
**Aligned outcome:** {{ALIGNED_OUTCOME}}

**All validated ideas (Round 1 + Round 2):**
{{VALIDATED_IDEAS}}

**Discarded ideas (with reasons):**
{{DISCARDED_IDEAS}}

## Your task — five questions, in order

### 1. Triage the validated pool
For each validated idea, mark:
- `KEEP` — definitely in the final plan.
- `DROP` — was validated in isolation but doesn't compose with other keepers.
- `MERGE_INTO` — combine with another idea; describe the merge.

### 2. Composition check
The kept ideas must compose into a single coherent plan. Run this check:
- Do any KEEP ideas conflict with each other? (e.g. one says "tighten L1", another
  says "loosen L1" under the same conditions.)
- Do any KEEP ideas depend on the same scarce resource? (e.g. two ideas both want
  to consume the only normal aggro slot on Casey.)
- Are there gaps the kept ideas don't address?

Resolve conflicts before proceeding. Drop the lower-confidence side, or restructure.

### 3. Final plan
Write the single coherent plan that achieves the Main Quest. Include:
- The kept ideas, in execution order.
- Their integration points (how they compose).
- The success metric (lifted from Phase 1's success criteria, sharpened by what
  the rounds taught us).
- The rollout sequence (shadow first, then live, with kill conditions per step).
- The kill criteria — under what conditions do we revert this entire plan?

### 4. The discard pile (write to DISCARD.md)
For every idea NOT used:
- The idea, in one sentence.
- Why it didn't make the final cut. Be honest:
  - "Failed backtest." (with the metric)
  - "Worked in isolation but conflicted with KEEP idea X."
  - "Validated under conditions Y but not Z; cost of detecting conditions exceeds win."
  - "Worked but produced no marginal lift over a kept idea that achieves the same."

### 5. Side Quest health check
Was this side quest worth running? Honest answer:
- Did the final plan move the Main Quest forward?
- Did Round 2's constraint produce real lift, or was it noise?
- What would you do differently next time?

This last answer feeds into the next side quest's prep.

## Format

Two output files:
- `PLAN.md` — sections 1, 2, 3 of this prompt.
- `DISCARD.md` — section 4.
- The Side Quest health check (section 5) appends to the bottom of `PLAN.md`
  as `## Side Quest postmortem`.

## Hard rules

- The final plan can use ALL kept ideas, ONE of them, or NONE of them. "None"
  is a valid outcome if Round 2 surfaced something genuinely better that
  synthesizes on its own. If "none", the side quest still wasn't a waste —
  the search itself produced the lessons.
- Every KEEP must trace back to a backtested PASS in Phase 2 or Phase 5. No
  new ideas appear in the synthesis that didn't survive a round.
- Every KEEP that has tunable parameters must have those parameters TUNED FROM
  THE BACKTEST DATA. If a KEEP idea reaches synthesis with thresholds picked
  from intuition or round numbers, downgrade it to "framework reserved" and
  do NOT ship live behavior.
- Architectural-but-untested ideas can appear in the plan as "framework
  reserved, awaits backtest" but cannot ship as live behavior changes.
  These get a follow-up backtest task before any live promotion, NOT a
  shadow-soak shortcut.
- Kill criteria are non-negotiable. A plan without "stop if X happens" rules
  is not a plan, it's a hope.
- If the side quest itself produced findings that REFUTE assumptions in the
  Main Quest (e.g. data shows the framing was inverted), the synthesis MUST
  surface this and propose either: (a) revising the Main Quest, or (b)
  acknowledging the gap and explaining how the final plan navigates around
  it. Hidden contradictions between plan and Main Quest are a synthesis
  failure.
