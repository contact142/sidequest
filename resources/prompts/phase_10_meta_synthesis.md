# Phase 10 — Meta-Synthesis (across multiple related side quests)

Activated when a quest tree (parent + children + siblings) has multiple
completed quests sharing the same Main Quest. The goal is to combine
their PLANs, DISCARD piles, and lessons into a single coherent strategy
that none of them could have produced alone.

## When to run Phase 10

- A parent quest spawned ≥ 2 child quests in Phase 7.5, and at least 2
  of them have completed.
- Sibling quests addressed the same Main Quest from independent angles
  and have all completed.
- Operator is preparing to ship the combined work (post all child
  shadow soaks).

Skip Phase 10 if there's only one quest. It's pointless overhead.

## Inputs

For each quest in the family:
- `MAIN_QUEST.md` (should be identical or near-identical across the
  family — divergent Main Quests imply the family was misorganized)
- `phase_-1_calibration.md` (operator answers; surface conflicts)
- `PLAN.md v2` (the quest's final plan after backtest redo if any)
- `DISCARD.md` (rejected ideas + reasons)
- `phase_8_backtest_redo.md` (if hardened backtests ran)

Optional but recommended: a Graphify pass over the whole quest archive
to find emergent patterns (`/graphify` on the side_quests/ tree).

## Pre-flight checks

- **Main Quest consistency**: confirm the family's quests share a
  compatible Main Quest. If they diverge, decide which Main Quest
  wins or split into two families.
- **Operator calibration consistency**: walk Q1-Q12 across each
  quest's calibration. If the operator changed answers between
  quests (e.g. risk posture moved from "adversarial" to "happy-path"),
  flag explicitly — the meta-synthesis must respect the LATEST
  calibration but acknowledge what was tuned under the prior one.
- **No-reuse propagation check**: for any Round-2 idea kept in any
  quest, confirm no sibling quest's Round-1 ideas reused it. If reuse
  happened, downgrade the duplicate.

## The synthesis pass

### Step 1: Pool ALL validated ideas across the family

Build a master table:

| Idea | Source quest | Phase | Verdict | Defaults | Caveats |
|---|---|---|---|---|---|

Include ALL verdicts from all quests, not just KEEPs.

### Step 2: De-duplicate

Some quests may have arrived at the same idea via different framings.
Merge entries; record which quest's defaults / backtest is more
recent / more rigorous; use those.

### Step 3: Detect cross-quest contradictions

Look for idea-level contradictions:
- Quest A's KEEP requires X; Quest B's KEEP requires not-X.
- Quest A tuned threshold to T1; Quest B tuned to T2.
- Quest A's framing assumes regime R1; Quest B's framing assumes R2.

Surface ALL contradictions. Resolve by:
- Newer / more rigorous backtest wins.
- If equal rigor, defer to operator with explicit choice prompt.
- If structurally incompatible, drop the lower-confidence one.

### Step 4: Detect emergent patterns

Now look for patterns NO single quest surfaced:
- Did multiple quests arrive at "regime detection is missing" without
  any one quest making it Layer 1?
- Did multiple quests' DISCARD piles share the same underlying reason
  ("untestable with current data")?
- Did the hardened backtest rules expose the same data quality issue
  in multiple quests?

These patterns are the meta-synthesis's distinctive contribution. A
single quest can't see them.

### Step 5: Produce the family PLAN.md

Combine: KEEP layers from all quests (minus contradictions),
framework_reserved items waiting on shared evidence, the emergent
patterns from step 4 framed as cross-cutting concerns, the
unified kill criteria, the unified rollout sequence.

Format:
```markdown
# FAMILY PLAN — <main quest slug>

## Quest family
- <list of quests with their PLANs linked>

## Combined live ship list
[layers across all quests, integrated]

## Cross-cutting concerns surfaced by Phase 10
- <emergent pattern>: source quests, why, how the family addresses it

## Unified kill criteria
[broader than any single quest's kill criteria]

## Unified rollout
[sequenced across the family]

## Family DISCARD
[ideas dropped across the family with cross-quest reasons]
```

### Step 6: Family postmortem

For each child / sibling:
- Worth running? Yes / no / depends.
- What did this child surface that the parent couldn't?
- What did this child do that was redundant?

This feeds the next family's Phase -1 calibration.

## Hard rules

- **Phase 10 cannot create new ideas.** Every line in the family PLAN
  must trace to a quest's Phase 7 KEEP or to a Phase 10 emergent
  pattern (which itself traces to multiple quests' findings).
- **Phase 10 inherits all Phase 8/9 hardness.** Defaults must come
  from the underlying backtests; no introducing intuition-tuned values.
- **The family PLAN is permanent.** If the operator wants to revise,
  that's a new quest spawned from this family.
- **If Phase 10 finds the family's work doesn't actually compose**
  (too many contradictions, no emergent pattern, work was siloed),
  the honest output is "the family's quests were independently useful
  but don't form a single plan." That's a valid Phase 10 result.
