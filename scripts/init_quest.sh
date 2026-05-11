#!/usr/bin/env bash
# Side Quest mission log scaffolder.
# Usage: init_quest.sh <slug>  (e.g. "checkout-flow-redesign")
# Creates: <quest-root>/<slug>-YYYYMMDD/ with all phase files
#
# Quest root resolution (in priority order):
#   1. $QUEST_ROOT environment variable (explicit override)
#   2. <PROJECT_ROOT>/data/side_quests/  if PROJECT_ROOT is set or pwd looks like a project root
#   3. ./.side_quests/  (fallback for any directory)
#
# PROJECT_ROOT resolution:
#   - $PROJECT_ROOT env var, OR
#   - nearest ancestor containing one of: .git, package.json, pyproject.toml, Cargo.toml, go.mod, pom.xml, build.gradle

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "usage: init_quest.sh <slug>" >&2
  echo "  env: QUEST_ROOT=<dir> overrides default location" >&2
  echo "  env: PROJECT_ROOT=<dir> overrides project-root autodetect" >&2
  exit 1
fi

SLUG="$1"
DATE="$(date -u +%Y%m%d)"

# Resolve PROJECT_ROOT if not set
if [ -z "${PROJECT_ROOT:-}" ]; then
  candidate="$(pwd)"
  while [ "$candidate" != "/" ]; do
    for marker in .git package.json pyproject.toml Cargo.toml go.mod pom.xml build.gradle; do
      if [ -e "$candidate/$marker" ]; then
        PROJECT_ROOT="$candidate"
        break 2
      fi
    done
    candidate="$(dirname "$candidate")"
  done
  PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
fi

# Resolve QUEST_ROOT
if [ -z "${QUEST_ROOT:-}" ]; then
  if [ -d "${PROJECT_ROOT}/data" ] || [ -w "${PROJECT_ROOT}" ]; then
    QUEST_ROOT="${PROJECT_ROOT}/data/side_quests"
  else
    QUEST_ROOT="$(pwd)/.side_quests"
  fi
fi

mkdir -p "$QUEST_ROOT"
QUEST_DIR="${QUEST_ROOT}/${SLUG}-${DATE}"

if [ -d "$QUEST_DIR" ]; then
  echo "quest already exists: $QUEST_DIR" >&2
  exit 1
fi

mkdir -p "$QUEST_DIR"

cat > "$QUEST_DIR/MAIN_QUEST.md" <<'EOF'
# Main Quest

(Paste or write the OVERALL PROJECT GOAL here. Every phase of the side quest
must serve this goal. If the side quest produces a plan that does not advance
the main quest, the side quest failed regardless of how clever the plan is.)

EOF

cat > "$QUEST_DIR/PROBLEM.md" <<'EOF'
# Problem Statement

(One paragraph describing what triggered this side quest. What is the immediate
problem? What attempts have already been made? What evidence exists?)

EOF

# Empty phase files that the operator + models will fill in.
# The actual model names get filled in by the agent at run time;
# we ship the placeholder pair claude/codex but the skill supports any voice.
for f in \
  phase_-1_calibration.md \
  phase_0_claude.md phase_0_codex.md \
  phase_1_claude.md phase_1_codex.md \
  phase_2_claude.md phase_2_codex.md \
  phase_3_analysis.md \
  phase_4_claude.md phase_4_codex.md \
  phase_5_claude.md phase_5_codex.md \
  phase_6_analysis.md \
  phase_7_synthesis.md \
  PLAN.md \
  DISCARD.md
do
  cat > "$QUEST_DIR/$f" <<HEADER
# ${f%.md}

(Empty until phase runs. Append-only — do not rewrite prior content.)
HEADER
done

# Phase 7.5 spawn decision file
cat > "$QUEST_DIR/phase_7.5_spawn_decisions.md" <<'SPN'
# phase_7.5_spawn_decisions

(Filled in after Phase 7 synthesis. For each item not in the live ship
list, decide: SPAWN_CHILD, DROP, or FRAMEWORK_RESERVED.)
SPN

# Inventory the project — find candidate data sources + code/doc folders.
# Used to inform the operator about what's available; the agent uses
# these lists when rendering Phase -1 Q6 (data sources) and Q11 (codebase scope)
# via whatever structured-question mechanism it has (Claude Code: AskUserQuestion;
# Cursor/Continue: inline inputs; Codex/Aider/generic: numbered markdown prompt).
# The lists are written to the calibration template as a starting point — the
# agent should still ask Q6 / Q11 interactively and let the operator confirm or override.

DATA_INVENTORY_FILE="$(mktemp)"
FOLDER_INVENTORY_FILE="$(mktemp)"
trap "rm -f $DATA_INVENTORY_FILE $FOLDER_INVENTORY_FILE" EXIT

# Common data formats. Limit depth, skip backups/archives/caches.
if [ -d "$PROJECT_ROOT/data" ]; then
  find "$PROJECT_ROOT/data" -maxdepth 4 \
    \( -name "*.jsonl" -o -name "*.json" -o -name "*.yaml" -o -name "*.csv" \
       -o -name "*.parquet" -o -name "*.tsv" -o -name "*.ndjson" \) \
    2>/dev/null \
    | grep -v -E "(\.bak|\.bleed|__pycache__|\.cache|/_archive/|/dist/|/build/)" \
    | sed "s|^$PROJECT_ROOT/||" \
    | sort \
    > "$DATA_INVENTORY_FILE" || true
fi

# Top-level code/doc folders (excluding noise)
find "$PROJECT_ROOT" -maxdepth 2 -type d 2>/dev/null \
  | grep -v -E "(__pycache__|\.git|node_modules|\.venv|\.cache|\.pytest_cache|_archive|/dist$|/build$|target/|\.next|\.nuxt|out/)" \
  | grep -v -E "/[._]" \
  | sed "s|^$PROJECT_ROOT/||" \
  | grep -v "^$" \
  | sort \
  > "$FOLDER_INVENTORY_FILE" || true

# Phase -1 calibration template — pre-populated with the 13 questions.
# The agent overwrites this file when it captures live interactive answers
# (via the agent's structured-question mechanism); this template exists so a
# quest that's run partially-offline still has structure.
{
cat <<'CAL_HEAD'
# phase_-1_calibration

Operator: <name>
Date: <iso>

> **Phase -1 is REQUIRED before Phase 0.** All 13 questions must be touched.
> When the agent runs interactively, it asks each question with structured
> option lists (recommended default as Option 1, common alternatives as
> Options 2-4, automatic free-text "Other"). The rendering mechanism depends
> on the agent (Claude Code: AskUserQuestion; Cursor/Continue: inline inputs;
> Codex/Aider/generic: numbered markdown prompt). See
> `resources/prompts/phase_-1_operator_calibration.md` for the canonical
> option lists and `adapters/` for per-agent rendering specifics.

## Q1. Primary success metric
[recommended-default | override: <text>]

## Q2. Kill criterion
[recommended-default | override: <text>]

## Q3. Time pressure (ship-now vs learn-first)
[recommended-default | override: <text>]

## Q4. Existing assumptions to explicitly CHALLENGE
[empty default | list:
- <assumption 1>
]

## Q5. Out of scope (will NOT touch)
[recommended-default | override: <text>]

## Q6. Backtest data sources (auto-inventoried — confirm/expand)
**Auto-discovered data files (review for relevance):**

CAL_HEAD

if [ -s "$DATA_INVENTORY_FILE" ]; then
  while read -r line; do echo "- [ ] $line"; done < "$DATA_INVENTORY_FILE"
  echo
  echo "Total: $(wc -l < "$DATA_INVENTORY_FILE") files."
else
  echo "(No data/ directory or no machine-readable data files found at scaffold time.)"
fi

cat <<'CAL_MID'

**Operator action**: check the boxes for sources this quest should consume.
Add any additional sources NOT listed (sources outside `data/`, external API
endpoints, runtime state, etc.). Flag any source known to be UNRELIABLE,
partial, or buggy.

[recommended-default = all checked | list edits below]

## Q7. Risk-tolerance posture (adversarial vs happy-path)
[recommended-default | override: <text>]

## Q8. Multi-model voices to include
[recommended-default Claude+Codex | also: Gemini, Perplexity, others]

## Q9. Operator-seeded ideas (pre-seeded into Phase 1)
[empty default | list]

## Q10. Prior attempts (what we tried that didn't work)
[empty default | list]

## Q11. Codebase scope — folders to map for Phase 0 grounding
**Auto-discovered top-level folders:**

CAL_MID

if [ -s "$FOLDER_INVENTORY_FILE" ]; then
  while read -r line; do echo "- [ ] $line"; done < "$FOLDER_INVENTORY_FILE"
  echo
fi

cat <<'CAL_TAIL'

**Operator action**: check folders the agent should scan for Phase 0
codebase-map generation. Default is "the folders related to the problem
area"; for breadth-first quests, check more. The agent generates a
`codebase_map.md` file BEFORE Phase 0 and feeds it to all subsequent phases
as shared ground truth.

[recommended-default = problem-area folders | list edits below]

## Q12. Regime / context awareness
[recommended-default | override: <text>]

## Q13. What does "good enough" look like
[recommended-default | override: <text>]

## Operator additions
- <free-form additional context>
CAL_TAIL
} > "$QUEST_DIR/phase_-1_calibration.md"

echo "side quest initialized at: $QUEST_DIR"
echo "  data sources auto-inventoried: $(wc -l < "$DATA_INVENTORY_FILE" 2>/dev/null || echo 0)"
echo "  candidate folders auto-inventoried: $(wc -l < "$FOLDER_INVENTORY_FILE" 2>/dev/null || echo 0)"
echo
echo "next steps:"
echo "  1. Write MAIN_QUEST.md and PROBLEM.md (or have the agent fill them from chat context)"
echo "  2. Run Phase -1 calibration interactively (the agent uses its native structured-question mechanism; see adapters/ for specifics)"
echo "  3. Run questmap to build the shared knowledge map for the chosen scope (Q11):"
echo "       QUEST_DIR=$QUEST_DIR ~/.claude/skills/side-quest/scripts/questmap.sh <scope-paths>"
echo "  4. Begin Phase 0 framing (each model references the questmap)"
