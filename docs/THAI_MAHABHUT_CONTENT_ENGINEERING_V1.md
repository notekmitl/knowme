# Thai Astrology — Mahabhut Content Engineering V1

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
