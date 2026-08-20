# V1.5 PR #100 Report Experience Production Release Record

## Status

`PREVIEW QA BLOCKED — PRODUCTION NOT DEPLOYED`

The Owner-authorized Production release began from `origin/main`
`46d7883bca87570950eb84a7ca3dffbb3e6653b3`, which contains merged PR #100
(`1a562c6a5c93d89485f70f9bba7820f018b2849f`). All mandatory fresh pre-deploy
technical gates passed and one Flutter Web release build was created.

The build deployed to Firebase Hosting Preview release `1787218038705000`,
version `397d3a927a64bd5d`. Preview assets matched 77/77 and the live five
dedicated PDFs and canonical infographics passed. The real browser-print path
then failed 5/5: Chrome emitted one clipped page per fixture instead of the
complete report. Computed print diagnostics bind the failure to the live Flutter
host (`body.position=fixed`, `html.height=0`) despite complete semantic print
markup.

Because this task forbids source repair and Production verification could not be
made complete, Production was not deployed. No rollback was necessary.
Production remains release `1787038542564000`, Hosting version
`5f98dfffef913e38`. Only Hosting Preview channels changed; no other Firebase
service changed.

PR #102 remains closed and unmerged. Monthly Timeline remains
`DEFERRED — NO AUTHORITATIVE MONTH-LEVEL SOURCE`, and
`monthlyTimelineAvailable=false` remains unchanged. R1–R7.1 are immutable.

Evidence is in
`product-acceptance/thai-report-experience-and-annual-infographic-production-release/`.
Its final `SHA256SUMS.txt` covers 427 entries / 168,275,924 payload bytes with
missing 0, mismatch 0, unlisted 0; manifest SHA-256 is
`59046E5BA89009CC10F256A02F0F861B0A16D7E6F4027E6A757D4D9EAD3D0BDA`.
A separate Owner-authorized print-host repair and complete fresh release rerun
are required before Production can be updated.
