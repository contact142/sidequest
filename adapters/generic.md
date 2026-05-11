# Generic adapter (no agent, or unsupported agent)

Side Quest is markdown + shell. If your agent isn't listed in the other adapter docs, or if you just want to drive the workflow as a human with your editor + a couple of LLM web UIs, this is the path.

## Install

```bash
git clone https://github.com/contact142/sidequest ~/sidequest
chmod +x ~/sidequest/scripts/*.sh
```

## The bare workflow

```bash
# 1. Scaffold:
~/sidequest/scripts/init_quest.sh "my-problem-slug"

cd <quest-dir>   # the script prints the path

# 2. Write MAIN_QUEST.md and PROBLEM.md by hand (open in your editor).

# 3. Phase -1: open phase_-1_calibration.md, answer each of the 13 questions.
#    The file is pre-populated with auto-discovered data sources and folders.
#    For each Q, the template gives you the recommended default; override if needed.

# 4. Phase 0 questmap:
~/sidequest/scripts/questmap.sh <scope-path> [scope-path ...]
# Reads <quest-dir>/questmap/MAP.md before Phase 0.

# 5. Phase 0 framing: copy the contents of
#    ~/sidequest/resources/prompts/phase_0_framing.md
#    into TWO different LLM web UIs (e.g. Claude.ai + ChatGPT), one per voice.
#    Add your MAIN_QUEST + PROBLEM + questmap/MAP.md as context to each.
#    Paste each model's response into phase_0_<voice>.md.

# 6. Phase 1 oversight: same pattern with ~/sidequest/resources/prompts/phase_1_oversight.md.

# 7. Phase 2 decompose + backtest: same pattern with
#    ~/sidequest/resources/prompts/phase_2_decompose_test.md.
#    NOTE: this phase requires running backtest code — you write it, the LLMs
#    can suggest the test design, but the test itself runs locally.

# 8. Continue through Phase 3 → Phase 7 the same way.

# 9. Final plan lives at <quest-dir>/PLAN.md (you write this synthesizing the
#    pooled validated ideas per the Phase 7 prompt).
```

## What you gain by doing it manually

- **Total visibility into what each voice said and how synthesis happened.** No agent abstractions, no hidden context windows. Every phase output is a markdown file you can re-read.
- **Model freedom.** Mix and match: Claude.ai for one voice, ChatGPT for another, Gemini for a third, a teammate's written input as a fourth.
- **No tool budget concerns.** The agent isn't burning context tokens orchestrating; you're.

## What you lose

- **The orchestration ergonomics.** Every paste-and-reply is friction.
- **Auto Phase-N tracking.** You have to remember which phase you're on.
- **Auto-prompt-construction.** The phase prompts have `{{MAIN_QUEST}}` / `{{PROBLEM}}` placeholders — you substitute these by hand.

## When this is the right choice

- You don't trust any single agent to orchestrate a high-stakes research workflow
- You want a paper trail with literal LLM-UI screenshots / chat-thread URLs
- You're running with a model that doesn't have a local CLI / agent integration (e.g. a research-only model accessed via API or web only)
- You're a researcher / scientist who's allergic to magic and wants every step explicit

## Hybrid: agent for some phases, human for others

A common pattern:

- **Claude Code / Cursor / Aider** as the orchestrator for Phase -1, Phase 0, Phase 1, Phase 7 (the agent-friendly framing + write-files phases)
- **You manually** for Phase 2 / Phase 5 backtest design + execution (because you trust your own test code more than the agent's)
- **Web UIs** for the extra voices (Gemini, Perplexity, Kemi) that don't have local CLIs

This hybrid works because Side Quest's mission log is just files — anyone (agent or human) can write to them.
