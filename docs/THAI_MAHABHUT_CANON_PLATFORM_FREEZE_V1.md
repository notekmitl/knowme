# Thai Astrology — Canon Platform Freeze V1

> **The Thai Astrology Canon Platform is FROZEN as of this milestone.** The
> architecture is complete and Production Ready for bringing canonical knowledge
> into the system. From here, **all further work is Content Engineering only** —
> reading, reviewing and approving "หลักมหาภูต" (and future books) content. No new
> platform layers, schemas, workflows or architecture changes are expected.

Status: **FROZEN** · Decision Log **D-056** · Engine frozen · **No deploy**.
Supersedes nothing; ratifies D-052 → D-055.

---

## What "Platform Freeze" means

- **Allowed from now on:** adding/reviewing/approving canonical *content*; bug
  fixes that block real usage; documentation of content.
- **Not allowed without a new explicit decision:** new platform features, new
  layers, new schemas, new workflows, or architecture changes.
- The reasoning engine continues to read **only** Canon-Approved units.
- Frozen calculation surfaces remain untouched: Swiss Ephemeris, calculation
  engine, matrix, runtime, provider, mirror, fusion, narrative.

---

## Audit result (this milestone)

A full audit was performed across Architecture, Database, Manifest, Knowledge
Model, Validation, Approval Workflow, Toolchain, CLI, Reviewer Workspace, QA,
Metrics and Documentation.

### Fixes applied (behaviour-preserving)

1. **Build break fixed.** `canon_knowledge_engine.dart` used the shared helpers
   `canonEnumByName` / `canonStringList` without importing
   `canon/canon_json.dart`. Added the missing import.
2. **Duplicate logic consolidated.** Identical private `_enumByName` /
   `_stringList` helpers in `database/canon_entities.dart` and
   `ingestion/canon_candidate.dart` were removed and now use the single source of
   truth in `canon/canon_json.dart`. No behaviour change (all 65 canon tests stay
   green).

### Verified clean

- **Dependencies.** No circular dependencies and no layer leakage. Direction is
  strictly: leaf models (`canon_json`, `knowledge_tier`, `canonical_knowledge_node`)
  → `database/` → `ingestion/`; the root reasoning pillar
  (`canon_knowledge_engine` / `canon_conflict_resolver`) does not depend on
  `database/` or `ingestion/`, and `database/` does not depend on `ingestion/`.
- **Data / schema files.** Consistently namespaced; no duplicate schemas
  (`canon.*` = Canon V1 nodes, `canon_database.*` = Canon Database,
  `library.manifest.*` = multi-book registry, `mahabhut.*` = per-book manifest,
  `canon_sources.json` = source registry, `*.template.json` = extraction
  templates).
- **Two manifests are complementary, not duplicate.** `CanonBookManifest`
  (root, `mahabhut.manifest.json`) is the *per-book structural skeleton*;
  `CanonLibraryManifest` (`database/`, `library.manifest.json`) is the
  *multi-book library registry*. They model different scopes and are both
  retained intentionally.

---

## Frozen platform map

| Layer | Location | Role |
| --- | --- | --- |
| Tiered authority | `canon/knowledge_tier.dart`, `canonical_source.dart` | Source priority Tier 0–4 |
| Canon V1 model | `canon/canonical_knowledge_node.dart`, `canon_conflict_resolver.dart`, `canon_knowledge_engine.dart` | Node model + "Canon always wins" + load/validate/resolve |
| Shared JSON util | `canon/canon_json.dart` | Single decode-helper leaf (no imports) |
| Per-book manifest | `canon/canon_book_manifest.dart` | Book skeleton (parts/chapters/sections) |
| Canon Database | `canon/database/canon_entities.dart`, `canon_database.dart` | Book→Chapter→Section→Topic→Unit + Evidence/CrossRef/SourceRef + trace/validate |
| Reasoning seam | `canon/database/canon_knowledge_index.dart` | Read-only query (Canon-Approved only) |
| Extraction pipeline | `canon/database/canon_extraction_pipeline.dart` | Auditable stage model |
| Library registry | `canon/database/canon_library_manifest.dart` | Multi-book progress |
| Ingestion toolchain | `canon/ingestion/*` + `tool/canon_ingest.dart` | Import → extract(Candidates) → validate → approve → promote; diff/QA/metrics |
| Content engineering | `canon/ingestion/canon_review_assistant.dart`, `canon_coverage_analysis.dart`, `canon_consistency_checker.dart`; `features/knowledge_workspace/canon_review/` | Reviewer aids + workspace |

Standards: `THAI_MAHABHUT_CANON_STYLE_GUIDE.md`,
`THAI_MAHABHUT_CONTENT_REVIEW_CHECKLIST.md`. Process docs:
`THAI_MAHABHUT_INGESTION_TOOLCHAIN_V1.md`, `THAI_MAHABHUT_CONTENT_ENGINEERING_V1.md`,
`THAI_MAHABHUT_CANON_EXTRACTION_V2_RUNBOOK.md`.

---

## Production-ready ingestion path (no architecture change needed)

```
register book (canon_sources.json + library.manifest.json)
  → drop verbatim text in knowledge/canon/sources/<bookId>/
  → dart run tool/canon_ingest.dart extract … (Candidates)
  → annotate (Style Guide) → validate → review (Checklist) → approve
  → promote → canon_database.knowme.json → Canon Knowledge Index → Reasoning Engine
```

## Tests

Full canon suite green: Canon V1 (20), Canon Database (21), Ingestion Toolchain
(15), Content Engineering (9) = **65 tests**. `flutter analyze` clean across the
platform.

---

## Post-freeze reconciliation — D-057 (provenance / copyright)

The implementation-mode directive (book = **Canon Reference**, never store
copyrighted narrative) surfaced a real inconsistency with the frozen, quote-first
approval rule. Per the freeze's own exception ("change only on a real
inconsistency"), provenance is now **reference-based**:

- Extraction no longer seeds a verbatim quote; the paragraph stays local working
  material and is never promoted to the canon DB.
- `missing_citation` / `hasCitation` require a **book reference** (page /
  chapter / section), not a stored quote; `missing_page` still requires a page.
- The Canon DB warns only when evidence has **no provenance at all**.
- The promoted `statement` is reviewer-authored **structured knowledge**, not the
  book paragraph (enforced via the review checklist).

No layers, schemas or workflows were added; behaviour is preserved except the
verbatim requirement. See `THAI_MAHABHUT_CANON_STYLE_GUIDE.md` §0.

## Post-freeze knowledge-model refinement — D-058 & D-059

The freeze covers the **platform** (database, manifest, ingestion, validation,
approval, toolchain, workspace). The **knowledge model** continued to evolve
without redesigning that platform or touching any frozen engine:

- **Atomic Knowledge V2 (D-058):** the canonical object is the
  `AtomicKnowledgeUnit` (one atomic fact), Canon is a knowledge graph, and
  completeness is domain-based (`canon/atomic/`).
- **Canonical Ontology V3 (D-059):** a mandatory controlled vocabulary
  (`canon/ontology/`) — stable entity ids, deterministic alias resolution, a
  relationship registry (superset of the V2 graph relations) and a domain
  taxonomy. No package may invent entity or relationship names.
- **Knowledge Extraction Workspace V4 (D-060):** the **only supported path** for
  adding Canon knowledge (`canon/workspace/`) — `KnowledgeExtractionSession`
  lifecycle, `WorkspaceValidator`, `KnowledgeDiff`, `CompletenessDelta` and
  `ReviewReport`. Consumes the atomic + ontology layers read-only; no engine
  depends on it.

These are additive, pure-Dart knowledge-layer packages with no engine/runtime/UI
dependency. See `THAI_CANON_ATOMIC_KNOWLEDGE_V2.md`, `THAI_CANON_ONTOLOGY_V3.md`
and `THAI_CANON_KNOWLEDGE_EXTRACTION_WORKSPACE_V4.md`.

---

**Conclusion:** Canon Platform = Production Ready and **FROZEN**. Subsequent work
is Content Engineering only, performed through the Knowledge Extraction Workspace
(D-060), under the reference-only provenance policy (D-057), the Atomic Knowledge
model (D-058) and the Canonical Ontology vocabulary (D-059).
