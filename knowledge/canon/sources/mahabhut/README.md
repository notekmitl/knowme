# Raw source intake — หลักมหาภูต (ส. หยกฟ้า)

This folder remains the **repository-safe intake location** for excerpts from
the canonical book `หลักมหาภูต` (ส. หยกฟ้า). The full working source is kept
outside the repository for copyright and size reasons.

> **Why this is empty:** the 308-page scan, page images, and OCR working source
> are available on the configured local source drive but must not be committed.
> Production extraction is complete and frozen at 834 atomic units plus 29
> reference-table cells. The `producedUnits` JSON array also contains 20 note
> sentinels, so its raw length is 854; those notes are not atomic units. See
> `docs/THAI_MAHABHUT_CANON_SOURCE_TRUTH_RECONCILIATION_V1.md`.

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

## What happens next (Canon V2 predictive modeling)

1. Read the relevant page image and cross-check its OCR.
2. Commit only source identity, hash, page/section, a short necessary excerpt,
   extracted structure, and review metadata.
3. Keep proposed predictive rules under `knowledge/canon/proposed/`; they are
   not runtime Canon until separately reviewed and approved.
4. Never silently edit the frozen production units or merge page provenance
   between editions.

See `docs/THAI_MAHABHUT_CANON_EXTRACTION_V2_RUNBOOK.md` for the full protocol.
