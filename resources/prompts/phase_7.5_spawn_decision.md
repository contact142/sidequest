# Phase 7.5 — Spawn Decision (between Phase 7 synthesis and ship)

After Phase 7 synthesizes a plan, examine the discard pile and the
"framework reserved" items. Some of those aren't really finished — they
deserve their own side quest.

## When to spawn a child quest vs DROP vs ship-as-reserved

For every item NOT in the live ship list, decide:

### SPAWN_CHILD if:
- The idea has positive backtest direction but the parent quest couldn't
  test it at sufficient depth (sample size, missing data, scope creep)
- The idea addresses a gap the parent quest didn't fully cover (e.g.
  out-of-regime test, parallel goal, adjacent problem)
- The operator's calibration (Q11 regime / Q12 good-enough bar) flagged
  scope the parent quest didn't reach
- A child quest would have meaningfully different framing (Phase 0)
  because of what we learned in Phase 3 / 6

### DROP if:
- Backtest showed null OR negative direction
- The idea contradicts a Main Quest constraint
- Operator calibration explicitly excluded this scope
- The idea was the same shape as another idea (covered by sibling)

### FRAMEWORK_RESERVED (ship scaffold, no live behavior):
- Architectural value clear, but specific policies need their own
  evidence; defer to a sibling quest later
- Distinct from SPAWN_CHILD because no immediate quest is needed —
  this idea waits until enough evidence accumulates organically

## For each SPAWN_CHILD, declare:

```markdown
### Child quest: <slug>
- **Parent quest**: <this quest's slug>
- **Relationship**: extends | rebuts | stress-tests | parallels
- **Triggering signal**: which Phase 3/6 lesson or operator
  calibration item triggered this spawn
- **Carry-over context**: which Phase 0 / Phase 8 outputs from the
  parent are binding inputs (NOT to be re-litigated)
- **Round-1 EXCLUDED list**: any ideas from the parent that this
  child cannot reuse (preserves the no-reuse rule across the family)
- **Success metric**: what would close this child quest
- **Estimated effort**: rough phase scope (full 8-phase or
  abbreviated)
```

## Quest tree convention

Quests form a tree under a single Main Quest:
- `quest-root-YYYYMMDD` — the original
- `quest-root-YYYYMMDD/child-down-market` — spawned during Phase 7.5
- `quest-root-YYYYMMDD/sibling-multi-model-eval` — spawned later

The mission log root maintains `quest_index.md` listing all related
quests + their statuses (active, complete, stalled, dropped).

## Hard rules

- **Spawn decisions are permanent for this quest's history.** If you
  spawn a child, that's recorded in this quest's PLAN.md and the
  child quest's parent_quest field. Don't retroactively un-spawn.
- **Spawning is not a way to defer hard work indefinitely.** If a
  child quest hasn't started within N days (where N is from Phase -1
  Q3 time-pressure answer; default 7), the operator should be
  notified — either start the child or convert it to DROP.
- **The hardened backtest rules apply to every child.** A child quest
  doesn't get to skip Phase 2/5 rigor because the parent already did
  some work. Each child has its own backtests.
- **Round 2 no-reuse propagates across the family**, not just within
  one quest. A child quest started after a parent's Round 2 cannot
  re-use Round 1 OR Round 2 ideas from the parent in its OWN Round 1
  proposals (only in Round 2 if novel framing, per the same rule).

## Format for Phase 7.5 output

Append to PLAN.md or write to a new `phase_7.5_spawn_decisions.md`:

```markdown
# phase_7.5_spawn_decisions

## Items shipped live (already in PLAN.md v2):
- <list>

## Items spawned to child quests:
### Child: <slug>
[full template above per child]

## Items dropped:
- <reason per item>

## Items framework-reserved (scaffold-only, no child):
- <list with "awaits N additional evidence" condition>
```
