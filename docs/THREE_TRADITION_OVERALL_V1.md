# Overall astrology from three traditions — V1 working branch

Status (2026-09-24): **Draft PR #149 OPEN; anonymous overall calculation fixed
locally and tested against a local API without Firebase/Firestore; Hosted Preview
still runs the older authenticated build; no new deployment or release**. The
five previously affected Production documents were restored and verified before
this change. Historical branch validation passed in
[GitHub Actions run #35824575799](https://github.com/notekmitl/knowme/actions/runs/35824575799)
at commit `c33160d4bf01bd2f0a870d2c50925d700645f8b0`: focused tests,
analyzer, release Web build, PDF dependencies, and the complete Flutter suite.
The local Flutter SDK is available for this revision.

## Reader path

`/beta/thai` → birth form → select **โหราศาสตร์โดยรวม**. The option requires a
known birth time and resolved province because Western V2 needs both. The overall
action now calls `/v1/calculate-bazi` and `/v1/calculate-chart` sequentially.
These new routes accept birth calculation fields only, require no Firebase Auth,
and return charts without calling the Firestore save services. The client sends
no UID, token, name, or profile field. Thai Beta runs its existing local
analysis. The report is composed only when all three return valid results.
The Chinese and Western single-system actions retain their existing signed-in
save flow; their behavior was not changed in this repair.

## Comparison rule

- Use the existing Thai Mirror, BaZi and Western natal theme adapters and their
  registered, nonempty engine evidence. No alteration to the three calculators,
  the readers, Firestore rules, Auth, or the legacy Fusion snapshot format.
- Group one result per lens and theme. Show exact matching themes, or compatible
  themes mapped to the same existing Fusion signal, only when at least two
  *different* traditions support the result. A third compatible lens joins the
  same card. Rank three-lens agreements before two-lens agreements.
- Do not merge a growth-area warning into a positive signal (for example,
  `overthinking` with `analytical`). Do not assert dates or age ranges because
  the available natal outputs do not contain comparable timing evidence across
  all three systems. A zero-agreement chart has an explicit empty state.
- Display the contributing traditions and their distinct meanings on each card.
  The result is calculated in memory and is not written as a new user document.
- Pass the actual submit instant to the Thai analysis runner, which converts it
  to Bangkok civil time once. The existing single-Thai choice now does the same;
  it avoids a second conversion on a device outside the Bangkok time zone.

## Known boundaries and verification

The combined action calls two anonymous, calculation-only endpoints in sequence.
It does not read or write saved charts. A failure in any source does not show a
partial combined report. The existing single-system routes remain independent.
The calculation endpoints are public, so rate limiting and abuse protection
must be reviewed before they are exposed beyond an isolated QA backend.

## 2026-09-24 root-cause repair and isolated verification

The prior selector called `resolveUser` for Overall, then reused
`ThaiBetaAstrologyHandoff.prepare`. That handoff sent the Firebase ID token and
canonical profile to `/v1/generate-bazi` and `/v1/generate-chart`. Both Backend
routes saved the profile, chart, and result mirror to Firestore under that UID.
Because the old Hosting Preview was built with the Production Cloud Run URL,
the silent existing browser session led to the five Production overwrites that
were subsequently restored. The in-memory combined report itself made no write;
its source-generation path did.

The repair adds dedicated calculation-only routes that reuse the existing BaZi
and Western builders. The Overall selector now uses an anonymous handoff and
never resolves a Firebase user. The Backend request models reject `uid` and
`profile`; the response has no `saved_paths`. Authenticated save routes and the
Thai engine are retained. No Firestore rules or schema changed.

Local checks using synthetic birth data: Backend full suite **54/54 PASS**,
including real HTTP calculation responses, no-save guards, rejection of UID and
profile, and continued 401 protection on save routes. Flutter focused feature
and three-system regressions **42/42 PASS**. Scoped analyzer **PASS (0 issues)**.
A mobile-size (390×844) Flutter selection-to-report test called a loopback
Backend started with lifespan off,
so Firebase Admin and Firestore were never initialized. Both HTTP calculations
returned 200 and the full report appeared in **1,608 ms**. This was a local
widget/runtime test, not a live Chrome or Hosted Preview timing measurement.
An isolated release Web build succeeded; its bundle contains the loopback API
URL and both calculation paths, and does not contain the Production API URL.

The current Hosted Preview still serves its older authenticated bundle and
Production API. A read-only download on 2026-09-24 matched the old bundle
SHA-256
`8479C6E1A9112F20914280D5834C9001308F0116545BBCEC366FF3638437AFBA`:
it contains the Production API and `/v1/generate-*` paths but neither
`/v1/calculate-*` path. It does **not** contain this repair and must not be
used to claim anonymous Overall QA. A new Preview build plus an isolated Backend with
the calculation routes are required for hosted end-to-end QA. Neither has been
deployed in this repair. The temporary exact Preview CORS entry remains live on
the Production Backend and still needs a separately reviewed removal revision.

Focused tests cover three matching lenses, exact plus similar themes, source
deduplication, empty evidence, growth-area exclusion, real Thai engine output,
the selector's known/unknown time and failure paths, single Bangkok conversion,
and mobile/desktop widget layouts. The draft workflow uses Flutter 3.41.1,
`TZ=Asia/Bangkok`, Poppler and Python `pypdf`, focused Flutter tests, the analyzer,
a release Web build, and the complete Flutter suite. This matches the timezone and PDF
dependencies used by the repository's earlier successful Flutter workflow.

The first full-suite attempt (run #35822200056) passed focused tests and
analyzer, then reported seven failures: four Bangkok civil-time assertions,
two missing-Poppler PDF gates, and one runtime evidence comparison affected by
the time value. The failing test files and Thai runner were unchanged from
`main`. Run #35823155332 passed focused tests, analyzer and Web build; installing
Poppler removed one missing-tool failure, while the real PDF parity script
then exposed its additional `pypdf` dependency. The final candidate workflow
includes both PDF dependencies and Bangkok time. Run #35824575799
completed successfully with all tests passing.

The historical validation described here preceded the anonymous repair.
Hosted browser QA and Owner review of the combined Thai wording remain open.

## Live Hosting Preview verification

The seven-day Preview channel `pr-149-overall-v1` serves
`https://knowme-app-694e1--pr-149-overall-v1-nr8oa6e0.web.app` until
`2026-09-30T07:23:50Z`. Its release Web build is from application source
`d56946d`, uses the configured Production Cloud Run API, passed the official
bundle validator and four explicit localhost/loopback guards, and has cache pin
`d56946d`. `main.dart.js` is 8,557,552 bytes with SHA-256
`8479C6E1A9112F20914280D5834C9001308F0116545BBCEC366FF3638437AFBA`.

Backend commit `2edf7a9` adds only the exact Preview URL to the explicit
production-origin list in `backend/app/main.py`; no wildcard is present.
Backend full tests pass `51/51`, the endpoint verifier passes `5/5`, and local
plus live CORS matrices accept both Production origins and the exact Preview
origin while rejecting an unrelated origin with `HTTP 400` and no allow-origin
header. Cloud Run revision `knowme-astrology-api-00014-j2z` receives 100%
traffic with the same CPU, memory, concurrency, timeout, instance bounds, CPU
allocation, startup boost, and environment as rollback revision
`knowme-astrology-api-00013-zc8`. The deploy took `224.895 s`. Production
Hosting, Firestore rules, Auth configuration, Functions, Storage, indexes, and
the PR merge state were not changed.

Real Chrome at mobile width reconfirmed the selector order: Thai, Chinese BaZi,
Western, then **โหราศาสตร์โดยรวม**. The synthetic known-time form reached a
combined report after the CORS repair, but this is not accepted QA: the browser
silently reused a non-QA Firebase session. The flow updated exactly five
pre-existing documents (canonical profile, two natal charts, and their two
result mirrors). It did not create a Fusion result document. Testing was paused
immediately after ownership was identified, and no corrective write or delete
has been performed.

A read-only historical `batchGet` recovered all five documents at
`2026-09-23T10:27:18.000000Z` (`17:27:18.000000 Asia/Bangkok`), before the
observed writes at `10:27:18.244907Z` through `10:27:19.514069Z`. The local-only
snapshot contains current and historical copies for all five paths and has
SHA-256 `423B6CCCDE6CB00C3A1FB15643A3F18CED80684609F54A56FD7F8B318E8B5D68`.
No UID or profile value is stored in this repository. PITR is disabled, no
managed backup exists, and no backup schedule exists; recovery used the
standard one-hour version-retention window.

The Unicode-safe restore validated the original snapshot SHA-256, `3,430` JSON
keys (`80` non-ASCII and no literal `??`), duplicate-key absence at every level,
Firestore value unions/types, and lossless snapshot/request round-trip. Each of
the five outgoing field maps matched its before-write source. A fresh live guard
then matched current `updateTime` and canonical field hash `5/5`.

One atomic commit restored all five complete historical field maps with no
`updateMask` and a `currentDocument.updateTime` precondition per write. Commit
time was `2026-09-24T03:37:55.719177Z` (`10:37:55.719177 Asia/Bangkok`). The
single readback passed `5/5`: fields and Firestore types equal the before-write
snapshot, all original `createTime` values are unchanged, and new `updateTime`
values equal their atomic write results. No other document or Firebase resource
was touched, and no personal value or UID is stored in this repository.

Local feature-focused tests pass 14/14 for consensus, ordering, known/unknown
time, sign-in cancellation, safe engine order, and mobile/desktop layouts.
The additional date-aware file retains the known Windows local-time mismatch
(three `+07:00` assertion failures); the pinned Ubuntu workflow above passes it
and the complete suite. This historical Preview QA remains **PAUSED/INVALID**;
the repaired anonymous flow has only been exercised locally.

Owner authorized the branch push and opening a Draft PR. GitHub branch
`codex/three-tradition-overall-v1` and PR #149 exist. No Ready, merge, or
Production Hosting deploy has been performed. After an isolated hosted QA path
is ready, remove the exact temporary Preview origin in a separately reviewed
Backend revision, rerun the CORS matrix, and close the old Preview channel or
let it expire.
