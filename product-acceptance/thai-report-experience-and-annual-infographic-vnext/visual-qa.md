# Visual QA — Revision 4

Revision 4 was inspected from final artifact bytes, not widget geometry alone.

- Infographic: 15/15 SHA-bound originals and five unique-labelled sheets; title/year, hierarchy, bounds, stress copy and 2569/2570 boundary pass.
- The viewer can omit the title while rendering byte-identical PNG content; SHA-bound/contact-sheet evidence and the direct pixel validator prevent this preview defect from being mistaken for stored-file loss.
- PDFs: dedicated 7×8 pages and browser print 7×7 pages; 14 PDFs / 105 source-labelled renders, failures 0, 32 contact sheets. Infographic page 2 contains the title in both output paths; Owner Known page 1 remains intact.
- Web: 360 and 390 Known/Unknown at top/middle/bottom, 12/12 fresh screenshots with no invented monthly visualization.
- No clipping, blank page, overlap, off-canvas text, missing section, birth-detail leakage or fake data chart was found.

Evidence: `generated-artifacts/revision-4/`, `visual-qa/revision-4/`, `web-screenshots-revision-4/`, `pdf-page-one-gate-revision-4-result.json` and `revision-4-infographic-title-integrity-result.json`. Technical visual QA passes and the Owner approved all 15 infographics, Web/dedicated PDF/browser-print presentation and 14 PDFs / 105 pages. `monthlyTimelineAvailable=false`; monthly timeline remains BLOCKED. Deploy and Firebase mutation are not authorized.
