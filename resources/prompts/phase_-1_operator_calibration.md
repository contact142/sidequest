# Phase -1 — Operator Calibration

Ask BEFORE Phase 0. Goal: catch unstated assumptions and ambiguity that would otherwise distort Phase 0 framing.

## How to render the questions

Use the `AskUserQuestion` tool with one phase-block per call. Per-call cap is 4 questions. For 13 questions plan **4 batches**.

Each question follows this contract:

- **Option 1** is the **recommended default**, labeled `(Recommended)`. Make this the option you, the agent, would pick if the operator said "use your best judgement."
- **Options 2–4** are the most-common alternatives appropriate to the project's domain and the quest's apparent shape.
- The tool auto-appends an `Other` option for free-text custom answers.
- Use `multiSelect: true` for questions where multiple answers compose naturally (Q4, Q6, Q8, Q9, Q10, Q11). Use single-select for the rest.
- Each `header` field is ≤ 12 characters.

After the operator answers, **write the responses verbatim** to `<quest-dir>/phase_-1_calibration.md` in the format at the bottom of this file. If they pick `Other`, capture their typed text exactly.

## The 13 Questions

### Q1. Primary success metric — how do we know this side quest worked?
- **Recommended default**: the metric named in `MAIN_QUEST.md`. Whatever's there is authoritative.
- Alt 1: a different headline metric (operator names it via Other)
- Alt 2: a leading indicator metric (faster signal, less authoritative)
- Alt 3: a composite metric (operator names the components)

`header: "Metric"` · `multiSelect: false`

### Q2. Kill criterion — when do we revert the whole plan?
- **Recommended default**: primary metric drops > 20% over 14 days post-live.
- Alt 1: tighter — > 10% over 7 days
- Alt 2: looser — > 30% over 30 days
- Alt 3: no automatic revert; operator-driven only

`header: "Kill bar"` · `multiSelect: false`

### Q3. Time pressure — ship-now vs learn-first?
- **Recommended default**: balanced. Ship the high-confidence layers immediately; defer architectural / speculative ideas to follow-up side quests.
- Alt 1: emergency mode — ship anything that helps now, worry about cleanup later
- Alt 2: research mode — don't ship anything until backtest agreement is rock solid
- Alt 3: learn-first with explicit ship trigger (operator names the trigger)

`header: "Time"` · `multiSelect: false`

### Q4. Existing assumptions to explicitly CHALLENGE
- **Recommended default**: empty — let Phase 0 surface them.
- Alt 1: "Bigger is better" (more data / more coverage / more features always helps)
- Alt 2: "Simpler is better" (or its inverse)
- Alt 3: "Recent is more relevant" (temporal weighting)

`header: "Challenge"` · `multiSelect: true`

(Operator can add domain-specific assumptions via Other; multi-select allows stacking.)

### Q5. Out of scope — what we will NOT touch
- **Recommended default**: no destructive changes; no changes to write-paths or production-side-effecting logic without explicit shadow soak; no rip-and-replace of working subsystems.
- Alt 1: also skip any data-pipeline changes
- Alt 2: also skip any external API or third-party integration changes
- Alt 3: scope is tighter — operator names the read-only zone

`header: "Out of scope"` · `multiSelect: false`

### Q6. Backtest data sources — what's actually available
- **Recommended default**: all auto-inventoried files + folders shown in the calibration template.
- Alt 1: specific subset (operator names which to include)
- Alt 2: also include external data not yet in the project (operator names sources)
- Alt 3: flag a specific source as known-buggy / partial / unreliable

`header: "Data"` · `multiSelect: true`

(Multi-select lets the operator both confirm sources AND flag unreliability in the same answer.)

### Q7. Risk-tolerance posture — adversarial or happy-path?
- **Recommended default**: ADVERSARIAL. Backtest design assumes the worst-case interpretation of every signal. Defaults err toward conservatism.
- Alt 1: happy-path — believe the data unless it contradicts itself
- Alt 2: asymmetric — adversarial on Layer X, happy-path on Layer Y (operator names which)
- Alt 3: chaos — actively try to break the plan with adversarial perturbations during backtest

`header: "Risk"` · `multiSelect: false`

### Q8. Multi-model voices — who's in the brainstorm pool?
- **Recommended default**: Claude + Codex.
- Alt 1: also Gemini (different model lineage; fed via web-UI prompt)
- Alt 2: also Perplexity (real-time web research strength)
- Alt 3: also a domain-expert human voice (operator or teammate writes Phase 0/1 directly)

`header: "Voices"` · `multiSelect: true`

### Q9. Operator-seeded ideas (Phase 1 contributions)
- **Recommended default**: empty — operator can add at any phase.
- Alt 1: operator has 1+ specific ideas to seed (typed via Other)
- Alt 2: operator wants to be a third Phase 1 voice
- Alt 3: operator has prior teammates' ideas to bring in

`header: "Seed ideas"` · `multiSelect: true`

### Q10. Prior attempts — what we tried that didn't work
- **Recommended default**: nothing — clean slate.
- Alt 1: prior attempts exist (operator describes them via Other)
- Alt 2: prior attempts succeeded but were rolled back (why?)
- Alt 3: prior attempts at adjacent problems exist that should be referenced

`header: "Prior"` · `multiSelect: true`

### Q11. Codebase scope — what folders should the agent map for Phase 0 grounding?
- **Recommended default**: the auto-discovered top-level folders most likely related to the problem area.
- Alt 1: full project (broad sweep)
- Alt 2: tighter — only the immediate problem-area files
- Alt 3: skip — pure-research quest with no existing code, OR team has already aligned on the existing-system model

`header: "Codebase"` · `multiSelect: true`

(Multi-select so operator can pick from both auto-discovered list AND add additional paths.)

### Q12. Regime / context awareness
- **Recommended default**: side quest is regime-agnostic; the data window we have is the data window we test on.
- Alt 1: explicit regime conditioning — split backtest by regime label
- Alt 2: deliberately test against a regime the plan wasn't tuned for (out-of-distribution stress)
- Alt 3: the current operating context is anomalous; deprioritize it in tuning

`header: "Regime"` · `multiSelect: false`

### Q13. What does "good enough" look like?
- **Recommended default**: any plan whose Phase 7 / Phase 8 backtests pass with data-tuned defaults at acceptable false-positive rates is good enough to ship in shadow mode.
- Alt 1: specific quantitative bar — operator names a number ("> +15% lift on primary metric, or no ship")
- Alt 2: specific deadline — ship by date or defer to next quest
- Alt 3: must beat a specific named baseline (not just "the current system")

`header: "Bar"` · `multiSelect: false`

## Format for the mission log

Operator's responses get written to `phase_-1_calibration.md` in this shape:

```markdown
# phase_-1_calibration

Operator: <name>
Date: <iso>

## Q1. Primary success metric
[selected option label, with custom text if "Other"]

## Q2. Kill criterion
[...]

... (and so on for Q3-Q13)

## Operator additions
- <free-form additional context>
```

## Hard rules

- **All 13 questions must be touched.** Even when the operator hits "Recommended" for everything, the structured pass surfaces edge cases an open-ended prompt would miss. If a question is genuinely n/a for this quest, write "n/a" with a one-line reason rather than leaving blank.
- **Overrides bind downstream phases.** If operator overrides Q4 ("challenge the assumption that <X>"), Phase 4's outside-the-box prompt MUST include that assumption in the EXCLUDED-from-Round-2 list and the Phase 0 prompt MUST surface it as something models can question.
- **The calibration file is append-only along with the rest of the mission log.** If the operator changes their mind mid-quest, append a new section dated, don't rewrite.
- **Do NOT skip Q11 (codebase scope) on quests that touch existing code.** Without it, the agent has no shared ground truth for Phase 0 / Phase 1 / Phase 4 plans, and proposals tend to reinvent existing structure or conflict with it.
- **If the operator picks `Other` and types a free-form answer, capture it verbatim** in `phase_-1_calibration.md`. Do not paraphrase. Free-text overrides are the highest-fidelity signal.
