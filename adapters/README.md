# Adapters

Per-agent integration guides for Side Quest. The methodology in [`../SKILL.md`](../SKILL.md) is universal; this directory holds the agent-specific glue.

| Agent | Adapter | Notes |
|---|---|---|
| [Claude Code](claude-code.md) | native skill | auto-discovery via SKILL.md YAML; arrow-key Phase -1 |
| [Cursor](cursor.md) | rules-file | `.cursor/rules/sidequest.mdc` points at SKILL.md |
| [Codex CLI](codex-cli.md) | inline prompt | `codex exec` with SKILL.md content; numbered Phase -1 |
| [Aider](aider.md) | `--read` flag | `aider --read SKILL.md`; numbered Phase -1 |
| [Continue.dev](continue.md) | custom command | `customCommands` in config; supports inline inputs |
| [Generic](generic.md) | bash + editor | no agent; manual paste-and-reply with web UIs |

## What an adapter provides

Each adapter explains:

1. **Install** for that agent
2. **Invoke** — how to trigger Side Quest in that environment
3. **Phase -1 rendering** — arrow-key picker vs numbered prompt vs inline inputs
4. **Phase 0 questmap** — how the agent invokes `scripts/questmap.sh`
5. **Voice pool** — how the agent dispatches to multiple models
6. **Things this agent does differently** — quirks worth knowing

## Writing a new adapter

Want to use Side Quest with an agent that isn't listed? PR welcome. Use [`claude-code.md`](claude-code.md) as the template — it's the most fully-realized integration and demonstrates each section. Replace the Claude-specific bits with your target agent's equivalents:

| Claude Code mechanism | Your agent's equivalent |
|---|---|
| YAML frontmatter in SKILL.md | rules file / config / startup prompt |
| `AskUserQuestion` tool | inline input field, structured form, numbered prompt |
| `Skill` tool invocation | slash command, alias, manual prompt |
| Subagent dispatch | parallel CLI subprocess, model-switch in same session |
| Permission prompts | your agent's confirmation UI (if any) |

If your agent has no mechanism for one of these, document that and fall back to the generic-adapter pattern for it.
