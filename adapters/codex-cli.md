# Codex CLI adapter (standalone)

Run Side Quest with Codex CLI as the orchestrating agent (not just as a consult voice). Codex doesn't have a skill discovery mechanism, so you invoke it explicitly with the SKILL.md instructions in the prompt.

## Install

```bash
# 1. Clone the repo:
git clone https://github.com/contact142/sidequest ~/sidequest
chmod +x ~/sidequest/scripts/*.sh

# 2. (Optional) Add a shell alias for convenience:
echo 'alias sidequest="codex exec --skip-git-repo-check \"\$(cat ~/sidequest/SKILL.md) Run a Side Quest on the following problem:\"' >> ~/.bashrc
```

## Invoke

Two patterns:

### Pattern A — single command kicks off the whole quest

```bash
codex exec --skip-git-repo-check "$(cat ~/sidequest/SKILL.md)

Run a Side Quest on this problem:

<paste your problem statement here>

Use ~/sidequest/scripts/init_quest.sh to scaffold the quest directory.
For Phase -1 calibration, render each question as a numbered prompt
in stdout; I'll reply with numbers. Continue through Phase 7."
```

Codex follows the SKILL.md instructions, scaffolds the quest, asks you the Phase -1 questions in stdout, and proceeds.

### Pattern B — phase-by-phase invocation

```bash
# Phase -1:
codex exec "$(cat ~/sidequest/resources/prompts/phase_-1_operator_calibration.md)
The quest dir is /path/to/quest. Ask me each question, write answers to
phase_-1_calibration.md, then stop."

# Phase 0 (Codex framing):
~/sidequest/scripts/codex_consult.sh ~/sidequest/resources/prompts/phase_0_framing.md \
  /path/to/quest/phase_0_codex.md

# Phase 0 (second voice — e.g., GPT via web UI):
# 1. Cat the same prompt + your quest context
# 2. Paste into ChatGPT web UI
# 3. Paste response back into /path/to/quest/phase_0_gpt.md

# Phase 1 onwards: same pattern, one phase prompt at a time.
```

Pattern B is more work per phase but gives finer control — useful when you want to fiddle with phase prompts before each run.

## Phase -1 rendering

Codex renders Phase -1 as a numbered Markdown prompt in stdout. You reply with comma-separated numbers (e.g. `1` or `2,4`) or `Other: <text>`.

## Phase 0 questmap

Codex invokes `~/sidequest/scripts/questmap.sh` directly. If `graphify` is on PATH, it uses that backend; otherwise native-lite.

## Voice pool

By default the orchestrating Codex IS the only voice. For multi-voice quests, the orchestrating Codex calls out to:

- A second Codex run with a different prompt (parallel voice via `codex exec` subprocess)
- A Claude CLI if you have one (e.g. `anthropic` CLI)
- Web UIs (Gemini, Perplexity, ChatGPT) via `UI_PROMPT.md` paste-and-reply

The scripts/*_consult.sh wrappers each have the right invocation flags.

## Things Codex CLI does differently

- **No skill auto-discovery**: you invoke explicitly with the SKILL.md content in the prompt.
- **No native structured input**: Phase -1 is plain numbered prompts.
- **stdin-handling footgun**: always use `</dev/null` when launching subprocess Codex from a Codex orchestrator (`codex_consult.sh` already does this).
- **Sandboxing**: `--sandbox read-only` is fine for Side Quest's research-only phases. Switch to `--sandbox workspace-write` only when you reach a phase that needs to write files outside the quest dir.
