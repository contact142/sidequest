#!/usr/bin/env bash
# questmap — build a knowledge map of a codebase/docs scope for a Side Quest.
#
# Usage:
#   questmap.sh <scope-path> [scope-path ...]
#   questmap.sh <github-url>
#
# Output:
#   <quest-dir>/questmap/                ← all artifacts (override with QUEST_OUT)
#   <quest-dir>/questmap/MAP.md          ← human-readable summary (always produced)
#   <quest-dir>/questmap/graph.json      ← machine-readable nodes+edges (when backend supports)
#   <quest-dir>/questmap/index.md        ← navigable per-cluster summary (when backend supports)
#
# Backends (auto-detected, in priority order):
#   1. graphify CLI  — if `graphify` is on PATH. Full feature set: knowledge graph,
#                      community detection, audit trail (EXTRACTED/INFERRED/AMBIGUOUS edges),
#                      multimodal (code/docs/papers/images), persistent across sessions,
#                      queryable. See https://github.com/karpathy-inspired/graphify or similar.
#   2. native-lite   — bundled fallback. Walks the scope, classifies files by extension,
#                      extracts top-level symbols (functions/classes/exports) via grep/ctags
#                      if available, emits MAP.md with a file→symbol→dependency listing.
#                      Lower fidelity than graphify but zero external dependencies.
#
# Environment overrides:
#   QUEST_DIR=<path>     Where to write questmap/ subdir (default: PWD)
#   QUEST_OUT=<path>     Explicit output dir (default: $QUEST_DIR/questmap)
#   QUESTMAP_BACKEND=    Force backend: "graphify" or "native-lite" (default: auto)

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "usage: questmap.sh <scope-path> [scope-path ...]" >&2
  echo "       questmap.sh <github-url>" >&2
  exit 1
fi

QUEST_DIR="${QUEST_DIR:-$PWD}"
QUEST_OUT="${QUEST_OUT:-$QUEST_DIR/questmap}"
mkdir -p "$QUEST_OUT"

# Backend selection
BACKEND="${QUESTMAP_BACKEND:-auto}"
if [ "$BACKEND" = "auto" ]; then
  if command -v graphify >/dev/null 2>&1; then
    BACKEND="graphify"
  else
    BACKEND="native-lite"
  fi
fi

echo "questmap backend: $BACKEND" >&2
echo "questmap output:  $QUEST_OUT" >&2

case "$BACKEND" in
  graphify)
    # Delegate to graphify, then copy/symlink its output into questmap/
    # graphify writes to ./graphify-out/ by convention; we collect and rename.
    pushd "$QUEST_OUT" >/dev/null
    for scope in "$@"; do
      echo "  → graphify $scope" >&2
      graphify "$scope" || {
        echo "  graphify failed on $scope (continuing)" >&2
      }
    done
    # Normalize graphify-out → MAP.md / graph.json / index.md
    if [ -d "graphify-out" ]; then
      [ -f "graphify-out/GRAPH_REPORT.md" ] && cp graphify-out/GRAPH_REPORT.md MAP.md
      [ -f "graphify-out/graph.json"      ] && cp graphify-out/graph.json graph.json
      [ -f "graphify-out/index.md"        ] && cp graphify-out/index.md index.md
    fi
    popd >/dev/null
    ;;

  native-lite)
    {
      echo "# Questmap (native-lite backend)"
      echo
      echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
      echo "Scope: $*"
      echo
      echo "> Native-lite is the bundled fallback. For richer output (community"
      echo "> detection, persistent graph, queryable concepts), install \`graphify\`"
      echo "> or another compatible backend and rerun with QUESTMAP_BACKEND=graphify."
      echo

      for scope in "$@"; do
        if [ ! -d "$scope" ] && [ ! -f "$scope" ]; then
          echo "## $scope"
          echo "*(path not found, skipped)*"
          echo
          continue
        fi
        echo "## $scope"
        echo

        # File inventory by extension
        echo "### File inventory"
        echo
        echo '```'
        find "$scope" -type f \
          ! -path '*/.git/*' ! -path '*/node_modules/*' ! -path '*/__pycache__/*' \
          ! -path '*/.venv/*' ! -path '*/dist/*' ! -path '*/build/*' \
          2>/dev/null \
          | sed -E 's/.*\.([a-zA-Z0-9]+)$/\1/' | sort | uniq -c | sort -rn | head -30
        echo '```'
        echo

        # Top-level symbols per file (python/js/ts/go/rust at minimum)
        echo "### Top-level symbols per file"
        echo
        find "$scope" -type f \
          \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.tsx" \
             -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.rb" \) \
          ! -path '*/.git/*' ! -path '*/node_modules/*' ! -path '*/__pycache__/*' \
          ! -path '*/.venv/*' ! -path '*/dist/*' ! -path '*/build/*' \
          2>/dev/null \
          | sort | head -200 \
          | while read -r f; do
              SYMBOLS=$(grep -nE '^(def |class |function |export function |export class |func |fn |public class )' "$f" 2>/dev/null | head -20)
              if [ -n "$SYMBOLS" ]; then
                echo "#### \`$f\`"
                echo '```'
                echo "$SYMBOLS"
                echo '```'
                echo
              fi
            done

        # Cross-file dependency hints (imports)
        echo "### Cross-file imports (sampled)"
        echo
        echo '```'
        find "$scope" -type f \
          \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.tsx" \) \
          ! -path '*/.git/*' ! -path '*/node_modules/*' ! -path '*/__pycache__/*' \
          ! -path '*/.venv/*' \
          -exec grep -lE "^(import |from |require\(|require )" {} \; 2>/dev/null \
          | head -40 \
          | while read -r f; do
              echo "$f:"
              grep -E '^(import |from )' "$f" 2>/dev/null | head -8 | sed 's/^/    /'
            done
        echo '```'
        echo

        # Config files (entry points)
        echo "### Configuration entry points"
        echo
        echo '```'
        find "$scope" -type f \
          \( -name "*.yaml" -o -name "*.yml" -o -name "*.toml" -o -name "*.json" \
             -o -name ".env*" -o -name "Dockerfile*" -o -name "Makefile" \
             -o -name "package.json" -o -name "pyproject.toml" -o -name "Cargo.toml" \
             -o -name "go.mod" -o -name "settings.*" \) \
          ! -path '*/.git/*' ! -path '*/node_modules/*' ! -path '*/__pycache__/*' \
          ! -path '*/.venv/*' ! -path '*/dist/*' ! -path '*/build/*' \
          2>/dev/null | head -30
        echo '```'
        echo

        echo "---"
        echo
      done

      echo "## Notes for downstream phases"
      echo
      echo "This native-lite map provides:"
      echo "- A file-type histogram per scope"
      echo "- Top-level symbol declarations (functions, classes, exports)"
      echo "- Cross-file import edges (sampled)"
      echo "- Configuration entry points"
      echo
      echo "What it does NOT provide (use \`graphify\` backend for these):"
      echo "- Persistent graph across sessions"
      echo "- Community detection (which files cluster together by responsibility)"
      echo "- EXTRACTED vs INFERRED edge audit trail"
      echo "- Cross-document semantic links (e.g., concept in code + concept in docs)"
      echo "- Queryable interface (\`questmap query \"<question>\"\`)"
      echo
      echo "When Phase 1 / Phase 4 plans reference specific files or functions, they"
      echo "should cite from this map. Vague references to \"the entry path\" or \"the"
      echo "scoring layer\" without naming files/functions defeat the purpose."
    } > "$QUEST_OUT/MAP.md"
    ;;

  *)
    echo "unknown backend: $BACKEND" >&2
    exit 1
    ;;
esac

echo "questmap done. See $QUEST_OUT/MAP.md" >&2
