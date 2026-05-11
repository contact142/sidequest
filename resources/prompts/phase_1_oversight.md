# Phase 1 Prompt — Oversight Brainstorm

The other model and you have independently answered the framing questions. The
operator has reviewed both answers and confirmed alignment on the outcome.

## Context

**Main Quest:** {{MAIN_QUEST}}
**Problem:** {{PROBLEM}}
**Aligned outcome (from Phase 0 reconciliation):** {{ALIGNED_OUTCOME}}

## Your task — propose ONE solution and ONE plan of action

### 1. Solution shape

In 2-4 sentences, describe the **high-level shape** of your proposed solution.
What is the mechanism? What does the world look like after it's deployed?

### 2. Plan of action

Numbered list of concrete steps to implement the solution. Each step should be:
- Atomic (one verb, one observable outcome).
- Testable (has a way to know it worked).
- Ordered (later steps depend on earlier steps where applicable).

### 3. Success criteria

The metric(s) you'd use to know the solution worked. State:
- The metric.
- The threshold (e.g. "lift ≥ +3pp on held-out", "false-positive rate < 5%").
- The measurement window (e.g. "over 100 events", "across one full out-of-regime slice").

### 4. Risks

The two or three most likely ways this plan fails. For each:
- The failure mode.
- The early-warning signal.
- The fallback.

## Format

Use markdown headers `## 1. Solution`, `## 2. Plan`, `## 3. Success criteria`,
`## 4. Risks`. Total length ~600-1000 words. Be specific — vague plans cannot be
backtested in Phase 2.
