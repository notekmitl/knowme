# Overall astrology from three traditions — V1 working branch

## 2026-09-25 evidence relationship reading for Draft PR #149

Starting from `dc4146b`, the report composer now examines every registered
observation in each lens before choosing a narrative path. For the
Owner-requested known-time case, it can place a Thai thinking-style
observation, a Chinese stability observation, and a Western adaptation
observation into one question about considering a choice, what to preserve,
and how to adjust if conditions change. The report explicitly calls this an
interpretive reading of different perspectives, **not a proven common point**
or a claim about actual events. The Thai observation in this case remains
below the unchanged `0.6` cross-tradition agreement threshold, so the case
still has no supported common point. Birth values, chart placements, and
personally identifying data are omitted here.

The copy has reviewed paths for a supported reliability pair plus a separate
thinking view, and for two distinct supported autonomy/growth pairs. Where
observations or proven points lack a defensible relationship, it says so
directly and leaves their evidence in the per-tradition panel. This revision
changes presentation only; adapters, calculated charts, agreement logic,
threshold, authentication, and persistence were not changed. A small prose
cleanup removes a repeated Thai evidence label without changing its source.

Focused consensus and mobile report tests passed **23/23**, including
non-leading evidence selection, honest unrelated-evidence fallback, distinct
proven points, and a 390×844 mobile layout. Changed-file Flutter analysis
found **0 issues**; the isolated release Web build succeeded. On the final
Hosted Preview at 390×844, the Owner-requested case and two synthetic cases
reached the report in **862/891/923 ms** respectively. All three had viewport
and scroll width of 390 px, no clipping or runtime errors, 18 GET requests,
and only two calculation POSTs to the isolated Preview Backend (200/200).
There were zero Auth, Firestore, Production API, other mutating, blocked, or
page/console-error requests; POST bodies contained no UID, profile, token,
or Auth field. The synthetic daytime case retained one proven two-tradition
point with the third view separate. The pre-sunrise case retained two
distinct proven two-tradition points without a three-way claim.

The final release bundle and Hosted `main.dart.js` match byte-for-byte at
SHA-256 `2CF5D9747D5CBED922088513AAA46EC94DED0083E3556D60D68E9906323C164F`.
The bundle contains the isolated Backend URL and two calculation paths, no
Auth/Firestore endpoint strings, and the Production API hostname only in its
negative Preview configuration guard. Only Hosting Preview channel
`pr-149-overall-safe` advanced to version `cd5892157c63f4a2`, expiring
`2026-10-02T07:34:08Z`. Production Hosting `live` remained
`d32e72678324e634`; the former unsafe channel remains absent. Owner wording
review and full PR CI verification are tracked on the Draft PR.

## 2026-09-25 one-reading prose revision for Draft PR #149

The report now starts with one Thai prose reading composed from the strongest
traceable observation of each available tradition. A proven agreement leads
the prose when one exists; another tradition's view is explicitly kept apart.
The agreement section follows the reading and shows the actual supporting
facts. When no agreement qualifies, the section states that limit after the
reading. Per-tradition detail remains available in a collapsed evidence panel
for review instead of forming the main report. This changes presentation only:
the adapters, source selection, and minimum agreement confidence of `0.6`
are unchanged. No synthetic fact, event, age prediction, or cross-tradition
bridge was added.

The Owner-requested known-time case was retested anonymously from selection
to report on the isolated Hosted Preview at 390×844. The report now reads as
one paragraph with a Thai view of thinking style, a Chinese view of stability,
and a Western view of adaptation, each grounded in its existing engine fact.
It then says no common topic reaches the evidence threshold. This is a
composed reading of different perspectives, not a claim that the three
traditions agree. Selection-to-report time was **894 ms** in this run; viewport
and scroll width were both 390 px, with no visible clipping. The complete
rendered paragraph was checked against the adapter outputs. Birth values and
chart placements are omitted from this document.

Two additional synthetic Hosted Preview cases exercised the other branch.
One showed **one** supported two-tradition point with the third view kept
separate (**384 ms**); a pre-sunrise case showed **two** distinct supported
two-tradition points without claiming a three-way agreement (**912 ms**).
Both longer reports scrolled to the end without horizontal overflow. The
focused Flutter selection, date-boundary, consensus, and mobile report tests
passed **34/34**; changed-file analyzer found **0 issues**.

Each Hosted Preview run made **18 GET and two calculation POST** requests to
the isolated Backend, both POST responses 200. There were zero Auth,
Firestore, Production API, or other write attempts, zero blocked requests,
and zero page/console errors. The request bodies contained no UID, name,
profile, token, or Auth field. The Preview release bundle contains the
isolated Backend URL and both calculation paths, no Auth/Firestore endpoint
string, and only the existing Production-hostname rejection guard. Hosted
`main.dart.js` matches the local release build byte-for-byte: SHA-256
`32B838493F0FEC12BD2E42AE88E824139A31029C38DD66B898F0ADC1A5C84190`.
Only safe Hosting channel `pr-149-overall-safe` advanced to version
`5d2d95d5892b9a8f` (expires `2026-10-02T06:56:24Z`); `live` remained
`d32e72678324e634`, and the unsafe old channel remains absent. PR #149
stays Draft for Owner wording review. No personal birth data, account, or
saved result was added by this revision.

## 2026-09-25 Thai evidence and anonymous Preview repair

The Owner-requested near-midnight case was traced from the Thai single-reading
runner into the Overall adapter. Both paths use the same normalized Thai
analysis and Mirror result. The Thai single report produced its complete
narrative. The normalizer correctly kept the civil birth date for the other
traditions and used the preceding Thai astrological day because the birth was
before local sunrise. No date-boundary change was needed.

The adapter previously examined only the Mirror's top three themes. None of
those themes was in the Overall Fusion registry for this case, while approved
Thai content in the Mirror sections contained registered themes and explicit
evidence rows. The adapter now also reads section supporting themes and keeps
its existing registry, source-evidence, deduplication, and confidence gates.
The Thai report's approved lagna content explicitly maps the three displayed
Thai observations. They come from one Thai source, each at confidence `0.55`;
they remain lens-specific. The `0.6` agreement threshold is unchanged, so
this case has **no supported two- or three-tradition common point**. The
Chinese and Western observations remain separate. No missing point was
invented to fill the Overall report.

The isolated Preview's Thai single report was also blank after confirmation:
its feature-flag-off branch instantiated a Firebase audience listener although
Preview deliberately has no Firebase initialization. The Preview build now
renders that report with an anonymous audience and does not create the
listener. Production-mode behavior is unchanged.

Focused adapter/consensus tests passed **23/23**. A synthetic pre-sunrise
birth test confirms section evidence survives when top themes do not map to
the Fusion registry. A synthetic daytime test confirms weak Thai evidence
stays visible without becoming an agreement. Changed-file analysis found
**0 issues**. The safe release Web bundle has SHA-256
`5E47FC67F7FED4A9BE9D91D72FFA381D3F8263BA989334F30D02FFABD7F0B7E8`;
the hosted bundle matches byte-for-byte. It contains the isolated Preview
Backend URL, both calculation paths, and no Auth/Firestore endpoint strings.
The one Production API hostname occurrence is solely in the negative Preview
configuration guard.

Only `pr-149-overall-safe` was advanced to Hosting version
`23c6890171b7618b`, expiring `2026-10-02T05:33:21Z`. The `live` Hosting
version stayed `d32e72678324e634`; the old unsafe channel remains absent.
The Owner-requested case was entered in a fresh 390×844 anonymous browser.
Thai single summary and visual report showed the preceding Thai astrological
day and a populated reading; its 18 requests were GET only. The Overall
selection-to-report time was **4,526 ms**. Its 20 requests were 18 GET and
exactly two calculation POSTs to the isolated Backend, both 200. Request
bodies had no UID, name, profile, token, or Auth field. Both routes had zero
Auth, Firestore, Production API, other mutating, blocked, page-error, or
console-error requests. At 390 px viewport, scroll width was 390 px and the
cards did not clip. The Overall text now shows three separately sourced Thai
observations and explicitly says that no common point is supported. The
Owner's wording review remains pending. Birth values and chart placements
are intentionally omitted from this document; no account or saved result was
created by the tested flows. PR #149 remains Draft.

## 2026-09-24 latest Draft PR #149 verification

The post-crash implementation commit `bd17b475` and its documentation were
pushed normally to the existing Draft branch with available credentials.
The full Flutter suite initially failed six tests. One expected the old
English Thai-evidence label; five were downstream of evidence merging in
the shared BaZi adapter helper. Implementation `b5aa038` keeps merged facts
for the Overall report and preserves the earlier single-fact behavior for
other runtime consumers. The five affected test files passed **50/50**
locally. [GitHub Actions run #35988691883](https://github.com/notekmitl/knowme/actions/runs/35988691883)
completed **successfully**, including focused tests, analyzer, Web build,
and the complete Flutter suite.

A new release Web bundle from `b5aa038` was built with
`KNOWME_OVERALL_PREVIEW=true`, Evidence Badge off, and only the isolated
Backend URL `https://knowme-overall-pr149-preview-avbyttircq-as.a.run.app`.
The hosted JS matches the local build byte-for-byte: 6,920,251 bytes,
SHA-256 `2F01AEE4677D5F299F4A7F69FF8EA278B19D134A91426F6E3098E7391786FDF2`.
It contains both calculate paths, zero Firestore/Auth API endpoint strings,
and one Production API hostname occurrence solely in the negative Preview
configuration guard. Hosting channel `pr-149-overall-safe` alone advanced
to version `dd4c850da6e99a3c`, expiring `2026-10-01T10:45:43Z`; the `live`
channel stayed on `d32e72678324e634`. The deploy used
`--no-authorized-domains`. The old unsafe channel remains absent.

The Owner-specified input was entered in two fresh 390×844 Chrome contexts
without sign-in. The selector displayed the exact requested date, time,
and province before the Overall action. Two earlier form attempts with an
incorrect hour selection were rejected by this check and are excluded.
The two accepted click-to-report timings were **4,388 ms** (first load)
and **898 ms** (repeat). Their report text was identical. The page had
390 px scroll width at 390 px viewport with readable cards and no clipping.
There were **zero supported cross-tradition agreements**; the report
explicitly said so, showed Thai as insufficient, and kept three distinct
Chinese and three distinct Western observations separate. The six
observations trace to actual response fields and existing source mappings;
no duplicate joint point, invented third-lens support, or unsupported
event/date/age claim appeared. This is source traceability, not independent
validation of astrological truth or Owner wording acceptance.

Each accepted run had **20 requests: 18 GET and exactly two POST** to
`/v1/calculate-bazi` and `/v1/calculate-chart` on the isolated Backend;
both returned 200. The POST bodies had no UID, name, profile, token, or
Auth field. There were zero Auth, Firestore, Production API, or other
mutating requests, zero blocked requests, and zero page/console errors.
No account or saved result was created by this browser flow. Exact birth
values are omitted from this document. PR #149 remains Draft pending
Owner wording review; no merge or Production/Firestore change occurred.

## Earlier Owner-specified Hosted Preview reading QA

The Owner-specified known-time input was tested in a fresh 390×844 Chrome
context with empty browser storage and no sign-in. The exact birth values and
derived chart placements are intentionally omitted from repository files. The
form preserved the requested input before the Overall action. Two accepted
runs reached the report in **814/878 ms** from click to heading. The page had
390 px scroll width at a 390 px viewport, and visual review found readable,
distinct lens sections without clipping.

This case produced **zero supported cross-tradition agreements**. The report
said so explicitly, kept the Thai lens at an insufficient-evidence state, and
showed three distinct Chinese plus three distinct Western observations only
as lens-specific material. It did not repeat a generic Chinese/Western point,
claim that the third lens agreed, or add an event/date/age prediction. The six
displayed observations were checked against live calculation response fields
and the source mapping: BaZi day master, dominant element, element balance,
and secondary year-animal signal; Western Big Three and derived modality. The
secondary animal signal was labelled as such. The Thai empty-evidence result
was observed in the report and is not presented as an independent chart fact.

The fresh-context trace contained **20 requests: 18 GET and exactly two POST**
to `/v1/calculate-bazi` and `/v1/calculate-chart` on the isolated Preview
Backend; both returned 200. The request bodies contained no UID, name,
profile, token, or Auth field. No Auth, Firestore, Production API, or other
mutating request was attempted; the protective browser route blocked zero
requests. Page and console errors were zero. No account or saved result was
created by this browser flow.

The live Hosting Preview release is version `72ddb6960c4ab6da` (09:45:49Z),
and hosted `main.dart.js` SHA-256 is
`E69C3D57A4DB379BED6668EC6359EE5027FFD7DF8AF0252396FD288FFBC2441F`.
The Production API hostname appears in the bundle only in an exact negative
guard that rejects a misconfigured Preview Backend URL; the active API URL is
the isolated Preview Backend. No Production API request was observed. The
channel expires `2026-10-01T09:45:43Z`.

After the `git.exe` crash, the correct local repo was found at the separate
KnowMe task checkout. It had clean working files, no Git lock files, and
`bd17b4753f9305823462ee4a1fdadf5f71b93a7b` exactly one commit ahead
of remote `c570a83`. A normal, non-force push with existing credentials moved
the Draft PR branch to `bd17b475`; Owner sign-in was not needed. Production
and Firestore were not changed. Owner wording acceptance remains pending.

## 2026-09-24 evidence-led wording revision — Owner review pending

The previously reported Hosted Preview wording (one common card, repeated
Chinese and Western text) was not accepted. The safe Hosted Preview now serves
the revised wording on the separate Backend. The referenced screenshot was unavailable in that earlier turn. The
Owner-specified input was tested in the follow-up above.

Root cause: `ThreeTraditionReportPage` previously received only agreements and
rendered the same generic theme label for every participating lens, discarding
each adapter's evidence. The comparator also joined broad signal-family themes
that did not always mean the same thing. The new reading model keeps ranked
observations for each lens, renders distinct Thai evidence from Thai Mirror
content titles, BaZi day master/element facts, and Western Sun/Moon/Rising
facts, and shows nonmatching traditions separately. Exact theme matches are
eligible only with nonempty evidence and confidence at least `0.6`. Only the
explicitly reviewed `independent`/`leadership` pair may form a near-match;
`supportive`, `loyal`, and `independent_connection` do not form one relationship
agreement. Year-animal bridge signals below `0.6` remain visible as secondary
Chinese observations but cannot establish a point of agreement. Western
dominant element/modality is emitted only with a unique count of at least two
among the Big Three. No date or event claim is added.

Synthetic example for Owner copy review (not the missing screenshot case):

> **ความมั่นคง — สอดคล้องกัน 2 ศาสตร์ (จีนและตะวันตก)**
>
> จีน: พบประเด็นการให้ความสำคัญกับความมั่นคงจากธาตุเด่นของดวงจีนเป็นดิน
>
> ตะวันตก: พบประเด็นการให้ความสำคัญกับความมั่นคงจากลัคนาอยู่ราศีพฤษภ
>
> ไทย: ไม่มีหลักฐานที่หนักพอให้นับร่วมในประเด็นนี้; แสดงข้อสังเกตไทยอื่นแยกด้านล่าง
>
> เวลาเลือกงานหรือแผนชีวิต ลองดูว่าความมั่นคงมีน้ำหนักเพียงใด

This is a reflective reading grounded in two separate facts, not a prediction
or a claim that Thai agrees. The old generic Chinese/Western duplicate is gone.

Local Backend full suite **54/54 PASS**; Thai/Chinese/Western and overall
Flutter regressions **48/48 PASS**; focused mobile/report tests **14/14 PASS**;
changed-file analyzer **0 issues**. Two synthetic birth sets via loopback-only
Backend produced **4** and **1** supported common topics; the second has only
one supported common topic, so the UI adds evidence-backed lens observations
instead of fabricating more agreements. Local mobile selection-to-report took
**1,602 ms**. The local loopback release Web build (not deployable as-is) contains
loopback API, both `/v1/calculate-*` paths, no Production API URL, SHA-256
`E0DA2AB4509C9D966A24BD390DC9872585463450D4F142D7C3D070637BC504F1`.

The already deployed calculation-only Preview Backend was not changed. The
loopback Web build must not be deployed. Public endpoint abuse protection,
rate limiting, and Owner wording review remain open. Production/Firestore and
PR Draft status were not changed.

A second release build configured for the existing isolated Preview Backend
succeeded from the rebased PR source. It contains both calculate paths,
no loopback or Firestore endpoint, and only a negative Production URL guard;
`main.dart.js` SHA-256 is `E69C3D57A4DB379BED6668EC6359EE5027FFD7DF8AF0252396FD288FFBC2441F`.
Only Hosting Preview channel `pr-149-overall-safe` was updated, with
`--no-authorized-domains`; it expires `2026-10-01T09:45:43Z`. The hosted
index/bootstrap cache pins and downloaded JS hash equal the local build. The
`live` Hosting release time did not change. Mobile Chrome at 390×844 showed
four supported two-tradition cards, distinct Chinese/Western evidence, and
separate Thai/Chinese/Western observations; scroll width was 390 px. A repeat
click-to-heading measurement was **2,147 ms**. Network capture after the click
had exactly two POSTs to Preview Backend, both 200, and no Auth, Firestore, or
Production API request. The earlier screenshot was unavailable; the Owner-specified input has
now been tested above. The branch push succeeded with existing credentials.

## Earlier isolated Hosted Preview QA

Status (2026-09-24): **Draft PR #149 OPEN; isolated Backend and safe Hosting
Preview deployed; earlier anonymous browser selector-to-report QA PASS; no
Production deployment or merge**. The
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
(previously scheduled to expire `2026-10-01T06:06:12Z` before this update).

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
  `2026-10-01T06:06:12Z` before this update. It was built from this PR checkout with
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
- Group one result per lens and theme. Show exact matching themes only when at
  least two *different* traditions have nonempty evidence with confidence at
  least `0.6`. The only reviewed near-match is `independent`/`leadership`,
  described narrowly as self-direction. Rank three-lens agreements before
  two-lens agreements; never promote an unrelated third lens.
- Do not merge a growth-area warning into a positive signal (for example,
  `overthinking` with `analytical`). Do not assert dates or age ranges because
  the available natal outputs do not contain comparable timing evidence across
  all three systems. A zero-agreement chart has an explicit empty state.
- Display each contributing tradition's distinct engine facts on its card and
  the remaining traditions' observations in a clearly separate section. The
  result is calculated in memory and is not written as a new user document.
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
