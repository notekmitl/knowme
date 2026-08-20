# Thai Report Experience and Annual Infographic Production Release

## Outcome

`PREVIEW QA BLOCKED — PRODUCTION NOT DEPLOYED`

The Owner-authorized release was stopped at the Firebase Preview gate on
2026-08-20. The one-time Web build deployed byte-for-byte to the Preview
channel, the five live dedicated PDFs were complete, and the live annual
infographics were valid. However, Chrome browser-print output from the real
Preview application was clipped to one page for all five canonical fixtures.
The missing pages violate the mandatory browser-print, semantic parity, and
all-page visual gates. This release task does not authorize a source repair, so
Production was not deployed.

Production remains release `1787038542564000`, Hosting version
`5f98dfffef913e38`. A final read-only Firebase channel query after the failure
confirmed that identity. No rollback was needed because Production never
changed.

## Bound identities

- Source and application commit: `46d7883bca87570950eb84a7ca3dffbb3e6653b3`
- PR #100 merge commit: `1a562c6a5c93d89485f70f9bba7820f018b2849f`
- PR #100 accepted HEAD: `18f10ba23dfdb193e41241db31dc0c2336c07023`
- PR #100 accepted application tree: `1f1aceaeb3a2567a3d39f850756ef4f837c41344`
- Build asset entries: 77 deployed files
- Build payload bytes: 44,246,367
- Build manifest SHA-256: `2008BBBACC075DDF126DF766E2AB630B5BB599C95F7A52E0E58D54B2A97DBC85`
- Flutter 3.41.1 (`582a0e7c55`) / Dart 3.11.0
- Actual pinned executable: `C:\Users\USER\Documents\Knowme\flutter-3.41.1-sdk\bin\flutter.bat`
- Preview channel: `pr100-rpt-release-20260820`
- Preview URL: `https://knowme-app-694e1--pr100-rpt-release-20260820-fmqyrd1t.web.app`
- Preview release/version: `1787218038705000` / `397d3a927a64bd5d`

The pre-change provenance line naming the non-`-sdk` Flutter path is corrected
by the raw build/test logs and this record: every authoritative command used
the pinned `flutter-3.41.1-sdk` executable above, which reports the required
Flutter/Dart versions.

## Fresh pre-deploy gates

| Gate | Fresh result |
| --- | --- |
| Focused report/copy/layout | 11/11 |
| Copy ledger | 300 profiles / 4,407 fields; all reader-visible impact counts 0 |
| Known/Unknown | 62/62 |
| Screenshot regression | 24/24 |
| Life Map | 32/32 |
| Matrix | 864/864; each weekday 108/108 |
| Authoritative R7 runner | 286/286 |
| Live-asOf/canonical/S008 focused | 25/25 |
| Scoped analyzer | 0 diagnostics across 6 scoped paths |
| Full analyzer | 297 diagnostics, exact accepted identity; new class/delta 0 |
| Full Flutter suite | 2,941 passed / 37 accepted failures; branch-only failures 0 |
| Report-vNext VM×2/Chrome×2 | byte-exact, mismatch 0 |
| Live-asOf VM×2/Chrome×2 | 300 profiles/run; canonical/report/narrative mismatch 0 |
| S008 | raw VM/Chrome differs by one ULP; canonical mismatch 0 |
| Canonical Web/PDF | 5/5 |
| Claim traceability | 170/170 |
| Rejected phrase scan | 0 hits |
| R7.1 | 10,709,328 bytes / 80 entries / accepted SHA; checksums 79/79 |
| R7 immutable comparison | 63/63; mismatch 0 |
| R1–R7.1 modified paths | 0 |

Raw preflight failures are intentionally retained with names such as
`*-invalid-wrapper-invocation*`, `*-sandbox-*`, and
`*-dependency-preflight-failure*`. They are not acceptance results. The final
authoritative reruns are the matching logs without those suffixes.

## Build-once and Hosting records

`flutter build web --release --no-pub` succeeded once. The build was not
rebuilt. Firebase ignores `.last_build_id`; the 77 deployable files were hashed
before deployment and every Preview asset matched its path, byte size, and
SHA-256 (missing 0, mismatch 0). Required routes `/` and `/beta/thai` returned
HTTP 200. Real Chrome desktop/mobile smoke had application console errors 0.

Rollback readiness cloned unchanged Production version `5f98dfffef913e38` to
channel `pr100-rpt-rollback-20260820`; the older V1.4 rollback version
`10af10c6d960d590` also remains available. Neither clone changed Production.

## Preview product QA

All five canonical forms reached the real report in Chrome with exact input
identity. Dedicated PDF and annual infographic results passed:

- dedicated PDFs: 5/5, 8 pages each, 40/40 pages visually reviewed;
- Owner Known: Aquarius 19°19′ present;
- regression 00:03: Aquarius 9°24′ present;
- Unknown: fail-closed text present;
- infographics: 5/5 canonical plus mobile save, each 1080×1920;
- title raster `ดวงชะตาปี 2569`, categories, icons, opportunity/caution, and
  no monthly visualization were visually present;
- browser/page/console errors affecting the flow: 0.

The browser-print gate failed 0/5. Each print PDF had one page and only
7.51–8.12% of the extracted characters in its corresponding dedicated PDF.
Manual inspection confirms each file ends inside the annual infographic and
omits the remaining report sections.

Computed print-media diagnostics for Owner Known prove that content generation
itself was complete: `#knowme-print-root` existed, contained 9,366 characters,
had 300,474 HTML characters and measured 4,979.70 px high. At the same time the
live page computed `body.position=fixed`, `body.height=8000`, and
`html.height=0`. Chrome emitted only one A4 page with 732 extracted characters.
See `PREVIEW_QA_BLOCKER.md` and `logs/preview-known-browser-print-metrics.json`.

The earlier deterministic 15-fixture source gate remains 15/15, but it is not
substituted for the failed live Preview browser-print gate. Once the mandatory
failure was confirmed, remaining Preview stress work and all Production QA were
not run.

## Deferred monthly scope

PR #102 remains closed and unmerged because no authoritative month-level source
exists. `monthlyTimelineAvailable=false` remains unchanged. No Monthly Timeline,
month name, month highlight, or inferred month-level claim was added.

## Firebase scope

Only Firebase Hosting Preview channels changed: the rollback-readiness clone and
the candidate Preview. No Production release, rollback release, Firestore, Auth,
Functions, Storage, Remote Config, Rules, or Index mutation occurred.

## Evidence map

- `pre-change-provenance.txt` — immutable starting state and exact restore list.
- `logs/` — raw tests, analyzers, builds, Firebase records, browser runs, and
  deterministic reconciliation.
- `build-asset-manifest.txt` and `preview-asset-verification.txt` — build/deploy
  byte identity.
- `preview-artifacts/` — real canonical-five dedicated/browser-print PDFs and
  downloaded infographics.
- `pdf-renders/preview/` — 45 uniquely named page renders.
- `pdf-contact-sheets/preview/` — one identity-labelled sheet per PDF.
- `screenshots/` — uniquely named desktop/mobile Preview evidence.
- `predeploy-artifacts/` — fresh deterministic 15-fixture PNG and 14-PDF gate.
- `PREVIEW_QA_BLOCKER.md` — failure table, root-cause proof, and repair boundary.
- `VISUAL_QA.md` — manual visual review record.
- `SHA256SUMS.txt` — every payload file except the manifest itself. Its final
  entry/byte/hash identity is recorded in the documentation PR and handoff.
