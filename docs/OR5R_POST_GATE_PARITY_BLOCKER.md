# OR5R — confirmed post-gate Known PDF parity blocker

Status: **STOPPED BEFORE ZIP / COMMIT / PUSH — OPEN + DRAFT — NOT MERGED — NOT DEPLOYED**.

This finding is separate from the 76 original full-suite failures. All 76 have resolved; the complete suite passed 1,649/1,649. Artifact inspection then found an unrelated/pre-existing Known PDF defect. It is not authorized by the Unknown sentinel containment scope.

## Exact reproduction

Actual input: male, 1982-06-06, 00:35, Chiang Mai, asOf 2026-08-29 Asia/Bangkok. `build/or5r-owner-package/product/known-390-canonical.json` contains title-only section `report-timeline-predictive-v2-past-heading`, title **คำทำนายอดีต**, paragraphs `[]`. All canonical sections equal the captured pre-repair 00:35 baseline, including this heading.

Chrome browser-print page 2 displays the heading. Dedicated PDF page 2 does not. Both PDFs were opened as real Poppler rasters. A separate VM render (`flutter test --no-pub build/or5r_known_pdf_probe_test.dart`) reproduces the missing heading; its page 2 raster was also opened. The diagnostic test checks that its input document equals the pre-repair baseline; its 1/1 success means only that the independent render completed, NOT that parity passed.

The exporter source is unchanged from `8e6d168baf8378068260fbbb39500d5eb4491b37` after line-ending normalization. `_semanticBlocks([])` returns no blocks; the ordinary section title is written only inside the block loop. A title-only section therefore produces no widget. The separate `plainText` accumulator nevertheless contains the heading, so a test that only compares that accumulator cannot prove PDF rendering parity.

Machine-readable evidence, hashes and file paths are in `OR5R_POST_GATE_PARITY_BLOCKER.json`. No PDF generator fix or expected-output relaxation has been applied.

## Other artifact facts and limits

- Actual PDF pages: Dedicated Known/Unknown **6/1**; Chrome browser-print Known/Unknown **6/1**. Known page 4 contains the infographic, not a blank page.
- Unknown infographic is explicitly omitted under OR5R, not replaced with an invented 4-domain forecast. Known surface 360 and 390 images are 1080×1920.
- Six local Web capture cases produced 47 scroll tiles, canonical/installed-print-DOM equality for all six. These are captures, not a claim that every tile received final visual acceptance.
- Raster and contact-sheet files exist for every PDF page. Manual final review was interrupted by the confirmed heading defect; no all-pages/all-surfaces visual pass is claimed.
- Chrome's pypdf text extraction has NUL substitutions for some Thai glyphs: initial full-field scan reports 55 Known / 12 Unknown mismatches. Dedicated scan reports one Known missing heading / zero Unknown. Raw text and nonzero counters are preserved. This extraction limitation has not been repaired by guessing glyphs or deleting characters.
- Existing Known generic/rejected runtime prose remains untrusted content. A compatibility match for five selectors and nine typed references does not establish all 22 Candidate claims for the actual input. The provisional authority matrix records missing complete actual claim bindings rather than claiming 22/22 authority.

## Next decision

Owner authorization is required before expanding into the Known PDF renderer: minimally retain legitimate title-only sections and add an actual-PDF assertion that cannot pass from the render-text accumulator alone. Preserve Known canonical text/order and Unknown containment. Alternatively Owner may explicitly defer this unrelated defect, but it must remain disclosed and cannot be relabeled parity PASS.

No ZIP, new commit, PostCommit or push was made. PR115 stays Open + Draft. No Ready for Review, Merge, Deploy, Firebase/Production or product-acceptance change.
