# Phase 5 Prompt — Round 2 Decomposition + Backtest

Same shape as Phase 2, applied to your Round 2 plan, with one additional rule.

## ADDITIONAL HARD RULE

**No duplicate thoughts within Round 2 either.** Once one model states an
idea or mechanism in their Round 2 atomization, the other model cannot
mirror it. This forces divergent exploration even within the round.

If you find your atomization landing on the same step the other model
proposed, REWRITE that step. Use a different mechanism, a different
metaphor, a different implementation.

## Context

**Main Quest:** {{MAIN_QUEST}}
**Your Round 2 plan:** {{ROUND_2_PLAN}}
**Other model's Round 2 atomization (so you don't duplicate):** {{OTHER_MODEL_STEPS}}
**Available data sources:** {{DATA_SOURCES}}

## Your task — four passes (same rigor as Phase 2)

### Pass 1: Atomize
Split your Round 2 plan into atomic steps. Cross-check against the other
model's steps. Any duplicate steps → rewrite with a divergent mechanism.

### Pass 2: Per-step brainstorm
Same as Phase 2: assumptions, failure modes, evidence required,
alternatives.

If your step uses a metaphor, explicitly translate it:
"The metaphor X means the code does Y."
Metaphors are allowed; metaphor-shaped vagueness is not.

### Pass 3: Backtest design (BEFORE running anything)

For each step where a backtest is possible, design the test up front
under the same six rules as Phase 2:
- **Replay shape**: replay each historical instance step-by-step, NOT
  summary stats over existing labels.
- **Trigger signal**: specific, time-stamped, identifiable in the data.
- **Outcome signal**: specific, TEMPORALLY POSTERIOR to the trigger.
- **Tautology guard**: trigger and outcome are NOT the same metric from
  the same source. State the separation explicitly.
- **Coverage**: full population or justified representative subset.
- **Sample-size + smallest detectable effect**: computed at design time.
- **Default tuning protocol**: every threshold/weight/window in the plan
  derived from data, with sweep + tuning curve.

### Pass 4: Run the backtest + record results

Same as Phase 2: execute the test, record numbers + tuning curves +
interpretation. Stop and fix data quality issues before declaring a
verdict.

## Format

Same as Phase 2 format. Each step gets:
```
### Step N: <name>
**Atomic action:** <verb + observable outcome>
**Metaphor (if any) → code translation:** ...
**Assumptions:** ...
**Failure modes:** ...
**Evidence required:** ...
**Alternatives:** ...

**Backtest design:**
  - Replay shape: ...
  - Trigger signal: ...
  - Outcome signal (temporally posterior): ...
  - Tautology guard: trigger ≠ outcome because ...
  - Coverage: N=X over <population>
  - Smallest detectable effect at this N: ...
  - Default tuning protocol: ...

**Backtest result:**
  - Test executed: ...
  - Result: <numerical, with CIs or sensitivity>
  - Tuning curve: ...
  - Interpretation: ...

**Verdict:** PASS | FAIL | INSUFFICIENT_DATA | NOT_FEASIBLE
**Cross-model check:** confirmed not a duplicate of <other model step ID>.
```

## Hard rules carried from Phase 2

- A step CANNOT be marked PASS without all of: a real replay-based
  backtest, a tautology-clean trigger/outcome separation, full coverage
  of relevant data (or a justified representative subset), data-tuned
  defaults, and a positive result on the chosen objective.
- Failed backtests stay in the log.
- Step dependencies preserved.
- Data quality issues mid-run are fixed, not caveated.
