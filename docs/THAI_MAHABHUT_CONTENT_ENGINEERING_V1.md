# Thai Astrology — Mahabhut Content Engineering V1

> **Production Mode (D-065):** the Canon Platform is **COMPLETE** and **FROZEN**.
> No new platform layers. Expected output = **verified Canon knowledge** or
> **documented gaps** (Ontology Gap / Knowledge Modeling Gap reports). See
> `THAI_CANON_PLATFORM_PRODUCTION_MODE_V1.md`.
>
> The Canon architecture and ingestion toolchain are complete. This milestone
> adds the **human-review layer** that turns book candidates into Canon-approved
> knowledge with the least manual effort — a reviewer workspace, review assistant,
> coverage analysis, consistency checker, a style guide and a review checklist.
> **No new architecture**: every analyzer composes the existing ingestion
> toolchain; the workspace reuses the existing admin guard and route chain.

Status: **CURRENT** · Reviewer tooling only · Engine frozen · **No deploy**.
Decision Log **D-055**. Builds on D-054 (Ingestion Toolchain).

Principles unchanged: no fabricated knowledge, no interpretation, no internet,
every unit traceable to the book.

> **Updated by Atomic Knowledge V2 (D-058):** the canonical object is the
> `AtomicKnowledgeUnit` (one atomic fact), not a free-text statement. Reviewers
> decompose each candidate paragraph into atomic units (entity / relationship /
> condition / effect / exception) feeding the knowledge graph; the completeness
> picture is now domain-based (`CanonCompletenessReport`). See
> `THAI_CANON_ATOMIC_KNOWLEDGE_V2.md`.
>
> **Updated by Ontology V3 (D-059):** every entity, domain and relationship in an
> atomic unit MUST resolve to the **Canonical Ontology** (`canon/ontology/`).
> Reviewers map surface forms (any language) to canonical ids via alias
> resolution; unknown/ambiguous terms stay unresolved (never guessed) and signal a
> missing ontology entry. No new entity or relationship names may be invented
> outside the ontology. See `THAI_CANON_ONTOLOGY_V3.md`.
>
> **Updated by Extraction Workspace V4 (D-060):** the **only supported path** for
> adding Canon knowledge is now the Knowledge Extraction Workspace
> (`canon/workspace/`). Work happens inside a `KnowledgeExtractionSession`
> (Draft→Extracting→Validated→Reviewed→Approved→Imported→Archived); the
> `WorkspaceValidator`, `KnowledgeDiff` (NEW/UPDATED/UNCHANGED/CONFLICT/DEPRECATED)
> and `ReviewReport` (with `CompletenessDelta`) are the review surface, and
> `readyForImport` gates entry into the Canon database. Nothing enters Canon
> directly. See `THAI_CANON_KNOWLEDGE_EXTRACTION_WORKSPACE_V4.md`.
>
> **Production V1 (D-061):** the platform foundation is complete; work is now
> *content production* for six foundational domains, tracked by the deterministic
> `KnowledgeProductionReport` (`canon/production/`). The Canon book is not yet in
> the repo, so all domains read **Unknown** — facts are never invented; drop the
> source text and run the workspace to produce them. See
> `THAI_CANON_KNOWLEDGE_PRODUCTION_V1.md`.
>
> **Authoring Studio V1 (D-062):** reviewers author a page using the
> **Knowledge Authoring Studio** (`canon/authoring/`) — the official editing layer
> *before* the Workspace. Create draft Atomic Knowledge Units, get live ontology
> assistance (resolved / missing-ontology / unknown), batch-edit
> (duplicate/split/merge/delete/reorder), preview validation **using the exact
> Workspace validator**, and export/import drafts to resume later. Nothing is
> Canon until imported via the Workspace. See
> `THAI_CANON_KNOWLEDGE_AUTHORING_STUDIO_V1.md`.
>
> **Golden Dataset V1 (D-063):** the Canon pipeline has a deterministic
> **regression suite** (`canon/golden/`) — synthetic fixtures with declared
> outcomes verified through the real Workspace pipeline. Treat a golden mismatch
> as a behavioural regression: investigate before changing fixtures. See
> `THAI_CANON_GOLDEN_DATASET_V1.md`.
>
> **Working Source Adapter V1 (D-064):** the source no longer has to be a pre-made
> TXT file. Load PDF / page images / OCR text / plain text through the **Working
> Source Adapter** (`canon/working_source/`) — a *temporary* layer that supplies
> deterministic Working Pages to the reviewer and a provenance-only
> `ExtractionSource` per page. It is never Canon (only book/edition/chapter/page
> survive) and is discarded after authoring. The adapter itself performs no OCR
> and no extraction — it only supplies page text. AI-assisted *extraction* happens
> later, at the authoring/atomic step, under mandatory human review (D-066:
> extraction allowed, generation forbidden). See
> `THAI_CANON_WORKING_SOURCE_ADAPTER_V1.md`.
>
> **Production Mode (D-065):** the Canon Platform is **COMPLETE** and **FROZEN**.
> Stop creating platform layers. All work is **Knowledge Production** through the
> official pipeline (Working Source → Authoring → Workspace → Review → Import),
> measured by **Coverage increase**. Unrepresentable statements → Knowledge
> Modeling Gap Report; repeated missing entities → Ontology Gap Report — never
> platform redesign. See `THAI_CANON_PLATFORM_PRODUCTION_MODE_V1.md`.

---

## 1 · Reviewer Workspace — `lib/features/knowledge_workspace/canon_review/`

`CanonReviewerWorkspacePage` (route `/internal/knowledge/canon-review`, behind
the existing `ThaiResearchAdminGuard`). Three tabs:

- **Review** — master/detail. The list shows every candidate with status, type
  and a health badge; the detail panel shows, together: **source text
  (working material)**, the **knowledge unit** fields, **citation** (page +
  location reference — no stored copyrighted quote, per D-057), **cross
  references**, **validation hints**, and the **pre-approval checklist**
  auto-evaluated for that unit.
- **Coverage** — chapter/section/citation/validation coverage bars + knowledge
  density + per-chapter breakdown.
- **Consistency** — cross-cutting consistency issues.

With no candidates loaded it shows an honest empty state pointing to the CLI —
there is no canonical content because the book text has not been provided.
`CanonReviewerData` assembles the store + reports and can load a candidate JSON
produced by `tool/canon_ingest.dart`.

## 2 · Review Assistant — `ingestion/canon_review_assistant.dart`

Helper only. `CanonReviewAssistant.review(store)` produces highlight annotations:
**un-converted paragraph**, **missing citation**, **missing page**, **duplicate**,
**rule without cross-reference**, **missing metadata**, **broken cross-reference**.
It *composes* the Validation Engine (authoritative errors) and QA Tools (orphan
rules) — no parallel checker. It also defines `CanonReviewChecklist` (the
pre-approval checklist as data) and auto-evaluates the verifiable items per unit;
manual items (faithful structured knowledge, no added interpretation) are surfaced for the
human.

## 3 · Coverage Analysis — `ingestion/canon_coverage_analysis.dart`

`CanonCoverageReport.analyze(store)` over `CanonExtractionMetrics` +
Validation Engine: **chapter coverage**, **section coverage**, **knowledge
density** (units/page), **citation coverage**, **validation coverage**, plus
per-chapter coverage — to see whether the book is fully converted.

## 4 · Consistency Checker — `ingestion/canon_consistency_checker.dart`

Cross-cutting checks (distinct from per-unit validation):
**concept naming** (one subject ⇒ one title), **duplicate rule id** (same rule
under different ids), **duplicate formula**, **citation gap**, **metadata gap**.

## 5 · Canon Style Guide — `THAI_MAHABHUT_CANON_STYLE_GUIDE.md`

Standards for ID / Concept / Rule / Formula naming and for writing Meaning /
Interpretation / Exception / Cross Reference, so the whole book is consistent.

## 6 · Content Review Checklist — `THAI_MAHABHUT_CONTENT_REVIEW_CHECKLIST.md`

The per-unit and per-chapter checklist a reviewer confirms before
`reviewed → canonApproved`. Mirrors `CanonReviewChecklist` in code.

## 7 · Documentation

This document + the two standards docs above; `DECISION_LOG` (D-055),
`PROJECT_INDEX`, `ARCHITECTURE`, `ROADMAP` updated.

---

## Reviewer flow

```
candidate JSON (from CLI)
  → Reviewer Workspace (source | unit | citation | cross-refs | errors)
  → Review Assistant highlights + auto checklist
  → Coverage + Consistency tabs confirm completeness
  → human confirms manual checklist items
  → approve via toolchain → promote → Canon Database → Knowledge Index
```

The human is left with **reading, reviewing and approving** — no architecture
changes required to ingest a chapter.

## Constraints honoured

- Reviewer aids **never create or alter knowledge**; analyzers are read-only and
  compose existing engines (no duplicate systems).
- No fabricated knowledge, no internet, no guessing.
- **No change** to engine, runtime, Swiss Ephemeris, matrix, provider, mirror,
  fusion or narrative. Analyzers stay pure Dart; the workspace reuses the
  existing admin guard + `KnowledgeWorkspaceRoutes`. Not deployed.

## Tests

`test/validation/thai/thai_canon_content_engineering_test.dart` (9 tests):
review assistant highlights + checklist, coverage analysis, consistency checker,
the reviewer workspace empty state + tabbed detail, and candidate-JSON
round-trip. Toolchain (15), Canon V1 (20) and Canon Database (21) suites stay
green.
