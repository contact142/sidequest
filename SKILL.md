---
name: "Side Quest"
description: "Multi-model collaborative problem-solving workflow with hardened backtest gates. Two rounds of brainstorm with a no-duplicate-thoughts rule between rounds, replay-not-stats backtests, walk-forward validation, sensitivity rejection, and per-quest verdict synthesis. Use when a hard problem stalls single-pass thinking, when you have testable data and want multiple model perspectives, or when an explicit creative-divergence step would surface non-obvious solutions. Works for any domain — software architecture, ML, infra, research design — anywhere replayable data exists."
---

# Side Quest

A structured multi-model brainstorm + backtest + synthesis workflow. Built for problems where one-pass analysis has plateaued and you want forced creative divergence before converging on a plan.

## When To Invoke

Trigger Side Quest when ANY of these are true:

- The user uses the phrase "side quest" or invokes `/sidequest`.
- A problem keeps cycling through the same handful of ideas without resolution.
- The user wants multiple AI perspectives (Claude + Codex + optionally web-UI voices) before committing to an approach.
- You have empirical data to backtest hypotheses against.
- The work serves a clear **overall project goal** ("main quest") that this branch must not lose sight of.

## Hard Rules

1. **Never skip Phase -1 or Phase 0.** Phase -1 is the operator calibration (13 questions with assumed defaults); Phase 0 is each model's independent framing. Skipping either causes misaligned plans downstream. Phase -1 outputs are BINDING context for every subsequent phase — operator's overrides cannot be silently ignored.
2. **Round 2 cannot reuse anything from Round 1.** Not the approach, not the mechanism, not the metaphor, not the tooling choice, not the data slice. The constraint exists to force novelty — relax it and you've defeated the skill.
3. **No duplicate thoughts within Round 2.** Once one model states an idea, the other model cannot mirror it.
4. **Every plan segment must be backtested with a REAL test before it counts.** A "real test" means:
   - **Replay, not summary statistics.** If the plan affects per-instance behavior, replay each historical instance through the proposed mechanism step by step (or event by event) and compare actual outcome vs counterfactual outcome under the plan. Aggregate stats on existing labels are not a backtest — they are a description.
   - **No tautology.** The signal used to LABEL outcomes cannot also be the TRIGGER the plan fires on, when both come from the same source. If the plan says "fire when X drops below threshold" you cannot use X to label whether firing was correct. Use a temporally-prior signal as trigger and a temporally-posterior outcome as the verdict — and confirm the temporal separation explicitly.
   - **Coverage.** Test on ALL relevant data, not just a convenient subset. If a plan applies to a population, it must be backtested across the population with sufficient data — not just the easy cases.
   - **Sample-size gate at design time, not at verdict time.** Before running the backtest, compute the available sample size and the smallest detectable effect. If the design can't separate signals at the available N, redesign the test (different metric, different window, different bucketing) — don't run it and discover the gap at verdict time.
   - **Fix data quality issues before declaring a verdict.** If the test surfaces a data bug (gaps, stale snapshots, dummy values, off-by-N timestamps, unreliable boundary inference), fix the test or fix the data and re-run. Caveats are not verdicts.
   - **Defaults must come from the data.** Any threshold, weight, window, or other tunable parameter in the plan must be derived from the backtest results — picked because it maximizes an explicit objective on real data — not picked from intuition or a round number. The plan must show the tuning curve / sensitivity analysis, not just a single chosen value.
   - **Walk-forward, not random split.** Train/validate splits must respect chronology. A random shuffle test on time-series data is not a backtest, it is a leak.
   - **Sensitivity rejection.** Perturb the chosen parameter ±10%. If the objective function degrades > 20% from a 10% shift, the threshold is overfit and the plan is rejected.
5. **The mission log is append-only.** Wrong turns and disproven hypotheses stay in the log — they're load-bearing for Phase 3 and Phase 6 analysis.
6. **Surface the main quest at every phase.** Each phase explicitly references the project's overall goal so the side quest doesn't drift.
7. **Synthesis (Phase 7) only KEEPs ideas with passing real backtests + data-tuned defaults.** An idea cannot enter the final plan because the framework feels right. It enters because the lifecycle-replay backtest produced a positive result on coverage data with data-tuned thresholds. Architectural-but-untested ideas can be NOTED in the plan as "framework reserved, awaits backtest" but cannot ship as live behavior changes.
8. **Plans must balance defensive and offensive layers, or explicitly justify why one is enough.** Defensive layers prevent bad outcomes (cut losers, quarantine bad inputs, block unknowns). Offensive layers actively select winners (predictive signals, opportunity capture, regime advantage). A plan composed entirely of one or the other is incomplete unless Phase -1 calibration explicitly scoped the quest as defensive-only or offensive-only. Phase 7 synthesis must surface the imbalance if it exists.
9. **Backtests must include at least one OUT-OF-REGIME or adversarial slice.** Every plan tested only on recent / convenient / in-distribution data is overfit by construction. Phase 2/5 backtest design must explicitly carve out an adversarial slice — different time window, different operating regime, different population segment — and report performance there. If no out-of-regime data exists, flag the gap; if the plan demonstrably breaks out-of-regime, that breakage is part of the verdict.
10. **Null backtest results lead to DROP, not framework_reserved.** Framework_reserved is for ideas with positive backtest direction but insufficient sample size. Null results (no signal in either direction) DROP. Negative results DROP. Only weak-but-positive-with-thin-N reaches framework_reserved.
11. **If Phase 2/3 reveals Phase 0 framing was inverted, document the inversion and consider RESETTING the quest.** Don't quietly continue on a refuted foundation. The honest options are: (a) reset to a new Phase 0 with the corrected framing and acknowledge the wasted Phase 1 work, OR (b) explicitly continue with the inversion documented as a Main-Quest revision, signed off by the operator. Silently building on a broken Phase 0 is the worst outcome.
12. **Multi-model voice diversity matters.** Codex is similar to Claude in many reasoning patterns. Adding Gemini brings different lineage; Perplexity brings real-time web context none of the others have. The operator picks voices in Phase -1 Q8. If the question is open-ended exploration, more voices help; if the question is narrow execution, fewer voices help. Don't add voices for show — add them when their distinct strength applies.
13. **Quest tree relationships are explicit.** When a quest spawns child quests in Phase 7.5, the relationship is recorded in `quest_index.md` at the project's mission-log root. Round 2 no-reuse propagates across the family — a child's Round 1 cannot reuse the parent's Round 1 OR Round 2 ideas. Phase 10 meta-synthesis combines the family.
14. **Reconstruction substrate is load-bearing — verify boundary truth before relying on derived data.** If your backtest reconstructs lifecycle / event / sequence boundaries from raw fills, logs, or telemetry, the reconstruction itself is a hypothesis. Validate it against an authoritative event ledger (rotation events, transaction events, span markers, etc.) before declaring any verdict from it. A WEAKLY_PASS verdict that depends on inferred boundaries can reverse to DROP when the substrate is corrected.

## Phase -1 — Operator Calibration (REQUIRED, before Phase 0)

The operator answers a structured questionnaire BEFORE the models start framing the problem. Each question has an **assumed default** (the option you, the agent, recommend based on the project context). The operator can accept, override with one of the offered alternatives, write a custom answer, or pick multiple.

### How to ask Phase -1 questions

**Use the `AskUserQuestion` tool, one phase-block at a time.** Render each question with:

- **Option 1**: the recommended default, labelled `(Recommended)`.
- **Options 2–4**: the most common alternatives appropriate to the project domain.
- The tool automatically appends an `Other` option for typed-in custom answers.
- Set `multiSelect: true` for questions where multiple answers compose naturally (e.g. assumptions to challenge, voices to include, data sources to consume).

This gives the operator arrow-key navigation, single- or multi-select, and a free-text path — without the agent needing to construct a custom UI. The tool's structured response feeds straight into `phase_-1_calibration.md`.

**Batching**: send 1–4 related questions per `AskUserQuestion` call (the tool's per-call cap). For 13 questions, that's typically 4 calls of 3-4 questions each. Keep each question's `header` ≤ 12 characters (e.g. `Metric`, `Kill bar`, `Voices`).

The questionnaire covers: primary success metric, kill criterion, time pressure, assumptions to challenge, out-of-scope topics, backtest data depth, risk-tolerance posture, multi-model voices, operator-seeded ideas, prior attempts, codebase-scope to ground proposals, regime awareness, and what "good enough" looks like.

See `resources/prompts/phase_-1_operator_calibration.md` for the full questionnaire with recommended option lists per question. Operator's responses live in `<quest-dir>/phase_-1_calibration.md`.

**Why it matters**: skipping Phase -1 leads to the models proposing solutions disconnected from the operator's actual constraints. Operators don't always volunteer assumptions; you have to ask. The structured-options interface lowers the friction enough that operators consistently engage rather than waving "yes do whatever."

## Phase 0 — Self-framing (each model, independently)

Both models answer **in writing, separately**, before either sees the other's answer:

1. What is the current problem?
2. Why is it a problem?
3. What is the best possible outcome **relative to the overall project goal**?

Phase 0 outputs go into the mission log as `phase_0_<model>.md` (e.g. `phase_0_claude.md`, `phase_0_codex.md`).

### Codebase-awareness sub-step (recommended before Phase 0)

When the side quest will touch existing code, generate a structured map of the relevant code, docs, and features BEFORE Phase 0. This gives every model a shared ground truth so proposals reference real functions / files / config keys, not hand-waved sketches.

**How**: have the agent inventory the problem-area scope chosen in Phase -1 Q11. Output a single markdown file (`<quest-dir>/codebase_map.md`) with: top-level files, key functions per file, public interfaces, configuration entry points, data shapes, and known cross-file dependencies. The agent can use grep/AST tools to do this; it doesn't need a separate "graph" infrastructure.

**Why it matters**: in early Side Quest runs, Phase 1 plans proposed mechanisms that already partly existed in the codebase or that conflicted with existing structure. Each model had a different mental model of what the system WAS. A shared codebase map makes Phase 0 / Phase 1 / Phase 4 work against common ground truth.

**When to skip**: if the problem area is small (single file, no dependencies), or if the operator confirms in Phase -1 Q11 that the team has already aligned on the existing-system model. For pure-research quests with no existing code (e.g., a green-field design), skip entirely.

**Hard rule when used**: every Phase 1 / Phase 4 plan must reference specific entries from the codebase map (files / functions / features) where applicable. "We add a new gate at the entry path" is too vague when the map shows the entry path has 4 distinct stages already.

## Phase 1 — Oversight brainstorm

Each model proposes, in their own document:

- Their **idea of the solution** (high-level shape).
- A **plan of action** (numbered steps to get there).
- The **success criteria** they'd use to know it worked.

Goal of Phase 1: alignment on the outcome being achieved before diverging on approach. If the two models disagree on what success looks like, **resolve that with the operator before Phase 2**.

## Phase 2 — Plan decomposition + segment-level brainstorm + backtest

For each model's plan:

1. Break the plan into atomic steps.
2. Brainstorm each step in isolation: assumptions, failure modes, evidence required, alternative implementations.
3. Once **all** steps have been brainstormed, **test each segment** with available data using the hardened backtest rules (Hard Rule #4).
4. Record results per segment in the mission log.

Backtest is required. A plan that can't be tested is a hypothesis, not a plan; downgrade it and explain why.

## Phase 3 — First analysis

- Sort ideas into what **worked** and what **didn't**.
- For every entry in either bucket: state **why**. ("Worked because X" / "Didn't because Y".)
- Capture transferable lessons (these inform Round 2 even though specific ideas can't repeat).

## Phase 4 — Outside-the-box brainstorm (Round 2)

Hard rule: **cannot reuse any idea from Round 1**.

What that excludes:
- Same approach or mechanism.
- Same metaphor or abstraction.
- Same data source or tooling choice as the primary lever.
- Same first-principles framing.

What's encouraged:
- Unconventional metaphors (translate them to code in Phase 5).
- Reframing the problem from a different domain.
- Inverting the assumption that drove Round 1.
- Adversarial framings (what would break this hardest?).

The constraint is not a punishment — it's a search-space expander. Use it to find ideas Round 1 couldn't reach.

## Phase 5 — Second decomposition + backtest

Same shape as Phase 2, applied to the Round 2 plans.

Additional constraint: **no duplicate thoughts within Round 2 either.** Once one model states an idea, the other cannot mirror it. Forces divergent exploration even within the round.

## Phase 6 — Second analysis

Same shape as Phase 3, applied to Round 2 results.

## Phase 7 — Final synthesis (per quest)

Pool **only what works** from both rounds. For each validated idea:

- Will it be **used** in the final plan? (yes / no / partial)
- If yes: how does it integrate with the others?
- If no: why not? (record so future side quests can see the deselection rationale)

Then build a single coherent plan that achieves the **overall project goal**. The plan can:
- Use all of the validated ideas.
- Use one of them.
- Use none of them (and explain why the side quest still mattered as a search).

Document the discard pile. Failed ideas are load-bearing context for the next side quest.

## Phase 7.5 — Spawn Decision (between synthesis and ship)

Examine items NOT in the live ship list. Decide for each: SPAWN_CHILD (needs its own quest), DROP (null/negative backtest), or FRAMEWORK_RESERVED (positive direction, thin sample, await evidence). Each spawn declares parent quest, relationship, carry-over context, inherited EXCLUDED list, success metric, estimated effort.

See `resources/prompts/phase_7.5_spawn_decision.md`.

## Phase 8 — Backtest redo (reopened quest, optional)

Activated when a Phase 7 verdict needs re-validation under hardened rules (e.g. earlier backtests were summary-stats not lifecycle replays, defaults from intuition not data, tautology guard missed, reconstruction substrate broken). Runs the hardened Phase 2 protocol on previously-soft verdicts. Outputs data-tuned defaults or explicit downgrades.

## Phase 9 — Re-synthesis with hardened defaults (after Phase 8)

Re-runs Phase 7 synthesis using Phase 8's data-tuned defaults. Old PLAN.md preserved as historical record (v1 below the divider, v2 above). Architectural-but-untested ideas demoted to FRAMEWORK_RESERVED.

## Phase 10 — Meta-synthesis (across multiple completed quests)

Activated when a quest tree has ≥ 2 completed quests sharing the same Main Quest. Pools validated ideas across the family, detects contradictions, surfaces emergent patterns no single quest could see, produces a family-level PLAN.md.

See `resources/prompts/phase_10_meta_synthesis.md`.

## Quick Start

```bash
# 1. Initialize a new side quest (creates a mission log directory)
~/.claude/skills/side-quest/scripts/init_quest.sh "<your-quest-slug>"

# 2. The agent runs Phase -1 calibration via AskUserQuestion (in chat).
# 3. The agent generates a codebase map for the problem-area scope (recommended).
# 4. The agent runs Phase 0 framing for itself; Codex via consult helper:
~/.claude/skills/side-quest/scripts/codex_consult.sh phase_0_prompt.md phase_0_codex.md

# 5. Continue through phases, writing each model's output to the mission log.
# 6. When the quest completes, the final plan lives at <quest-dir>/PLAN.md
```

## Mission log structure

Each side quest creates a directory under the active project. The default location is `<project-root>/data/side_quests/<slug>-YYYYMMDD/`, but `init_quest.sh` accepts a `QUEST_ROOT` env var if your project uses a different convention.

```
<quest-dir>/
├── MAIN_QUEST.md            # the overall project goal (copied at quest start)
├── PROBLEM.md               # the immediate problem being side-quested
├── phase_-1_calibration.md  # operator answers to the 13-question calibration
├── codebase_map.md          # (optional) shared ground-truth map of relevant code
├── phase_0_<model>.md       # framing per model
├── phase_1_<model>.md       # oversight brainstorm
├── phase_2_<model>.md       # decomposition + segment results
├── phase_3_analysis.md      # first works/doesn't analysis
├── phase_4_<model>.md       # outside-the-box brainstorm
├── phase_5_<model>.md       # second decomposition + segment results
├── phase_6_analysis.md      # second works/doesn't analysis
├── phase_7_synthesis.md     # the final pooled-ideas pass
├── phase_7.5_spawn_decisions.md
├── PLAN.md                  # the single coherent plan that comes out
└── DISCARD.md               # ideas that didn't make the cut + why
```

## Multi-model consult patterns

### Codex (CLI, available when `codex` is installed)

```bash
timeout 420 codex exec --skip-git-repo-check --sandbox read-only "$(cat <phase-prompt.md>)" \
  </dev/null > <phase-output.md> 2>&1
```

The `</dev/null` prevents Codex from hanging on stdin (a known footgun). xhigh reasoning is the default and right for this work. Use `scripts/codex_consult.sh` as a wrapper.

### Gemini, Perplexity, or other web-UI models (no API path)

For voices that aren't available as a CLI from this machine, the agent generates a single self-contained prompt at `<quest-dir>/UI_PROMPT.md`. The operator pastes that into the model's web UI and pastes the response back. The skill's prompt template tells the model:

- All the calibration context it needs
- What's EXCLUDED (Round 2 no-reuse list)
- What output structure to produce
- A confidence-level + biggest-uncertainty closer

Stub helpers `scripts/gemini_consult.sh` and `scripts/perplexity_consult.sh` exist for environments where those CLIs become available; otherwise the UI_PROMPT path is the universal fallback.

### Single-model degraded mode

If only one model is available, **flag the gap explicitly in the mission log**. A single-model side quest is degraded — the synthesis must weigh that. The skill still produces useful output (one round of forced creative divergence by Phase 4 alone is valuable), but Round 2's "no duplicate within round" constraint becomes vacuous.

## Files in this skill

- `SKILL.md` — this file (the methodology)
- `README.md` — open-source project description, install, contributing
- `scripts/init_quest.sh` — scaffold a mission log directory
- `scripts/codex_consult.sh` — invoke Codex with the right flags
- `scripts/gemini_consult.sh` — Gemini consult stub
- `scripts/perplexity_consult.sh` — Perplexity consult stub
- `resources/prompts/` — reusable prompt templates per phase
- `resources/templates/mission_log.md.template` — blank mission log skeleton
- `docs/EXAMPLE.md` — a worked example illustrating phases end-to-end

## Self-review checklist (run before declaring the quest done)

- [ ] Phase -1 calibration was rendered with structured option lists, not as an open-ended free-form prompt?
- [ ] Both rounds of brainstorm completed for the chosen voice pool?
- [ ] Round 2 contains zero ideas from Round 1? (Verify by diffing.)
- [ ] Every "validated" idea has a documented backtest result (replay, walk-forward, sensitivity)?
- [ ] Reconstruction substrate (if any) was validated against a boundary-truth source before the verdict?
- [ ] Out-of-regime / adversarial slice tested?
- [ ] Final plan references the overall project goal?
- [ ] DISCARD.md explains why each rejected idea was rejected?
- [ ] Mission log is append-only (no rewriting earlier phases)?
- [ ] If a voice was unavailable for any phase, that gap is flagged?

## Failure modes to avoid

| Failure | Symptom | Fix |
|---|---|---|
| Round 2 quietly mirrors Round 1 | "Different words, same idea" | Explicit diff check; if any concept repeats, restart Round 2 with stronger constraints |
| Skipping the backtest because "obvious" | Plan looks great but fails in production | Backtest is non-optional. If untestable, downgrade to hypothesis. |
| Summary-stat backtest masquerading as a real test | Verdict marked PASS without a per-instance replay | Phase 2 + 5 require explicit replay shape in the design pass. If the test isn't a replay, it isn't a backtest. |
| Tautology-shaped backtest | Trigger and outcome derive from the same metric | Phase 2 + 5 require a tautology guard at design time. State the separation explicitly. |
| Convenience-subset coverage | Test runs on the easy cohort and skips the rest | Coverage requirement: full population or justified representative subset, not "the data I had handy." |
| Sample-size discovered at verdict time | Test runs, p-values inconclusive, no actionable signal | Compute sample size + smallest detectable effect at design time. Redesign before running if N is too thin. |
| Data quality bug caveated instead of fixed | "+308% lift (data bug)" appears in the verdict | Stop, fix the data or fix the test, re-run. Caveats are not verdicts. |
| Reconstruction substrate broken | Verdict relies on inferred boundaries that don't match authoritative event ledger | Validate the reconstruction against boundary-truth events before declaring; reverse the verdict if substrate is corrected and the result inverts. |
| Defaults picked from intuition | Plan ships with `max_hold_hours = 24` because it sounded round | Phase 2 + 5 require defaults to come from a backtest tuning curve. Show the sweep, show the chosen value's justification. |
| Architectural plausibility passing for tested | "The framework is sound" used as evidence the framework works | Phase 7 demotes architectural-but-untested ideas to "framework reserved." Cannot ship live behavior. |
| Drift from the main quest | Brilliant solution to the wrong problem | Re-read MAIN_QUEST.md at the start of every phase |
| Hidden Main-Quest contradiction in synthesis | Plan ignores or papers over a Phase 3/6 finding that refutes Phase 0 | Phase 7 must surface refutations of the Main Quest explicitly and propose revise-or-navigate-around. |
| Lost-in-the-loop synthesis | Phase 7 just reuses one model's plan | Force the synthesis to acknowledge ALL validated ideas, then justify the final structure |
| Voice unavailable, ignored | Single-model side quest framed as multi-model | Flag the gap explicitly in `phase_*_<model>.md` files |
| Phase -1 rendered as free-form text | Operator skips it or gives one-word answers | Use `AskUserQuestion` with structured options + recommended default; lowers friction enough that operators engage |
