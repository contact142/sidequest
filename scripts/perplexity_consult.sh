#!/usr/bin/env bash
# Side Quest Perplexity consult helper.
# Usage: perplexity_consult.sh <prompt-file> [output-file]
#
# Perplexity's distinctive contribution: real-time web context.
# Use for queries that benefit from current news, market data,
# regulatory events, on-chain analysis, or recent community discussion.
#
# Configuration: set PERPLEXITY_API_KEY in env, or have `pplx` CLI
# installed. If neither is present, exits 0 with a missing-voice marker.

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "usage: perplexity_consult.sh <prompt-file> [output-file]" >&2
  exit 1
fi

PROMPT_FILE="$1"
OUT_FILE="${2:-/dev/stdout}"

if [ ! -f "$PROMPT_FILE" ]; then
  echo "prompt file not found: $PROMPT_FILE" >&2
  exit 1
fi

PROMPT="$(cat "$PROMPT_FILE")"

# Try CLI first, then API.
if command -v pplx >/dev/null 2>&1; then
  timeout 420 pplx ask "$PROMPT" </dev/null > "$OUT_FILE" 2>&1
elif [ -n "${PERPLEXITY_API_KEY:-}" ]; then
  curl -sS https://api.perplexity.ai/chat/completions \
    -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg p "$PROMPT" '{
      model: "llama-3.1-sonar-large-128k-online",
      messages: [{role: "user", content: $p}]
    }')" > "$OUT_FILE"
else
  cat > "$OUT_FILE" <<EOF
# Perplexity consult — UNAVAILABLE
Neither \`pplx\` CLI nor PERPLEXITY_API_KEY env var found. Operator
selected Perplexity in Phase -1 Q8 but the tooling is not configured.
This phase's Perplexity voice is missing — flag in the mission log
per SKILL.md hard rule on unavailable models.

Configure: install \`pplx\` CLI OR set PERPLEXITY_API_KEY in env.
EOF
fi
