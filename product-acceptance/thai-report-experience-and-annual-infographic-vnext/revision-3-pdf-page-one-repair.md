# Revision 3 PDF page-one root-cause repair

Status: **TECHNICAL GATES PASSED — OWNER COPY/VISUAL REVIEW PENDING — PR #100 DRAFT — NOT DEPLOYED.**

## Root cause and impact

The generated `owner-known-0035` PDFs were not clipped. The false observation occurred in the evidence-display path: every PDF render directory reused `page-1.png`, so a preview/cache identity collision could display another raster while showing the requested path.

- Browser Owner Known page 1 is 909×1287, 46,201 bytes, SHA-256 `7C0BE83B8085A76BFE8B2E4178E59B0797E14D4AE3F524873A8CAE7F1FD5A91A`.
- A direct Poppler rerender to a unique basename is byte-identical and visibly contains the full KnowMe header, subtitle, introduction and opening section.
- Browser PDFs are 7 pages each; dedicated PDFs are 8 pages each. Extracted text, glyph coordinates, MediaBox/CropBox and raster bounds are valid.
- Actual clipping impact across all 14 PDFs is zero. No profile-specific model, astrology, copy, pagination, font or renderer defect was found.

The historical stop record remains in `revision-3-blocker.md` and is explicitly corrected there; it is not silently rewritten.

## Minimal repair

No application layout, canonical R1–R7.1 text, astrology logic, monthly engine, golden or expected output was changed for this repair. The repair adds:

- `tool/thai_report_pdf_page_one_gate.py`, which binds every raster name to its source PDF and checks page-one contract text, page geometry, all-page raster bounds, blank pages, page counts and identities;
- `tool/thai_report_pdf_review_sheets.ps1`, which creates identity-labelled contact sheets;
- `tool/thai_report_vnext_browser_print_pdfs.cjs`, which deterministically creates the seven browser-print PDFs;
- shared-model regression assertions in `test/validation/thai_beta/thai_report_experience_infographic_vnext_test.dart`.

Chrome's embedded Thai font map can expose decomposed combining marks or `NUL` during extraction. The gate therefore preserves raw extraction and geometry, verifies the four page-one contract units, compares a deterministic Thai-base-consonant/number/ASCII sequence, and pairs that with exact shared-model Dart assertions plus full raster review.

## Fresh artifact and visual evidence

- Artifact generation: 15/15 fixtures PASS.
- PDFs: 14 total; browser 7×7 pages and dedicated 7×8 pages; 105 pages total.
- Unique raster identities: 105/105; validator failures 0.
- Manual review: 105/105 pages inspected across 32 contact sheets; clipping, blank pages, overlap, collision, missing header and missing introduction all 0.
- Owner Known before/after: browser raster byte-identical; dedicated raster byte-identical.

Primary evidence: `pdf-page-one-repair-final-result.json`, `logs/pdf-page-one-repair-final-result.txt`, `visual-qa/revision-3-page-one-repair/` and `generated-artifacts/revision-3/`.

## R7 226 → 286 reconciliation

The authoritative R7 runner is the original directory-scope command recorded by the earlier Final Merge Gate:

```text
flutter test --no-pub test/validation/thai_beta/narrative test/validation/thai_beta/core_reading test/validation/thai_beta/thai_beta_report_export_test.dart test/validation/thai_beta/synthetic_audit/thai_beta_synthetic_audit_300_test.dart --reporter expanded
```

The first Revision 3 attempt reconstructed a narrower explicit-file command from paths visible in parallel progress output and reached 226/226. That reconstruction was invalid because quick files need not appear in the captured progress lines; there is no authoritative 24-file inventory. The exact original directory command was rerun fresh and passed 286/286. No test was deleted, skipped, tagged out or weakened. Diagnostic attempts are retained as raw evidence and are not represented as the final result.

## Final technical gates

| Gate | Fresh result |
|---|---|
| Focused PDF page-one regression | 10/10 PASS |
| Focused copy/layout | 11/11 PASS |
| Copy audit | 300 profiles / 4,407 changed fields; omission/addition/semantic/prediction-advice/traceability impact 0 |
| Known/Unknown fail-closed | 62/62 PASS |
| Screenshot regression | 24/24 PASS |
| Life Map regression | 32/32 PASS |
| Matrix | 864/864; each weekday 108/108 PASS |
| R7 authoritative original command | 286/286 PASS |
| Scoped analyzer | 0 issues |
| Full analyzer | branch 297 / main 299; branch-only 0, main-only 2 |
| Full suite | branch 2,940 passed / 37 failed; main 2,925 / 39; common 37; branch-only 0, main-only 2 |
| Web release build | PASS; not deployed |
| VM×2 / real Chrome×2 | exact 133,592-byte manifest, SHA-256 `AE15130780DA9B5CAF847909D60B5A29459BB5298F4715EF2CC82F58E41E537E`, mismatch 0 |

The first Chrome parity invocation failed before browser launch because the default Node runtime lacked Playwright. Its raw failure is retained. The rerun used the bundled Node/Playwright runtime and passed; no product output was changed to obtain the result.

## Provenance and stop point

- Source-tested starting HEAD: `21fbcd51d16d5a289d215791780c95a1b0db389a`.
- R7.1 ZIP: 10,709,328 bytes, 80 entries, SHA-256 `9E541F21C68FDAD93BC595C55BD0BE23600F88454CFBA7FAB6C713FE53F79E58`; internal checksums 79/79.
- R7 immutable comparison 63/63; R1–R7.1 modified paths 0.
- Owner Known remains Aquarius 19°19′; regression 00:03 remains Aquarius 9°24′; Unknown remains fail-closed; canonical five 5/5; traceability 170/170.
- The exact tracked test-generated paths listed in `logs/revision-3-pdf-repair-pre-change-provenance.txt` were restored individually to HEAD after exact-path validation. The prose summary said 27, while its explicit list contained 28 paths; the explicit list is authoritative. Substantive candidate and repair changes were preserved.

The Owner subsequently Approved the Revision 3/4 copy and visual scope at `2026-08-19T08:52:49Z`, including 14/14 PDFs and 105/105 pages. `monthlyTimelineAvailable = false`; the monthly timeline remains BLOCKED because the engine has no validated month-by-month evidence. PR #100 remains Draft until the Final Merge Gate passes. Production remains V1.5 Hosting version `5f98dfffef913e38`. Deploy and Firebase mutation are not authorized.
