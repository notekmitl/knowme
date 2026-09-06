# OR5R — authorized title-only Dedicated PDF repair

## Root cause and scope

Owner explicitly authorized the Dedicated PDF renderer and direct real-file tests after the out-of-scope blocker. The pre-repair actual 00:35 / male / 1982-06-06 / Chiang Mai / asOf 2026-08-29 document contained `report-timeline-predictive-v2-past-heading`, title `คำทำนายอดีต`, paragraphs `[]`. Web/Chrome print retained it. `_semanticBlocks([])` returned no blocks, and the ordinary renderer emitted a section title only within the block loop. The independent canonical/plainText accumulator still contained the title, concealing the missing widget from accumulator-only checks.

The generic repair passes the section title to the shared semantic-block builder. A nonblank title with no paragraphs becomes one empty-body semantic unit, rendered once through the existing atomic path. An empty/whitespace-only title with no paragraphs still yields no unit. No hardcoded Thai heading, fixture branch, invented paragraph, canonical model change or special chapter/disclaimer/methodology/infographic rewrite was used. The debug pagination units and actual renderer call the same function. Ordinary paragraph-bearing sections are unchanged.

Known canonical text, IDs, order, paragraph bodies, kinds and traces remain untouched; only the previously missing PDF widget is restored. Unknown containment is unchanged. Candidate0011 remains immutable. The old blocker report is retained as historical evidence, not silently rewritten as a past PASS.

## Real-file regression and negative controls

`test/validation/thai_beta/thai_beta_pdf_title_only_test.dart` has four tests covering ordinary/timeline title-only units, empty units, exact normal-section units, and the actual pinned 00:35 PDF. The latter asserts the Known document against the pre-repair baseline, writes actual exporter bytes, and invokes `tool/or5r_actual_pdf_gate.py` on the saved PDF.

The gate uses pypdf PDF stream extraction. It compares the entire normalized PDF text against the complete ordered expected field inventory, preserving all Thai characters (NFKD, whitespace/zero-width normalization, and explicit page-footer removal only). It requires one occurrence of the title and zero missing/extra/duplicate/order/paragraph mismatches. It also opens and rasterizes every page with Poppler. Neither `document.fullPlainText` nor `renderResult.plainText` is read by this regression.

Before applying the renderer change, the new suite genuinely failed 2/4: the title-only unit was empty and the actual PDF lacked exactly this heading (one missing heading, one order mismatch, zero paragraph mismatches). After repair the same four tests pass. An additional test-only PDF mutant removes text-paint operations on the title's page while keeping the canonical inventory unchanged; the actual-file gate rejects it and records requiredHeadingCount=0. The mutant is diagnostic evidence, never a product PDF or a visual PASS.

The regression export excludes infographic to keep the independently checked text stream isolated; its measured 4 pages are not the page count of the final product export with infographic. Final product page counts, all-pages visual review, full-suite/gate results, source binding and package identity are recorded in `OR5R_PDF_REPAIR_VALIDATION.json` and the final Owner guide.

## Authority is a separate gate

Restoring PDF parity does not accept the existing generic Known prose or establish all 22 Candidate0011 claims for actual 00:35 input. The authority matrix retains compatible components, explicit fixture mismatch and missing complete actual claim bindings. No claims are added or rewritten to satisfy a count. No Owner Product Acceptance, Merge or Deploy is implied.
