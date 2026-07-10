# Thai Astrology — Mahabhut Canon Extraction V1

> Build the **Mahabhut Canon Database** — the permanent structure that will hold
> the book **`หลักมหาภูต` (ส. หยกฟ้า)** (and future texts) as fully-traceable
> Canonical Knowledge. **No book content is extracted yet**; this milestone ships
> the database schema, manifest system, extraction pipeline, traceability and
> cross-reference systems, and validation layer — ready to extract chapter by
> chapter without further architecture change.

Status: **CURRENT** · Knowledge layer only · Engine frozen · **No deploy**.
Decision Log **D-053**. Builds on Canon V1 (`THAI_ASTROLOGY_CANON_V1.md`, D-052).

---

## What this adds over Canon V1

Canon V1 gave the **Source Priority ladder**, the `CanonicalKnowledgeNode`, the
**"Canon always wins"** resolver, and a single book-manifest skeleton. Canon
Extraction V1 turns that into a **normalized, multi-book database** with the full
entity set, a traceable extraction pipeline, and a query seam for the reasoning
engine — while staying 100% compatible with V1 and the V1–V9 knowledge platform.

Module: `lib/features/astrology/thai/knowledge/canon/database/`.

---

## 1 · Canon Database (entities)

`canon_entities.dart` + `knowledge/canon/canon_database.schema.json`

Structural hierarchy **Book → Chapter → Section → Topic → Knowledge Unit**, plus
first-class supporting entities:

| Entity | Model | Notes |
|--------|-------|-------|
| Book | `CanonBook` | `sourceId` → `canon_sources.json` (authority origin) |
| Chapter | `CanonChapter` | belongs to a book |
| Section | `CanonSection` | belongs to a chapter; carries `topic` hint + page range |
| Topic | `CanonTopicEntity` | heading-level grouping inside a section |
| Knowledge Unit | `CanonKnowledgeUnit` | the atom — type ∈ {topic, **concept, rule, formula, interpretation, meaning, example, exception, condition**} |
| Evidence | `CanonEvidence` | quote-first; linked to a unit + source reference |
| Cross Reference | `CanonCrossReference` | directed link between entities |
| Source Reference | `CanonSourceReference` | a specific citation into a registered source |
| Location | `CanonLocation` | book/chapter/section/topic/page/position — the traceability spine |

Every entity has an explicit JSON schema and parses defensively (`fromMap`). The
schema is extensible (additive fields only) so future entity kinds don't break
existing data.

A unit's **authority is derived, never self-declared**: its tier/canonical flag
come from its book's source via the Canon V1 registry.

---

## 2 · Manifest System (multi-book)

`canon_library_manifest.dart` + `knowledge/canon/library.manifest.json`

`CanonLibraryManifest` is a **registry of books** — built for many books, not
only `หลักมหาภูต`. Each `CanonLibraryBookEntry` carries: metadata, a pointer to
its detailed per-book manifest (`manifestAsset`), **extraction state**
(`notStarted/inProgress/completed`), **validation state**
(`unvalidated/partial/validated/canonApproved`), **version**, and **progress
counters** (chapters/sections/units/approved). `overallProgress` aggregates
across the whole library.

The shipped manifest registers `หลักมหาภูต` as the canonical book,
`extraction: notStarted`. The detailed chapter/section skeleton continues to live
in `mahabhut.manifest.json` (Canon V1).

---

## 3 · Canon Extraction Pipeline

`canon_extraction_pipeline.dart`

The workflow is modelled as an explicit, ordered, auditable sequence:

```
Book → Chapter → Section → Knowledge Unit → Validation
     → Canon Database → Knowledge Index → Reasoning Engine
```

- `CanonPipelineStage` enumerates the eight stages.
- `CanonPipelineStep` / `CanonPipelineRun` record each stage execution (status,
  input/outputs, issues) for a reversible audit trail.
- `CanonExtractionPipeline.statusFor(db)` computes how far the current corpus
  has progressed and what blocks the next stage. **Validation errors block the
  Canon-Database stage and everything after it** — nothing reaches the reasoning
  engine unless it is error-free and has canon-approved units.
- `toKnowledgeIndex(db)` is the documented route from database → index.

---

## 4 · Traceability System

`CanonDatabase.trace(unitId)` → `CanonTrace`

Every unit resolves its full provenance: **book → chapter → section → topic →
page → source references**, with a human-readable `citation` such as
`หลักมหาภูต › บท 1 › ความสัมพันธ์ดาว › ศุกร์-เสาร์ › น.128`. The chapter is
inferred from the section when the unit omits it. This guarantees the Reasoning
Engine can cite the origin of every insight.

---

## 5 · Cross Reference System

`CanonCrossReference` + `CanonCrossReferenceType`

Directed links across the corpus: `ruleToRule`, `conceptToConcept`,
`chapterToChapter`, `conceptToFormula`, `formulaToInterpretation`, plus
`seeAlso`, `refines`, `dependsOn`, `exampleOf`, `contradicts`. The database
exposes `crossReferencesFrom(id)` / `crossReferencesInvolving(id)` and validates
that both endpoints exist.

---

## 6 · Validation Layer

`CanonValidationStatus`: `draft → extracted → reviewed → validated →
canonApproved` (monotonic; `atLeast()` queries). Only **canon-approved** units
are eligible for the reasoning engine.

`CanonDatabase.validate()` checks: `broken_parent`, `broken_location`,
`broken_evidence`, `broken_source_ref`, `broken_cross_ref`, `dangling_cross_ref`,
`duplicate_*`, `evidence_no_quote` (never summarize a source away),
`approved_without_evidence`, `invalid_json`. Re-runnable any time.

---

## 7 · Compatibility (V1–V9, runtime, provider, mirror, fusion, narrative)

- **Canon V1 bridge:** `CanonDatabase.toCanonNodes(tierOf:, isCanonOf:)` converts
  assertive, canon-approved units into Canon V1 `CanonicalKnowledgeNode`s, so the
  existing `CanonConflictResolver` / `CanonKnowledgeEngine` consume them
  unchanged ("Canon always wins" still holds). Non-assertive units
  (topic/example/condition) are skipped.
- **Reasoning Engine seam:** `CanonKnowledgeIndex` is **read-only** and the
  reasoning engine depends on it — never the reverse. The index imports no
  calculation engine.
- **No changes** to runtime, provider, mirror, fusion, narrative, the V1–V9
  evidence/source/consensus/review layers, the calculation engine, Swiss
  Ephemeris, or any formula. `PlanetRelationshipMatrix` is never imported, read,
  or written (decoupling test).

---

## Data files (`knowledge/canon/`)

| File | Purpose |
|------|---------|
| `canon_database.knowme.json` | **Empty baseline** — structure ready, nothing extracted |
| `canon_database.schema.json` | Full DB schema (all entities) |
| `canon_unit.template.json` | Authoring template for extracting one chapter |
| `library.manifest.json` | Multi-book registry (`หลักมหาภูต` canonical, not started) |
| `library.manifest.schema.json` | Library manifest schema |

(Existing Canon V1 files — `canon_sources.json`, `canon.knowme.json`,
`canon.schema.json`, `canon.template.json`, `mahabhut.manifest.json`,
`mahabhut.book.schema.json` — are unchanged.) All under the already-registered
`knowledge/canon/` asset directory.

---

## Tests

`test/validation/thai/thai_canon_database_test.dart` (21 tests): entity loading,
type→category mapping, traceability (incl. chapter inference), validation (all
issue codes, duplicates, missing quote, malformed JSON), coverage, knowledge
index queries + approval gating, pipeline progression + error blocking, the V1
compatibility bridge (units → nodes → "Canon wins"), multi-book manifest +
progress aggregation, empty-baseline integrity, and decoupling. Canon V1's 20
tests remain green.

---

## How extraction will proceed (future)

1. Fill `mahabhut.manifest.json` with the real part/chapter/section skeleton.
2. For each chapter, add Book/Chapter/Section/Topic + Knowledge Units (+ Evidence
   with verbatim quotes, Source/Cross references) to `canon_database.knowme.json`
   using `canon_unit.template.json`.
3. Advance units through the validation lifecycle to `canonApproved`.
4. Update the library manifest progress counters.
5. The Knowledge Index then surfaces canon-approved, fully-cited knowledge to the
   reasoning engine — no architecture change required.
