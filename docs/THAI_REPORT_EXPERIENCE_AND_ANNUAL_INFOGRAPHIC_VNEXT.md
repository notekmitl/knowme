# Thai Report Experience and Annual Infographic vNext

## Scope

Draft PR #100 Revision 2 repairs Owner-review artifacts and reader-facing candidate copy without changing accepted V1.5/R1–R7.1 canonical content. Web, dedicated PDF, browser print and annual infographic continue to use one shared presentation model.

## Product behavior

- Web and both PDF paths preserve exact section order, heading, paragraph, annual classification and Unknown omission rules
- dedicated PDF remains purpose-built A4; browser print is semantic multi-page A4 HTML
- annual infographic exports exactly 1080×1920 and appears after the shared summary
- Known/Unknown use the same hierarchy and font sizes; repaired wrapping and decorative spacing prevent clipping at 360/390 px and in print
- decorative arcs and the four-petal ornament contain no month labels, axes or data points
- candidate copy is opt-in with `applyReaderCopy=true`; accepted V1.5 default and canonical R1–R7.1 remain unchanged

## Owner-review evidence

Packet: `product-acceptance/thai-report-experience-and-annual-infographic-vnext/OWNER_REVIEW_INDEX.md`

- 300 profiles / 4,003 Revision 2 fields; 45 active grouped rules; omission, addition, semantic, prediction↔advice and traceability impact all 0
- prior 2,105-field ledger preserved for provenance
- 15 infographic fixtures including canonical five and stress cases
- dedicated PDF: 7 fixtures × 8 pages; browser print: 7 fixtures × 7 pages; rendered 105/105 pages
- Web mobile evidence at 360×800 and 390×844 for Known and Unknown
- Owner copy and visual decision: Pending

## Technical gates

- focused Revision 2 105/105; layout/export/screenshot 98/98
- full suite branch 2,940 passed / 37 failed vs exact main 2,925 / 39; branch-only failures 0
- analyzer scoped 0; full branch/main 297/299; branch-only diagnostics 0
- Life Map 32/32; matrix 864/864; R7 original runner 286/286
- VM/Chrome exact parity: 133,841 bytes, SHA-256 `2726315A625CF8AF0999EE27B673EBBDF1DA22EC24BB34A0B52AF79C74D5E093`
- Web release build passed without deploy
- R7.1 ZIP/checksums/63-file immutable identity passed; R1–R7.1 modified paths 0

## Stop point

The engine does not provide validated calendar-month scores or classifications with deterministic ordering and claim provenance. Annual narrative is not converted into invented months, so `monthlyTimelineAvailable` remains false and the monthly timeline is BLOCKED pending a separately authorized engine contract.

PR #100 must remain Open, Draft and unmerged. No Merge, Deploy or Firebase change is authorized. Production remains V1.5 Hosting version `5f98dfffef913e38`.
