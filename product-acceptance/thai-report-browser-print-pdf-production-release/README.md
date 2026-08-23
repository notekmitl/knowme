# Browser-print PDF Production Release Evidence

## Final status

`DEPLOYED AND VERIFIED — NO ROLLBACK REQUIRED`

This packet binds the Case B browser-print repair to repair PR #104, merge
commit `05c233a6759730d29b6cf7170d16b738e760d4b7`, one Flutter Web release build,
the replacement Preview channel and the Production Hosting release. The build
was created once with Flutter 3.41.1 / Dart 3.11.0 and the same `build/web`
directory was deployed to both environments without a rebuild.

The original PR #100 application/report experience remains the accepted
reader-visible baseline. No report copy, canonical text, dedicated-PDF layout,
infographic design, expected output, golden, R1–R7.1 artifact or monthly feature
changed in the repair or release.

## Release identities

| Item | Identity |
| --- | --- |
| Pinned pre-repair main | `0095494a5218289535d587f0c2887a5daa07b4d1` |
| Repair commit | `34da4ca2d58d4acaef411265ceb2383d883efdb0` |
| Repair PR | #104, regular merge, source branch retained |
| Repair merge | `05c233a6759730d29b6cf7170d16b738e760d4b7` |
| Merge parents | `0095494a5218289535d587f0c2887a5daa07b4d1`, `34da4ca2d58d4acaef411265ceb2383d883efdb0` |
| Merge time | `2026-08-23T10:22:49Z` |
| Build asset manifest | 77 entries / 44,246,432 bytes / SHA-256 `0CE308A01A3C913C9A7DF39476D60BE97BAC93C9F3CF8DD545513E4FC9DBEBE8` |
| Preview | release `1787481247171000`, version `dedf5b2acf6e17c4` |
| Production | release `1787482140137000`, version `e563b9b6df94ef81` |
| Production release time | `2026-08-23T10:49:00.137Z` |
| Rollback-ready version | `5f98dfffef913e38` on channel `pr100-print-repair-rollback-20260823` |

The repair merge tree `376eebd8c87dd0df0b92afecdf51c43d020c6936`
is byte-identical to the repair PR tree. Unexpected merge-tree diff is 0.

## Root cause and repair

The defect is `CASE B — APPLICATION PRINT REGRESSION`. Real Chrome on the
blocked Preview and the local pre-repair build contained the complete semantic
report, no dialog/overlay, the expected route and real `beforeprint`/
`afterprint` events, but retained `body.position=fixed` with `html.height=0`.
Chrome therefore printed one clipped page. Case A is excluded by the correct
visible-flow/capture state and Case C by deterministic reproduction in both
environments.

The minimal application repair resets only print-media host geometry in
`lib/features/thai_beta/presentation/export/thai_beta_browser_print.dart`:
`html` and `body` use static flow and the approved standalone 8 px body margin.
One focused regression and evidence helpers were added. Reader-visible delta is
0.

## Post-merge gates

| Gate | Result |
| --- | --- |
| Focused print/copy | 14/14 |
| Known/Unknown + screenshots + Life Map/matrix | 118/118 |
| R7 + live-asOf/canonical/S008 | 322/322 |
| Scoped analyzer | 0 diagnostics |
| Full analyzer | 297 accepted / 297 fresh; fresh-only 0 |
| Full suite | 2,942 passed / 37 accepted baseline failures; fresh-only 0 |
| Authorized generated-output restoration | 28/28; identity mismatch 0 |
| Web release build | PASS; run once after merge |

The 37 full-suite failures and 297 analyzer diagnostics are the exact accepted
baseline identities. No branch/fresh-only failure or diagnostic exists.

## Preview and Production verification

Both environments passed the same gates:

| Gate | Preview | Production |
| --- | --- | --- |
| Build assets | 77/77 | 77/77 |
| Routes `/`, `/beta/thai` | 200 / 200 | 200 / 200 |
| Real Chrome fixtures | 7/7 | 7/7 |
| Browser-print PDF | 7/7; 49/49 pages | 7/7; 49/49 pages |
| Dedicated PDF | 7/7; 56/56 pages | 7/7; 56/56 pages |
| Semantic section/text parity | 100% | 100% |
| Reader-visible delta | 0 | 0 |
| PDF visual QA | 105/105 | 105/105 |
| Console/page/request errors | 0 / 0 / 0 | 0 / 0 / 0 |
| Mobile Known/Unknown | PASS at 390x844; overflow 0 | PASS at 390x844; overflow 0 |
| Canonical Web/PDF | 5/5 | 5/5 |
| S008 canonical mismatch | 0 | 0 |
| Infographic identity/title | 15/15 at 1080x1920 | 15/15 at 1080x1920 |
| Monthly Timeline | unavailable; no fake content | unavailable; no fake content |

The infographic result is bound by the accepted 15-fixture final-raster gate at
the byte-identical repair tree, the one-build provenance, 77/77 remote asset
identity in each environment and the seven live embedded infographic pages.
Every live title reads `ดวงชะตาปี 2569` for the 2569 fixtures. The year-boundary
2570 fixture retains its separately approved year-aware title contract.

The 105-page render comparison in each environment has 91 byte-identical pages
and 14 page-2 raster differences caused only by infographic antialiasing. All 14
differences were inspected with source-labelled contact sheets and match the
Owner-approved Revision 4 content and geometry. No blank page, clipping,
overlap, duplicated section, omission or addition exists.

## Immutable and deferred scope

- R7.1: 10,709,328 bytes / 80 entries / SHA-256
  `9E541F21C68FDAD93BC595C55BD0BE23600F88454CFBA7FAB6C713FE53F79E58`.
- R7.1 checksums: 79/79; immutable comparison: 63/63; R1–R7.1 modified paths: 0.
- PR #102 remains Closed and unmerged; its source branch is retained.
- `monthlyTimelineAvailable=false`; Monthly Timeline remains deferred because
  no authoritative month-level source exists.
- No fake monthly record, opportunity/caution month or monthly Web/PDF/PNG was
  created.

## Firebase scope

Only Firebase Hosting changed: rollback-readiness Preview, release Preview and
Production Hosting. Firestore, Auth, Functions, Storage, Remote Config, Rules
and Indexes were not changed. Production verification passed, so rollback was
not executed.

## Evidence map

- `logs/`: build, pre-deploy, asset, route and Firebase records.
- `preview/`, `production/`: real Chrome flow screenshots, 14 PDFs per
  environment and structured QA records.
- `preview-mobile/`, `production-mobile/`: Known/Unknown 390x844 browser QA.
- `preview-renders/`, `production-renders/`: 105 uniquely named renders per
  environment; filenames include their environment.
- `preview-contact-sheets/`, `production-contact-sheets/`: seven labelled
  Owner-approved/current comparisons per environment.
- `VISUAL_QA.md`: all-page visual decision and fixture matrix.
- `FIREBASE_RELEASE_RECORD.md`: Hosting mutation and rollback readiness.
- `tools/`: exact release-verification helper snapshots.
- `SHA256SUMS.txt`: packet manifest generated after final documentation.

