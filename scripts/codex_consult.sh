#!/usr/bin/env bash
# Side Quest Codex consult helper.
# Usage: codex_consult.sh <prompt-file> [output-file]
#
# Wraps `codex exec` with the right flags + stdin handling. xhigh reasoning,
# read-only sandbox, 7-min ceiling. If output-file is omitted, writes to stdout.

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "usage: codex_consult.sh <prompt-file> [output-file]" >&2
  exit 1
fi

PROMPT_FILE="$1"
OUT_FILE="${2:-}"

if [ ! -f "$PROMPT_FILE" ]; then
  echo "prompt file not found: $PROMPT_FILE" >&2
  exit 1
fi

PROMPT="$(cat "$PROMPT_FILE")"

if [ -n "$OUT_FILE" ]; then
  timeout 420 codex exec --skip-git-repo-check --sandbox read-only "$PROMPT" \
    </dev/null > "$OUT_FILE" 2>&1
  echo "codex output -> $OUT_FILE" >&2
else
  timeout 420 codex exec --skip-git-repo-check --sandbox read-only "$PROMPT" \
    </dev/null
fi
