# Side Quest

A Claude Code skill for **structured multi-model problem-solving with hardened backtest gates.**

When single-pass thinking has plateaued on a hard problem and you have data to test against, Side Quest runs you through a disciplined two-round brainstorm with multiple AI voices, forces creative divergence between rounds, gates every plan segment behind a *real* backtest (not summary statistics), and synthesizes only what survives into a coherent ship-decision.

It works for **any domain** where replayable data exists — software architecture, ML deployment decisions, infra/SRE, research design, product strategy, trading systems, anywhere a verdict needs more rigor than "this seemed reasonable."

## Marquee features

- **Phase -1 operator calibration** with arrow-key option selection (13 structured questions, multi-select where appropriate, free-text fallback)
- **Questmap** — turns the relevant code, docs, and features into a shared knowledge map so every model in the brainstorm pool argues against the same ground truth ([deep dive](docs/QUESTMAP.md))
- **Two-round brainstorm with hard no-reuse constraint** between rounds
- **Hardened backtest rules** — replay-not-stats, tautology guard, walk-forward validation, ±10% sensitivity rejection, out-of-regime slice required, reconstruction-substrate validation
- **Multi-voice synthesis** — Claude + Codex + optional Gemini / Perplexity via web-UI prompt pattern
- **Quest tree** — parent / child / sibling relationships with no-reuse propagation; cross-family meta-synthesis (Phase 10)
- **Per-quest verdict types** — PASS / WEAKLY_PASS / DROP / FRAMEWORK_RESERVED, with audit trail for reversals

---

## Why this skill exists

Most "AI brainstorm" workflows fail in one of three ways:

1. **They converge too fast.** A single model proposes one shape, the operator rubber-stamps it, the answer is the path of least resistance.
2. **They confuse plausibility for evidence.** "The framework is sound" gets used as proof the framework works. Untested architectural claims get shipped.
3. **They drift.** A clever side investigation produces a plan that doesn't serve the original goal anymore.

Side Quest fixes all three:

- **Forced divergence**: Round 2 cannot reuse anything from Round 1. Not the mechanism, not the metaphor, not the data slice. The constraint is a search-space expander.
- **Replay-not-stats backtests**: every plan segment that affects per-instance behavior must be replayed through the proposed mechanism instance-by-instance. Aggregate stats on existing labels are a description, not a test.
- **Main-quest discipline**: every phase explicitly references the project's overall goal. If the side quest produces a plan that doesn't advance the main quest, the side quest failed regardless of how clever the plan is.
- **Hardened verdict gates**: walk-forward validation, ±10% sensitivity rejection (>20% degradation = overfit), tautology guard, sample-size gate at design time, out-of-regime/adversarial slice required.
- **Reconstruction-substrate paranoia**: if your backtest reconstructs lifecycle/event/sequence boundaries from raw data, validate that reconstruction against an authoritative event ledger before declaring a verdict. A plan can pass with bad substrate and reverse to DROP when the substrate is fixed.

---

## How it works

### The phase flow

```
Phase -1: Operator calibration  (13 structured questions, agent uses AskUserQuestion)
   ↓
Phase 0:  Questmap (if applicable — shared knowledge map) + each model's independent self-framing
   ↓
Phase 1:  Each voice proposes a plan + success criteria (Round 1)
   ↓
Phase 2:  Decompose plans, brainstorm each step, BACKTEST under hardened rules
   ↓
Phase 3:  First analysis — what worked / what didn't, and why
   ↓
Phase 4:  Outside-the-box brainstorm (Round 2) — NO REUSE from Round 1
   ↓
Phase 5:  Decompose Round 2 + BACKTEST again, no duplicate thoughts within round
   ↓
Phase 6:  Second analysis
   ↓
Phase 7:  Synthesis — pool only what works, build coherent plan
   ↓
Phase 7.5: Spawn decisions — for each unshipped item: SPAWN_CHILD / DROP / FRAMEWORK_RESERVED
   ↓
[Optional]
Phase 8:   Backtest redo (when Phase 7 verdicts need re-validation under hardened rules)
Phase 9:   Re-synthesis with the redo's data-tuned defaults
Phase 10:  Meta-synthesis across multiple completed quests in the same family
```

### The mission log

Every quest creates an append-only directory:

```
<quest-dir>/
├── MAIN_QUEST.md            # the overall project goal — never overwrite
├── PROBLEM.md               # what triggered this quest
├── phase_-1_calibration.md  # operator's answers to the 13 calibration questions
├── questmap/                # (optional) shared knowledge map for Phase 0 grounding
│   ├── MAP.md
│   ├── graph.json           # (graphify backend only)
│   └── index.md             # (graphify backend only)
├── phase_0_<model>.md       # per-model self-framing
├── phase_1_<model>.md       # Round 1 plans
├── phase_2_<model>.md       # decomposition + backtest results
├── phase_3_analysis.md
├── phase_4_<model>.md       # Round 2 plans (no reuse)
├── phase_5_<model>.md       # Round 2 decomposition + backtest
├── phase_6_analysis.md
├── phase_7_synthesis.md     # final pooling pass
├── phase_7.5_spawn_decisions.md
├── PLAN.md                  # the single coherent plan that ships
└── DISCARD.md               # rejected ideas + rationale (load-bearing context)
```

### Multi-model voice pool

The skill is built for **Claude + Codex** by default, with optional voices via web-UI:

- **Claude (you)**: handles all phases inline as the orchestrating agent.
- **Codex (CLI)**: invoked via `scripts/codex_consult.sh` for parallel Phase 0 / 1 / 4 framings.
- **Gemini, Perplexity, Kemi, etc.**: invoked via a single self-contained `UI_PROMPT.md` the operator pastes into the model's web UI. Their responses get pasted back. Stub helpers (`scripts/gemini_consult.sh`, `scripts/perplexity_consult.sh`) exist for environments where those CLIs become available.
- **Domain-expert human voice**: the operator can be a third Phase 0 / Phase 1 voice directly.

The operator picks voices in Phase -1 Q8. More voices = wider search. Single-voice degraded mode is supported but flagged in the mission log.

### The hardened backtest rules

Every plan segment that affects per-instance behavior must satisfy ALL of these to enter the final plan:

| Rule | What it catches |
|---|---|
| **Replay, not summary stats** | Plans that "looked good in aggregate" but fail per-instance |
| **Tautology guard** | Trigger and outcome from the same metric (the plan can't be wrong by construction) |
| **Coverage** | "Tested on the easy cases" |
| **Sample-size gate at design time** | Verdict-time discoveries that N is too thin |
| **Walk-forward, not random split** | Time-series leakage |
| **Defaults from data, not intuition** | "We picked 0.5 because it sounded round" |
| **±10% sensitivity rejection** | Overfit knife-edge optima (degradation > 20% = reject) |
| **Out-of-regime / adversarial slice** | Plans tuned only on the friendly slice of history |
| **Reconstruction substrate validation** | Verdicts that depend on inferred boundaries that don't match authoritative event ledgers |

Plans that fail any of these get DROPPED or demoted to FRAMEWORK_RESERVED (positive direction, thin sample, awaits more evidence).

---

## Installation

Side Quest is a Claude Code skill. To install it:

1. Clone or copy the `side-quest/` directory into your skills location:

   - **User-level skills** (available in all projects): `~/.claude/skills/side-quest/`
   - **Project-level skills** (only this project, version-controlled): `<project-root>/.claude/skills/side-quest/`

2. Make the helper scripts executable:

   ```bash
   chmod +x ~/.claude/skills/side-quest/scripts/*.sh
   ```

3. Optional dependencies:

   - **Codex CLI** (`codex`) — for the second model voice. The skill works without Codex but flags the gap. Get it from [openai/codex](https://github.com/openai/codex).
   - **Gemini CLI / Perplexity CLI** — supported via stub wrappers, but most users invoke those models through their web UIs.
   - **graphify (or compatible knowledge-graph tool)** — upgrades questmap from native-lite (bundled fallback: file inventory + grep-extracted symbols) to a full knowledge graph with community detection, edge audit trail, and persistent cross-session storage. See [`docs/QUESTMAP.md`](docs/QUESTMAP.md) for setup.

4. Verify discovery: in Claude Code, type `/sidequest` or any prompt containing "side quest". The skill should be invoked.

---

## Quick start

```bash
# 1. Initialize a new quest (in your project root):
~/.claude/skills/side-quest/scripts/init_quest.sh "your-problem-slug"

# 2. The agent will guide you through Phase -1 calibration interactively
#    using arrow-key option selection (via the AskUserQuestion tool).
#    For each of 13 questions: Option 1 is the recommended default,
#    Options 2-4 are the most-common alternatives, you can also type Other.

# 3. The agent runs questmap to build a shared knowledge map of the chosen scope:
#    QUEST_DIR=<quest-dir> ~/.claude/skills/side-quest/scripts/questmap.sh src/ docs/
#    Uses graphify if installed; falls back to bundled native-lite backend.

# 4. Phase 0 framing happens for each voice in the pool, referencing the questmap.

# 5. The agent walks you through Phases 1-7 iteratively, writing each
#    phase's outputs to the mission log as it goes.

# 6. The final plan lives at <quest-dir>/PLAN.md
```

For a worked end-to-end example, see [`docs/EXAMPLE.md`](docs/EXAMPLE.md).

---

## Configuration

### Quest root location

By default, quests are created at `<project-root>/data/side_quests/<slug>-YYYYMMDD/`.

If your project uses a different convention, override via env vars:

```bash
QUEST_ROOT=path/to/your/quest/dir init_quest.sh "my-quest"
PROJECT_ROOT=/explicit/project/root init_quest.sh "my-quest"
```

`PROJECT_ROOT` is autodetected by walking up from `pwd` looking for: `.git`, `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `pom.xml`, or `build.gradle`.

### Codex consult settings

The Codex CLI wrapper (`scripts/codex_consult.sh`) uses:

- `xhigh` reasoning level (default; appropriate for this work)
- `read-only` sandbox (safe — no file modification)
- 7-minute timeout (configurable in the script)
- `</dev/null` stdin redirect (prevents a known hang footgun)

If you need different defaults, copy the script and modify your local copy.

---

## Hard rules (the load-bearing constraints)

These are enforced throughout the skill and documented in [`SKILL.md`](SKILL.md):

1. Never skip Phase -1 or Phase 0
2. Round 2 cannot reuse anything from Round 1
3. No duplicate thoughts within Round 2
4. Every plan segment must be backtested with a real test (the 8 sub-rules of "real test")
5. The mission log is append-only
6. Surface the main quest at every phase
7. Synthesis only KEEPs ideas with passing real backtests + data-tuned defaults
8. Plans must balance defensive and offensive layers, or justify why one is enough
9. Backtests must include at least one out-of-regime or adversarial slice
10. Null backtest results lead to DROP, not framework_reserved
11. If Phase 2/3 reveals Phase 0 framing was inverted, document and consider RESETTING
12. Multi-model voice diversity matters — pick voices in Phase -1 Q8
13. Quest tree relationships are explicit; the no-reuse rule propagates across families
14. Reconstruction substrate is load-bearing — validate against boundary truth before relying on derived data

---

## When to use it

✅ **Good fit:**
- A hard problem keeps cycling through the same handful of ideas without resolution
- You have empirical / replayable data to test hypotheses against
- The work serves a clear overall project goal you don't want to lose sight of
- You want multiple AI perspectives but need them to actually disagree, not echo
- A previous one-pass attempt produced a plausible-looking plan you don't quite trust

❌ **Wrong fit:**
- The problem is small enough for a 5-minute decision (use a single-pass)
- You have no testable data and no realistic way to backtest (the skill's value is in the gates)
- You already know the answer and just want execution help (use a different skill)
- The problem is pure execution with no design ambiguity

---

## File map

```
side-quest/
├── README.md                 ← this file
├── SKILL.md                  ← the methodology, hard rules, phase definitions
├── scripts/
│   ├── init_quest.sh         ← scaffold a mission log
│   ├── questmap.sh           ← build a knowledge map for Phase 0 grounding (graphify or native-lite)
│   ├── codex_consult.sh      ← invoke Codex CLI
│   ├── gemini_consult.sh     ← Gemini stub
│   └── perplexity_consult.sh ← Perplexity stub
├── resources/
│   ├── prompts/              ← reusable prompt templates per phase
│   │   ├── phase_-1_operator_calibration.md  ← 13 questions with option lists
│   │   ├── phase_0_framing.md
│   │   ├── phase_1_oversight.md
│   │   ├── phase_2_decompose_test.md         ← hardened backtest rules
│   │   ├── phase_3_analysis.md
│   │   ├── phase_4_outside_box.md
│   │   ├── phase_5_decompose_test_round2.md
│   │   ├── phase_6_analysis_round2.md
│   │   ├── phase_7_synthesis.md
│   │   ├── phase_7.5_spawn_decision.md
│   │   └── phase_10_meta_synthesis.md
│   └── templates/
│       └── mission_log.md.template
└── docs/
    ├── EXAMPLE.md            ← worked end-to-end example (generic web-app domain)
    └── QUESTMAP.md           ← questmap feature deep dive + backend integration
```

---

## Contributing

Contributions welcome. Please:

1. **Don't soften the hard rules.** They exist because each one was learned from a failed quest. If you think a rule is wrong, open an issue with the failure mode it would have caught — not a PR removing it.
2. **New voice integrations**: the skill assumes voices have a "send a self-contained prompt, get a self-contained response" interface. PRs adding new voice helpers should follow the `scripts/<model>_consult.sh` pattern.
3. **New prompt templates**: phase prompts live in `resources/prompts/`. Per-domain customizations go in user/project skills, not the upstream prompts.
4. **Examples**: `docs/EXAMPLE.md` is intentionally domain-agnostic. Domain-specific examples (trading, ML, infra, etc.) are welcome as additional `docs/EXAMPLE_<domain>.md` files but should not replace the generic one.

### Reporting failure modes

If you run a quest and the skill produces a bad outcome, the most useful contribution is documenting *which rule should have caught it but didn't*. The "Failure modes to avoid" table in `SKILL.md` is the canonical list; add to it.

---

## License

MIT (see `LICENSE`). Use freely, modify freely, ship without attribution if you want — but tell us if it works for you, that's how the rules get refined.

---

## Acknowledgments

Side Quest emerged from a real production research workflow where each of the following failure modes happened in sequence:

- 5 independent AI voices converged on a mechanism that empirically didn't work — multi-voice agreement is not validation
- A 2-voice synthesis produced a "WEAKLY_PASS" verdict that **reversed to DROP** after an external audit caught a reconstruction-substrate flaw — the backtest had been measuring against inferred boundaries that didn't match the authoritative event ledger
- A "narrow targeted offense beats broad defense" pattern was claimed based on the (now reversed) lift, then had to be retracted

Each of those failure modes became a hard rule (4-replay-not-stats, 14-substrate-validation, and the no-architectural-plausibility-without-evidence guard in synthesis, respectively). The methodology is the residue of those failures, not their absence.
