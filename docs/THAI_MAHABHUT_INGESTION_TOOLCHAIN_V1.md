# Thai Astrology — Mahabhut Ingestion Toolchain V1

> The book text is not yet available, so **no Canonical Knowledge is created**.
> Instead this milestone ships the **toolchain** that turns prepared book text
> (OCR / plain / Markdown / `.txt`) into Canon-approved knowledge almost
> automatically: **Extract → Validate → Review → Approve → Index**. Pure
> knowledge layer; no engine/runtime/mirror/fusion/narrative change.

Status: **CURRENT** · Knowledge tooling only · Engine frozen · **No deploy**.
Decision Log **D-054**. Builds on D-052 (Canon V1) and D-053 (Canon Database).

Module: `lib/features/astrology/thai/knowledge/canon/ingestion/` ·
CLI: `tool/canon_ingest.dart`.

---

## Honest boundary (why nothing was extracted)

The toolchain **restructures text the user provides** — it never invents
knowledge. Extraction performs *structural segmentation only*: each paragraph is
copied verbatim into a candidate; the semantic fields (`type`, `topic`,
`subject`, `value`) are left **empty** for a human reviewer. No source text was
present in the repo, so no candidates and no canon nodes were produced. The
toolchain is fully tested against sample text and ready the moment a chapter is
pasted in.

---

## 1 · Import Pipeline — `canon_source_document.dart`

`CanonSourceDocument.parse(text, bookId:, config:)` accepts **OCR / plain text /
Markdown / TXT** (no PDF). It segments into **pages → chapters → sections →
paragraphs**, keeping every paragraph verbatim. Markers are configurable
(`CanonParseConfig`): page `[หน้า N]` / `[page N]`, chapter `บทที่/บท/ภาค/#`,
section `หัวข้อ/เรื่อง/##`. Text before any heading is captured and **noted**,
never dropped.

## 2 · Canon Extraction Engine — `canon_extraction_engine.dart`

`CanonExtractionEngine.extractText(text, bookId:, sourceId:)` →
`CanonExtractionResult` = structural entities (`CanonChapter`/`CanonSection`) +
**Candidate** units (one per paragraph). Each candidate gets a deterministic id,
its verbatim `statement` (working material), page and chapter/section ids — and
**no interpreted meaning**. Per the provenance policy (D-057) it does **not**
seed a copyrighted quote; provenance is by reference (page + chapter/section),
and the reviewer rewrites `statement` into structured knowledge before approval.

## 3 · Candidate Layer — `canon_candidate.dart`

Everything lands as a `CanonCandidateUnit` in a serialisable
`CanonCandidateStore`, kept **separate from the Canon Database**. Status begins
at `candidate`; nothing is canon until promoted. Candidates carry all required
fields (id, title, type, statement, value, conditions, exceptions, examples,
evidence quote, page, section, chapter, confidence, status, cross references) and
an `extractionNotes` list for in-book problems — recorded, never edited into the
source.

## 4 · Validation Engine — `canon_candidate_validator.dart`

`CanonCandidateValidator.validate(store, knownIds:)` checks: **Required Fields,
Duplicate, Broken Reference, Missing Citation, Missing Page, Invalid Cross
Reference, Empty Rule, Empty Concept**. A candidate may only become `validated`
when it has no errors.

## 5 · Canon Approval Workflow — `canon_approval_workflow.dart`

State machine with guards: `candidate → validated → reviewed → canonApproved`
(`validate` requires a clean candidate; `review` only from validated; `approve`
only from reviewed). `promote(store, extraction:)` converts **canon-approved**
candidates into a `CanonDatabasePatch` (units + evidence + chapters/sections +
`exampleOf` cross-refs and example sub-units) that loads straight into the Canon
Database. The reasoning engine reads **only** `canonApproved` (enforced by the
`CanonKnowledgeIndex` default).

## 6 · Diff Engine — `canon_diff_engine.dart`

`CanonDiffEngine.diff(oldStore, newStore)` matches by id and reports
added / removed / changed with field-level changes, plus convenience flags:
**rule changed** (`type`/`value`) and **citation changed** (`quote`/`page`) — so
an OCR correction shows exactly which units, rules and citations moved.

## 7 · Canon QA Tools — `canon_qa_tools.dart`

Standalone reports: **Missing Citation, Duplicate Rule, Orphan Rule, Broken
Cross Reference, Empty Concept** (`CanonQaTools.all(store)`).

## 8 · Extraction Metrics — `canon_extraction_metrics.dart`

`CanonExtractionMetrics.of(store)` → book / chapter / section counts,
extracted / validated / reviewed / approved, **coverage** (approved ÷ extracted)
and **progress** (beyond candidate ÷ extracted), with per-chapter/section
breakdown.

## 9 · CLI — `tool/canon_ingest.dart`

Code-free ingestion via the Dart SDK:

```
dart run tool/canon_ingest.dart extract <textFile> <bookId> [--source <id>] [--out <file>]
dart run tool/canon_ingest.dart validate <candidates.json>
dart run tool/canon_ingest.dart qa       <candidates.json>
dart run tool/canon_ingest.dart metrics  <candidates.json>
dart run tool/canon_ingest.dart diff     <old.json> <new.json>
```

The toolchain is **pure Dart** (no Flutter import), so the CLI runs without the
app. Verified end-to-end on sample text.

---

## End-to-end flow

```
prepared text (OCR/txt/md)
  → Import Pipeline (parse)
  → Extraction Engine (Candidates, verbatim, unapproved)
  → [human assigns type/topic/subject/value + cross refs]
  → Validation Engine (8 checks)            → validated
  → Review                                  → reviewed
  → Approve                                 → canonApproved
  → promote() → CanonDatabasePatch → canon_database.knowme.json
  → CanonKnowledgeIndex → Reasoning Engine (cites book › chapter › section › page)
```

No architecture change is needed to add a chapter, and the same flow serves any
future Canon book (register it in `canon_sources.json` + `library.manifest.json`,
drop text under `knowledge/canon/sources/<bookId>/`, ingest).

---

## Constraints honoured

- **No fabricated knowledge** — extraction only restructures provided text;
  meaning is human-assigned; baseline corpora stay empty.
- **No internet, no memory-sourced content, no guessing.**
- **No change** to Swiss Ephemeris, calculation engine, matrix, runtime,
  provider, mirror, fusion, narrative, or the existing Thai engine. Decoupling
  test asserts the ingestion layer imports none of them (and stays Flutter-free).

## Tests

`test/validation/thai/thai_canon_ingestion_toolchain_test.dart` (15 tests):
parsing, candidate extraction (verbatim, no interpretation), validation (all
codes), the approval state machine + gates, promotion → Canon Database round-trip
with traceability, diff (rule/citation change detection), QA reports, metrics,
JSON round-trip, and decoupling. Canon V1 (20) and Canon Database (21) tests stay
green.
