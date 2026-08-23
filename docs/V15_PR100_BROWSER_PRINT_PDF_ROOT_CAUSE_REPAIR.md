# V1.5 PR #100 Browser-print PDF Root-cause Repair

## Pre-merge status

The blocked PR #100 Preview behavior is classified as
`CASE B — APPLICATION PRINT REGRESSION`. The complete semantic report is
present, no dialog/overlay is open and actual print events fire, but Flutter's
host keeps `body.position=fixed` while `html.height=0`; Chrome therefore emits
one clipped page. The defect reproduces on the blocked Preview and the local
pre-repair release build for Known and Unknown, excluding QA-state and
environment-only explanations.

The minimal repair changes only print-media host geometry in
`thai_beta_browser_print.dart`: `html` and `body` become static for print, and
the approved standalone 8 px body margin is restored. One focused regression
test and three evidence/QA helpers accompany the repair. No report copy,
canonical text, dedicated-PDF layout, infographic design, expected output,
golden, R1–R7.1 artifact or monthly feature changes.

Fresh local Chrome acceptance passes seven browser-print PDFs at seven pages
each and seven dedicated PDFs at eight pages each: 14 PDFs / 105 pages, semantic
coverage 100%, reader-visible delta 0 and manual visual QA 105/105. Ninety-one
renders are byte-identical to Owner-approved Revision 4; the remaining 14 are
the infographic page in both PDF runtimes and were visually confirmed identical
apart from antialiasing. Infographic identity passes 15/15.

Technical gates pass on Flutter 3.41.1 / Dart 3.11.0: focused 3/3 and 11/11,
Known/Unknown 62/62, screenshots 24/24, Life Map 32/32, matrix 864/864,
authoritative R7 286/286, canonical/live-asOf/S008 36/36, Web/PDF 5/5,
traceability 170/170, VM×2/Chrome×2 mismatch 0, scoped analyzer 0, full analyzer
branch/main 297/297 with branch-only 0, and full suite branch 2,942/37 versus
main 2,941/37 with identical 37 failure IDs and branch-only 0. Web release build
passes.

R7.1 remains 10,709,328 bytes / 80 entries / SHA-256
`9E541F21C68FDAD93BC595C55BD0BE23600F88454CFBA7FAB6C713FE53F79E58`,
with checksums 79/79, immutable comparison 63/63 and R1–R7.1 modified paths 0.
PR #102 is Closed and unmerged. `monthlyTimelineAvailable=false`.

At this pre-merge checkpoint Production remains Hosting release
`1787038542564000`, version `5f98dfffef913e38`. Deployment is permitted only
after the repair PR merges and the success-only post-merge Preview gate passes
using the exact one-time Production candidate build.
