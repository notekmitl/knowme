# Thai Report Browser-print PDF Repair V1

## Status

`LOCAL REPAIR GATES PASSED — REPAIR PR AND RELEASE PENDING`

The previous PR #100 Production release was blocked because real Chrome emitted
one clipped browser-print page although the full semantic report existed. Fresh
diagnosis proves Case B: the Flutter host retained `body.position=fixed` and
`html.height=0` in print media. The minimal print-only repair resets the host to
static flow and preserves the approved standalone 8 px body geometry.

No canonical copy, approved reader-visible output, dedicated-PDF layout,
infographic design, expected output, golden, R1–R7.1 artifact or monthly feature
changed. Production is still release `1787038542564000`, version
`5f98dfffef913e38` at this checkpoint. PR #102 remains Closed and unmerged;
`monthlyTimelineAvailable=false`.

## Local acceptance

| Gate | Result |
| --- | --- |
| Browser-print PDFs | 7/7; 49/49 pages |
| Dedicated PDFs | 7/7; 56/56 pages |
| Total PDF visual QA | 14/14; 105/105 pages |
| Semantic section/text parity | 100%; reader-visible delta 0 |
| Revision 4 render comparison | 91 byte-identical; 14 antialias-only pages manually passed |
| Infographic title/identity | 15/15 at 1080×1920 |
| Focused browser-print | 3/3 |
| Focused copy/layout | 11/11 |
| Copy audit | 300 profiles / 4,407 fields; all impact counts 0 |
| Known/Unknown | 62/62 |
| Screenshots | 24/24 |
| Life Map | 32/32 |
| Matrix | 864/864; each weekday 108/108 |
| Authoritative R7 original runner | 286/286 |
| Canonical/live-asOf/S008 | 36/36; canonical mismatch 0 |
| Canonical Web/PDF | 5/5 |
| Claim traceability | 170/170 |
| VM×2 / real Chrome×2 | byte-exact; mismatch 0 |
| Scoped analyzer | 0 diagnostics |
| Full analyzer | branch 297 / main 297 / branch-only 0 |
| Full suite | branch 2,942 passed / 37 baseline failures; main 2,941 / 37; branch-only 0 |
| Web release build | PASS on Flutter 3.41.1 / Dart 3.11.0 |
| R7.1 | 10,709,328 bytes / 80 entries / 79/79 checksums / accepted SHA |
| R7 immutable comparison | 63/63; mismatch 0; modified paths 0 |

The full-suite and analyzer nonzero totals are reconciled against exact pinned
main `0095494a5218289535d587f0c2887a5daa07b4d1`; no branch-only failure or
diagnostic identity exists. The repair branch adds one passing regression test.

## Evidence map

- `ROOT_CAUSE.md`: Case B proof and exclusion of Cases A/C.
- `VISUAL_QA.md`: 14-PDF / 105-page visual decision.
- `diagnosis/`: blocked-state and local pre/post-repair Chrome evidence.
- `acceptance/local-final-seven/`: final seven-fixture Chrome flow and PDFs.
- `acceptance/final-validated-artifacts/`: final 14 PDFs and approved HTML copies.
- `pdf-renders/local-final/`: 105 uniquely named renders.
- `pdf-contact-sheets/local-final/`: source-labelled comparison sheets.
- `logs/`: raw tests, analyzers, builds, QA and deterministic comparisons.
- `pre-change-provenance.txt`: exact 28-path generated-output restore authority.
- `SHA256SUMS.txt`: final packet manifest, regenerated after documentation.

Logs from failed harness/debug invocations are retained with explicit pre-repair,
rerun or diagnostic names and are not acceptance results. Authoritative results
use the `final` names documented above.

The next success-only steps are a non-force repair PR, verified merge, one fresh
post-merge build, a new Firebase Preview QA run, and only then a Production
Hosting release from the same build. No Merge or Firebase mutation has occurred
at this checkpoint.
