#!/usr/bin/env bash
# Side Quest Gemini consult helper.
# Usage: gemini_consult.sh <prompt-file> [output-file]
#
# Wraps `gemini` CLI invocation. If the CLI isn't installed or the
# operator hasn't enabled Gemini (Phase -1 Q8), the helper exits 0
# with a marker output saying so — a missing voice should not crash
# the quest, just be flagged.

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "usage: gemini_consult.sh <prompt-file> [output-file]" >&2
  exit 1
fi

PROMPT_FILE="$1"
OUT_FILE="${2:-/dev/stdout}"

if ! command -v gemini >/dev/null 2>&1; then
  cat > "$OUT_FILE" <<EOF
# Gemini consult — UNAVAILABLE
\`gemini\` CLI not found in PATH. Operator selected Gemini in Phase -1
Q8 but the tooling is not installed. This phase's Gemini voice is
missing — flag in the mission log per SKILL.md hard rule on
unavailable models.
EOF
  exit 0
fi

if [ ! -f "$PROMPT_FILE" ]; then
  echo "prompt file not found: $PROMPT_FILE" >&2
  exit 1
fi

# Replace with whatever your gemini CLI invocation is.
# Common forms: `gemini chat --file <prompt>`, `gemini exec --prompt <text>`,
# or piping into `gemini`.
PROMPT="$(cat "$PROMPT_FILE")"
timeout 420 gemini exec "$PROMPT" </dev/null > "$OUT_FILE" 2>&1
