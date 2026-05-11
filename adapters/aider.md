# Aider adapter

Aider doesn't have skill discovery, but it's good at following multi-step instructions from a markdown file you `/add` to the context.

## Install

```bash
git clone https://github.com/contact142/sidequest ~/sidequest
chmod +x ~/sidequest/scripts/*.sh
```

## Invoke

```bash
cd <your-project>
aider --read ~/sidequest/SKILL.md
```

Then in the chat:

```
run a side quest on <problem statement>
```

Aider reads SKILL.md (from `--read` so it's in context but not editable), invokes `~/sidequest/scripts/init_quest.sh`, and walks through the phases.

## Phase -1 rendering

Aider doesn't have an arrow-key picker. It renders each question as a numbered prompt and waits for your reply:

```
Q1. Primary success metric — how do we know this side quest worked?
  1. (Recommended) The metric named in MAIN_QUEST.md
  2. A different headline metric (type via Other)
  3. A leading indicator metric (faster signal)
  4. A composite metric (you name components)
  5. Other (type your own)

> 1
```

Reply with numbers, comma-separated for multi-select, or `Other: <text>`.

## Phase 0 questmap

Aider invokes `~/sidequest/scripts/questmap.sh` via its shell-command capability. Output lands at `<quest-dir>/questmap/MAP.md`. Aider can then `/add` that file to the chat context so subsequent Phase 1/4 plans reference it.

## Voice pool

Aider is a single-model agent (configured to one of: GPT, Claude, Gemini, local models). For multi-voice quests:

- The orchestrating Aider session IS one voice
- Use `~/sidequest/scripts/codex_consult.sh` to call Codex for a second voice
- Use web UIs for additional voices via the `UI_PROMPT.md` paste-and-reply pattern

If your Aider is configured to use Claude, the second-voice slot naturally falls to Codex (different model, different reasoning lineage). If your Aider uses GPT, consider Claude as the second voice via the `anthropic` CLI.

## Things Aider does differently

- **Edit-first interface**: Aider is built around making code changes, so be explicit that Side Quest is research-mode for Phases -1 through 6. Use `/ask` mode or tell Aider "don't make any code edits this phase, just write to the quest directory."
- **File-context budget**: don't `/add` the entire mission log directory; just `/add` the current phase's prompt + the questmap MAP.md.
- **Git integration**: Aider commits as it goes by default. Either disable autocommit during the quest (`--no-auto-commits`) or expect a flurry of small commits.
