# Worked Example — Side Quest end-to-end

A walk-through of a Side Quest from scaffold to verdict, using a generic web-app example so you can map the workflow to any domain.

## Scenario

You run a SaaS product. The signup → first-paid-conversion funnel has plateaued at 18%. A handful of one-off A/B tests over the past quarter haven't moved it. Single-pass thinking ("try better copy", "shorten the form", "add social proof") has been exhausted. You have:

- 6 months of session-event data (`events/sessions/*.jsonl`)
- 12 months of paid-conversion outcomes (`events/conversions.jsonl`)
- A codebase whose checkout flow lives in `src/checkout/` and `src/auth/`

The Main Quest: **lift first-paid-conversion ≥ +3pp without sacrificing >5% retention at 30d.**

## Step 1: Initialize

```bash
~/.claude/skills/side-quest/scripts/init_quest.sh "checkout-conversion-plateau"
```

The scaffold creates `<project-root>/data/side_quests/checkout-conversion-plateau-YYYYMMDD/` with all phase files, including `phase_-1_calibration.md` pre-populated with auto-inventoried data sources.

## Step 2: Phase -1 — Operator calibration

The agent reads the scaffold, sees you have `events/sessions/*.jsonl` and `events/conversions.jsonl`, and presents the 13 calibration questions via `AskUserQuestion` in 4 batches.

Example for Q1 (single-select):

```
What's the primary success metric for this quest?

1. (Recommended) Headline metric from MAIN_QUEST.md: first-paid-conversion lift ≥ +3pp
2. Funnel-step lift (e.g. "checkout completion %") instead of paid conversion
3. Composite metric (paid conversion × 30d retention)
4. Other (typed)
```

Example for Q4 (multi-select):

```
Which assumptions should we explicitly CHALLENGE?

[ ] (Recommended) None — let Phase 0 surface them
[ ] "Bigger is better" (more form fields, more social proof, more copy)
[ ] "Simpler is better" (every removed step helps)
[ ] "Recent is more relevant" (latest session > older sessions)
[ ] Other (typed)
```

You arrow through, hit `Recommended` for most, multi-select Q4 to challenge "simpler is better" specifically (you suspect ultra-short forms hurt trust), and type a custom answer for Q11 to add `src/onboarding/` to the codebase-scope.

The agent writes your answers verbatim to `phase_-1_calibration.md`.

## Step 3: Codebase map

Per Phase -1 Q11, the agent scans `src/checkout/`, `src/auth/`, `src/onboarding/` and writes `codebase_map.md` with:

- File-to-responsibility mapping
- Public functions per file
- Cross-file dependencies
- Configuration entry points
- Existing experiment hooks (if you have an A/B framework)

This becomes shared ground truth for both Claude and Codex's Phase 0/1/4 work.

## Step 4: Phase 0 — Self-framing

Both models answer the same 3 questions independently:

**Claude `phase_0_claude.md`** (excerpt):
> The current plateau suggests the funnel's bottleneck is **trust friction at price-reveal**, not form length or copy. Sessions that reach the price page have a 60% drop, far higher than the form-fill drop. The Main Quest is "+3pp paid conversion without retention sacrifice," so any solution that boosts conversion via aggressive friction-removal but tanks retention fails.

**Codex `phase_0_codex.md`** (excerpt):
> The funnel converts sessions linearly through 5 stages but the dropoff distribution is bimodal: a fast-quit cluster at the email-confirmation stage and a slow-decline cluster after price exposure. Single-treatment A/B tests can't separate these populations, which is why the past quarter's tests didn't move the needle.

Notice they agree on "the funnel has multiple dropoff modes" but disagree on which mode dominates. This disagreement gets resolved with the operator before Phase 1 (or by Phase 2 backtest data).

## Step 5: Phase 1 — Oversight brainstorm

Each model proposes **solution shape + plan + success criteria** in `phase_1_<model>.md`.

Claude proposes a **two-stage friction redistribution** — move auth friction earlier, defer payment-method commitment. Codex proposes a **price-page split** — segment users by visited-pricing-before-signup vs not, and give the latter a different price-reveal treatment.

## Step 6: Phase 2 — Decompose + backtest

Each plan gets atomic-stepped + backtested with hardened rules:

- **Replay**, not summary stats: each historical session gets replayed through the proposed funnel variant. The harness compares actual conversion vs counterfactual.
- **Tautology guard**: trigger features (session metadata visible at funnel entry) come from data ≤ T_funnel_start. Outcome (paid conversion) comes from data > T_funnel_start + 30d.
- **Walk-forward**: train on months 1-9, hold out months 10-12.
- **Out-of-regime slice**: include the post-policy-change month (where conversion mechanics shifted slightly).
- **Sensitivity**: ±10% on the price-segment cutoff threshold; reject if objective degrades > 20%.

Result tables go into `phase_2_<model>.md`.

Suppose Claude's plan shows +1.8pp lift on holdout but sensitivity collapses 35% (overfit, **DROP**). Codex's plan shows +2.4pp lift on holdout, sensitivity 12% (within tolerance, **PASS**), but only on the "visited pricing before signup" segment — not universal.

## Step 7: Phase 3 — First analysis

Sort what worked and what didn't:

- ✓ Codex's segment-split: +2.4pp lift, sensitivity-clean, restricted to one segment
- ✗ Claude's friction-redistribution: nominally lifted but failed sensitivity rejection — overfit
- Lesson: pre-funnel-entry segmentation may be more powerful than within-funnel-mechanic changes

## Step 8: Phase 4 — Outside-the-box (Round 2)

Hard rule: cannot reuse anything from Round 1. So:
- Excluded: friction redistribution, price-page split, segment-by-pricing-visit
- Excluded: same data slices, same metaphors

Models go further afield. Claude proposes treating the funnel as a **bandit problem with confidence-weighted arms per session-class**. Codex proposes **inverting the assumption that the funnel needs to convert in one session** and proposes a **pre-commit asynchronous follow-up** after a delay.

## Step 9: Phase 5 — Decompose Round 2 + backtest

Same shape as Phase 2 with the same hardened rules. Suppose:

- Claude's bandit plan: +0.8pp lift but coverage too thin (the bandit only had enough samples per arm in 2 of 8 segment classes). **FRAMEWORK_RESERVED, retest after live data accumulates.**
- Codex's pre-commit-then-followup: +1.6pp lift, sensitivity 18%, **PASS**. But: requires a write-side change (sending followup emails), so out-of-scope per Q5 unless explicitly approved.

## Step 10: Phase 6 — Second analysis

Combine what we know:
- ✓ Codex's pre-commit-followup: real lift, real test, but write-side scope blocker
- ⏳ Claude's bandit: framework-reserved, blocked on data
- The cross-round insight: **conversion isn't a single-session decision**, two of the three winning ideas treat the user across multiple sessions / async time.

## Step 11: Phase 7 — Synthesis

Pool what worked. Decide:
- Codex Round 1 segment-split: **KEEP** (ship as the live admission gate)
- Codex Round 2 pre-commit-followup: **KEEP**, but as a Phase 7.5 spawn (write-side scope quest of its own)
- Claude Round 2 bandit: **FRAMEWORK_RESERVED**, write `<quest-dir>/PLAN.md` reserves it for retest after segment-split runs for 30d

The final `PLAN.md` ships the segment-split layer first; the spawn list captures the rest.

## Step 12: Phase 7.5 — Spawn decisions

| Item | Decision | Reason |
|---|---|---|
| Pre-commit followup | SPAWN_CHILD | Different scope (write-side, retention measurement, email infra) |
| Bandit framework | FRAMEWORK_RESERVED | Real direction, thin sample, retest after live |
| Friction redistribution | DROP | Sensitivity overfit |

## Step 13: Phase 10 — Meta-synthesis (after the spawn child completes)

Once the pre-commit-followup spawn quest completes, the family has 2 quests sharing the same Main Quest. Phase 10 pools their validated layers, detects contradictions (does segment-split's per-session targeting conflict with multi-session followups?), and produces a family-level PLAN.md.

## What this skill saved

Without Side Quest: probably a 4th single-mechanism A/B test that conflated segments and missed the bimodal-dropoff structure entirely.

With Side Quest: shipped the segment-split (validated +2.4pp), reserved a real next bet (multi-session followup), explicitly dropped an overfit candidate (friction redistribution) instead of running it as the next test, and exposed a higher-order insight ("conversion is multi-session") that makes the next quest faster.

## Mapping this to your domain

The same shape works for:
- **ML model deployment**: should-we-ship gating, model-version regression hunts, feature-importance audits
- **Infra/SRE**: incident-pattern decomposition, capacity-plan validation, on-call rotation effectiveness
- **Research design**: hypothesis selection, study-design red-teaming, replication audits
- **Product strategy**: pricing-tier experiments, retention-cohort analysis, churn-cause searches
- **Trading systems**: regime-conditional admission gates, lifecycle-PnL backtests, cohort behavior shifts

The hardened backtest rules (replay-not-stats, tautology guard, walk-forward, sensitivity rejection) apply anywhere replayable data exists. The two-round no-duplicate constraint applies anywhere multi-pass divergent thinking is more valuable than single-pass convergence.
