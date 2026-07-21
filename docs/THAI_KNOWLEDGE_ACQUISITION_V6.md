# Thai Astrology Knowledge Acquisition V6

> Begin collecting **real** Thai astrology knowledge. The goal is to *populate*
> the Knowledge Platform (V1–V5) — **not** to change the engine. Research is
> imported gradually, **JSON only, no manual Dart editing**, with a validation
> preview, an import summary, and rollback. **Nothing modifies the
> `PlanetRelationshipMatrix`.**

Status: **CURRENT** · Internal admin tool · No engine/runtime change · **No deploy**.
Decision Log **D-048**. Builds on Workspace **V5** (D-047) and the knowledge
layers V1–V4.

---

## Architecture

```
knowledge/acquisition/
├── acquisition.schema.json     # batch contract (evidence[] + research[])
└── acquisition.template.json   # blank batch to copy

lib/features/knowledge_workspace/acquisition/
├── knowledge_acquisition_engine.dart      # pure validate/preview/merge + ImportReport + session
└── knowledge_acquisition_dashboard.dart   # admin UI (overview, detail, import, rollback)
```

`knowledge/acquisition/` is a registered Flutter asset. Route:
**`/internal/knowledge/acquire`** (added to `KnowledgeWorkspaceRoutes`), behind
the existing `ThaiResearchAdminGuard` (same `admins/{uid}` allow-list).

---

## Batch format

A batch is a JSON object (`domain: "knowledge_acquisition"`, optional `batchId`)
with two optional arrays:

- `evidence[]` — `EvidenceRecord`s (V4 shape, see `evidence.schema.json`).
- `research[]` — `KnowledgeResearchRecord`s (V3/V4 shape, `evidenceIds[]`).

`evidenceIds` must resolve to an evidence record already in the corpus **or
earlier in the same batch**.

---

## Engine — `KnowledgeAcquisitionEngine` (pure)

`preview(AcquisitionState base, String batchJson) → AcquisitionImportReport`
validates and computes the would-be result without mutating anything. Each
record is classified:

| Outcome | Meaning |
|---------|---------|
| **imported** | id not in the corpus |
| **updated** | id exists, content differs (canonical-JSON diff) |
| **skipped** | id exists, content identical (no-op) |
| **error** | excluded from the merge |

Error reasons: `validation_failed` (missing required field / unknown enum),
`duplicate_in_batch`, `invalid_relation` (not friend/neutral/enemy),
`broken_link` (evidenceId resolves to nothing). A malformed/!object batch is a
**fatal error** — nothing is imported and the state is unchanged.

**Conflicts** are computed for the directed pairs the batch touches: if research
records disagree on the relation for a pair, an `AcquisitionConflict` is reported
and the participating imported/updated records are flagged. Conflicts do **not**
block import — disagreement is data (same philosophy as V4).

### Session — `KnowledgeAcquisitionSession`

In-session workbench: `preview()`, `apply()` (advances the working corpus; valid
records merged, errored skipped; no-op/fatal batches change nothing and don't
push undo), `rollback()` (undo the last applied import). `state.toAssetJson()`
emits ready-to-paste `evidence.knowme.json` + `research.knowme.json` so the admin
can commit the merged corpus back into the repo (the "JSON only" loop).

---

## Dashboard

`/internal/knowledge/acquire` — admin-only, read/preview/apply:

- **Overview**: relationship counts — Total · Verified · Candidate · Unknown ·
  Disputed — and **Coverage %** (relationships with research / total).
- **Relationship detail** (tap a row): Current Matrix · Knowledge status ·
  Conflicts · Research · Evidence.
- **Bulk JSON import**: paste a batch → **Validate / Preview** (dry-run report)
  → **Apply** (import summary, corpus refreshes) → **Rollback** (undo last).
- **Copy merged corpus JSON** (app-bar action) for committing back to the repo.

Every import renders an **Import Report**: Imported · Updated · Skipped ·
Conflicts · Errors (with per-record reasons).

---

## Matrix safety

The acquisition layer only merges the **research + evidence** corpora. It never
imports or writes the engine or `PlanetRelationshipMatrix`; the "Current Matrix"
shown in detail is read from the frozen V2 knowledge record (display only). A
test scans the source files to assert no matrix/runtime/prediction imports.

---

## Tests

`test/features/knowledge_workspace/knowledge_acquisition_test.dart`:
classification (imported/updated/skipped), every error class, conflict
detection + flagging, fatal-error handling, session apply/rollback (incl. no-op
guarding), `toAssetJson` round-trip through the V4 engines, route resolution,
dashboard render, and the matrix/runtime decoupling guard.

---

## Related documents

- [`THAI_KNOWLEDGE_WORKSPACE_V5.md`](THAI_KNOWLEDGE_WORKSPACE_V5.md) · [`THAI_KNOWLEDGE_EVIDENCE_LINKING_V4.md`](THAI_KNOWLEDGE_EVIDENCE_LINKING_V4.md) · [`THAI_KNOWLEDGE_RESEARCH_V3.md`](THAI_KNOWLEDGE_RESEARCH_V3.md) · [`THAI_KNOWLEDGE_IMPORTER_V2.md`](THAI_KNOWLEDGE_IMPORTER_V2.md) · [`THAI_KNOWLEDGE_FOUNDATION_V1.md`](THAI_KNOWLEDGE_FOUNDATION_V1.md).
- [`DECISION_LOG.md`](DECISION_LOG.md) — D-048. [`ARCHITECTURE.md`](ARCHITECTURE.md) · [`ROADMAP.md`](ROADMAP.md).
