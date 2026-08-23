# V1.5 PR #100 Browser-print PDF Production Release

## Outcome

The PR #100 Thai report experience is deployed and verified after the Case B
browser-print repair. Repair PR #104 merged as regular merge commit
`05c233a6759730d29b6cf7170d16b738e760d4b7` at
`2026-08-23T10:22:49Z`. Its parents are pinned main
`0095494a5218289535d587f0c2887a5daa07b4d1` and repair commit
`34da4ca2d58d4acaef411265ceb2383d883efdb0`; merge tree identity is exact and
unexpected diff is 0.

One Flutter 3.41.1 / Dart 3.11.0 Web release build was created from the merge
commit. Its deployable manifest is 77 entries / 44,246,432 bytes / SHA-256
`0CE308A01A3C913C9A7DF39476D60BE97BAC93C9F3CF8DD545513E4FC9DBEBE8`.
The same build directory was deployed to Preview and Production without a
rebuild.

Preview release/version `1787481247171000` / `dedf5b2acf6e17c4` and Production
release/version `1787482140137000` / `e563b9b6df94ef81` pass exact asset 77/77,
routes 2/2, real Chrome console/page/request errors 0, browser-print 7/7 at
49/49 pages, dedicated PDFs 7/7 at 56/56 pages, semantic parity 100% and visual
QA 105/105. Mobile Known/Unknown pass at 390x844 with horizontal overflow 0.
Canonical Web/PDF remains 5/5, S008 mismatch remains 0, Known/Unknown remains
fail-closed and reader-visible delta is 0. The accepted infographic gate remains
15/15 at 1080x1920 and live fixture titles preserve `ดวงชะตาปี 2569`.

Production passed, so rollback was not required. Only Firebase Hosting changed;
Firestore, Auth, Functions, Storage, Remote Config, Rules and Indexes did not.
R7.1 and R1–R7.1 remain immutable. PR #102 remains Closed/unmerged,
`monthlyTimelineAvailable=false`, and Monthly Timeline remains deferred because
there is no authoritative month-level source.

Release evidence is in
`product-acceptance/thai-report-browser-print-pdf-production-release/`.
Its final manifest covers 442 payload files / 46,972,334 bytes; missing,
mismatch and unlisted counts are 0. `SHA256SUMS.txt` SHA-256 is
`16DCE07B32F2D3ABA27F7DBA95513AF3B435B8439FDC612ADDC360AFE467216E`.
