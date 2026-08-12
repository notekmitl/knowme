# V1.4 Production PDF pagination hotfix

## Production evidence

The initial V1.4 deployment from `0c3d1ef9d083502aa5f1ddae67b9acd23acecbed` exposed a defect in real downloads from `https://knowme-app-694e1.web.app`:

- Known: `knowme-thai-report (18).pdf`, 37,305 bytes, SHA-256 `5CE22BC8B80B00DE0ECF693DC9F52EA85186D1C4A5AF7CBFA0B169E56F015A30`, 7 pages; page 7 was empty except for its footer.
- Unknown: `knowme-thai-report (19).pdf`, 33,602 bytes, SHA-256 `87D0B21982B1929BA3DD1F7674EC2611DB586639C398C03A5EFF8968B750B8E6`, 6 pages; page 6 contained the complete omission card and was not blank.

## Root cause

`ThaiBetaReportExportButton` calls `ThaiBetaReportPdfExporter.buildBytes`, so Production and automated artifact generation share the same exporter. The exporter used `pw.MultiPage` for measured pagination but also inserted an unconditional `pw.NewPage()` at a content-index marker inside the reading-basis section. That marker was intended only to add an accepted continuation heading.

The marker did not represent a measured page boundary. When preceding content already filled a page naturally, `MultiPage` advanced before processing the forced break and the additional `pw.NewPage()` advanced again. In the Known Production fixture this left a footer-only seventh page. In the Unknown fixture it displaced the atomic omission card onto a sixth page. Font loading, browser device-pixel ratio, DOM measurement, and asynchronous Web font readiness were ruled out: the downloadable PDF uses bundled fonts and the Dart `pdf` renderer rather than browser print layout.

## Why prior gates missed it

The accepted r16 evidence used the fixed 1982-06-06 fixture and remained 6/5 pages. Production verification used 2001-01-15, whose different age/timeline prose placed the forced marker at a different measured boundary. The existing raster gate permitted up to 32 Known and 30 Unknown pages and checked only forbidden-margin ink; it did not assert 6/5 pages or reject blank/footer-only pages. Canonical parity checked text, not pagination.

## Fix

The hotfix removes the forced page break. The continuation heading and its intended paragraph now form one atomic pagination unit, allowing `MultiPage` to place them together at the measured boundary. No margins, font sizes, text, cards, calculations, or content ordering changed. `ThaiBetaPdfRenderResult` now exposes the final renderer page count so the real download path can be asserted directly.

## Regression and local evidence

- Production fixtures 2001-01-15: Known 6 pages; Unknown 5 pages.
- Accepted fixtures 1982-06-06: Known 6 pages; Unknown 5 pages.
- Poppler raster gate requires exact 6/5 counts, body ink on every page, and no ink outside printable margins.
- Local Production-fixture Known: 36,416 bytes, SHA-256 `30ED523F28DFCAFF04DD1615103859183BD799511CE2FF2AA2E653B8C73CF87B`.
- Local Production-fixture Unknown: 32,256 bytes, SHA-256 `5FE3C84669F82CD0DB28D43C43E0420BF67F42677F8EF6308D2E92871AD67E88`.
- All 11 local pages were rendered at 150 DPI and inspected. No blank/footer-only page, clipping, overlap, truncation, out-of-bounds text, broken Thai wrapping, or card-border escape was found.
- Accepted canonical hashes remain unchanged: Known `AAB53A53DD8699365E5EDAD1F57C61ABCB4A7A69FD90D6E99E4B940C0987FC10`; Unknown `43274E0CEDAA187CFF51879B77547D1C6746E497FF57CCB2ECDB0540F87FDF99`.
- Focused exporter/parity/acceptance/core/audit suite passed 93/93. The complete repository suite finished at 2,861 passed / 39 failed: the same 39 documented baseline failures and three additional passing hotfix regressions, with zero new failure. Analyzer remains exactly the documented 299 warning/info baseline.

Production remains defective until this hotfix is merged and redeployed. Rollback remains available through Firebase Hosting release history.
