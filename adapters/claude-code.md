# Claude Code adapter

Side Quest runs natively as a Claude Code skill — auto-discovery via the YAML frontmatter in `SKILL.md`, arrow-key Phase -1 calibration via the `AskUserQuestion` tool, slash-command trigger.

## Install (personal skill, all projects)

```bash
mkdir -p ~/.claude/skills
git clone https://github.com/contact142/sidequest ~/.claude/skills/side-quest
chmod +x ~/.claude/skills/side-quest/scripts/*.sh
```

## Install (project-level, committed to your repo)

```bash
git clone https://github.com/contact142/sidequest .claude/skills/side-quest
chmod +x .claude/skills/side-quest/scripts/*.sh
echo ".claude/skills/side-quest/data/" >> .gitignore  # if any quest output lands here
git add .claude/skills/side-quest
```

## Invoke

Any of these triggers the skill:

- Type `/sidequest` (slash command form, if you've enabled the alias)
- Type "side quest" or "let's run a side quest" in chat
- The agent invokes it via the `Skill` tool when your task description matches the skill's description field

## Phase -1 rendering

Claude Code reads the SKILL.md instructions and uses the `AskUserQuestion` tool for Phase -1 calibration. The operator gets:

- Arrow-key navigation between options
- Space-bar to toggle multi-select
- Enter to confirm
- Automatic `Other` option for typed custom answers

13 questions are batched into 4 calls (the tool's per-call cap is 4). Operator answers in ~2 minutes.

## Phase 0 questmap

The agent runs `scripts/questmap.sh` against the codebase scope chosen in Phase -1 Q11. Output lands at `<quest-dir>/questmap/MAP.md` and is auto-referenced by Phase 0 / 1 / 4 prompts.

If `graphify` is installed and on PATH, the agent uses it as the questmap backend (full knowledge graph + community detection). Otherwise the bundled native-lite backend runs.

## Codex consult

If you have the Codex CLI installed, the agent runs `scripts/codex_consult.sh` for each phase that needs a second voice. The wrapper handles the `--skip-git-repo-check --sandbox read-only </dev/null` stdin-hang footgun.

## Web-UI voices (Gemini / Perplexity / Kemi / other)

When Phase -1 Q8 includes web-UI voices, the agent writes a self-contained `<quest-dir>/UI_PROMPT.md` and asks you to paste it into the model's web interface. You paste the response back into chat; the agent writes it to `<quest-dir>/phase_<n>_<voice>.md`.

## What you don't need to do

- Don't manually invoke `init_quest.sh` — the agent does it
- Don't manually generate the questmap — the agent does it after Q11
- Don't construct the UI prompts — the agent does it
- Don't track which phase you're on — the agent maintains the mission log

## Permission prompts you'll see

First-time use will prompt for permission on:

- `init_quest.sh` (creates files)
- `questmap.sh` (reads files, runs grep/find)
- `codex_consult.sh` (invokes external CLI)
- Each subagent dispatch when the agent uses parallel voices

Approve once with "always allow for this session" to avoid friction.
