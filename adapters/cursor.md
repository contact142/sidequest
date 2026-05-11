# Cursor adapter

Cursor doesn't have a native "skill" concept like Claude Code, but its rules-file mechanism (`.cursorrules` or `.cursor/rules/*.mdc`) covers the same ground: persistent instructions the agent loads at the start of every chat.

## Install

```bash
# 1. Clone the repo somewhere convenient:
git clone https://github.com/contact142/sidequest ~/sidequest
chmod +x ~/sidequest/scripts/*.sh

# 2. Add a Cursor rules file that points the agent at SKILL.md.
#    Project-level rules go in .cursor/rules/sidequest.mdc:
mkdir -p .cursor/rules
cat > .cursor/rules/sidequest.mdc <<'EOF'
---
description: "Multi-model collaborative problem-solving with hardened backtest gates. Invoke when the user says 'side quest', when a problem stalls single-pass thinking, or when you have testable data and want multiple model perspectives."
globs:
  - "**/*"
alwaysApply: false
---

# Side Quest

When the user invokes side quest, follow the methodology in
~/sidequest/SKILL.md and use the scripts at ~/sidequest/scripts/.

Begin by running:
  ~/sidequest/scripts/init_quest.sh <slug>

Then walk through Phase -1 → Phase 7 as described in SKILL.md.

For Phase -1 calibration, render each of the 13 questions as a
numbered Markdown prompt (since Cursor doesn't have AskUserQuestion-
equivalent structured input). The shape is:

  Q<n>. <question> (multi-select OK if applicable; reply with numbers)
    1. (Recommended) <default>
    2. <alt 1>
    3. <alt 2>
    4. <alt 3>
    5. Other (type your own)

Read the operator's reply, write it verbatim into
<quest-dir>/phase_-1_calibration.md, then proceed to the next batch
of questions.
EOF
```

## Invoke

Type "side quest" or "run a side quest on X" in Cursor chat. The agent should pick up the rules file and start the workflow.

## Phase -1 rendering

Cursor doesn't have an arrow-key picker. The agent renders each question as a numbered Markdown list and waits for the operator to reply with comma-separated numbers (e.g. `1` or `2,4`) or `Other: <text>`.

## Phase 0 questmap

The agent invokes `~/sidequest/scripts/questmap.sh` directly via Cursor's bash tool. Output lands at `<quest-dir>/questmap/MAP.md`.

## Codex / Gemini / Perplexity consult

Same as Claude Code adapter — the scripts are CLI-only, no agent-specific integration needed.

## Things Cursor does differently

- **No native skill discovery**: the rules file must explicitly tell the agent to use SKILL.md. If you remove the rules file, the agent won't auto-invoke.
- **No structured-input tool**: Phase -1 is plain numbered prompts, slightly more friction than Claude Code's arrow-key picker.
- **Chat-side rendering**: questmap output may render larger inline; consider asking the agent to summarize MAP.md after generating rather than dumping it in chat.
