# Phase 0 Prompt — Self-framing

You are about to participate in a Side Quest: a structured multi-model brainstorming
workflow. Before any solution-mode thinking, you must answer three questions. These
answers will be compared against the other model's answers to confirm alignment.

## Context

**Main Quest (overall project goal):**
{{MAIN_QUEST}}

**Immediate problem triggering this side quest:**
{{PROBLEM}}

**Operator calibration (BINDING — Phase -1 outputs):**
{{OPERATOR_CALIBRATION}}

The calibration above is authoritative. If your framing conflicts with
any operator answer, the operator wins. Specifically:
- If operator named a primary metric, use that as your success criterion.
- If operator listed assumptions to challenge, treat them as
  unexamined-and-suspect; do NOT default to them in your framing.
- If operator named "out of scope", do not propose anything that touches
  those areas.
- If operator named "prior attempts didn't work", do not re-propose
  those ideas without explicit reasoning about why this time is
  different.
- If operator's risk posture is "adversarial," default to conservative
  thresholds in your eventual plan.

**Available data sources for backtesting:**
{{DATA_SOURCES}}

## Your task — answer all three, in order, in writing

### 1. What is the current problem?

State the problem in one paragraph, in your own words. Do not propose solutions yet.
Focus on:
- What is happening that shouldn't be?
- What is NOT happening that should be?
- What is the observable signal of the problem?

### 2. Why is it a problem?

State the consequences if the problem is left unaddressed:
- What does it cost the project? (capital, time, trust, optionality)
- What other problems does it cause downstream?
- Why is now the right time to address it (vs. deferring)?

### 3. What is the best possible outcome — relative to the Main Quest?

The outcome must serve the Main Quest. Solutions that solve the immediate problem
but don't advance the Main Quest are LOSSES, not wins. State:
- The shape of the ideal outcome.
- The metric you'd use to know it was achieved.
- The constraints the outcome must respect (live trading safety, no regrid leaks, etc.)

## Format

Reply with markdown headers `## 1.`, `## 2.`, `## 3.`. Be concise — under 300 words
per question. Do not propose solutions. Solution mode starts in Phase 1.
