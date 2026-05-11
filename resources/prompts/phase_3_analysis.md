# Phase 3 Prompt — First Analysis

You and the other model have completed Phase 2 backtests on your respective plans.
Now categorize and explain.

## Context

**Main Quest:** {{MAIN_QUEST}}
**Both Phase 2 results:**
{{PHASE_2_RESULTS}}

## Your task — separate, label, explain

### 1. What worked

For each step or sub-idea that PASSED backtest:
- The step.
- The metric/result that proved it worked.
- **WHY it worked** (the underlying principle or mechanism that made it succeed).

### 2. What didn't work

For each step that FAILED or was INSUFFICIENT_DATA:
- The step.
- The metric/result that proved failure (or the data gap).
- **WHY it didn't work** (the assumption that turned out false; the missing piece).

### 3. Transferable lessons

State the principles that emerge from the works/doesn't-work split. These are NOT
ideas (you can't reuse ideas in Phase 4) — they are first-principles observations
about the problem space. Examples:
- "Maker fills don't happen on assets with thin volume."
- "BTC-correlated assets compound bleeding when BTC dumps."
- "Fee drag dominates short-cycle trades below 0.5% wiggle."

These lessons are usable in Phase 4 — the SPECIFIC ideas that yielded them are not.

## Format

Use markdown headers `## What worked`, `## What didn't`, `## Transferable lessons`.
Be ruthless — gray-area ideas (worked sometimes) belong in "didn't work" with an
explicit "worked under conditions X but not Y" footnote.
