# Thai Report Experience and Annual Infographic vNext

## Scope

This Draft candidate repairs the report experience without changing accepted R1–R7.1 artifacts. It introduces one shared presentation model for the on-screen report, dedicated PDF, browser print and annual infographic, plus a candidate-only Thai copy projection for Owner review.

## Product behavior

- Web and both PDF paths preserve exact section order, heading, paragraph, annual classification and Unknown omission rules
- dedicated PDF remains a purpose-built A4 layout; browser print is semantic A4 HTML rather than a fixed Flutter viewport
- export controls distinguish “ดาวน์โหลดรายงาน PDF” from “พิมพ์ / บันทึกหน้าเว็บเป็น PDF”
- annual infographic exports 1080×1920 and is inserted after the shared summary on Web, dedicated PDF and browser print
- infographic year is derived from Bangkok civil `asOf`; icons are vector, fonts are bundled, and birth details are excluded
- accepted V1.5 remains the default; natural-copy changes are explicit candidate output awaiting Owner approval

## Evidence and gates

Packet: `product-acceptance/thai-report-experience-and-annual-infographic-vnext/`

- candidate corpus: 300 profiles / 2,105 fields; omission, addition, semantic, prediction↔advice and traceability impact all 0
- final PDF pages: dedicated Known 8, Unknown 8; browser print Known 7, Unknown 7
- full suite: branch 2,938/37 vs exact main 2,925/39; branch-only 0, main-only 2
- analyzer: scoped 0; full branch/main 297/299; branch-only 0
- R7 runner 286/286; screenshot 24/24; Life Map 32/32; matrix 864/864
- VM/Chrome byte parity and Web release build pass
- accepted R7.1 ZIP/hash/checksums/63-file immutable identity pass; modified paths 0

## Stop point

The current engine does not provide validated calendar-month scores/classifications with deterministic ordering and claim provenance. Generic “กลางปี” or annual narrative is not converted to months. The infographic therefore omits the 12-month timeline and requests a separate, Owner-authorized engine contract.

This is a Draft PR for copy and visual review. It is not authorized for Merge or Deploy. Production remains V1.5 Hosting version `5f98dfffef913e38`.
