# Overall astrology from three traditions — V1 working branch

Status (2026-09-24): **Draft PR #149 OPEN; isolated Backend and fresh Hosting
Preview deployed; anonymous browser selection-to-report QA PASS; no Production
deployment or merge**. The
five previously affected Production documents were restored and verified before
this change. Historical branch validation passed in
[GitHub Actions run #35824575799](https://github.com/notekmitl/knowme/actions/runs/35824575799)
at commit `c33160d4bf01bd2f0a870d2c50925d700645f8b0`: focused tests,
analyzer, release Web build, PDF dependencies, and the complete Flutter suite.
The local Flutter SDK is available for this revision. The isolated Preview
implementation commit `05a2af4ab04ff988039131cde66040a200c022aa` also passed the focused tests,
analyzer, release Web build, PDF dependency setup, and complete Flutter suite in
[GitHub Actions run #35963786418](https://github.com/notekmitl/knowme/actions/runs/35963786418).
No related test failure required a code change.

## 2026-09-24 mobile Hosted Preview follow-up and old-channel closure

- In a fresh mobile Chrome context at **390×844**, Bangkok timezone and no
  saved session, the flow opened the new Hosted Preview, filled synthetic
  known-time birth data, selected **ดูดวงรวม**, and reached the report. Click to
  report heading took **4,799 ms** on the first run and **795/793 ms** on two
  fresh-context runs after the old channel was closed. These are browser
  measurements, including sequential Backend calculation requests; the first
  run may include a Cloud Run cold start.
- The selector showed all four choices in order (Thai, Chinese, Western,
  Overall) and the correct birth summary. Visual review of the report at the
  top and bottom found readable Thai text, three- and two-tradition cards,
  source labels, and the no-age-range disclosure. No text was clipped or
  overlapped. Both document and body scroll width were **390 px** at a 390 px
  viewport. Owner wording acceptance is still pending.
- Each accepted mobile run made exactly two POSTs, `/v1/calculate-bazi` and
  `/v1/calculate-chart`, to the separate Backend Preview. Both returned
  **HTTP 200**. Captured requests contained **zero** Firebase Auth, Firestore,
  Production API, or other mutating requests; page and console errors were
  zero. Screenshots, the latest full request list, and the validation summary are in ignored
  `.preview-qa/mobile-390x844/`; the repeatable check is
  `tool/pr149_preview_mobile_flow.cjs`.
- Deleted only Hosting channel `pr-149-overall-v1` after confirming it was the
  historical Production-API bundle. A fresh channel listing contains
  `pr-149-overall-safe` and `live`, with the old channel absent. The old URL
  now returns **HTTP 404**; the new `/beta/thai` returns **HTTP 200** and passed
  the full mobile selector-to-report flow again after deletion.

Owner wording review link:
`https://knowme-app-694e1--pr-149-overall-safe-vbx6de6a.web.app/beta/thai`
(expires `2026-10-01T06:06:12Z`).

## 2026-09-24 isolated hosted Preview QA

- Backend: new Cloud Run service `knowme-overall-pr149-preview`, revision
  `knowme-overall-pr149-preview-00001-gfn`, at
  `https://knowme-overall-pr149-preview-avbyttircq-as.a.run.app`. Its runtime
  identity is the new
  `knowme-pr149-overall-preview@knowme-app-694e1.iam.gserviceaccount.com`.
  Project IAM inspection found **zero role bindings** for that identity and no
  parent organization/folder. It has no Production Firestore permission. Its
  staged source and container include only the calculation app and BaZi/Western
  engines, with no Firebase/Firestore library, save module, Firebase Auth
  initialization, or saved-chart route. Cloud Build
  `7827ecc3-97e1-43b3-be4f-bc6571ebb54e` passed the import and route gate.
  The service has `min-instances=0`, `max-instances=2`, and a 60-second timeout.
- Backend live checks with synthetic birth data: both anonymous calculation
  POSTs returned `200`, with no `saved_paths`; `/v1/generate-bazi` returned
  `404`; `uid` and `profile` on calculation requests returned `422`. CORS
  accepted only the new Hosting Preview origin; Production Hosting and an
  unrelated origin returned `400` without an allow-origin header.
- Hosting Preview: new seven-day channel `pr-149-overall-safe` at
  `https://knowme-app-694e1--pr-149-overall-safe-vbx6de6a.web.app`, expiring
  `2026-10-01T06:06:12Z`. It was built from this PR checkout with
  `KNOWME_OVERALL_PREVIEW=true`, the new Backend URL, and the Evidence Badge
  flag off. This build skips Firebase initialization and the landing page's
  participant-count Firestore read. The release bundle is 6,910,773 bytes,
  SHA-256
  `6E5393809982E1D3BA4C177896FBCD78DF997DCFC87FFDB0969B9117AA3B9962`;
  the downloaded hosted bundle matched that hash exactly. It contains the
  Preview Backend URL and both `/v1/calculate-*` paths, but no Production API
  URL, loopback API URL, or `firestore.googleapis.com` string. Entrypoint cache
  pin: `6e5393809982`.
- Fresh headless Chrome context (1280×800, Bangkok timezone, no saved session)
  opened `/beta/thai`, entered synthetic known-time data, reached the selector,
  clicked **ดูดวงรวม**, and displayed the combined report in **843 ms** and
  **860 ms** on two runs. The report included both three-tradition and
  two-tradition agreements. Network capture saw exactly two calculation POSTs
  to the Preview Backend and zero Auth, Firestore, Production API, or other
  mutating requests; page errors were zero. Local screenshots and the network
  record are in ignored `.preview-qa/`; the repeatable browser check is
  `tool/pr149_preview_flow.cjs`. No Firebase Auth account or Firestore document
  was created for this QA.
- The first Preview build briefly made a Firestore **read** for the landing
  participant count. It made no write, but was replaced immediately. The final
  hosted bundle and both accepted Chrome runs have zero Auth/Firestore traffic.
  Production Cloud Run remains on `knowme-astrology-api-00014-j2z`; Production
  Hosting, Firestore rules/data, Auth configuration, Functions, and Storage were
  not deployed or changed. PR #149 stays Draft.

This is a time-limited public QA service. Before wider exposure, add a rate
limit and abuse controls. The old `pr-149-overall-v1` channel was deleted on
2026-09-24. The exact temporary CORS origin on the Production Backend remains
for a separate reviewed removal revision.

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

Before this follow-up, the old Hosted Preview served its authenticated bundle and
Production API. A read-only download on 2026-09-24 matched the old bundle
SHA-256
`8479C6E1A9112F20914280D5834C9001308F0116545BBCEC366FF3638437AFBA`:
it contains the Production API and `/v1/generate-*` paths but neither
`/v1/calculate-*` path. It does **not** contain this repair and must not be
used to claim anonymous Overall QA. The new isolated Preview described above
supersedes this historical blocker. The temporary exact Preview CORS entry remains live on
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
The isolated hosted browser QA passed as recorded above. Owner review of the
combined Thai wording remains open.

## Historical Hosting Preview verification (invalid QA)

The former seven-day Preview channel `pr-149-overall-v1` served
`https://knowme-app-694e1--pr-149-overall-v1-nr8oa6e0.web.app`; it was
deleted on 2026-09-24 and now returns HTTP 404. Its release Web build was from
application source `d56946d`, used the configured Production Cloud Run API,
passed the official
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
the repaired anonymous flow later passed on the separate Preview above.

Owner authorized the branch push and opening a Draft PR. GitHub branch
`codex/three-tradition-overall-v1` and PR #149 exist. No Ready, merge, or
Production Hosting deploy has been performed. The isolated hosted QA path is
ready and the old Preview channel is closed. Remove the exact temporary
Preview origin in a separately reviewed Production Backend revision and rerun
the CORS matrix when that change is authorized.
