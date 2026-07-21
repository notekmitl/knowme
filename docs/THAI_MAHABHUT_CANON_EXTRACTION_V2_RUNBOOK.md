# Thai Astrology — Mahabhut Canon Extraction V2 (Book Ingestion Runbook)

> V2 is the **book-ingestion** milestone: turn `หลักมหาภูต` (ส. หยกฟ้า) into
> Canonical Knowledge the Reasoning Engine can use. This runbook is the
> **intake + extraction protocol**. The V1 architecture
> (`THAI_MAHABHUT_CANON_EXTRACTION_V1.md`, D-053) is ready; this defines how a
> chapter becomes canon-approved knowledge.

Status: **BLOCKED ON SOURCE** · Knowledge layer only · Engine frozen · No deploy.
Builds on D-052 (Canon V1) and D-053 (Canon Database).

> **Provenance policy (D-057):** the book is a Canon Reference. Record structured
> knowledge and cite **by reference** (book › chapter › section › page). Do
> **not** store copyrighted paragraphs; any verbatim text stays as local working
> material and is never promoted to the canon database. Where this runbook says
> "verbatim", treat it as *read the source faithfully*, not *store the paragraph*.
>
> **Source intake (D-064):** the source no longer has to be a pre-made TXT file.
> A reviewer can load PDF / page images / OCR text / plain text through the
> **Working Source Adapter** (`canon/working_source/`,
> `THAI_CANON_WORKING_SOURCE_ADAPTER_V1.md`) — a *temporary* layer that yields
> deterministic Working Pages and a provenance-only `ExtractionSource` per page.
> Working Sources are never Canon (only book/edition/chapter/page survive) and are
> discarded after authoring.
>
> **Extraction path (D-058 / D-059 / D-060 / D-062 / D-064 / D-066):** for each
> page from the Working Source, **AI-assisted deterministic extraction** reads the
> page and produces draft Atomic Knowledge Units for the facts **stated on that
> page** — *extraction only, never generation* (D-066: no hallucination,
> inference, interpretation, summarization or external knowledge). A reviewer
> then confirms/edits them in the **Knowledge Authoring Studio**
> (`canon/authoring/`, `THAI_CANON_KNOWLEDGE_AUTHORING_STUDIO_V1.md`) — draft
> Atomic Knowledge Units with live ontology assistance and batch editing — then
> hands the session to the **Knowledge Extraction Workspace** (`canon/workspace/`,
> `THAI_CANON_KNOWLEDGE_EXTRACTION_WORKSPACE_V4.md`), the only supported ingestion
> path. Each chapter becomes a `KnowledgeExtractionSession`; pages are decomposed
> into **Atomic Knowledge Units** (D-058) whose subjects/objects/relations resolve
> to the **Canonical Ontology** (D-059); the `WorkspaceValidator`, `KnowledgeDiff`
> and `ReviewReport` gate import. Steps below map onto: Draft → Extracting →
> Validated → Reviewed → Approved → Imported → Archived.
>
> **QA gate (D-063):** the Canon pipeline is regression-tested by the **Golden
> Canon Dataset** (`canon/golden/`, `THAI_CANON_GOLDEN_DATASET_V1.md`) — synthetic
> fixtures with declared deterministic outcomes verified through the real
> `WorkspaceValidator`/`KnowledgeDiff`/`CompletenessDelta`/`ReviewReport`. Run
> `thai_canon_golden_test.dart` after any change to extraction, validation or the
> ontology; a golden mismatch means the change altered pipeline behaviour.
>
> **Production Mode (D-065):** the Canon Platform is **COMPLETE** and **FROZEN**.
> This runbook is the **only supported production workflow**. Future milestones are
> evaluated by **Knowledge Coverage increase**, not new platform code. See
> `THAI_CANON_PLATFORM_PRODUCTION_MODE_V1.md`.

---

## Blocking precondition (why no units were extracted in this pass)

The verbatim text of `หลักมหาภูต` is **not in the repository** and was not
provided. The extraction rules are absolute:

- Extract **only** what is in the book. Never interpret, summarize, guess, or
  pull from the internet or Supporting Sources.
- Every Knowledge Unit must trace back to the original (chapter / section /
  page / quote).

Therefore no unit can be created until the source text is available. Fabricating
content would produce fake citations and destroy the canon's traceability — the
exact opposite of the goal. `canon_database.knowme.json` correctly stays empty.

**To start ingestion:** drop the verbatim text into
`knowledge/canon/sources/mahabhut/` (see its README), one `chapter-NN.txt` per
chapter with inline `[หน้า N]` markers. Extraction then proceeds mechanically
per the loop below.

---

## Field mapping — book → `CanonKnowledgeUnit`

For every distinct statement in a chapter, create one unit. Fields the brief
requires, mapped to the shipped schema (`canon_database.schema.json`). **If a
field is not present in the book, leave it empty — never invent it.**

| Brief field | Schema field | Rule |
|-------------|--------------|------|
| id | `id` | `mahabhut-uNNNN` (stable, sequential) |
| title | `title` | the book's heading for the statement, else empty |
| type | `type` | one of concept/rule/formula/interpretation/meaning/example/exception/condition |
| concept / rule / formula / interpretation / meaning | `statement` (+ `type`) | the verbatim knowledge text; `type` records which kind it is |
| conditions | `conditions[]` | only conditions stated in the book |
| exceptions | `exceptions[]` | only exceptions (ยกเว้น) stated in the book |
| examples | separate unit, `type: example`, linked via `exampleOf` cross-ref | keep the book's own example |
| evidence | `evidenceIds[]` → `CanonEvidence` | **verbatim quote** + page; mandatory for canon-approval |
| source | `location.bookId` + `sourceReferenceIds[]` | book = `mahabhut`; source ref → `canon_sources.json` |
| page | `location.page` + evidence `page` | from the `[หน้า N]` marker |
| section | `location.sectionId` | the section the statement sits in |
| chapter | `location.chapterId` | the chapter |
| confidence | `confidence` | how explicit the book is (none/low/medium/high) — about *clarity in the book*, never external belief |
| validation status | `validationStatus` | starts `extracted`, ends `canonApproved` |
| cross references | `crossReferenceIds[]` → `CanonCrossReference` | links discovered during extraction |
| (book problems) | `notes` (Extraction Note) | duplicate/ambiguous/archaic spelling/hard tables — record, never edit the source |

Normalized assertion (`value`) is set only for rule-type units whose claim maps
to an existing engine vocabulary (e.g. a planet-relationship `friend`/`enemy`/
`neutral`), so the Canon V1 resolver can use it. Leave empty otherwise.

---

## Per-chapter loop

```
for each chapter file in knowledge/canon/sources/mahabhut/:
  1. Book      → ensure the `mahabhut` book entity exists.
  2. Chapter   → add CanonChapter (number + verbatim title).
  3. Section   → add CanonSection(s) for the chapter's หัวข้อ (+ page range).
  4. Topic     → add CanonTopicEntity for sub-headings where present.
  5. Units     → one CanonKnowledgeUnit per statement, with Evidence (quote+page)
                 and SourceReference; conditions/exceptions/examples per the book.
  6. CrossRefs → add CanonCrossReference whenever a statement relates to one
                 already extracted (Rule↔Rule, Concept↔Concept,
                 Formula↔Interpretation, Exception↔Rule, …).
  7. Validate  → run the four gates below; fix data (not the source) until clean.
  8. Approve   → flip the chapter's units to validationStatus = canonApproved.
  9. Index     → CanonKnowledgeIndex picks them up; Reasoning Engine can cite them.
 10. Manifest  → bump library.manifest.json progress counters for `mahabhut`.
```

## Validation gates (all must pass before Canon Approved)

Run via `CanonDatabase.load(...).validate()` /
`CanonExtractionPipeline.statusFor(db)`:

- **Structure** — required fields present; valid `type`/`validationStatus`;
  parents resolve (chapter→book, section→chapter, topic→section).
- **Reference** — every `evidenceIds` / `sourceReferenceIds` /
  `crossReferenceIds` endpoint exists; no dangling cross-references.
- **Traceability** — each unit's `location` resolves to a real
  book/chapter/section and carries a page + verbatim quote.
- **Duplicate** — no duplicate ids; genuine in-book repetition is linked with a
  cross-reference and noted, not silently merged.

A chapter only advances to `canonApproved` when these are error-free and each
approved unit carries evidence (`approved_without_evidence` warning must be
clear).

---

## Reasoning readiness

Once a chapter is approved, it is consumable immediately and without any
architecture change:

- `CanonKnowledgeIndex.build(db).approvedFor(topic, subject)` returns
  canon-approved, fully-traced units.
- `CanonDatabase.toCanonNodes(tierOf:, isCanonOf:)` feeds the Canon V1
  resolver, so "Canon always wins" applies wherever a unit asserts a `value`.
- Narrative / Mirror / Fusion consume the same traced units; every insight can
  cite `book › chapter › section › page`.

## Compatibility

No change to the calculation engine, Swiss Ephemeris, matrix, runtime, provider,
mirror, fusion, narrative, or the existing Thai engine. This milestone adds
knowledge only.

## Future books

The same loop applies to any Tier-1/Tier-2 book: register it in
`canon_sources.json` + `library.manifest.json`, drop its text under
`knowledge/canon/sources/<bookId>/`, and extract. No architecture change.
