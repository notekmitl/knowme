# Raw source intake — หลักมหาภูต (ส. หยกฟ้า)

This folder is the **drop location for the verbatim source text** of the
canonical book `หลักมหาภูต` (ส. หยกฟ้า), prior to extraction into the Canon
Database.

> **Why this is empty:** as of Canon Extraction V2 the book's actual content is
> **not present in the repository** and was not provided. Extraction has **not**
> begun. No knowledge unit may be created without the original text in front of
> the extractor — fabricated chapters/quotes/pages would violate the canon's
> core rule (every unit must trace back to the original; never guess, never
> interpret, never summarize, never pull from the internet).

## What to put here

One file per chapter, named `chapter-NN.txt` (or `.md`), containing the
**verbatim** transcription of that chapter, with page markers inline, e.g.:

```
[หน้า 127]
<ข้อความตามต้นฉบับทุกตัวอักษร>
[หน้า 128]
<ข้อความต่อ>
```

Acceptable forms: typed transcription, OCR text (kept verbatim — do not
"clean up" wording), or page images alongside a transcription. Keep the
original spelling even if archaic; spelling/ambiguity notes are recorded as
**Extraction Notes** during extraction, never by editing the source.

## What happens next (per chapter)

1. Extractor reads `chapter-NN.txt` and creates Book/Chapter/Section/Topic +
   Knowledge Units in `knowledge/canon/canon_database.knowme.json`, following
   `knowledge/canon/canon_unit.template.json` and the schema
   `knowledge/canon/canon_database.schema.json`.
2. Every unit keeps a verbatim quote in `evidence` with its `page`.
3. The chapter passes Structure / Reference / Traceability / Duplicate
   validation (`CanonDatabase.validate()`), then units advance to
   `canonApproved`.
4. Library manifest progress (`knowledge/canon/library.manifest.json`) is
   updated; the chapter becomes available to the Reasoning Engine via the
   read-only `CanonKnowledgeIndex` — no architecture change required.

See `docs/THAI_MAHABHUT_CANON_EXTRACTION_V2_RUNBOOK.md` for the full protocol.
