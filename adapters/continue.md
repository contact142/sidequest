# Continue.dev adapter

Continue.dev's custom prompt + custom command facility maps well onto Side Quest.

## Install

```bash
git clone https://github.com/contact142/sidequest ~/sidequest
chmod +x ~/sidequest/scripts/*.sh
```

Then add a custom command to your Continue config (`~/.continue/config.json` or `.continue/config.yaml`):

```yaml
customCommands:
  - name: sidequest
    description: "Run a Side Quest: multi-model brainstorm + backtest"
    prompt: |
      Read the methodology in ~/sidequest/SKILL.md.

      Then start a Side Quest on the user's current problem. Use
      ~/sidequest/scripts/init_quest.sh to scaffold the quest dir.

      For Phase -1 calibration, render each question as a numbered
      Markdown prompt in chat (Continue supports inline option lists
      via the {{{input}}} template — use it if your config wires it up).

      Walk through Phase -1 → Phase 7. Write each phase's output to
      the mission log before moving on.
```

## Invoke

In Continue chat: `/sidequest <problem statement>`

## Phase -1 rendering

Continue can render inline input fields if you wire `{{{input}}}` templates into the custom command. Otherwise the agent falls back to numbered Markdown prompts (operator replies with numbers, same as Aider/Codex CLI).

## Phase 0 questmap

Continue invokes `~/sidequest/scripts/questmap.sh` via its terminal-command tool. The MAP.md is then referenced by subsequent phase prompts.

## Voice pool

Continue's `models` config typically lists multiple models (e.g., Claude + GPT + a local model). Use those as your voice pool. For each voice in Phase 0 / 1 / 4, the agent should switch models via Continue's model-selector for the duration of that voice's call, then switch back to the orchestrator model.

## Things Continue does differently

- **Multi-model native**: easier to add a third or fourth voice than in single-model agents — just configure them and invoke.
- **Local-model option**: if you've got an ollama-served local model in your config, it can serve as an extra cheap-and-fast voice (lower-quality, useful as a sanity-check sibling).
- **No file-watch hooks for auto-Phase-N progression**: you drive the phase progression manually via successive `/sidequest` invocations or the agent's `continue` button between phases.
