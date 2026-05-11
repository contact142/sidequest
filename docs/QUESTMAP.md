# Questmap — Side Quest's grounding feature

**Questmap turns the relevant code, docs, and features into a shared knowledge map BEFORE Phase 0,** so every model in the brainstorm pool argues against the same ground truth.

Without it, each voice ends up with a different mental model of what the system already is, and Phase 1 plans propose mechanisms that conflict with existing structure or already partly exist. With it, every Phase 1 / Phase 4 plan cites specific files, functions, and config keys — and the synthesis pass in Phase 7 can spot redundancy or contradiction concretely.

---

## Why this is a real feature, not just `grep`

A naive "list the files and call it grounded" approach misses what makes shared ground truth load-bearing across phases:

1. **Persistence across sessions.** Side Quest's quest tree can have parent + child + sibling quests spanning weeks. A persistent graph means the second quest doesn't re-discover the codebase; it references the parent's map.
2. **Edge audit trail.** Distinguishing **EXTRACTED** edges (literally found in the source — "function `foo` calls function `bar`") from **INFERRED** edges (likely related — "`auth.py` and `session.py` share imports") from **AMBIGUOUS** ones (could go either way). This matters because Phase 7 synthesis must know *whether the relationship it's relying on is observed or guessed*.
3. **Community detection.** Cluster files/concepts/docs that hang together by topic. Forces models to argue about which cluster they're touching, surfacing cross-cluster dependencies that hand-waved descriptions hide.
4. **Cross-document semantic links.** If a concept appears both in code (`UserSession` class) and in docs (`docs/auth-flow.md` mentions sessions), connect them. Phase 4's outside-the-box round especially benefits from links into design docs the code map alone doesn't show.
5. **Queryable.** With a graph, the agent can answer `questmap query "where is the rate limiter wired in?"` instead of grepping blind. Phase 1 plans that depend on accurate "where does X live" get faster and more correct.

The native-lite fallback gives you (1) partially — files persist on disk — but not the rest. That's the gap between "grep the codebase" and a proper questmap.

---

## How questmap works

```
scripts/questmap.sh <scope-path> [scope-path ...]
```

The script picks a backend (in priority order):

| Backend | Required | What you get |
|---|---|---|
| **graphify** | `graphify` CLI on `$PATH` | Full knowledge graph (`graph.json`), community detection (`index.md`), edge audit trail (EXTRACTED/INFERRED/AMBIGUOUS), persistent across sessions, queryable, multimodal (code + docs + papers + images) |
| **native-lite** | Nothing (bundled) | `MAP.md` with file inventory, top-level symbols per file, sampled cross-file imports, configuration entry points |

Auto-detection happens at runtime. Force a backend with `QUESTMAP_BACKEND=graphify` or `QUESTMAP_BACKEND=native-lite`.

### Output layout

All backends produce a normalized layout under `<quest-dir>/questmap/`:

```
questmap/
├── MAP.md         # human-readable summary, always present
├── graph.json     # machine-readable nodes + edges (graphify only)
├── index.md       # per-cluster summaries (graphify only)
└── graphify-out/  # graphify's full output (graphify only)
```

Downstream phases reference `MAP.md` as the canonical entry point. Phase 1/4 prompts include something like: "Review `<quest-dir>/questmap/MAP.md` before proposing — your plan must name specific files or functions from the map."

---

## When to use each backend

### Use `graphify` when:
- The quest scope is non-trivial (≥ 10 files, ≥ 1 layer of indirection)
- The quest is part of a family (parent + children) — persistence across quests is worth a lot
- The codebase has substantial docs, papers, or RFCs alongside code
- You expect Phase 4 to want adversarial / unconventional framings — community detection surfaces non-obvious connections

### Use `native-lite` when:
- The quest scope is small (1-5 files) and the relationships are obvious
- You're in a fresh environment without external tools and don't want to install one
- This is a single-quest project, not a family

### Skip questmap entirely when:
- Phase -1 Q11 says "no codebase scope" (pure-research quest, green-field design)
- The team has explicitly aligned on the existing-system model and you don't need a refresher
- The quest scope is a single file with no external dependencies

---

## Installing a `graphify` backend

Side Quest's questmap is backend-agnostic. It reads/writes a standardized layout under `<quest-dir>/questmap/` and shells out to whatever produces it. Common implementations:

- **graphify CLI** (Karpathy-style /raw folder + knowledge graph) — install via `pipx install graphify` or `uv tool install graphify` (varies by upstream)
- **Custom**: any tool you write that produces a `graphify-out/` directory with `GRAPH_REPORT.md`, `graph.json`, and `index.md` will work — the wrapper copies those into `<quest-dir>/questmap/` automatically

To verify a backend works:

```bash
which graphify  # should print a path
cd /tmp && mkdir qm_test && echo "def foo(): pass" > qm_test/sample.py
QUEST_DIR=/tmp/qm_test ~/.claude/skills/side-quest/scripts/questmap.sh /tmp/qm_test
ls /tmp/qm_test/questmap/  # should show MAP.md (and graph.json if graphify ran)
```

---

## How questmap shows up in the phase flow

```
Phase -1 (calibration)
  └── Q11: which folders should the agent map?
        ↓
Phase 0 sub-step (questmap)
  └── scripts/questmap.sh <chosen-scopes>
        ↓ writes <quest-dir>/questmap/MAP.md
Phase 0 (self-framing)
  └── each model reads MAP.md before framing
Phase 1 / Phase 4 (brainstorms)
  └── plans MUST cite specific entries from MAP.md
Phase 2 / Phase 5 (backtests)
  └── replay harness can reference graph.json edges
Phase 7 (synthesis)
  └── redundancy check: does any proposed mechanism duplicate an existing one
      visible in the map?
Phase 10 (meta-synthesis, across family)
  └── if backend supports it, merge per-quest questmaps into a cross-quest graph
```

---

## Anti-patterns

| Anti-pattern | Fix |
|---|---|
| Running questmap with scope = entire project on a huge monorepo | Phase -1 Q11 should scope to the problem area. Big maps are noisy and slow. |
| Plans that say "we add a gate at the entry path" without citing files | Reject in Phase 7. The entire point of the questmap is concrete reference. |
| Treating native-lite output as if it had graphify's audit trail | Native-lite is a fallback. Don't draw conclusions that depend on edge-type confidence. |
| Re-running questmap from scratch on every quest in a family | Use `graphify --update` if backend supports it, or scope the rerun to only the changed area. |
| Skipping questmap because "I know the code" | Other voices in the pool don't. Run it for them. |

---

## Implementation status

- ✅ `scripts/questmap.sh` — backend dispatcher with auto-detection
- ✅ native-lite backend — bundled, zero-dependency fallback
- ✅ graphify backend — shells out to `graphify` if installed
- 🟡 cross-quest merge — possible with graphify backend (`graphify merge-graphs`), not yet wired into Phase 10 prompts
- 🟡 query interface — possible with graphify backend (`graphify query "..."`), not yet wired into Phase 1/4 prompts

The 🟡 items are tracked as enhancement work. They become high-priority if Phase 10 meta-synthesis quests start accumulating in real use.
