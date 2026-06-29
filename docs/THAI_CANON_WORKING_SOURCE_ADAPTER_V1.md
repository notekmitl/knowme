# KnowMe Canon Platform — Working Source Adapter V1

> Removes the manual requirement that Canon sources must already exist as TXT
> files. A **temporary** working-source layer lets the Authoring Studio consume
> PDF / Images / OCR text / plain text through one interface. **No platform
> redesign** — the frozen layers are untouched.

Status: **CURRENT** · Decision Log **D-064** · Adapter layer only · Engine +
platform frozen · No deploy · No runtime changes.

Module: `lib/features/astrology/thai/knowledge/canon/working_source/` (pure Dart).
Depends only on the workspace `ExtractionSource`; no engine/runtime/ontology/
workspace-redesign dependency.

---

## Flow

```
Working Source → Page → Paragraph → Authoring Studio → Workspace Validation →
Review → Canon Import   (Working Source may then be discarded)
```

Nothing beyond the Authoring Studio may access Working Sources.

## Common interface — `working_source_base.dart`

`WorkingSource` is the single, file-type-agnostic interface the Authoring Studio
consumes — never a concrete file type:

- `pages()` → deterministic `List<WorkingPage>` (empty after `dispose`).
- `page(ref)` → a selected page.
- `extractionSourceForPage(page, …)` → a provenance-only `ExtractionSource`
  (book / edition / chapter / page). It carries **no prose**, so wiring it into
  the studio cannot leak copyrighted text into Canon.
- `dispose()` → discards all temporary material (idempotent).

`WorkingSourceRef` (book / edition / chapter / title) holds the **only** fields
allowed to survive into Canon (D-057). `WorkingPage` / `WorkingParagraph`
(`working_page.dart`) carry the reviewer-facing prose and are **ephemeral**.

## Input adapters — `working_source_adapters.dart`

Four adapters normalise to the **same** `WorkingPage` structure through one shared
paginator (`WorkingSourcePaginator`):

| Adapter | Input |
| --- | --- |
| `TxtWorkingSource` | plain text with page markers `[หน้า N]` / `[page N]` |
| `OcrWorkingSource` | OCR text (already textual; parsed exactly like TXT) |
| `PdfWorkingSource` | per-page text extracted from the PDF **externally** |
| `ImageWorkingSource` | per-page text the reviewer transcribed from images |

There is **no automatic extraction and no AI**: PDF/Image adapters consume text
the reviewer/tooling already obtained per page; the adapter only *supplies*
temporary text. Given equivalent content, **every adapter yields identical
pages** (verified by test). Page markers and paragraph splitting are
deterministic; text before the first page marker is treated as front matter and
ignored, and marker-free text becomes a single page `"1"`.

## Copyright guarantees (by construction)

- The bridge to authoring is `ExtractionSource`, which has **no text field** —
  only references — so authored sessions/units/reviews can never carry prose.
- `dispose()` clears all pages; **deleting the working source leaves Canon
  intact** (authored units are unchanged).
- Tests assert that session JSON contains no working-source paragraph text and
  that only the page reference survives as evidence.

## Validation (tests)

`test/validation/thai/thai_canon_working_source_test.dart` (10 tests): every
source type produces identical Working Pages; page references + parsing are
deterministic; the extraction source carries refs only (no prose); session/review
output carry references, not paragraphs; **deleting the Working Source leaves
Canon intact**; `dispose` is idempotent; marker-free and Thai-marker parsing; and
decoupling (no engine/runtime/matrix/mirror/fusion/narrative/canon-database/flutter
imports). Full canon suite (158 tests) green; `flutter analyze` clean.

## Constraints honoured

- Adapter layer only — no runtime/engine/ontology change, no workspace redesign,
  no deploy, no AI-generated knowledge, no automatic extraction.
- Untouched: Atomic Knowledge, Ontology, Knowledge Graph, Workspace, Authoring
  Studio, Golden Dataset, Rule Engine, Prediction, Timeline, Decision, Runtime,
  Mirror, Conversation, Fusion, `PlanetRelationshipMatrix`. The adapter only
  *supplies* temporary text and a provenance reference to the reviewer.
