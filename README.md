# Side Quest

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Built for](https://img.shields.io/badge/built%20for-Claude%20Code-orange)
![Status](https://img.shields.io/badge/status-v1.0-brightgreen)
![PRs](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)

**Structured multi-model problem-solving for Claude Code, with hardened backtest gates.**

When single-pass thinking has plateaued and you have data to test against, Side Quest runs you through a disciplined two-round brainstorm with multiple AI voices, forces creative divergence between rounds, gates every plan segment behind a *real* backtest (not summary statistics), and synthesizes only what survives into a coherent ship-decision.

Works for **any domain** with replayable data — software architecture, ML deployment, infra/SRE, research design, product strategy, trading systems.

---

## What Phase -1 looks like

The agent calibrates the quest with you via arrow-key option selection (the `AskUserQuestion` tool, rendered in your terminal):

```
? Which assumptions should we explicitly CHALLENGE?  (space to select, enter to confirm)

  ◉ None — let Phase 0 surface them                              (Recommended)
> ◯ "Bigger is better" (more features, more data, more coverage)
  ◯ "Simpler is better" (or its inverse)
  ◯ "Recent is more relevant" (temporal weighting)
  ◯ Other (type your own)

  ↑/↓ navigate · space toggle · ↵ confirm · esc cancel
```

13 questions across 4 batches. Each one has a recommended default as Option 1, common alternatives as Options 2-4, automatic `Other` for free text. Multi-select where the answers compose (assumptions to challenge, voices to include, data sources, codebase scope).

---

## Marquee features

- **Phase -1 operator calibration** — 13 structured questions with arrow-key selection, multi-select where appropriate, free-text fallback
- **Questmap** — turns the relevant code/docs into a shared knowledge map so every model in the pool argues against the same ground truth ([deep dive](docs/QUESTMAP.md)). Plugs into `graphify` for full knowledge graph + community detection + edge audit trail; falls back to bundled native-lite (file inventory + grep symbols + import edges)
- **Two-round brainstorm with hard no-reuse constraint** between rounds — forces creative divergence
- **Hardened backtest rules** — replay-not-stats, tautology guard, walk-forward validation, ±10% sensitivity rejection (>20% degradation = overfit), out-of-regime slice required, reconstruction-substrate validation
- **Multi-voice synthesis** — Claude + Codex via CLI; Gemini / Perplexity / others via web-UI prompt pattern
- **Quest tree** — parent / child / sibling relationships with no-reuse propagation; cross-family meta-synthesis at Phase 10
- **Verdict types** — `PASS` / `WEAKLY_PASS` / `DROP` / `FRAMEWORK_RESERVED`, with audit trail for reversals

---

## Why this skill exists

Most "AI brainstorm" workflows fail in one of three ways:

1. **They converge too fast** — single model, single shape, single answer.
2. **They confuse plausibility for evidence** — "the framework is sound" gets used as proof the framework works.
3. **They drift** — a clever side investigation produces a plan that doesn't serve the original goal anymore.

Side Quest fixes all three by making creative divergence mandatory (Round 2 no-reuse), making backtests structural (not vibes-driven), and making the main quest re-referenced at every phase.

The methodology is the residue of real failure modes — see the [Acknowledgments](#acknowledgments).

---

## Install

```bash
# Personal skill (available in all projects):
mkdir -p ~/.claude/skills
git clone https://github.com/contact142/sidequest ~/.claude/skills/side-quest
chmod +x ~/.claude/skills/side-quest/scripts/*.sh

# Or project-level (committed to your repo):
git clone https://github.com/contact142/sidequest .claude/skills/side-quest
```

Optional dependencies:

- **Codex CLI** — second model voice. [github.com/openai/codex](https://github.com/openai/codex). Skill works without it but flags the gap.
- **`graphify` or compatible knowledge-graph tool** — upgrades questmap to full graph + community detection. See [`docs/QUESTMAP.md`](docs/QUESTMAP.md).

Verify discovery: in Claude Code, type `/sidequest` or any prompt containing "side quest". The skill should be invoked.

---

## Quick start

```bash
# 1. Initialize a quest:
~/.claude/skills/side-quest/scripts/init_quest.sh "your-problem-slug"

# 2. The agent runs Phase -1 calibration interactively (arrow-key UI).

# 3. The agent runs questmap to build the shared knowledge map:
QUEST_DIR=<quest-dir> ~/.claude/skills/side-quest/scripts/questmap.sh src/ docs/

# 4. The agent walks you through Phases 0-7 (and optionally 7.5, 8, 9, 10),
#    writing each phase's outputs to the mission log as it goes.

# 5. Final plan lives at <quest-dir>/PLAN.md
```

Worked end-to-end example: [`docs/EXAMPLE.md`](docs/EXAMPLE.md).

---

## When to use it

✅ A hard problem keeps cycling through the same ideas without resolution
✅ You have empirical / replayable data to test hypotheses against
✅ Work serves a clear overall project goal you don't want to drift from
✅ You want multiple AI perspectives that actually disagree, not echo
✅ A previous one-pass attempt produced a plausible-looking plan you don't quite trust

❌ Small enough for a 5-minute decision
❌ No testable data and no realistic path to backtest
❌ Pure execution with no design ambiguity

---

## File map

```
side-quest/
├── README.md                ← this file
├── SKILL.md                 ← methodology, 14 hard rules, phase definitions
├── LICENSE                  ← MIT
├── scripts/
│   ├── init_quest.sh        ← scaffold a mission log
│   ├── questmap.sh          ← build knowledge map (graphify or native-lite)
│   ├── codex_consult.sh     ← invoke Codex CLI
│   ├── gemini_consult.sh    ← Gemini stub
│   └── perplexity_consult.sh
├── resources/
│   ├── prompts/             ← 11 phase prompt templates
│   └── templates/
└── docs/
    ├── EXAMPLE.md           ← worked end-to-end example
    └── QUESTMAP.md          ← questmap feature deep dive
```

For the methodology, hard rules, phase-by-phase walkthroughs, voice consult patterns, mission log structure, configuration, and failure modes — see [`SKILL.md`](SKILL.md).

---

## Contributing

PRs welcome. Two requests:

1. **Don't soften the hard rules.** Each one was learned from a failed quest. If you think a rule is wrong, open an issue with the failure mode it would have caught — not a PR removing it. The list lives in [`SKILL.md`](SKILL.md#hard-rules).
2. **Domain-specific examples** as additional `docs/EXAMPLE_<domain>.md` files are welcome but should not replace the generic one.

---

## License

[MIT](LICENSE). Use freely, modify freely, ship without attribution if you want — but tell us if it works for you. That's how the rules get refined.

---

## Acknowledgments

Side Quest emerged from a real production research workflow where each of these failure modes happened in sequence:

- 5 independent AI voices converged on a mechanism that empirically didn't work — multi-voice agreement is not validation
- A 2-voice synthesis produced a `WEAKLY_PASS` verdict that **reversed to `DROP`** after an external audit caught a reconstruction-substrate flaw — the backtest had been measuring against inferred boundaries that didn't match the authoritative event ledger
- A "narrow targeted offense beats broad defense" pattern was claimed from the (now-reversed) lift, then had to be retracted

Each became a hard rule. The methodology is the residue of those failures, not their absence.
