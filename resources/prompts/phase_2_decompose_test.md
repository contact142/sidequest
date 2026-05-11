# Phase 2 Prompt — Decomposition + Segment Brainstorm + Backtest

You have a Phase 1 plan. Now decompose and test it.

## Context

**Main Quest:** {{MAIN_QUEST}}
**Your Phase 1 plan:**
{{PLAN}}

**Available data sources:** {{DATA_SOURCES}}

## Your task — four passes

### Pass 1: Atomize

Re-list each step of your plan as the smallest atomic action it can be. If a
step contains "and" or compound verbs, split it. Number them.

### Pass 2: Per-step brainstorm

For each atomic step, answer:
- **Assumptions**: what must be true for this step to work?
- **Failure modes**: how does this step fail in practice?
- **Evidence required**: what data would prove this step works as intended?
- **Alternative implementations**: what's a different way to accomplish this step?

### Pass 3: Backtest design (BEFORE running anything)

For each step where a backtest is possible, design the test up front:

- **Replay shape**: how does this test simulate the plan against historical
  data? Be specific. "Replay each historical instance step-by-step (or
  event-by-event) and compare counterfactual outcome under the plan to the
  actual outcome." NOT "compute summary stats on existing labels."
- **Trigger signal**: what specific signal does the plan use to fire?
  Where does it come from in the data? At what point in time relative to
  each historical instance does that signal exist?
- **Outcome signal**: what specific signal labels whether the plan was
  correct? Where does it come from? Confirm it is TEMPORALLY POSTERIOR to
  the trigger.
- **Tautology guard**: state explicitly that the trigger signal and the
  outcome signal are NOT the same metric from the same source. If they are,
  redesign — change the trigger, change the outcome window, or both.
- **Coverage**: how many historical instances will the test cover? Is that
  the full population, or a convenient subset? If subset, justify why the
  subset is representative.
- **Sample size + smallest detectable effect**: compute available N and
  the smallest effect size the test can detect at standard power. If the
  design can't separate signals at available N, REDESIGN before running.
- **Default tuning protocol**: list every threshold, weight, window, or
  tunable in the plan. State explicitly how each will be derived from
  the backtest results — what objective is maximized on what data, what
  range of values is swept, and what evidence justifies the chosen value.
  No defaults are allowed to be picked from intuition or round numbers.

### Pass 4: Run the backtest + record results

Execute the test you designed. Record:
- The test (what you measured, on what slice of data).
- The result (numerical, with confidence intervals or sensitivity ranges
  where applicable).
- The tuning curve for each tunable parameter (objective vs parameter
  value across the sweep).
- The interpretation: does this step survive contact with reality?
  Specifically: does the counterfactual outcome under the plan beat the
  actual historical outcome on the chosen objective, with statistical
  significance proportional to the available N?

If a data quality issue surfaces during the run (gaps, stale snapshots,
wrong timestamps, dummy values), STOP and fix the test or the data
before continuing. Caveats are not verdicts. A test you don't trust is
a test that hasn't run.

If a step CANNOT be backtested with available data, mark it
`BACKTEST: not feasible` with an explicit reason. Steps marked not-feasible
DO NOT enter the synthesis pool — they require richer data and ship as
"framework reserved" with no live behavior change.

## Format

For each step:
```
### Step N: <name>
**Atomic action:** <verb + observable outcome>
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
```

## Hard rules

- A step CANNOT be marked PASS without all of: a real replay-based backtest,
  a tautology-clean trigger/outcome separation, full coverage of relevant
  data (or a justified representative subset), data-tuned defaults, and a
  positive result on the chosen objective.
- "Sounds right" is not a backtest. Architectural plausibility is not a
  backtest. Single-snapshot summary statistics are not a backtest.
- Failed backtests stay in the log. Do NOT delete or rewrite them.
- If a step depends on another step, run them in order.
- If you find a data quality issue mid-run, fix it and re-run. Do not
  caveat past it.
