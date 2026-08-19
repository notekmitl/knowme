# Thai Report Experience and Annual Infographic vNext

## Revision 4 scope and finding

Draft PR #100 Revision 4 closes the infographic title-integrity evidence gap while preserving accepted V1.5/R1–R7.1 content. The Owner correctly observed at least three Revision 3 previews without `ดวงชะตาปี 2569`; byte/pixel proof shows the corresponding stored PNGs contain the title and all 15 Revision 3/4 PNG pairs are byte-identical. The divergence is in preview rendering after file identity, not the shared model, widget, layout or capture bytes.

Revision 4 therefore changes the test/evidence path, not the application layout: all 15 generated PNGs are reopened and checked for model title, exactly one widget and semantics value, safe in-canvas bounds, 1080×1920, fixture/sidecar/SHA identity, non-background title pixels and repeat-capture byte identity. Negative tests reject omissions, off-canvas placement, fixture swaps, stale files and basename collisions. SHA-bound originals and unique-labelled contact sheets prevent ambiguous review identities.

## Fresh evidence

- infographic final raster 15/15; manual original-resolution review 15/15; five contact sheets
- browser print 7×7 pages and dedicated PDF 7×8 pages; 14 PDFs / 105 unique renders / failures 0
- 12 fresh Web screenshots at 360/390 for Known/Unknown
- copy audit 300 profiles / 4,407 fields, all semantic/omission/addition/traceability impacts 0
- Owner copy and visual decision: Pending

## Technical gates

- focused 13/13; Known/Unknown 62/62; screenshots 24/24
- Life Map 32/32; matrix 864/864; exact R7 runner 286/286
- full suite branch/main 2,941/37 vs 2,925/39; branch-only 0, main-only 2
- scoped analyzer 0; full analyzer 297/299; branch-only 0, main-only 2
- VM×2/Chrome×2 exact 133,592 bytes, mismatch 0
- production-equivalent Web build passed without deployment
- R7.1 ZIP/checksums/63-file immutable identity, canonical 5/5 and claims 170/170 passed; R1–R7.1 modified paths 0

## Stop point

The engine does not expose validated calendar-month scores. `monthlyTimelineAvailable=false`; monthly content remains BLOCKED and is not invented. PR #100 must remain Open, Draft and unmerged. No Merge, Deploy or Firebase change is authorized. Production remains V1.5 Hosting release `1787038542564000`, version `5f98dfffef913e38`.
