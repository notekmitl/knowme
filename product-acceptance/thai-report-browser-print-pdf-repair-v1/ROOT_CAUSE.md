# Browser-print PDF root-cause decision

## Decision

`CASE B — APPLICATION PRINT REGRESSION`

The report model, dedicated PDF and QA state were complete. The live Flutter
host remained `position: fixed` in print media, while `html` computed to zero
height. Chrome therefore paginated only the first surface even though the full
semantic print tree was present.

## Reproduction evidence

The blocked Firebase Preview produced one clipped A4 page for every canonical
fixture, with only 7.51–8.12% of the dedicated-PDF text. Fresh local pre-repair
Chrome reproduction through the visible `/beta/thai` flow confirmed the same
condition for Known and Unknown:

- route `/beta/thai/capture` after completing the normal form flow;
- dialogs/overlays open: 0;
- `#knowme-print-root` present with the full section inventory;
- Known print root: 9,427 text characters / 288,658 HTML characters / 5,151 px;
- `beforeprint` and `afterprint` fired during the user-visible print flow and
  CDP `printToPDF` capture;
- pre-repair computed `body.position=fixed`, `body.height=720px`,
  `html.height=0px`, while the print root was 5,151 px tall;
- browser-print output remained one page, while the dedicated PDF remained
  eight pages.

The raw browser state, screenshots, DOM/style inventory and PDF files are under
`diagnosis/local-pre-repair/`. The earlier blocked-Preview proof is preserved in
`product-acceptance/thai-report-experience-and-annual-infographic-production-release/`.

## Why Cases A and C are excluded

Case A is excluded because the same failure occurs after the report is visibly
ready, with no dialog or infographic overlay open, the semantic print root
selected, and actual `beforeprint`/`afterprint` events observed. The capture did
not target a modal or canvas surface.

Case C is excluded because the one-page result is deterministic on the blocked
Firebase Preview and the local release build before repair, for both Known and
Unknown. The repaired build changes the computed host geometry and restores
seven-page pagination without changing report content.

## Minimal repair

`lib/features/thai_beta/presentation/export/thai_beta_browser_print.dart` now
resets `position: static !important` on both `html` and `body` inside
`@media print`. It also restores the browser-default 8 px body margin used by
the Owner-approved Revision 4 standalone browser-print artifacts. No screen
style, report structure, canonical copy, dedicated-PDF layout or infographic
design changed.

The focused regression in
`test/validation/thai_beta/thai_report_vnext_artifact_generation_test.dart`
locks the host reset, semantic print-root selection and approved margin.

## Post-repair proof

Fresh real-Chrome output covers all seven required fixtures:

- browser-print: 7 PDFs / 49 pages, seven pages per fixture;
- dedicated: 7 PDFs / 56 pages, eight pages per fixture;
- total: 14 PDFs / 105 pages;
- approved section/text parity: 100% for every fixture;
- dialogs, console errors, page errors and request failures: 0;
- post-repair computed `body.position=static` and nonzero `html` height;
- Known and Unknown fail-closed behavior preserved;
- `monthlyTimelineAvailable=false` and no monthly output.

Revision 4 render comparison found 91/105 byte-identical pages. The remaining
14 are page 2 infographic rasters from the two PDF runtimes. Their differences
are limited to runtime antialiasing; all 14 were manually compared against the
approved counterparts and have identical reader-visible title, copy, geometry,
color, and content. No clipping, overlap, omission, duplicate section or visual
design change was found. Manual visual QA passes 105/105.
