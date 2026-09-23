# Overall astrology from three traditions — V1 working branch

Status: **Draft PR #149 OPEN; exact Preview-origin CORS revision live; Preview
QA paused pending Owner-approved five-document restore; not released**. Branch validation passed in
[GitHub Actions run #35824575799](https://github.com/notekmitl/knowme/actions/runs/35824575799)
at commit `c33160d4bf01bd2f0a870d2c50925d700645f8b0`: focused tests,
analyzer, release Web build, PDF dependencies, and the complete Flutter suite.
Flutter/Dart SDKs remain unavailable in the local workspace.

## Reader path

`/beta/thai` → birth form → select **โหราศาสตร์โดยรวม**. The option requires a
known birth time and resolved province because Western V2 needs both. It uses
the existing sign-in gate for the two authenticated backend calculations.
BaZi and Western are generated sequentially through their existing authenticated
endpoints using the same normalized profile; Thai Beta runs its existing local
analysis. The report is composed only when all three return valid results.

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

The combined action calls two authenticated generation endpoints in sequence,
so total latency may exceed the accepted per-reader five-second target. It
does not read old saved charts, which avoids mixing a previous birth profile
with the newly submitted form. A failure in any source does not show a partial
combined report; an earlier successful endpoint may still have persisted its
individual chart. Old single-system routes remain independent.

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

Valid separate-account three-chart browser QA, real endpoint latency, visual
review of the combined Thai wording, data restoration, and Owner acceptance are
still required before Ready, Merge, or deployment.

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

Restoration is pending explicit Owner approval. The proposed procedure is one
atomic five-document commit using the historical field maps and per-document
`currentDocument.updateTime` preconditions after a fresh drift check. The
post-restore read must match the historical snapshot field-for-field, with
unchanged `createTime` and only new `updateTime` values. No user root, sibling
document, Auth record, rule, index, or other collection is in scope. The saved
current snapshot is the bounded rollback source.

Local feature-focused tests pass 14/14 for consensus, ordering, known/unknown
time, sign-in cancellation, safe engine order, and mobile/desktop layouts.
The additional date-aware file retains the known Windows local-time mismatch
(three `+07:00` assertion failures); the pinned Ubuntu workflow above passes it
and the complete suite. This Preview QA remains **PAUSED/INVALID** until the
five-document restore is approved and a separate QA account is verified.

Owner authorized the branch push and opening a Draft PR. GitHub branch
`codex/three-tradition-overall-v1` and PR #149 exist. No Ready, merge, or
Production Hosting deploy has been performed. After valid QA, remove the exact
temporary Preview origin in a new Backend revision, rerun the three-origin CORS
matrix, and close the Preview channel or let it expire.
