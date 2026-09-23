Warning: truncated output (original token count: 56745)
Total output lines: 1384

## Active draft — Overall astrology from three traditions (2026-09-23)

On Draft PR #149 (`codex/three-tradition-overall-v1`), the post-birth selector now offers a
three-tradition overall reading. Its source-backed theme comparison requires at
least two distinct lenses, shows the exact contributors, and avoids unsupported
event timing. GitHub Actions now runs the focused tests, analyzer, release Web
build and full Flutter suite with Bangkok timezone, Poppler and `pypdf`. A
duplicate Bangkok conversion in the selected Thai path was corrected. Run #35824575799 passed the complete Flutter suite; authenticated chart QA and
Owner wording acceptance remain open. Details:
`docs/THREE_TRADITION_OVERALL_V1.md`.
PR #149 remains OPEN + DRAFT; no Ready, Merge or Deploy.

## Completed repair - Western Reader V2 authenticated latency (2026-09-22)

Status: **PASS — PR #147 MERGED — BACKEND LIVE — PRODUCTION ACCEPTED**

- Performance PR #147 merged as
  `afbcb72e490512d597b69daa6ca4574c5d13c1a8`, tree
  `39f62b5fc6ccc27c1cbde32eaf7b2b8fa59f7c8e`. The exact merge image is live
  on Cloud Run `knowme-astrology-api-00013-zc8` at 100% traffic with digest
  `sha256:8f7c41bff70ff238e09263316ffe872b6f32227d4b4f0ffb10dcf72a7dc0070d`.
- Root cause was remote dependency readiness/tail latency, not the reader:
  the Firestore client/first RPC were lazy, Firestore is in `africa-south1`
  while Cloud Run is in `asia-southeast1`, and revoked-token Auth plus the
  awaited atomic commit are sequential. One instrumented pre-config run spent
  `2,367.287 ms` in Auth and `2,401.013 ms` saving; reader composition was only
  `0.054 ms`.
- The repair performs a read-only Firestore startup probe before readiness,
  adds PII-free phase logs, and uses instance-based CPU allocation with min
  instance `1` so initialized network clients are not CPU-suspended while idle.
  Auth policy, write atomicity, schema, calculation, copy, cache contract,
  Fusion, Thai Astrology, and BaZi are unchanged.
- Final three Mobile and three Desktop selected-generation runs measured
  browser body `0.889–3.303 s` and Cloud Run `0.835–3.230 s`. Every run used
  authenticated POST 1, returned r2/V2 and correct UTC/Big Three, and had zero
  post-response Western reads, zero Fusion traffic, zero console/runtime error,
  zero overflow, and no stuck loading.
- Cache hit passed with `western_natal` read 1, generation POST 0, Fusion 0,
  correct r2/V2/UTC/Big Three, and no runtime UI defect.
- Backend focused `20/20`, Backend full `51/51`, Python compilation, Flutter
  focused `37/37`, Flutter full `3,097/3,097`, analyzer policy (exit `0`, 275
  inherited diagnostics), and Production Web build/validator pass.
- Hosting was not rebuilt or deployed. Release/version remain
  `1790074568414000` / `d32e72678324e634`; live `main.dart.js` SHA-256 is
  `46d5b86b87dfddacfbce90fd036d312e1e9372d3a7897c7d8f855fa46232f629`.
- Full traces and phase evidence are in
  `docs/WESTERN_ASTROLOGY_READER_V2_LATENCY_REPAIR.md`. Rollback was not
  required.

## Historical release - Western Reader V2 Thai readability revision (2026-09-22)

Status: **OWNER-ACCEPTED; PR #146 MERGED AND DEPLOYED; LATENCY CLOSEOUT PASSED**

- Root cause is deterministic copy in
  `backend/app/services/astrology/reader.py`, not an AI prompt. The candidate
  rewrites only Western Thai composition and presentation.
- Main prose now starts from real-life behavior, likely effect, and a caution or
  practical use. Sun, Moon, and Rising are read together; exact signs, houses,
  and aspects move to a secondary basis line, and Chart Structure is collapsed.
- The Owner-feedback revision keeps the overview short and gives the identity
  section its own concrete decision scenario. Money, love, recovery, strengths,
  cautions, and guidance now use explicit observable actions; repeated and
  abstract phrases identified by the Owner are removed at composer source.
- Chart schema `western_natal_v2`, contract `knowme_western_reader_v2`, all
  calculations, Auth, Firestore paths, Fusion, Thai astrology, and BaZi are
  unchanged. Reader revision advances to `western_reader_th_v2_r2` only.
- Old `western_reader_th_v2` cache is rejected once and regenerated through the
  existing authenticated path; the saved r2 document then returns to normal
  cache-hit behavior. Regression tests cover one POST for stale cache and zero
  POST for current cache.
- Owner case remains `1982-06-05T17:03:00Z`, Gemini Sun, Sagittarius Moon,
  Pisces Rising. The generated full Thai sample is in
  `docs/WESTERN_ASTROLOGY_READER_V2_THAI_READABILITY.md`.
- Validation covers eight charts across all elements/modalities, source-linked
  signs/houses/aspects, responsive UI, backend/full Flutter/analyzer/build, and
  fresh same-machine latency comparison. Backend passes 48/48, focused Flutter
  24/24, full Flutter 3,097/3,097, analyzer policy exits 0 with 275 inherited
  diagnostics and no changed-scope issue, and the local Production Web build
  passes. The revised composer is 0.000086 ms faster than PR HEAD before this
  feedback on the same-machine benchmark; three full-chart medians are
  0.204681-0.206452 ms.
- Historical outcome: PR #146 was approved, marked ready, merged as
  `1a48f234e4720a3e858ca0aa03944e87f6b35609`, and deployed before the active
  latency investigation above. The older Production identity in this section
  is superseded by the active release identity at the top of this file.

## Completed release - Western Astrology Reader V2 and performance (2026-09-21)

Status: **PASS — MEASUREMENT ARTIFACT CLOSED; APPLICATION AND HOSTING UNCHANGED**

- Exact source: `de0a83bdfbb18532471ba58e539e7d0b6cf553a4`; tree: `f902d98d1d70ad39700df14e5406d07374d26f6a`; cache pin: `de0a83b`.
- Owner case: `1982-06-06 00:03`, Chiang Mai, `Asia/Bangkok`, `18.7883, 98.9853` -> `1982-06-05T17:03:00Z`, Gemini/Sagittarius/Pisces, contract `knowme_western_reader_v2`.
- **Cache-hit PASS:** one `western_natal` read, zero generation POSTs, zero browser `astrology_fusion` traffic, correct Big 3.
- **Generation-path mobile PASS (390x844, 3 runs):** authenticated POST 1/run, OPTIONS 0/1/0, `western_natal` reads 0, `astrology_fusion` traffic 0; response-complete-to-readable median 87.985 ms / maximum 90.149 ms; click-to-readable median 1,251.186 ms / maximum 1,286.553 ms.
- **Generation-path desktop PASS (1535x863, 3 runs):** authenticated POST 1/run, OPTIONS 0/0/0, `western_natal` reads 0, `astrology_fusion` traffic 0; response-complete-to-readable median 81.950 ms / maximum 82.005 ms; click-to-readable median 1,361.083 ms / maximum 2,953.287 ms.
- The superseded 14.662 s mobile and 31.251 s desktop observations included Agent/tool wait and visual-observation delay. CDP Network, Flutter state, and compositor-frame timestamps prove that they were measurement artifacts, not application runtime.
- Both viewports rendered the complete Reader V2 without overflow, console overflow/error, or stuck loading copy.
- Hosting release/version remain `1789977665171000` / `4065a55e03f5aa1e`; bundle SHA-256 is `2c8f901f9858211603b4b3689aa04fe5e077c7a4866ca1a5dd83dc48b25b5335`.
- Final acceptance was read-only against the existing release: no application source edit, build, deploy, Backend, IAM, Firestore, Functions, Auth, or Storage change. Only Markdown closeout documentation changed.

See `docs/WESTERN_ASTROLOGY_READER_V2.md` for the contract and
`docs/WESTERN_ASTROLOGY_READER_V2_PERFORMANCE_CLOSEOUT.md` for the browser
instrumentation, six-run table, and root-cause evidence.

## Completed release - BaZi Reader V4 conversational Thai (2026-09-20)

Status: **PASS — PR #140 MERGED, HOSTING RELEASED, PRODUCTION-VERIFIED**

- Shared Reader V2/V4 copy now uses short, direct Thai and practical guidance
  without fixture-specific branches or unsupported event certainty.
- The trend disclaimer appears once in the Reader V4 introduction. Duplicate
  past, annual, and future-cycle paragraphs are suppressed deterministically.
- `ข้อมูลที่ใช้คำนวณ` is hidden from Reader V4 Web and PDF; the chart input and
  location/time evidence remain intact internally and under test.
- Actual-chart QA covers Bangkok, Chiang Mai, Phuket, and Owner case
  1982-06-06 00:03 Chiang Mai male. Web passes at 1440px and 390px.
- Focused Flutter 12/12, backend 23/23, and complete Flutter 3,085/3,085 pass
  with Flutter 3.41.1. Analyzer exits 0 under policy with 282 inherited
  non-fatal diagnostics.
- Four PDFs / 12 pages pass semantic, font, blank-page, clipping, overlap,
  overflow, and glyph review. They use Noto Sans Thai Regular/Bold and Noto
  Sans SC Regular; Thin is absent.
- Exact-merge Web build passes the Production API and route checks. The live
  bundle is 8,609,239 bytes / SHA-256
  `FF070AFFE07F8441155D84E33F12A3A177D9E1EA2A0615C8B059A990DBCB5562`;
  actual loopback endpoints are zero.
- Calculation, Backend application, Thai astrology, Firebase resources, and
  Production data remain unchanged.
- Local Gate PreCommit/PostCommit pass. PR #140 merged as `24eaef1`, tree
  `19856f8a`; GitHub reported MERGEABLE/CLEAN with no configured checks.
- Hosting-only release `1789891789495000` / version `b5d2cde74c2e1fd6`
  serves pin `24eaef1`; both domains and the Known route return HTTP 200.
- Production Web has the complete conversational report, hides calculation
  input, and has zero application-origin console errors. The real PDF is three
  A4 pages / 30,939 bytes / SHA-256
  `341786FB69F5941E802D24777855985329BA61A72A2C2CD36E898083992B3655`;
  all pages pass content, font, clipping, overlap, overflow, blank, and glyph
  review. No release action remains.

## Completed release - BaZi Reader V4 Owner copy acceptance repair (2026-09-20)

Status: **PASS — PR #138 MERGED, HOSTING RELEASED, PRODUCTION-VERIFIED**

- The five accepted Owner wording repairs are centralized in the deterministic
  Reader V2/V4 composers. No case-specific copy branch was added.
- The additional report-wide audit removes unsupported certainty, repetitive
  past-cycle advice, current/year repetition, and one unnatural doubled phrase.
  Existing headings, visual structure, hidden technical sections, calculation,
  pillars, persistence, and API behavior remain unchanged.
- Bangkok, Chiang Mai, and Phuket now have explicit automated coverage from
  UI handoff through authenticated payload and backend apparent-solar input.
  Submitted place labels, coordinates, timezone, and civil time are preserved;
  the engine uses longitude plus Equation of Time and passes 38/38 tests.
- Focused Flutter passes 21/21 and the full Flutter suite passes 3,084/3,084
  with Flutter 3.41.1 and bundled PDF dependencies.
- Local Gate PreCommit passes the final candidate: scope and forbidden-text
  guards, analyzer policy with 282 inherited non-fatal diagnostics, focused
  tests 21/21, and full suite 3,084/3,084.
- All 12 pages across the three four-page candidate PDFs were rendered and
  inspected. Web/PDF semantics match, all required timeline sections are
  present, Regular Thai/CJK fonts are embedded, and missing text, blank page,
  clipping, overlap, overflow, or broken-glyph findings are zero.
- Thai runtime, Thai goldens, `product-acceptance/`, backend application code,
  Firebase configuration, and Production data have zero intended delta.
- Local Gate PostCommit passes. PR #138 merged as `949c6d16`, tree
  `04ca7169`; GitHub reported it mergeable/clean and no repository checks were
  configured.
- Firebase Hosting-only release `1789886487340000`, version
  `b89bf52264152570`, serves cache pin `949c6d1`. Backend and all other
  Firebase resources were not deployed.
- Both Production domains and the Known route return HTTP 200. The live
  8,611,124-byte bundle matches the exact-merge build at SHA-256
  `369AFF2D8B1BF7DED42075C9750A6E8CE667158A7E40FE1464DE910AEDD1D06D`,
  contains the Production API and route, and has zero actual loopback endpoint.
- Production Web QA shows the repaired copy and complete past/current/five-year/
  two-cycle timeline with zero application console errors. The downloaded PDF
  is 4 A4 pages / 33,082 bytes / SHA-256
  `AD7AE0A7E370CE8398648A1A22F95BB277677D7E6CD652004C6D56759009D69E`;
  every page passes text, font, glyph, clipping, overlap, overflow, and
  blank-page review.

## Completed release - BaZi Reader V4 life timeline (2026-09-19)

Status: **PASS — PR #135 MERGED, HOSTING RELEASED, PRODUCTION-VERIFIED**

- Reader V4 keeps calculation contract `knowme_bazi_reader_v3` and versions
  only the Thai interpretation as `knowme_bazi_reader_th_v4`.
- The report adds up to three completed Da Yun cycles, five future Liu Nian
  years, and two future Da Yun cycles around the accepted current timing.
- Past wording is reflective rather than a claim that an event occurred;
  future wording describes tendencies and planning priorities without a
  guaranteed outcome.
- The Reader V3 apparent-solar-time rules, API, saved chart, fingerprint,
  Unknown fail-closed behavior, hidden technical sections, and concise input
  card remain unchanged.
- Scope is Flutter report, fixture, tests, PDF metadata, and documentation.
  Backend and non-Hosting Firebase resources are out of scope.
- PR #135 is rebased onto baseline merge `e1426fc`; the three Owner formatting
  changes were restored byte-for-byte after rebase. Focused V4 tests pass
  17/17, the Windows full suite passes 3,080/3,080, and analyzer passes the
  repository policy with 282 inherited non-fatal diagnostics.
- The Production-configured Web release bundle contains `/beta/chinese` and
  the Cloud Run API host with zero loopback endpoint strings. Local Firebase
  Hosting QA confirms the V4 Owner label, past/current sections, five future
  years, two future decade cycles, normal Thai/Chinese text, and zero browser
  console errors.
- The real V4 PDF is 4 A4 pages / 33,262 bytes / SHA-256
  `4E76DB104848DB94FD12014BBC158387BE3EEA93844AB26A483DC669E9D2666E`.
  Every page was rendered and inspected: all timeline sections are present,
  Thai/Chinese glyphs are intact, and there is no clipping, overlap, overflow,
  or blank page. Embedded fonts are Noto Sans Thai Regular/Bold and Noto Sans
  SC Regular.
- Browser QA found and closed one presentation-only gap: the Owner fixture
  header now says `BaZi Reader V4`; calculation and report content are
  unchanged. Local Gate PreCommit/PostCommit pass. PR #135 merged as
  `63c790d8ffca03bb5b6d776d6e9f9dad9c703b68`, tree
  `b9fa82a516fa125c04fb819820f8f1fc97ff0201`.
- Exact-merge Hosting-only release `1789821517363000`, version
  `e08803aacc812816`, is live with cache pin `63c790d`; no Backend, Firestore,
  Functions, Auth, Storage, IAM, or Production data was changed.
- Both Firebase domains return HTTP 200. Live `main.dart.js` matches the local
  8,601,936-byte exact-merge bundle at SHA-256
  `62BB3DE78672506E80DFAF4ED61FA098250CEA9F5D18D46617473A5589ECCC8F`;
  it contains the Production API and zero loopback endpoint strings.
- Production browser QA confirms the V4 label, past and present, years
  2570–2574, and the next two decade cycles with normal Thai/Chinese text and
  zero console errors. The real downloaded PDF is 4 A4 pages / 33,437 bytes /
  SHA-256
  `CF0B1CB8ACDD7D95BBDC124185945F3E96D92AF1C6623D0F68C827D03D1B7266`.
  All four rendered pages match the candidate PNGs pixel-for-pixel and have no
  missing content, broken glyph, clipping, overlap, overflow, or blank page.

## Completed baseline repair - Windows Thai Mirror goldens (2026-09-19)

Status: **MERGED THROUGH SEPARATE PR #136.**

The 40 unchanged-main Windows failures were fully classified: 38 golden test
cases covered 174 PNG comparisons, while two OR5R checks hashed CRLF worktree
bytes instead of the canonical LF fixture. Linux keeps all accepted originals.
Windows selects same-name, same-dimension strict sibling baselines; the OR5R
fixture alone is pinned to LF. Windows and native Linux focused suites pass
46/46 each, OR5R/PDF focused tests pass 9/9, and Local Gate PreCommit and
PostCommit pass with the full Windows suite at 3,080/3,080. PR #136 merged as
`e1426fcfd0f51d4681d56f1426e9788e4fc36fd7`. No product source, Thai
calculation/copy/visual, comparator, threshold, Gate, Backend, Firebase, or
Production resource changed.

## Completed release - BaZi generation latency acceptance (2026-09-19)

Status: **PASS — RELEASED AND PRODUCTION-VERIFIED AT 4.890 SECONDS**

- Live baseline `2d2125c` / `knowme-astrology-api-00007-qkk` took 22.578
  seconds from selection click to readable BaZi result. The measured phases
  were 6.875 seconds click-to-API, 10.201 seconds POST, and 5.503 seconds from
  API success to the final result-specific asset.
- Exactly one authenticated `POST /v1/generate-bazi` returned 200. There was no
  coordinator, legacy/generate duplicate, settled-page chart reload, or
  application console error.
- PR #132 / `cf06bd2` removed the pre-API sequencing and post-API chart reload,
  and revision `knowme-astrology-api-00008-gcq` now keeps one instance warm.
  The first post-release run measured about 0.029 seconds click-to-API, 4.893
  seconds POST, 1.770 seconds response-to-final-font and 6.690 seconds total;
  Cloud Run measured 4.568 seconds. A warm POST measured 3.076 seconds, while
  the still-awaited client profile/Fusion requests continued for about 6.240
  seconds. The five-second target therefore remains unmet.
- PR #133 merged the atomic follow-up as application commit `839534c3` and
  tree `9c306806`. Cloud Run revision `knowme-astrology-api-00009-bpw` was
  deployed first and is Ready at 100% traffic with one minimum instance.
  Hosting release `1789799510184000` / version `6ab2558866d0be41` then
  deployed only Hosting with pin `839534c`.
- Final signed-in direct-click Production timing was 0.038 seconds
  click-to-API, 4.721 seconds POST, 0.131 seconds API-to-final-result-font and
  4.890 seconds total. Cloud Run measured the single successful POST at 4.448
  seconds and the application at 4,445.1 ms.
- Network evidence recorded one POST and one preflight, with zero legacy
  generation, generate-chart, coordinator, browser Firestore freshness, late
  events or post-navigation chart reloads. Browser console errors were zero.
- Backend tests pass 35/35, focused Flutter tests pass 22/22, scoped analyzer
  has zero issues, and the Production Web bundle guard passes. Live
  `main.dart.js` matches the local 8,576,087-byte bundle at SHA-256
  `3A3125ACA50FC65DDD4A85EB8F97F5A296BF626FFC48F15A40E34F6FF0E9E3BA`.
- The complete Windows suite is 3,036 passed / 40 existing Thai
  screenshot-golden failures. No Thai golden changed and the suite is not
  represented as passing. No Thai golden, Firestore rules, Functions, Auth,
  Storage or IAM changed; Production data mutation was limited to the
  authorized BaZi test artifact.

## Release candidate - BaZi Reader V3 (2026-09-17)

Status: **IMPLEMENTED AND UNDER FULL RELEASE VALIDATION**

- Contract `knowme_bazi_reader_v3` converts known birth times to apparent
  solar time with the historical IANA-zone UTC offset, coordinates, and the
  NOAA Equation of Time approximation. The response exposes every correction
  component and includes coordinates in the known-time input fingerprint.
- Historical DST gaps and folds fail closed instead of selecting a time.
  Unknown birth time remains null; no Hour pillar, apparent-solar timestamp,
  luck onset, or other time-dependent value is fabricated.
- Thai contract `knowme_bazi_reader_th_v3` keeps the practical reader order:
  overview, identity, work, money, love, cautions, current ten-year cycle, and
  current year, followed by calculation evidence and limitations.
- The dedicated PDF embeds Thai and CJK fonts, normalizes dash glyphs, and
  stacks long source rows. Five offline fixtures render as 3/5/3/4/4 A4 pages;
  all rendered pages are readable with zero replacement glyphs, clipping,
  overlap, or overflow.
- Production release remains gated on the repository tests, analyzer, Local
  Gate, merge, Cloud Run-first deployment, Hosting-only deployment, and live
  Production web/PDF QA. No Firestore rules, Functions, Auth, Storage, IAM, or
  Production data are in scope.

## Production status - BaZi Reader V2 live (2026-09-16)

Status: **PASS - Production release complete**

- Release baseline: Reader V2 merge `0c8eec05f6741068ef9bd87a5a651f75941eb86d`; production QA found the known no-write fixture still selected V1, fixed separately in PR #126. Final application commit is `fc7e56c8647fdcbddc08885bf853b74a287c4056`, tree `07235acdbdd7bb71986302c816d879cbf62e3144`.
- Cloud Run: `knowme-astrology-api-00005-r87`, image digest `sha256:a1495d512376e81f424c47e0256645d455cd0db72628c51840eb16d37c93f25a`, created `2026-09-16T11:22:35.948120Z`, Ready, traffic 100%. Firebase Admin initialization command override is retained.
- API QA: `/health` returned 200 with status ok; unauthenticated `/v1/generate-bazi` and `/v1/generate-chart` both returned 401.
- Web build: Flutter 3.41.1 / Dart 3.11.0, Production API `https://knowme-astrology-api-avbyttircq-as.a.run.app`, public beta badge, no tree-shaken icons, cache pin `fc7e56c`. Bundle SHA-256 is `dc741c252a2b510b39c2adab39138802a10698193811205f38aa4a9774287c0c`; no localhost or loopback URL was found.
- Firebase Hosting only: release `sites/knowme-app-694e1/releases/1789557959784000`, version `sites/knowme-app-694e1/versions/02ad04dcd6116530`, released `2026-09-16T11:25:59.784Z`.
- Production QA: both `web.app` and `firebaseapp.com` returned 200 for root, `/beta/thai`, and `/beta/chinese?case=known`; both served `flutter_bootstrap.js?v=fc7e56c` and `main.dart.js?v=fc7e56c`. Browser accessibility inspection confirmed Reader V2 order: pillars, overview, identity, work, money, relationships, cautions, ten-year cycle, current year, then technical data, method, sources, and limitations. No V1 slot/group-count report appeared.
- PDF QA: Production button generated a 4-page Reader V2 PDF, SHA-256 `1e247ec57753a61ccc8facdb01e81b549f8587e4553557f595849b58443d5ca1`. All required sections and both contracts were present; Thai and Chinese glyphs rendered correctly; citation wrapping stayed within card bounds; no clipping or overlap was observed.
- Verification reused the accepted Reader V2 candidate results because the baseline tree matched. The production-route hotfix was additionally checked with focused route/report/PDF tests 9/9 and static analysis with no issues.
- Scope guard: only Cloud Run service and Firebase Hosting were deployed. Firestore rules, Functions, Auth, Storage, IAM, and Production data were not changed.

## Source-ready Firebase Admin startup fix (2026-09-17)

Status: **CODE COMPLETE AND LOCALLY VALIDATED; NOT MERGED OR DEPLOYED**

- Root cause: Firebase Admin was initialized only when a persistence module
  lazily created the Firestore client. Authenticated endpoints verify the ID
  token before that persistence path, so Production needed a Cloud Run command
  override that initialized the default app before Uvicorn.
- The FastAPI lifespan now calls one shared, idempotent Firebase Admin
  initializer before serving requests. It reuses an existing default app and
  preserves both the configured service-account-file path and Application
  Default Credentials path.
- Firestore remains lazy. Importing the API app does not initialize Firebase
  Admin or import `firebase_service`; the first persistence call reuses the
  shared initializer before creating the Firestore client.
- Focused startup/auth/UID tests pass 13/13; the complete backend suite passes
  29/29. Python compile validation passes. The Windows Python 3.12 test venv
  used the `pysweph` 2.10.3.6 compatibility wheel for the `swisseph` module
  because the Production-pinned `pyswisseph` 2.10.3.2 release has no CPython
  3.12 Windows wheel; repository requirements and Production dependencies were
  not changed.
- Scope guard: no API contract, calculation, report, Flutter, Firestore schema
  or rules, Firebase Auth/IAM, Production data, Cloud Run, Hosting or deployment
  change is included.
- Keep the live Cloud Run startup override until this source change is reviewed,
  merged, deployed and authenticated Production QA proves the source-owned
  startup path. Remove the override only in that separately authorized release.

# KnowMe Current Status


## Archived pre-release snapshot - BaZi Reader V2 candidate (2026-09-16)

**SOURCE READY: PR #125 REPLACES THE TECHNICAL, COUNT-FIRST BAIZI READING WITH
A READER-FIRST THAI REPORT. PRODUCTION REMAINS ON V1 UNTIL A SEPARATE CLOUD RUN
AND FIREBASE HOSTING DEPLOYMENT COMPLETES.**

- Contract: `knowme_bazi_reader_v2`; Thai interpretation contract:
  `knowme_bazi_reader_th_v2`.
- Reader order: Four Pillars, overview, identity, work, money, relationships,
  balance, current 10-year cycle and current year; auditable technical facts,
  methods, sources and limitations follow the reading.
- Calculation now exposes hidden stems, polarity-specific Ten Gods, a disclosed
  Day Master support heuristic, natal interactions, 10-year luck cycles and
  annual influences. It retains local civil time, Li Chun/Jie boundaries,
  `sect=2` and no true-solar correction.
- Gender is normalized and included in the fingerprint because it determines
  luck-cycle direction. Existing V1 charts remain renderable with the V1
  report path.
- Regression fixtures are synthetic. Personal birth details supplied during
  diagnosis were not added to source, tests, workflow artifacts or docs.
- Validation: backend 24/24; changed Dart formatting and scoped analyzer pass;
  focused Flutter/report/PDF 35/35; full Flutter 3,072/3,072. The generated
  four-page A4 PDF was inspected with no broken Thai/Chinese glyph, clipping or
  overlap.
- PR #125 is source-only. No Cloud Run revision, Firebase Hosting release,
  Firestore rules change or Firebase data mutation is part of this change.

## Archived V1 Production snapshot (2026-09-16)
**LIVE: KNOWME ASTROLOGY V1 IS DEPLOYED TO CLOUD RUN AND FIREBASE HOSTING; PRODUCTION QA PASSED.**
- Release provenance: remote `https://github.com/notekmitl/knowme.git`, commit `664c8656a2028cf266745f9c1c3a0567989266ec`, tree `bee0a7c8ea07035920bc58b2524aa9b68ab96df6`, project `knowme-app-694e1`.
- Final Cloud Run revision: `knowme-astrology-api-00003-b29` in `asia-southeast1`, created `2026-09-16T05:00:07.320990Z`, image digest `sha256:99c1831eb7bda8135cfa9593bf39d074b059588196bc5736aaeb26946701e0df`.
- Firebase Hosting release: `sites/knowme-app-694e1/releases/1789470114786000`, version `sites/knowme-app-694e1/versions/e915f14591fb48f2`, released `2026-09-15T11:01:54.786Z`.
- API QA: `/health` 200; unauthenticated `/v1/generate-bazi` 401; unauthenticated `/v1/generate-chart` 401; authenticated empty-payload probe 422, proving token verification completed before body validation; focused repository auth/UID tests 8/8.
- Production browser QA: Thai, BaZi and Western choices were visible; authenticated BaZi generation returned 200 at `2026-09-16T05:01:45.265470Z` and the full Thai-language BaZi report rendered. No Flutter/API application exception was observed; browser-extension message-channel noise was excluded.
Hosting serves cache pin `664c865` on both `web.app` and `firebaseapp.com`; `/beta/thai` returns 200. The release bundle uses Flutter 3.41.1 / Dart 3.11.0, contains the Production API and both v1 routes, and contains no localhost/loopback API endpoint.
The final Cloud Run revision retains the exact release image. Its command initializes Firebase Admin before Uvicorn because the merged source initializes Admin only at the persistence boundary; real signed-in QA proved that the original startup path rejected an otherwise valid project token. This runtime mitigation is active and verified.
No Firestore rules, Functions, Auth configuration or Storage configuration was deployed. Remaining work is post-release observation and a separately reviewed source-level replacement for the startup wrapper before that wrapper is removed.


## Prior status — BaZi V1 merged; Production deploy pending (2026-09-14)

**CURRENT: PR #120 AND PR #122 ARE MERGED TO `main`. THE BAIZI V1 RELEASE
CANDIDATE IS VALIDATED, BUT THIS CLOSEOUT DID NOT DEPLOY CLOUD RUN OR FIREBASE
HOSTING BECAUSE THE RUNNER COULD NOT COMPLETE A SUPPORTED GOOGLE CLOUD CLI
SESSION AND CLOUD CONSOLE/CLOUD SHELL WERE BLOCKED BY ITS NETWORK POLICY.**

- PR #120 merge: `d8245cd29e94641151988da33800670acbb8866a`.
- PR #122 merge: `664c8656a2028cf266745f9c1c3a0567989266ec`.
- PR #122 application tree: `bee0a7c8ea07035920bc58b2524aa9b68ab96df6`.

The Owner authorized Ready, merge and Production release. Both PR transitions
and merges completed. The remaining action is operational only: from an
authenticated Google Cloud/Firebase runner, deploy the backend from exact
`main` commit `664c8656`, verify `/health` plus authenticated v1 rejection/
UID-binding behavior, then build and deploy Hosting from that same commit.
Do not deploy Firestore rules; this release contains no rules change.

Submitting the birth form at `/beta/thai` now opens one choice screen for Thai,
Chinese BaZi and Western astrology. Choosing Thai runs the existing accepted
Thai path. Chinese and Western verify authentication, map the same birth input
to the canonical profile, generate only the selected system and fail closed if
the fresh result is not ready. Unknown time is stored as empty, works for BaZi
under its omission contract, and disables Western rather than inventing an
ascendant/hour.

The Chinese result now reads as a natal horoscope while remaining auditable:
it starts with a calculated overview, then gives separate strengths, work,
money/resources, relationships and cautions/development readings. Copy is
deterministic and checked in. Each area discloses the Day Master and
joint-highest visible relationship family/count behind it. It does not use AI,
claim timed events or label surface counts as strength, favourability or fate.
Li-Chun/Jie boundary-partial Unknown omits all whole-chart life-area readings.

Authenticated versioned BaZi and Western endpoints and bearer-capable clients
are now merged to `main`. They have not been deployed by this closeout.
Compatibility routes remain during rollout; the existing BaZi compatibility
route is still authenticated, while the pre-existing Western legacy route
remains isolated from the new client. Required release order is backend v1, then client,
adoption verification, then separately authorized legacy retirement.

Fresh closeout validation on Flutter 3.41.1 / Dart 3.11.0: backend **22/22**, focused
Flutter **79/79**, full Flutter **3,070/3,070**, full analyzer exit 0 with 282
inherited non-fatal diagnostics. The Web release build passes route/API scans
at 8,511,604 bytes and SHA-256
`ee11caf2001c75aa86f9cb0018e893d0d76f60ea479d35c8a7a818071e3b874d`.
Production API and both v1 paths are present. Forbidden loopback endpoint
patterns are 0. The sole `localhost` literal is the existing
`window.location.hostname == "localhost"` host-mode comparison, not an API
endpoint; the repository's production endpoint guard passes, so the prior
strict-policy blocker is closed by contextual classification.

No new Cloud Run revision, Firebase Hosting release, Firestore rules change or
Firebase data mutation occurred during this closeout attempt.

The final Known/Unknown/Li-Chun/Jie PDFs are 5/4/3/3 A4 pages. All 15 pages
were inspected with no missing text, broken Thai/Chinese glyph, clipping,
overlap, blank page or Known-to-Unknown Hour leak. Thai calculation/report
source, Thai goldens and `product-acceptance/` have zero delta; the only Thai
route change is the new post-submit navigation seam.

## Prior sourced-reading checkpoint (2026-09-13)

**CURRENT: SOURCED SYMBOLIC READING IMPLEMENTED AND VALIDATED ON STACKED DRAFT
PR #122; NOT READY FOR REVIEW, NOT MERGED AND NOT DEPLOYED.**

Validated application commit `afaa3a97b3a6ce82f555efbfbd79917567ebc339`,
tree `3b56c98a3d03552246acc66ca7e6830b256ba957`.

The Chinese feature is BaZi/Four Pillars, not a year-animal-only horoscope. Its
approved compatibility calculation remains deterministic: Gregorian local
civil fields in a validated IANA zone, Li Chun Year, Jie Month, civil-midnight
Day with `sect=2`, no true-solar correction and fail-closed Unknown time.

The product now adds `knowme_bazi_symbolic_reading_v1`: a checked-in Thai and
English reading catalog covering all ten Day Masters and five broad elemental
relationship families over the visible stems/branches. The report explains a
symbolic tendency, constructive expression, balance point and practical
reflection, then shows which relationship families are most visible without
calling the counts good/bad or strong/weak. It prints a source ledger and does
not use AI to compose a request-time prediction.

Known uses four pillars. Ordinary Unknown uses Year/Month/Day and has no Hour
contribution. Li Chun/Jie Unknown displays only the invariant Day Master reading
and omits a chart-wide relationship summary. Full hidden stems, seasonal
strength, Useful God, polarity-specific Ten Gods, combinations/clashes, Da Yun,
annual timing and domain/event forecasts remain explicitly outside V1.

Signed-in Web, `/beta/chinese` fixtures, plain text and PDF project the same
report object. Authentication/UID binding, input regeneration, stale-chart
hiding and Fusion Known-to-Unknown invalidation remain automated gates.

Final Flutter 3.41.1 / Dart 3.11.0 validation with `CI=true`, analytics
suppressed and `TZ=Asia/Bangkok`: backend **18/18**, focused Flutter **57/57**,
full Flutter **3,055/3,055**, analyzer exit 0 with 282 inherited non-fatal
diagnostics and scoped findings 0. Generated tracked-output deltas were restored
by exact path; Thai source/golden and `product-acceptance/` deltas are 0.

All four PDFs are three A4 pages and the latest 12 raster pages pass visual and
Known/Unknown content QA. `NotoSansSC-Regular` is embedded. The release Web
bundle is 8,469,824 bytes / SHA-256
`3DFF3095890C8EF72E00F499AA44EC6BFA7292CF0F02B548B439699E40C5FCE8`;
Production API and `/beta/chinese` occur once, actual loopback endpoints are 0.
The one inherited `localhost` hostname comparison remains a separate shared
strict-guard blocker before Production.

No V1 calculation or interpretation decision remains. Owner testing is the
next gate; PR #122 must remain Draft and release sequencing still requires a
separate parallel authenticated versioned endpoint migration.

## Prior calculation/report checkpoint — superseded by the sourced reading (2026-09-13)

**CURRENT: READY FOR OWNER TESTING ON STACKED DRAFT PR #122; NOT READY FOR
REVIEW, NOT MERGED AND NOT DEPLOYED.**

The Owner-approved compatibility rules are now an explicit deterministic
contract. Known time returns four pillars. Unknown time omits Hour and all
hour-dependent data and suppresses Year/Month values that are not invariant
across the civil date. Li Chun, Jie, Chinese New Year non-boundary, leap day,
23:00/00:00, timezone and coordinate semantics have targeted tests.

The API verifies Firebase bearer identity, rejects body UID mismatch and writes
only to the verified UID. Profile fingerprints force regeneration after birth
data or contract version changes, and a failed refresh cannot display stale
facts. Fusion versions now incorporate the BaZi input fingerprint and detect a
removed lens, so a Known -> Unknown edit invalidates the old hour-bearing Fusion
snapshot. Signed-in Web, `/beta/chinese` Owner fixtures and PDF/export share one
fact-only report with no unsourced personality or predictive prose.

Owner manual QA covers only the four no-write fixtures—Known, ordinary Unknown,
Li Chun Unknown and Jie Unknown—and their Web/PDF parity. Authentication token,
UID/revoked-token, regeneration and Fusion-freshness assertions are automated
engineering gates rather than Owner fixture tasks.

Authoritative Flutter 3.41.1 Linux validation passes backend **18/18**, focused
Flutter **51/51**, full Flutter **3,049/3,049**, repository analyzer exit 0 with
282 existing non-fatal diagnostics and scoped analyzer 0. Four two-page A4 PDFs
were rendered as eight pages and inspected with visual defect count 0; CJK is
embedded as static `NotoSansSC-Regular`. The release Web bundle passes the
Production endpoint guard and contains `/beta/chinese`; its SHA-256 is
`F30256BE2AF1725DF933ECA7D9228341BBA980D07C6FA058AC08418132AE2959`.

No Thai astrology source, Thai golden, `product-acceptance/`, Production service
or Hosting asset is in scope. The application stays pinned to commit
`8fe3c68e2c60ec9a1511e75bc22982a1d854c007`, tree
`a478defae8cd8f88435e8f5fda7c908db4a11773`.

Actual loopback endpoint findings are 0. The single literal `localhost`
hostname comparison is not an endpoint; strict-guard refinement is a future
shared guard-quality task that remains a policy blocker before Production, and
PR #122 does not change shared runtime. Release is also blocked because
client-first/immediate backend enforcement does not cover cached/open legacy
clients. The recommended unimplemented path is a parallel authenticated
versioned endpoint, new-client migration, adoption verification and later
legacy-endpoint retirement. Exact test/PDF results are in
`CHINESE_ASTROLOGY_VALIDATION_V1.md`.

## Prior Chinese discovery gate — superseded (2026-09-12)

**CURRENT: DRAFT PR #122 OPEN; AUDIT COMPLETE; IMPLEMENTATION AWAITS ONE OWNER
CALCULATION-POLICY DECISION.**

The exact PR #120 head `4ce29747fee66d08637dbe0b16b982b17071526d`
is the stacked base for `codex/chinese-astrology-report-v1`. GitHub, source
lineage and the live `/beta/thai` release match the recorded Production baseline;
there is no older duplicate Chinese PR and no Thai application-code delta from
Production source `e6aaa98` to the stack base. The existing Chinese audit branch
was continued and published as stacked Draft PR #122.

Chinese astrology is BaZi/Four Pillars with a secondary year-animal lens. The
backend implements local-civil calculation with Li Chun/Jie, `sect=2` and no
true-solar correction, while shared Birth Normalization explicitly says real BaZi
normalization is unimplemented. Unknown time, authenticated UID-bound writes,
birth-change cache freshness, citable interpretation provenance and PDF/export
parity are missing. Work is paused under the Owner's explicit hard-stop rule.

Fresh validation: focused Chinese Flutter 83/83; analyzer exit 0 with 297
existing warning/info diagnostics; full Flutter 2,989 passed / 40 existing Thai
screenshot-golden pixel failures on Flutter 3.41.3. No golden was changed.

Fresh live verification returns 200 and cache pin `e6aaa98`. The strict bundle
guard nevertheless finds one literal `localhost` in a hostname comparison; it
finds no localhost/loopback URL and no other loopback string. This pre-existing
shared Production-bundle finding is reported as a separate blocker and was not
fixed or deployed from the Chinese branch.

See [`CHINESE_ASTROLOGY_CURRENT_STATE.md`](CHINESE_ASTROLOGY_CURRENT_STATE.md);
the initial audit remains an explicitly historical snapshot. Audit-only: no
runtime, Thai, `product-acceptance/`, Production, Ready, merge or deploy change.

## PR120 Reader Voice V3 Revision 8 — Production Hosting release (2026-09-12)

**OWNER-AUTHORIZED PRODUCTION HOSTING RELEASE LIVE — FIREBASE RELEASE `04c592` — PUBLIC ROUTE SMOKE PASS — OPEN + DRAFT — NOT MERGED.**

The Owner explicitly authorized the Production deployment after the Revision 7 supported-input matrix passed. The deployed application is pinned to source HEAD `e6aaa987ebf02da4ac3c05909c385f8378514b35`, tree `c3318444a97b74fdc0e58a67560fa0cb2745479b` and cache key `e6aaa98`. It was built with Flutter 3.41.1 / Dart 3.11.0 for the Production astrology API and `THAI_PUBLIC_EVIDENCE_BADGE_BETA=public_beta`. The Flutter tool was run from an AOT snapshot because this environment could not execute its JIT snapshot; `--no-tree-shake-icons` was required for the same JIT limitation and changes only icon-font optimization, not application source, reader copy or prediction logic.

Pre-upload guards found the Production API host and zero `localhost`, `127.0.0.1`, `10.0.2.2` or `0.0.0.0` endpoints. Pinned payload SHA-256 values are `7585e92bccd47cbb6e4874f493de7c7dfac8e85b6a27251254eca65217e2ea56` for `index.html`, `4af0e8f2fd062dfdf5bb65abc5a715e267b8255c4649738c797edcd95fd5b67f` for `flutter_bootstrap.js`, `389fe890ca9882a9d3b36710411c5d8eaaf45ab5316b6478e5d536923c208970` for `main.dart.js` and `a131df5ca46154cc4eb79044f7f5a14029c2f8bfccf8cef34e3ec3b5a9f5a88c` for `flutter_service_worker.js`. The transfer archive SHA-256 is `c14a9a8340904b9564dbcd76961865aa2970f1e27972771de5c3eb2c9739db43`.

The first Hosting upload stopped safely during file transfer after Firebase exhausted its retries; no release was finalized. The authorized serial retry uploaded all 77 Hosting files, finalized the version and completed the release. Firebase Console reports current release `04c592` at `2026-09-12 12:03 Asia/Bangkok`; previous release `8635e6` remains available as the rollback baseline. Live browser QA opened `https://knowme-app-694e1.web.app/beta/thai`, rendered the Thai research landing screen and its start action, and confirmed both `flutter_bootstrap.js?v=e6aaa98` and `main.dart.js?v=e6aaa98`. No application-origin runtime error was observed; the remote QA browser emitted only its expected CPU-rendering fallback warning.

Deployment scope was Firebase Hosting only. Firestore, Functions, Cloud Run, Authentication, Storage, Firebase configuration, Production data and `product-acceptance/` were not changed. The already-passed Revision 7 gates were not rerun for this deployment/docs-only closeout. PR #120 remains Open + Draft and unmerged; this Production authorization does not authorize merge or Ready for Review.

## PR120 Reader Voice V3 Revision 7 — supported-input completeness (2026-09-11)

**CANDIDATE 0029 SUPPORTED-INPUT MATRIX PASSED — OPEN + DRAFT — READY FOR OWNER TESTING ONLY — NOT OWNER-ACCEPTED — NOT READY FOR REVIEW — NOT MERGED — NOT DEPLOYED.**

At the Owner's request, Revision 7 adds a layered completeness matrix over the full input domain exposed by the Thai report flow. Birth normalization passes all 776,160 combinations of 7 civil weekdays × 1,440 clock minutes × 77 selectable Thai provinces, including both sides of local sunrise and all seven resulting astrological weekdays. The Known-time runtime passes 1,909 real analysis/plan cases and 126 complete reader documents, reaching all five form gender representations, 12 lagna values, 49 predictive contexts and all 392 context/age/planet rows at their inclusive boundaries. Unknown time passes all 539 weekday/province combinations with no predictive leakage.

The matrix found and fixed two generalized-runtime defects that the earlier reference-profile tests did not expose. Generic profiles still carried legacy current, relationship, zero-based past-range and rolling-highlight wording; terminal age periods could also suppress the whole plan when no legitimate next-life-period window existed. The runtime now applies the requested reader structure to every supported context and emits all applicable claims at terminal periods without inventing a future period. Two stale UI assertions were updated from the retired generic heading to “คำทำนาย 12 เดือนข้างหน้า”; the independently versioned infographic title remains unchanged.

Final gates on Flutter 3.41.1 / Dart 3.11.0 with CI=true, analytics suppressed and TZ=Asia/Bangkok: completeness matrix 3/3; focused runtime/export/PDF/completeness 84/84; updated heading regressions 13/13; OR5 evidence 5/5; Node foundation/signature 9/9; Candidate 0024–0029 validators PASS; full Flutter suite 3,029/3,029; changed-scope analyzer 0 issues; repository analyzer exits 0 with 297 historical warning/info diagnostics.

The exhaustive statement is intentionally limited to the selectable Thai place domain. It does not cover arbitrary worldwide coordinates or every Cartesian combination as a full rendered document, and it does not claim astrological predictive accuracy. Selector, evidence authority, Canon, Known/Unknown boundary and product-acceptance/ are unchanged. PR #120 remains Open + Draft; this revision does not authorize Ready for Review, merge, deployment, Production access or Production mutation.


## PR120 Reader Voice V3 Revision 6 — Candidate 0029 runtime (2026-09-11)

**CANDIDATE 0029 IMPLEMENTED AND VALIDATED FOR OWNER TESTING — OPEN + DRAFT — NOT OWNER-ACCEPTED — NOT READY FOR REVIEW — NOT MERGED — NOT DEPLOYED.**

Owner feedback rejects Candidate 0028 Runtime Revision 5 as the final reader experience. Revision 5 interpreted “ท้ายสุดของคำทำนาย” as the final prediction section instead of the absolute final report section, and it grouped the current domains semantically while still rendering their labels as subheadings. Candidate 0028 remains an immutable historical artifact at SHA-256 `53F4A8DEA71CAAE7EC19CBDC3E359B560C3B260285631804932ED3B40A1C1798`.

Candidate 0029 moves `ข้อจำกัด` after `ที่มาของผลวิเคราะห์` as the final report section. The current reading is now one heading followed by exactly six continuous paragraphs: the current overview and five inline `ด้าน...` paragraphs, with zero domain subheadings. All previously requested past-period, governing-planet, partnered/single relationship, rolling-12-month and facts-only chart corrections remain intact.

The implementation retains the Candidate 0023 selector, evidence bindings, calculations, Known/Unknown boundary and fail-closed behavior. No selector, evidence authority, fixture override, Canon rule or predictive claim was added.

Validation on Flutter 3.41.1 / Dart 3.11.0 with `CI=true`, analytics suppressed and `TZ=Asia/Bangkok`: focused Flutter 81/81; OR5 evidence 5/5; PDF artifact generation 3/3; Node foundation/signature 9/9; Candidate 0024–0029 validators pass; full Flutter suite 3,026/3,026. Full analyzer exits 0 under repository policy with 297 historical warning/info diagnostics; scoped analysis reports 0 issues.

A fresh Owner Review PDF was generated from the actual 00:03 profile for `asOf=2026-09-11 Asia/Bangkok`: `KnowMe_Candidate_0029_Runtime_Revision_6_Owner_Review_0003.pdf`, 5 A4 pages, 333,750 bytes, SHA-256 `ACC141F1EEAE6D9579172FDCD17B779BB5B39DA049F5E36E835A4EDC93A2DD1E`. All five rendered pages were inspected; missing text, broken Thai glyphs, clipping, overlap, overflow and blank pages are 0.

Candidate 0029 has no Owner-accepted exact golden. PR #120 must remain Open + Draft until explicit Owner acceptance. This revision does not authorize Ready for Review, merge, Firebase deployment, Production data access or any Production change. `product-acceptance/` is unchanged.


## PR120 Reader Voice V3 Revision 5 — Candidate 0028 runtime (2026-09-11)

**CANDIDATE 0028 IMPLEMENTED FOR OWNER TESTING — OPEN + DRAFT — NOT OWNER-ACCEPTED — NOT READY FOR REVIEW — NOT MERGED — NOT DEPLOYED.**

Owner feedback rejects Candidate 0027 Runtime Revision 4 as the final reader experience. Candidate 0027 remains an immutable historical review artifact. Candidate 0028 omits the redundant life-path overview, keeps one past-prediction heading, replaces the first range with `ตั้งแต่เกิดจนถึง 10 ปี`, adds the dynamically resolved governing planet to every life-period heading, expands all past-period explanations, groups the current introduction and five domains into one continuous section, covers both partnered and single readers, adds `เด่นเรื่อง` to both rolling-12-month topics, moves limitations to the end of the prediction sequence, and reduces the main-chart structure to seven facts without explanatory tails.

The implementation retains the Candidate 0023 selector, evidence bindings, calculations, Known/Unknown boundary and fail-closed behavior. The single-reader wording stays evidence-bound (`หากกำลังทำความรู้จักใคร`) rather than promising an unsupported new person or event. No new selector, evidence authority, fixture override, Canon rule or predictive claim was added.

Final validation on Flutter 3.41.1 / Dart 3.11.0 with `CI=true`, analytics suppressed and `TZ=Asia/Bangkok`: Candidate runtime 18/18; export 59/59; PDF title/field integrity 4/4; OR5 evidence 5/5; Node foundation/signature 9/9; Candidate 0024–0028 validators pass; full Flutter suite 3,026/3,026. Full analyzer exits 0 under repository policy with 297 historical warning/info diagnostics; scoped analysis of all changed Dart/test files reports 0 issues.

A fresh Owner Review PDF was generated from the actual 00:03 profile for `asOf=2026-09-11 Asia/Bangkok`: `KnowMe_Candidate_0028_Runtime_Revision_5_Owner_Review_0003.pdf`, 5 A4 pages, 333,991 bytes, SHA-256 `1E400D4DD435D2C22DB6A11C7C93267B7DBB68A6130C720478C2C89F67E605CC`. All five rendered pages were inspected; missing text, broken Thai glyphs, clipping, overlap and overflow are 0.

Candidate 0028 has no Owner-accepted exact golden. PR #120 must remain Open + Draft until explicit Owner acceptance. This revision does not authorize Ready for Review, merge, Firebase deployment, Production data access or any Production change. `product-acceptance/` is unchanged.


## PR120 Reader Voice V3 Revision 4 — Candidate 0027 runtime (2026-09-11)

**CANDIDATE 0027 IMPLEMENTED FOR OWNER TESTING — OPEN + DRAFT — NOT OWNER-ACCEPTED — NOT READY FOR REVIEW — NOT MERGED — NOT DEPLOYED.**

Implementation commit `772f69dbb6f7b0ad81d25a26a4b7303b2c827264` applies the Candidate 0027 reader copy to the accepted Candidate 0023 selector/evidence component set.…31745 tokens truncated…Firebase/Production ไม่เปลี่ยน.

**CURRENT — PR107-OR3 TECHNICAL CLOSURE COMPLETE — PENDING OWNER FINAL LANGUAGE RE-ACCEPTANCE (2026-08-26).** OR2 ผ่าน Visual/Structure/Infographic แต่ถูก Owner Reject ด้าน final human-sounding Thai copy. OR3 แก้ reader-copy/test-only ที่ `5e05d1c0c725064a8a833489a5904cff53871e02`: Known ให้ความหมายมาก่อนหลักฐานและตัดภาษารายงาน; Unknown รวม opening/limitation ที่ซ้ำและปรับ Section 4/omission rows โดยคง fail-closed, semantics, traceability, four sections, `แนวโน้ม 12 เดือนข้างหน้า`, `7 ส.ค. 2569 – 6 ส.ค. 2570`, `monthlyTimelineAvailable=false`, Engine, Canon, R1–R7.1 และ infographic OR2. Validation: Focused 96/96, Narrative 38/38, Artifact 3/3, audit 300 / 12,651 / impacts 0, Full 1,623/1,623, Analyzer exit 0 baseline 298 และ PreCommit PASS. Fresh QA ผ่าน Web 12, infographic 4×1080×1920, Dedicated 8/7, Chrome print 7/7 และ raster 29/29; provenance missing/mismatch 0. ZIP SHA-256 `104A39A6A55E11F4A14211A464BB426B93C9955AB95EB1BE0A1B7C1CEA862A0A`. PR #107 ยัง Open + Draft; ไม่ Merge, Ready, Deploy หรือเปลี่ยน Firebase/Production/`product-acceptance/`.

**CURRENT — PR106 DEPLOYED TO PRODUCTION — OWNER ACCEPTED — FULL AUTHENTICATED PRODUCTION QA PASSED — FIXTURE REMOVED (2026-08-25).** PQ2 run `pr106_pq2_prod_qa_20260825T101222177Z` verified Production release `1787640954233000` / version `0aea9c854b86b99f` end-to-end with synthetic Known-time and Unknown-time accounts. Desktop 1440/mobile 390 Web, four 1080×1920 infographic surfaces, Dedicated PDFs 9/8 and Chrome browser-print PDFs 8/7 all passed; 32 PDF rasters were opened and inspected. Unknown remains fail-closed, `monthlyTimelineAvailable=false`, and there are no good/caution months or monthly predictions. Cleanup is complete: Auth 2/2 user-not-found, exact Firestore roots 2/2 and Known subdocuments 8/8 missing, Unknown subdocuments 0, fixture-tag/Storage-prefix/pending jobs 0. Hosting is unchanged. Evidence ZIP SHA-256: `271C75CF207A91A218D97F6817A45CDBA9E649E2C438D59D1528897775B59789`. PQ2 changed only these six status Markdown files; source/code/test/artifact and `product-acceptance/` delta are 0.

**CURRENT — PR106 PAGINATION AUDIT: FALSE NEGATIVE CONFIRMED; FULL AUTHENTICATED RE-QA STILL REQUIRED (2026-08-25).** PQ1 classification is **A — content-dependent pagination**. OR3 and Production PDFs came from byte-equivalent app/PDF/print source and materially equivalent A4/font/Chrome 151/Skia m151 settings, but different profile inputs and as-of dates. Production tail pages contain substantive Section 4/evidence/omission content; no blank page, clipping, overlap or overflow was found. OR3 8/7/7/7 is fixture-specific, not global. This corrects the regression interpretation but does not grant Production QA PASS: all four Known/Unknown infographic surfaces at 360/390 were not completed. Full authenticated re-QA remains required. No source, test, artifact, deployment, Firebase, Production-data or `product-acceptance/` change occurred.

**CURRENT — PR106 AUTHENTICATED PRODUCTION QA FAILED; FIXTURE REMOVED (2026-08-25).** Two synthetic Auth accounts exercised live Known-time and Unknown-time reports on release `1787640954233000` / version `0aea9c854b86b99f`. Unknown remained fail-closed, but fresh PDFs were Dedicated 9/8 and Chrome browser-print 8/7 pages, not the Owner-accepted OR3 baseline 8/7/7/7. No Production QA pass is claimed. Cleanup is complete: both exact UIDs return user-not-found, exact Firestore roots/subcollections are 0, and the run-tag Storage prefix is 0. No code or deploy change was made; Production remains on the same Hosting release.

**Console clarification (2026-08-25):** KnowMe runtime errors were 0. Chrome logged three extension message-channel errors against the page URL, plus extension-origin warnings; these are disclosed browser-extension noise rather than output from the KnowMe bundle.

**CURRENT — PR106 DEPLOYED; PUBLIC/ASSET VERIFIED; AUTHENTICATED PRODUCTION QA BLOCKED (2026-08-25).** Exact merged source `d63a6079372db1c23f6458f5a5dc10e4973c2c05` was deployed Hosting-only to Firebase project/site `knowme-app-694e1` as release `1787640954233000`, version `0aea9c854b86b99f`, at `2026-08-25T13:55:54.233+07:00`; Production URL is `https://knowme-app-694e1.web.app`. Cache-bypassed `/` and `/beta/thai` are HTTPS 200 and the three release entry assets match the clean local bundle exactly by SHA-256. Chrome desktop 1440/mobile 390 smoke has no blank screen, clipping, horizontal overflow, or application-origin console error. The available authenticated session did not contain a completed safe QA report fixture, so live Known/Unknown copy, infographic and PDF/Print were not claimed verified; no user data was changed. Focused 95/95, audit 300/8,956/impacts 0, narrative 38/38, artifact 3/3 and production bundle guards passed; unchanged-source OR3 full 1,622/1,622 and Analyzer/PreCommit/PostCommit remain applicable. Rollback baseline `1787482140137000` / `e563b9b6df94ef81` was recorded and not used. Only Hosting changed; other Firebase resources and Production data are unchanged.

**CURRENT — PR106 MERGED TO MAIN — OWNER ACCEPTED — NOT DEPLOYED — READY FOR RELEASE DECISION (2026-08-25).** PR #106 merged by regular merge commit `4be5eddca88b13ea1303480c0370e46d91f3c425` at `2026-08-25T13:10:39+07:00`, from base `58b1d742f7a00ef9c882c1fad2357dbcf08f3ad0` and accepted PR HEAD `c422c4748c30d7c9ca7d722fe0624857614edb7a`. GitHub reports MERGED and no check runs (`statusCheckRollup=[]`). Post-merge verification found the merge tree byte-identical to PR HEAD, unexpected paths 0 and `product-acceptance/` delta 0. Owner Final Language Acceptance PASS remains bound to implementation `d516477a808f7ff2fe791e561451c68043796301`, OR3 source/evidence `f5780d4881b8dbf91138bb6bdb3e773a4ba77c5f`, and ZIP SHA-256 `42F729EF2E14AAB8200B0911E96DF565DBDCB2BFA7D18DEC8D0D7528BEE5DC11`. Reference validation: Focused 95/95, audit 300 / 8,956 / impacts 0, full 1,622/1,622, Analyzer/PreCommit/PostCommit pass, PDFs 8/7/7/7. Production has not been deployed and Firebase/Production are unchanged. Next gate: separate Release/Deployment Decision.

**CURRENT — PR106 OWNER ACCEPTANCE PASSED — READY FOR FINAL MERGE DECISION (2026-08-25).** Owner decision is `PR106-OR3 OWNER FINAL LANGUAGE ACCEPTANCE: PASS`, bound only to implementation commit `d516477a808f7ff2fe791e561451c68043796301`, pre-closeout PR HEAD `f5780d4881b8dbf91138bb6bdb3e773a4ba77c5f`, and Owner ZIP SHA-256 `42F729EF2E14AAB8200B0911E96DF565DBDCB2BFA7D18DEC8D0D7528BEE5DC11`. OR1 passed Visual/Structure but was rejected for language; OR2 fixed the main issues but was rejected for Final Editorial Quality; OR3 passed Visual, Structure, Infographic and Final Thai Language for Known/Unknown. The four-part order, infographic after `แนวโน้ม 12 เดือนข้างหน้า`, and `7 ส.ค. 2569 – 6 ส.ค. 2570` are accepted. Unknown stays fail-closed and omits topics requiring birth time; `monthlyTimelineAvailable=false`; no good/caution months or monthly predictions. OR3 validation remains Focused 95/95, audit 300 profiles / 8,956 fields / impacts 0, full 1,622/1,622 and Analyzer/PreCommit/PostCommit pass; PDFs are Dedicated 8/7 and browser-print 7/7. Closeout is docs/status-only. PR #106 has not been merged or deployed; Firebase/Production are unchanged.

**CURRENT — PR106-OR3 TECHNICAL VALIDATION COMPLETE — PENDING OWNER FINAL LANGUAGE RE-ACCEPTANCE (2026-08-25).** OR2 passed Visual/Structure/PDF/Technical Validation but was rejected for Final Thai Editorial Quality. The copy-only OR3 sweep is implemented at final source commit `d516477a808f7ff2fe791e561451c68043796301`; accepted R1–R7.1, `product-acceptance/`, semantics and traceability are unchanged. Focused 95/95, 300 profiles / 8,956 changed fields with all six impact counters 0, full suite 1,622/1,622, analyzer, PreCommit and PostCommit pass. Fresh QA covers Web desktop/mobile, four 1080×1920 infographics, Dedicated 8/7 and Chrome print 7/7 pages; all 29 PDF rasters were opened. Verified package: `OWNER_REVIEW_PR106_OR3_d516477.zip`, SHA-256 `42F729EF2E14AAB8200B0911E96DF565DBDCB2BFA7D18DEC8D0D7528BEE5DC11`. PR #106 remains Open + Draft; no Acceptance, merge, Ready-for-Review, deploy or Firebase/Production mutation.

**CURRENT — PR106-OR2 TECHNICAL VALIDATION COMPLETE — PENDING OWNER LANGUAGE RE-ACCEPTANCE (2026-08-24).** OR1 passed Owner visual/structure review but was rejected for language. The limited OR2 copy/consistency repair is implemented at `7a03a0ca4a692b0caa7dcdf6c51ae7fbf1ae4892`: Unknown is explicitly fail-closed, omission reasons and all past-reflection age bands read naturally, and the Unknown conclusion is identical on report and infographic surfaces. The 300-profile / 6,192-field audit has semantic, omission, addition, prediction/advice and traceability impact 0; required full suite is 1,621/1,621 and analyzer retains only the 298-item non-fatal baseline. Fresh QA measures Dedicated 8/7 and Chrome browser-print 7/7 pages, with four complete 1080x1920 infographics and desktop/mobile Web captures opened and inspected. External package: `OWNER_REVIEW_PR106_OR2_7a03a0c.zip`. PR #106 remains Open and Draft. This is not Owner/Product Acceptance; no merge, Ready-for-Review, deploy or Firebase/Production mutation occurred.

**CURRENT — PR106-OR1 COMPLETE — PENDING OWNER VISUAL AND LANGUAGE RE-ACCEPTANCE (2026-08-24).** Owner-rejected Draft PR #106 was repaired in source at implementation commit `b5526dd33441e96e47308c038f9fc15de119f6e9`. Focused tests, 300-profile / 5,720-field copy audit (all impact counters 0), required full suite 1,620/1,620, analyzer, PreCommit and PostCommit pass. Fresh actual QA passes Dedicated Known/Unknown 8/7 pages, Chrome browser-print 7/7 pages, four 1080×1920 Known/Unknown infographics for 360/390 surfaces, and Web desktop/mobile contact sheets. External ZIP `OWNER_REVIEW_PR106_OR1_b5526dd.zip` has SHA-256 `2B7BCF311CCE3F881A4192020B9AC02FA530FE209F8D8E1CA71EF0DEA2432956`; extraction verifies 95 files / 94 manifest hashes / 0 errors. This is not Owner/Product Acceptance. PR remains Open and Draft; no merge, Ready-for-Review, deploy or Firebase/Production mutation occurred.

**HISTORICAL — PRE-OR1 OWNER PACKAGE, REJECTED (2026-08-24).** The prior package was generated from `f0931fd581c7ea24567cbee165146c7d725f14e0` with Dedicated 9/8 pages and was subsequently rejected by Owner. It is superseded by the PR106-OR1 package above and must not be used for re-acceptance.

**CURRENT — THAI REPORT READER EXPERIENCE V2 DRAFT PR #106 OPEN; LOCAL GATES PASSED (2026-08-24).** Branch `codex/thai-report-reader-experience-v2` from exact main `58b1d742f7a00ef9c882c1fad2357dbcf08f3ad0` is pushed at implementation commit `2f59602867c6ce5c53bd76d00efe2645121e7d68`; Draft PR https://github.com/notekmitl/knowme/pull/106 is open. Focused tests pass 91+1+38+3, 300-profile audit passes 4,884 fields with all impact counters 0, required full suite passes 1,618/1,618, analyzer exits 0, and PreCommit/PostCommit pass. Direct QA passes four 360/390 Known/Unknown PNGs, dedicated PDF Known 9 / Unknown 8 pages and Chrome browser-print Known 7 / Unknown 7 pages. Thai Engine, Canon, calculations, life-period boundaries, evidence traces, Known/Unknown fail-closed behavior and accepted R1–R7.1 artifacts are unchanged; `monthlyTimelineAvailable=false`. GitHub reports clean merge state but no check runs or Actions runs for this branch. No merge, deploy or Firebase mutation occurred. See `docs/THAI_REPORT_READER_EXPERIENCE_V2.md` and `TASK_RESULT.md`.

**CURRENT — PR #100 REPORT EXPERIENCE DEPLOYED; BROWSER-PRINT PDF VERIFIED (2026-08-23).** Case B repair PR #104 merged as `05c233a6759730d29b6cf7170d16b738e760d4b7`. One Flutter 3.41.1 / Dart 3.11.0 build was deployed unchanged to Preview `1787481247171000` / `dedf5b2acf6e17c4` and Production `1787482140137000` / `e563b9b6df94ef81` at `2026-08-23T10:49:00.137Z`. Both environments pass assets 77/77, routes 2/2, Browser-print 7/7 and 49/49 pages, dedicated PDF 7/7 and 56/56 pages, semantic parity 100%, visual QA 105/105, console/page/request errors 0, mobile Known/Unknown and reader-visible delta 0. Infographic identity remains 15/15 at 1080x1920. Rollback was prepared but not required. Only Firebase Hosting changed. R7.1/R1–R7.1 remain immutable; PR #102 remains Closed/unmerged and `monthlyTimelineAvailable=false`, so Monthly Timeline remains deferred. See `docs/V15_PR100_BROWSER_PRINT_PDF_PRODUCTION_RELEASE.md`.

**CURRENT — BROWSER-PRINT CASE B ROOT CAUSE REPAIRED LOCALLY; REPAIR PR/RELEASE PENDING (2026-08-23).** The PR #100 Preview blocker is reproducible with a complete semantic print tree, no open overlay, actual print events, `body.position=fixed` and `html.height=0`; this proves an application print regression rather than QA capture state. The minimal print-only host reset restores 7/7 browser-print PDFs at 49/49 pages while dedicated PDFs remain 7/7 at 56/56 pages. Reader-visible/semantic delta is 0 and all 105 pages pass visual QA; focused, canonical, R7, cross-runtime, analyzer and full-suite reconciliation gates have branch-only delta 0. R7.1 and R1–R7.1 remain immutable. PR #102 remains Closed/unmerged and `monthlyTimelineAvailable=false`. Production remains release `1787038542564000`, version `5f98dfffef913e38`; no repair merge or Firebase mutation has occurred at this checkpoint. See `docs/V15_PR100_BROWSER_PRINT_PDF_ROOT_CAUSE_REPAIR.md`.

**CURRENT — PR #100 RELEASE BLOCKED AT LIVE PREVIEW BROWSER-PRINT GATE; PRODUCTION UNCHANGED (2026-08-20).** Fresh pre-deploy gates passed from main `46d7883bca87570950eb84a7ca3dffbb3e6653b3`, and the one-time build matched Firebase Preview 77/77 at release/version `1787218038705000` / `397d3a927a64bd5d`. Real Preview dedicated PDFs pass 5/5 at 8 pages each, canonical degrees and Unknown fail-closed pass, and canonical/mobile infographics are 1080×1920 with the approved title. Real Chrome browser-print fails 5/5: every output is one clipped page with only 7.51–8.12% of the corresponding dedicated-PDF text. Root proof shows complete semantic print markup but computed `body.position=fixed` and `html.height=0`. The task forbids source repair, so Production was not deployed and no rollback was needed. Production remains release `1787038542564000`, version `5f98dfffef913e38`; only Hosting Preview channels changed. PR #102 remains closed unmerged; Monthly Timeline is DEFERRED and `monthlyTimelineAvailable=false`; R1–R7.1 remain immutable. See `docs/V15_PR100_REPORT_EXPERIENCE_PRODUCTION_RELEASE.md`.

**CURRENT — PR #100 OWNER-APPROVED COPY/VISUAL EXPERIENCE MERGED; PRODUCTION UNCHANGED (2026-08-19).** PR #100 merged as regular merge commit `1a562c6a5c93d89485f70f9bba7820f018b2849f` at `2026-08-19T09:03:56Z`. Parents are pinned main `be5e38a211eb9aa47edf88a95e71659d33752245` and approval-documentation HEAD `18f10ba23dfdb193e41241db31dc0c2336c07023`; merge tree `1f1aceaeb3a2567a3d39f850756ef4f837c41344` is byte-identical to the accepted PR tree with unexpected diff 0. Accepted application/test/tool/web trees remain byte-identical to Owner-approved evidence HEAD `87bd8d466d5ed657667c6ab2c21871d4ffd2ab5d`. Approved coverage is 60/60 rules, 4,407/4,407 ledger fields, 15/15 infographics and 14/14 PDFs / 105/105 pages; branch-only test/analyzer delta is 0 and R7.1 remains immutable. `monthlyTimelineAvailable=false`; monthly timeline remains BLOCKED and requires a separate future PR. Production remains V1.5 release `1787038542564000`, version `5f98dfffef913e38`; no Deploy or Firebase mutation occurred.

**CURRENT — PR #100 OWNER COPY/VISUAL APPROVED; FINAL MERGE GATE PENDING (2026-08-19).** Owner approval is bound to accepted HEAD `87bd8d466d5ed657667c6ab2c21871d4ffd2ab5d` and evidence manifest `A03C979B8FA9F1BAFA85993371C17E19475DD2DE0927840CCD87002BC203BC78`. Approved scope is 60/60 grouped copy rules, 4,407/4,407 fields across 300 profiles, 15/15 Revision 4 infographics and 14/14 PDFs / 105/105 pages. Semantic, omission, addition, prediction/advice and traceability impacts remain 0; Web/PDF parity and title raster 15/15 remain accepted. PR #100 stays Draft until the Final Merge Gate passes. `monthlyTimelineAvailable=false`; monthly timeline remains BLOCKED. Deployment and Firebase mutation are not authorized. Production remains V1.5 release `1787038542564000`, version `5f98dfffef913e38`.

**CURRENT — PR #100 REVISION 4 INFOGRAPHIC TITLE INTEGRITY VERIFIED; OWNER REVIEW PENDING (2026-08-19).** Owner rejection of Revision 3 is preserved, but final-byte proof corrects the diagnosis: all 15 Revision 3/4 PNG pairs are byte-identical and contain the expected title raster; ambiguous preview rendering is the first divergence. Revision 4 adds a 15-fixture final-raster gate, five negative regressions, SHA-bound originals, unique-labelled contact sheets, 14 PDFs/105 source-labelled renders and 12 fresh Web screenshots. Fresh gates pass: focused 13/13, copy audit 300/4,407 with all impact counts 0, Known/Unknown 62/62, screenshots 24/24, Life Map 32/32, matrix 864/864, R7 286/286, full-suite and analyzer branch-only deltas 0, Web build and VM×2/Chrome×2 exact parity. R7.1 remains immutable 63/63; R1–R7.1 modified paths 0. Owner decision remains Pending; `monthlyTimelineAvailable=false`. Keep PR #100 Open, Draft and unmerged. DO NOT MERGE or DEPLOY. Production remains V1.5 release `1787038542564000`, version `5f98dfffef913e38`; no Firebase mutation occurred.

**CURRENT — PR #100 REVISION 3 PDF EVIDENCE REPAIR VERIFIED; OWNER REVIEW PENDING (2026-08-19).** Root-cause proof shows the Owner Known PDFs were never clipped: repeated `page-1.png` basenames caused a preview/cache identity collision. Final evidence now binds every raster to its source PDF; all 14 PDFs / 105 pages passed automated geometry/content checks and manual review. Fresh gates pass: PDF 10/10, copy/layout 11/11, Known/Unknown 62/62, screenshots 24/24, Life Map 32/32, matrix 864/864, exact original R7 runner 286/286, scoped analyzer 0, full analyzer branch-only 0, full-suite branch-only failures 0, Web build, and VM×2/Chrome×2 exact parity. R7.1 remains immutable 63/63 and R1–R7.1 modified paths are 0. Owner copy/visual decisions remain Pending; monthly timeline is still BLOCKED with `monthlyTimelineAvailable=false`. Keep PR #100 Open, Draft and unmerged. DO NOT MERGE or DEPLOY. Production remains V1.5 Hosting version `5f98dfffef913e38`; no Firebase mutation occurred.

**CURRENT — PR #100 OWNER REVIEW ARTIFACT REPAIR REVISION 2; MONTHLY TIMELINE BLOCKED (2026-08-18).** Draft-only vNext candidate now has repaired Known/Unknown 1080×1920 infographics, 360/390 Web captures, complete PDF/browser-print contact sheets, and a readable grouped Owner copy table backed by a full 300-profile / 4,003-field Revision 2 ledger. Semantic, omission, addition, prediction/advice and traceability impacts are 0; the prior 2,105-field ledger remains preserved. Technical gates pass with focused 105/105, layout/export/screenshot 98/98, full-suite branch-only failures 0, analyzer branch-only diagnostics 0, Web build pass, VM/Chrome byte parity, and R7.1 immutable 63/63. Owner copy and visual decisions remain Pending. Monthly evidence is absent, so no good/caution months are invented and the timeline remains BLOCKED. PR #100 must remain Open, Draft and unmerged; DO NOT MERGE or DEPLOY. Production remains V1.5 Hosting version `5f98dfffef913e38`; V1.4 rollback remains `10af10c6d960d590`.

**CURRENT — V1.5 DEPLOYED AND VERIFIED (2026-08-18).** Canonical line-ending repair PR #98 merged as `642069f0f298bc8a1f86b795f043e02e914aa97d`; the accepted application tree remains unchanged. A fresh isolated Flutter 3.41.1 / Dart 3.11.0 release gate passed, one immutable Web build was deployed first to Preview and then Hosting-only to Production. Preview release/version is `1787036689380000` / `95bbd383a56dee39`; Production release/version is `1787038542564000` / `5f98dfffef913e38` at `2026-08-18T07:35:42.564Z`. Production assets match 77/77 and routes 2/2; desktop/mobile browser smoke has application console errors 0. Frozen/live canonical Web/PDF is 5/5, S008 canonical mismatch 0, reader-visible delta 0, traceability 170/170, Owner Known Aquarius 19°19′, regression 00:03 Aquarius 9°24′, and Unknown remains fail-closed. Five live Production PDFs total 34 pages; extracted/canonical text is exact 5/5 with substantive delta 0 and every page passed visual QA. No rollback was required. Only Firebase Hosting changed; other Firebase services and accepted R1–R7.1 artifacts remain unchanged.

**CURRENT — V1.5 CANONICAL LINE-ENDING GATE REPAIR VALIDATED; PRODUCTION REMAINS V1.4 (2026-08-18).** Byte-level proof across all ten canonical Web/PDF comparisons establishes that Windows Git checkout conversion was the only mismatch: Git blobs and pipeline are LF, worktree/loader are CRLF, and line-ending-only canonicalization restores exact identity 10/10 with no hidden content delta. The test/comparison-only repair passes helper 11/11, focused 36/36, copy audit 300/300 with reader-visible/semantic/omission/addition/prediction-to-advice delta 0, real VM/Chrome canonical parity 0, analyzers 299/299/delta 0, and full-suite reconciliation branch 2,925/39 versus pinned-main LF 2,914/39 with branch-only/main-only 0. R7.1 remains immutable. No application/canonical/golden/expected/artifact change and no V1.5 build, Preview, deploy, or Firebase mutation occurred. Production remains V1.4 `10af10c6d960d590` pending merge and a fresh release run.

**CURRENT — V1.5 PRODUCTION RELEASE RERUN BLOCKED BEFORE BUILD; PRODUCTION REMAINS V1.4 (2026-08-18).** Owner-authorized release provenance passed at final main `bf8fbd159568d521bcb0f88cd72b21e24444cd9a`; application paths remain identical to accepted HEAD/tree and the authoritative accepted packet remains 332 files / 480,630,900 bytes / missing 0 / mismatch 0. Exact V1.4 version `10af10c6d960d590` was cloned to a seven-day Hosting Preview rollback channel. The fresh pinned-toolchain `live_asof` gate then failed at 21 passed / 4 failed: four accepted exact-text assertions differ at offset 23 because accepted fixtures read CRLF while generated text uses LF. Work stopped immediately. No V1.5 build, V1.5 Preview deploy, Production deploy, browser/PDF verification or rollback was run; no source/test/artifact repair was attempted. Only the V1.4 rollback-readiness Preview channel changed. Production live remains V1.4 release `1786872330369000`; Firestore/Auth/Functions/Storage/Remote Config/Rules/Indexes are unchanged.

**CURRENT — V1.5 LIVE-AS-OF/COPY-SEMANTIC REPAIR MERGED; NOT DEPLOYED (2026-08-18).** Owner-approved PR #95 accepted HEAD `3934de20852c6a3b733299c93ba029edb8334ea4` was merged to pinned main `075ddfc6eeb8fbe4e3a0aaade9c4c2d5711340b9` by regular merge commit `e2f27be6cce02e821750110771eb461418d8af91` at `2026-08-18T04:42:45Z`. Its parents are the exact pinned main and accepted PR HEAD. Merge tree `d65d91f79a9c3f55eaff48ef7e087eb7d4189437` is byte-identical to the accepted PR tree; unexpected code/test/golden/canonical/artifact diff is 0, so the accepted gate was not rerun. S008 canonical parity remains exact despite the disclosed raw one-ULP diagnostic; reader-visible delta is 0. Accepted full-suite reconciliation remains branch 2,914 passed/39 failed versus main 2,889 passed/39 failed, common 39, branch-only 0, main-only 0. Evidence manifest remains 332 files / 480,630,900 bytes / missing 0 / mismatch 0 / SHA-256 `2E04DDC4D219203074AACD972D7FEDB2102B134E6DBFA8B2B6C0E493E5EE6DE5`; R7.1 remains immutable. No deployment or Firebase mutation occurred. Production remains V1.4 Hosting version `10af10c6d960d590`; V1.5 deployment is not authorized.

**CURRENT — V1.5 COPY SEMANTIC SAFETY VERIFIED; PR #95 READY FOR REVIEW (2026-08-18).** The Owner authorized only replacement of two stale broad-normalization expectations. The test file and coverage were retained and strengthened around fresh 300-profile pipeline output. Broad reader-visible normalization is no longer accepted behavior: delta 0, omission 0, addition 0 and prediction-to-advice transformation 0; Known/Unknown share the same semantic rule; `owner-unknown`, canonical five, Unknown fail-closed and Web/PDF remain exact. Fresh VM×2/real-Chrome×2 runs are 300/300 with nondeterminism and canonical/report/narrative mismatch 0; S008 retains only its disclosed raw one-ULP diagnostic difference. Final gates pass against pinned main `075ddfc`: focused 6/6, screenshots 24/24, Life Map 67/67, matrix 864/864, R7 286/286, synthetic 300/300, analyzer 299/299/delta 0, identical 39-failure full-suite baseline with branch-only/main-only 0, and Web build. R7.1/R1–R7.1 remain immutable. No merge/deploy/Firebase change; Production remains V1.4 (`10af10c6d960d590`).

**CURRENT — V1.5 S008 CANONICAL PARITY VERIFIED; PR #95 REMAINS DRAFT (2026-08-17).** S008's raw ascendant degree differs by one ULP between VM and Chrome, but the shared 1e9 fixed-point snapshot/hash boundary yields exact canonical degree, snapshot, report hash, canonical text and narrative. Final VM×2/real-Chrome×2 300-profile comparisons have nondeterminism 0 and all canonical/profile/structured/period-score/report/narrative/omission/copy mismatch counts 0. Fresh gates pass: 20/20 clock/canonical, 24/24 screenshots, 67/67 Life Map, 864/864 matrix and 108/108 each weekday, 286/286 R7, 300/300 synthetic, analyzer 299/299/delta 0, Web build, full-suite common baseline 39 with branch-only/main-only 0, and R7.1 ZIP/checksums/63-file immutable identity. Copy normalization remains reader-visible scope (93 profiles / 112 summaries) awaiting Owner review; therefore PR #95 stays Draft. No merge/deploy/Firebase change; Production remains V1.4 (`10af10c6d960d590`).

**CURRENT — V1.5 LIVE AS-OF ROOT CAUSE PROVEN; DRAFT REPAIR VERIFIED LOCALLY (2026-08-16).** The `asOf` hypothesis is disproved: explicit frozen `2026-08-07` and the evidenced `2026-08-16` Production interval yield the same accepted VM canonical output. The rollback Production text is reproduced byte-for-byte by the pre-repair compiled Web runtime and traced to reader-visible selection using runtime-dependent `String.hashCode`/`Object.hash`. The repair uses a Dart 3.11 VM-compatible stable hash and makes submit-time Asia/Bangkok `analysis.asOf` explicit while preserving `startedAt` for session duration. Frozen and live oracle parity pass 5/5, targeted 24/24, Life Map 67/67, matrix 864/864, R7 focused 286/286, synthetic 300/300, scoped analyzer clean, full analyzer 299/299/delta 0, Web build pass, and full branch/main failure sets match 39/39 with branch-only 0. R7.1 remains 10,709,328 bytes / 80 entries / SHA-256 `9E541F21C68FDAD93BC595C55BD0BE23600F88454CFBA7FAB6C713FE53F79E58`, checksums 79/79, immutable 63/63. Repair is Draft-only; DO NOT MERGE; DO NOT DEPLOY. V1.5 is not live and Production remains rolled-back V1.4.

**CURRENT — V1.5 PRODUCTION VERIFICATION FAILED; HOSTING ROLLED BACK TO V1.4 (2026-08-16).** Owner-authorized source `7a2bdea4d88ebd3e87ee7268641a37a70a7a959f` (product merge `a574fcb65437013e98c64b1fc9af19f50723534b`) was deployed Hosting-only as release `1786871603892000` / version `a5721c17f758aa6d` at `2026-08-16T09:13:23.892Z`. Hosting integrity passed 77/77 assets, but the first real Production `owner-known-0035` PDF had four substantive extracted-text replacements versus accepted R7.1, so mandatory verification failed and the other four fixtures were not run. Firebase Hosting Release history restored exact V1.4 version `10af10c6d960d590` as rollback release `1786872330369000` at `2026-08-16T09:25:30.369Z`; six baseline assets match 6/6 and browser smoke passes. Production is V1.4; V1.5 is not live. R7/R7.1 acceptance and identities remain immutable, the 39 common baseline failures remain disclosed debt, and no Firestore/Auth/Functions/Storage/Remote Config/mobile/source/test/golden change occurred. Evidence: `product-acceptance/thai-narrative-v1.5-production-release/`.

**HISTORICAL — V1.5 MERGED, NOT YET DEPLOYED (2026-08-16).** PR #92 was merged to `main` as regular merge commit `a574fcb65437013e98c64b1fc9af19f50723534b` from accepted source HEAD `e8cc382fa950e581b4da5ec0ff6b93202a1cd4ee`. The Final Merge Gate passed against pinned main `22cbb3cfcb583b63fe8d48a164d5083d9ee32163`; the 39 common baseline failures remain disclosed as pre-existing debt and were not hidden or changed. R7/R7.1 Owner Acceptance and immutable identities remain unchanged. At this historical checkpoint no deployment or Firebase change had occurred; Production remained V1.4 and Production Release required separate Owner authorization.

**CURRENT — V1.5 FINAL MERGE GATE PASSED AGAINST PINNED MAIN (2026-08-16).** Case A restored only the exact 18 Owner-authorized Life Timeline goldens byte-for-byte from pinned main `22cbb3cfcb583b63fe8d48a164d5083d9ee32163` after fresh repaired actuals matched it pixel-for-pixel 18/18 and passed original-resolution visual QA 18/18. Targeted screenshots pass 24/24; Life Map passes 67/67 and matrix 864/864; R7 focused passes 286/286; synthetic remains 300/300 unique and deterministic; scoped analyzer is clean; full analyzer is 299/299/delta 0; Web release build passes. Full branch 2,889/39 and pinned main 2,861/39 share the exact same 39 failures, with branch-only 0 and main-only 0. R7/R7.1 acceptance and identities remain unchanged. Merge/deploy are not authorized; Firebase is unchanged and Production remains V1.4.

**HISTORICAL — V1.5 LIFE MAP COMPATIBILITY REPAIR GATE BLOCKED (2026-08-16).** The authorized four-string restoration removed all 14 prior Life Map V1.2.6-V1.3.2 failures: isolated scope passed 67/67, matrix passed 864/864 and each weekday passed 108/108. The full suite was then branch 2,871/57 versus main 2,861/39, with 18 branch-only Life Timeline golden failures. That task did not change tests/goldens and kept PR #92 Draft pending separate Owner authorization.

**V1.5 PRODUCT ACCEPTED — FINAL MERGE GATE BLOCKED (2026-08-16).** Authoritative Owner decision: `V1.5 R7.1 OWNER ACCEPTANCE PASSED` and `V1.5 PRODUCT ACCEPTANCE PASSED`; R7 narrative and R7.1 evidence are accepted and R1-R7.1 remain immutable. The R7.1 ZIP remains 10,709,328 bytes / 80 entries / SHA-256 `9E541F21C68FDAD93BC595C55BD0BE23600F88454CFBA7FAB6C713FE53F79E58`, with 79/79 checksums and 63/63 immutable matches. Final Merge Gate focused tests pass 286/286, scoped analyzer is clean, full analyzer is branch 299 / main 299 / delta 0, and Web release build succeeds. The mandatory full suite fails at 2,875 passed / 53 failed; `origin/main` has 2,861 passed / 39 failed and the branch has 14 additional Life Map V1.2.6-V1.3.2 failures, reproduced in isolation. Full-suite pass remains required before merge. PR #92 stays Open Draft; DO NOT MERGE; DO NOT DEPLOY; Production remains V1.4.

**V1.5 R7.1 — PENDING OWNER ACCEPTANCE (2026-08-16).** `R7 NARRATIVE ACCEPTED`; `R7 ACCEPTANCE PACKAGE REJECTED` only for evidence encoding/accuracy. R7.1 repairs the finalizer and strict validator without changing application implementation, product tests, canonical text, PDFs, renders, ledger, traceability, or R7 audit JSON. Staging and extracted ZIP have zero UTF-8/BOM/U+FFFD/C0/C1/tab/mojibake/identity findings; negative fixture rejection passes; 63 immutable files have mismatch 0; 79/79 checksums pass. R7 focused 286/286 was not rerun and full suite was not run. Product Acceptance remains pending. PR #92 remains Open Draft; DO NOT MERGE; DO NOT DEPLOY; Production remains V1.4.

**V1.5 R7 — PENDING OWNER ACCEPTANCE (2026-08-15).** `V1.5 R6 OWNER ACCEPTANCE REJECTED`. R7 removes motif/phase injection, restores natural Thai subjects and domain ownership, preserves Known factual evidence and Unknown fail-closed behavior, and adds deterministic reader-quality gates. Final gates: motif/phase prose 2/2 per fixture, reader-quality failures 0, traceability 170/170, Web/PDF parity 5/5, focused tests 286/286, analyzer clean, synthetic reports/narratives 300/300 unique, and all 34 PDF pages visually passed. Full suite was not run. Owner Acceptance is pending. PR #92 remains Open Draft; DO NOT MERGE; DO NOT DEPLOY; Production remains V1.4.

**V1.5 R6 — PENDING OWNER ACCEPTANCE (2026-08-15).** `V1.5 R5 OWNER ACCEPTANCE REJECTED`. R6 replaces report-level template closure with one thesis and distinct section responsibilities, adds natural Known evidence explanation, preserves Unknown fail-closed and R5 Past age bands, and audits clauses for exact/prefix/suffix/skeleton/Unicode similarity. Final gates: exact consumer reuse 0/222, cross-profile exact sentences 0, flagged clause pairs 0, callbacks without new information 0, traceability 170/170, Web/PDF parity 5/5, focused tests 280/280, analyzer clean, synthetic reports/narratives 300/300 unique and all 37 PDF pages visually passed. Full suite was not run. Owner Acceptance is pending. PR #92 remains Open Draft; DO NOT MERGE; DO NOT DEPLOY; Production remains V1.4.

**V1.5 R5 — PENDING OWNER ACCEPTANCE (2026-08-15).** `V1.5 R4 OWNER ACCEPTANCE REJECTED`. R5 replaces templated Past substitutions with a deterministic four-band age resolver, makes Unknown current work/finance/health observable rather than biographical, adds Thai Unicode character/skeleton gates, and derives freshness from counted consumer units only. Corrected R4 baseline is 62/222 reused (27.93%, 23 groups); R5 is 57/216 (26.39%, 22 groups). Past pairs ≥0.78 and repeated skeletons are zero; traceability is 170/170; focused tests pass 226/226; analyzer is clean; synthetic narratives are unique 300/300; all 34 PDF pages passed visual QA. Owner Acceptance is pending. PR #92 remains Draft; DO NOT MERGE; DO NOT DEPLOY; Production remains V1.4.

**V1.5 R4 — PENDING OWNER ACCEPTANCE (2026-08-15).** `V1.5 R3 OWNER ACCEPTANCE REJECTED`. R4 replaces the shared hook/suffix path with an evidence-led report plan, renders current claims canonically, adds complete claim traceability and consumer-unit freshness evidence, and produces a portable five-PDF packet. R3→R4 exact reuse falls from 74/177 (41.81%) to 65/220 (29.55%) under one denominator; materially different hook reuse is 0; expressed claims are 170/170 present in Web/PDF; synthetic consumer narratives are distinct 300/300. All 34 final PDF pages passed visual QA. ZIP `product-acceptance/thai-narrative-v1.5-r4.zip` is 8,253,794 bytes / 76 entries / SHA-256 `64A4D8838A0A104C77B9CD6FED92701FD73964A9F36D49BFA4819CF890FDDB1F`; backslash/unsafe/duplicate entries are all zero and 75/75 checksums pass. PR #92 remains Draft; do not merge/deploy; Production remains V1.4.

**V1.4 PDF PAGINATION HOTFIX DEPLOYED AND PRODUCTION VERIFIED (2026-08-12).** PR #90 (`effab1bffcb410891ae5361908392c92188da8b7`) and exact-boundary follow-up PR #91 (`bbdb209b8c2573b16a49d445dd214f7cdfe5fd30`) are merged. Clean merged `origin/main` at `bbdb209` was deployed to Firebase project/site `knowme-app-694e1` from 08:17:11Z to 08:18:09Z (exit 0; 77 Hosting files). Cache-bypassed `/` and `/beta/thai` are HTTP 200 and the bundle pin is `bbdb209`. Fresh Production PDFs are Known `(22)`, 36,839 bytes, SHA-256 `1D4A599B9089A7B6F22EEA6E68862B5839F151B05EC8CE35D890F46209D54881`, 6 pages; and Unknown `(23)`, 32,756 bytes, SHA-256 `A7CC414114EDD21566F701A8B10B7101779C6AB74DA7D3880C86CC4D5F93FB4D`, 5 pages. All 11 pages passed direct visual QA with correct numbering and no blank/footer-only page, clipping, overlap, truncation, broken wrapping, or border escape. Four Web categories remain visible, Unknown remains fail-closed, and canonical text hashes remain unchanged. Rollback is available through Firebase Hosting release history.

**V1.4 PDF PAGINATION HOTFIX FOLLOW-UP (2026-08-12).** PR #90 was merged and deployed as `effab1bffcb410891ae5361908392c92188da8b7`. New Production Unknown output passed at 5 pages, but Known remained 7 pages because the live evidence-badge disclosure made final content exactly fill page 6 and a content-free trailing section spacer allocated a footer-only page 7. The correction removes spacing after the final section and adds the badge-inclusive exact Production regression. Production remains defective pending follow-up merge/redeploy.

**V1.4 PDF PAGINATION HOTFIX — LOCAL FIX VERIFIED (2026-08-12).** Root cause is the exporter combining measured `MultiPage` pagination with an unconditional continuation `pw.NewPage()`. The minimal fix removes the forced break and makes the continuation heading atomic with its paragraph. Local real-export Production fixtures pass Known 6 / Unknown 5 pages, all-page visual review, printable-bound containment, and unchanged canonical hashes. Production still serves the defective revision until hotfix merge and redeploy.

**V1.4 DEPLOYED — PRODUCTION DEFECT FOUND (2026-08-12).** Accepted PR #89 merge `0c3d1ef9d083502aa5f1ddae67b9acd23acecbed` is live on Firebase project `knowme-app-694e1` at `https://knowme-app-694e1.web.app`. The official deploy completed successfully at 2026-08-12 07:26:31Z after all pre-deployment gates passed. Production HTTP, pinned assets, Production API guard, Known/Unknown Web flows, Unknown fail-closed behavior, and real PDF download actions passed. The runtime PDFs fail the accepted pagination gate: Known has 7 pages with an empty final page instead of 6; Unknown has 6 pages instead of 5. This deployment task did not change application source. Rollback remains available through Firebase Hosting release history.

**V1.4 PRODUCT ACCEPTANCE — PASSED (2026-08-12).** The Owner accepts the r16 packet `thai-report-natural-narrative-v1-4-final-r16-evidence-24c10f5.zip` (23,386,793 bytes; 45 entries; SHA-256 `9DF9C2B414BF2B8EF6ADA64AD53056AF8F7AD4D157A57597390E6906AFD343D3`) and evidence report SHA-256 `50AC460E5C1A745725AF98D31F8B4B4A6A36C500F72DA50C93DD114A397226B1`. Known 6 pages, Unknown 5 pages, and all 11 renders were independently inspected and accepted. Approved r15 product artifacts remain byte-for-byte unchanged. PR #89 is approved for merge. Deployment has not occurred and Production remains unchanged. All earlier V1.4 pending statements below are historical and superseded.

**V1.4 PRODUCT OUTPUT PASSES — ACCEPTANCE EVIDENCE CORRECTED (2026-08-12).** Owner inspection passes r15 product output but rejects its generic page-review evidence. The corrected workflow requires complete page-specific manual observations and rejects footer headings, placeholders, missing identities/cards, and ambiguous continuations. Product artifacts remain byte-identical to r15. Status: **PENDING OWNER RE-ACCEPTANCE**. PR #89 remains Draft; no merge, deploy, or Production change.

**V1.4 REVISION COMPLETE — PENDING OWNER RE-ACCEPTANCE (2026-08-12).** Owner rejection of r6 is recorded. Candidate-r14 removes the three Unknown same-passage repetitions, restores supported future interpretation before advice, and adds `โครงสร้างดวงหลัก — ต่อ` / `รายงานนี้ดูจากอะไร — ต่อ` PDF orientation. PR #89 remains Draft; no merge, deploy, or Production change.

**V1.4 REVISION COMPLETE — PENDING OWNER RE-ACCEPTANCE (2026-08-11).** The Owner replaced the impossible absolute-zero broad gate with a strict zero-new-failure gate. Clean HEAD is 2,856 passed / 40 failed; final V1.4 is 2,858 passed / 39 failed. Machine-readable reconciliation proves 39 unchanged baseline failures, one baseline failure now passing, zero new, zero worsened, and zero unmatched. All V1.4-specific, scoped, narrative, golden, analyzer, artifact, and visual gates pass. Final candidate-r6 is packaged from implementation commit `179c5c9a3f6318d799b0be8c2233be7013b89c1c`; PR #89 remains Draft with no merge, deploy, or Production change.

## Active Draft — Thai Report Reading Flow and Friendly Voice V1

**Last updated:** August 12, 2026

**Branch:** remote `main`

**Deployed revision:** `0c3d1ef9d083502aa5f1ddae67b9acd23acecbed`

**Product Acceptance:** V1.4 passed Owner Acceptance on August 12, 2026

**Merge/deployment:** PR #89 merged and V1.4 deployed; Production PDF pagination defect found (Known 7 pages, Unknown 6 pages; required 6/5)

Owner feedback after the completed Round 9 release requires the Thai Beta report to explain the reader first and move technical transparency to the end. The active draft changes Web/PDF information architecture and consumer wording only. It keeps one `ThaiBetaAnalysis`, typed narrative semantics, factual provenance, Known-time facts, Unknown-time fail-closed behavior, calculation engines, Canon, routes, flags, Auth, audience policy, and Production unchanged.

Round 9 remains a historical completed release. Its acceptance evidence and the existing `product-acceptance/` directory are not changed or overwritten by this task.

Round 2 confirmed that removing labels still left the underlying timed-claim/impact/risk/action/fallback/transition fragment chain, and that V1.1 Known PDF pages 6–8 repeated continuation headings before fragments. The prior all-pages visual-pass conclusion is invalid. V1.2 composes one finished thought within horizon budgets, checks internal clauses and normalized skeletons, and renders a parent section heading only once. Exact Known input 1982-06-06 00:03 Chiang Mai still yields Aquarius 9°24′; 19°19′ belongs to the separate 00:35 fixture.
# PR #89 V1.3 recovery — 2026-08-11

V1.2 Product Acceptance was rejected after owner inspection found cross-fixture narrative reuse, repeated Known past material, an Unknown displayed-versus-omitted wording contradiction, and malformed Known PDF limitation-card geometry. V1.3 uses evidence ownership metadata and single-horizon allocation, keeps Unknown fail-closed while qualifying only Lagna/house material as omitted, and renders every disclaimer paragraph inside a full-width bordered component. Status: **PENDING OWNER RE-ACCEPTANCE**. PR #89 remains Draft; no merge or deploy. Earlier packets and `product-acceptance/` are untouched.
# V1.5 narrative-quality draft — Owner Acceptance pending

V1.4 remains technically live and stable, but its narrative quality is rejected.
V1.5 is a Draft-only architecture rewrite on `codex/thai-narrative-v1-5`.
Acceptance packet: `product-acceptance/thai-narrative-v1.5-r1/`. No merge or
Production deployment is authorised.
# Update — Thai Narrative V1.5 R2 (2026-08-12)

## R2 evidence correction - 2026-08-13

The acceptance packet now reports and displays all 30 final rendered pages; all five contact sheets were rebuilt from the final six-page PDFs. PDFs and source are unchanged. Focused validation reran at 261/261. Final R2 ZIP SHA-256: `610E69A38E2CA012BE4698E266E465EA8B17F44275761812050854A47F9B36CD`. PR #92 remains Draft and awaits Owner Acceptance; Production remains V1.4.

R1 owner acceptance was rejected, including a stale failed log contradicting its summary. R2 restores four domains per horizon and adds complete acceptance evidence. PR #92 remains Draft and owner acceptance is pending. No merge/deploy is authorised; Production remains V1.4.

# Update — Thai Narrative V1.5 R3 (2026-08-13)

`V1.5 R2 OWNER ACCEPTANCE REJECTED`. R2 passed correctness/coverage but failed consumer freshness (60/84 exact-reused strong-claim instances; 36/66 after excluding the explicit 00:03 twin). R3 now composes one report-level tension around no more than two motifs, gives current/12-month/next-period distinct functions, removes internal labels, and rewrites past content as cautious reflection rather than asserted biography. Final R3 metrics are zero internal exact duplicate bodies, zero callback-without-delta, zero system-language/unsupported-biography hits, and 0/26 exact strong-claim reuse for materially different fixtures. Owner Acceptance is pending; PR #92 remains Draft; no merge/deploy; Production remains V1.4.

# Current — V1.5 Final Merge Gate passed (2026-08-16)

Controlled Case A reconciliation restored only the authorized 18 Life Timeline goldens byte-for-byte from pinned main after fresh repaired actuals proved pixel-identical 18/18 and passed original-resolution visual QA 18/18. Targeted screenshots pass 24/24; Life Map passes 67/67 and 864/864; R7 focused passes 286/286; synthetic remains 300/300 unique and deterministic; scoped analyzer is clean; full analyzer is 299/299/delta 0; Web release build passes. Full branch 2,889/39 and pinned main 2,861/39 share the exact same 39 failures, with branch-only 0 and main-only 0. R7/R7.1 acceptance and identities remain unchanged. No merge/deploy/Firebase/Production change; Production remains V1.4.

# Current — PR #95 Final Cross-Runtime Parity Gate blocked (2026-08-17)

The `asOf` hypothesis remains disproved; the release-visible root cause was runtime-dependent hashing. Stable-hash and exact-integer vectors now match in Dart VM and compiled JavaScript/Chrome, and each runtime is internally deterministic across two exact 300-profile runs. The mandatory exact comparison is still blocked: S008 has one report and one narrative mismatch caused by `siderealAscendantDeg` differing by one ULP (`102.39560244592322` VM versus `102.39560244592323` Chrome). All other manifest groups match, and the canonical frozen/live five remain exact 5/5. Copy normalization is retained because removing it breaks frozen `owner-unknown`; its exact scope is 93 profiles / 112 `summary` fields and requires Owner review. PR #95 remains Open, Draft and unmerged. No merge, deploy or Firebase change; Production remains V1.4.
# Update 2026-08-26 — Conversational Plain Language V1

Technical validation และ visual QA เสร็จครบที่ implementation `01d27911b2ce0b647016dde0074fa35c4aa3827b` สถานะ `PENDING OWNER LANGUAGE ACCEPTANCE` บน Draft PR; copy audit 300 profiles / 10,189 fields มี impacts = 0 และ full suite 1,622/1,622 ผ่าน ไม่มี Merge/Deploy/Firebase/Production change

# Update 2026-08-26 — Conversational Plain Language V1 Owner Review OR1

Owner Language Acceptance ของ V1 รอบแรกไม่ผ่าน. OR1 implementation `40967efa42662e75fd0901d68f3f407891b85057` แก้เฉพาะ reader-copy; strict audit 300 profiles / 11,339 fields และ impacts ทุกมิติ = 0, full suite 1,622/1,622, PreCommit/PostCommit และ visual QA 29 PDF pages ผ่าน. สถานะ `PENDING OWNER LANGUAGE RE-ACCEPTANCE` บน Draft PR #107; ยังไม่ Merge/Deploy และ Firebase/Production ไม่เปลี่ยน

# Update 2026-08-26 — Conversational Plain Language V1 Owner Review OR2

OR1 ถูก Owner Reject ด้านภาษา. OR2 implementation `0f5b7e86e16a8f7f99af6856daa35f8a2a4e5b8b` เก็บ copy/consistency รอบสุดท้ายโดยไม่เปลี่ยน semantics. Focused 95/95, narrative 38/38, artifact 3/3, audit 300 profiles / 11,414 fields impacts = 0, full suite 1,622/1,622, analyzer baseline และ PreCommit/PostCommit ผ่าน. Visual QA ครบ Web 12, infographic 4, PDF raster 29 หน้า; page counts 8/7/7/7. ZIP SHA-256 `24D74EA3CDE2311CF3335A07EFC7C5E80B62AA3C31B4367F3BC53C45E8A7F8EB`. สถานะ `PENDING OWNER FINAL LANGUAGE RE-ACCEPTANCE`; PR #107 ยัง Draft และไม่ Merge/Deploy/Firebase/Production change

## PR108 OR1 — 2026-08-28

Owner Reject evidence เดิมเพราะ copy ข้าม variant และหลักฐานไม่ครบ. OR1 `647e1f0` ซ่อม copy/audit/canonical fixture/desktop capture; audit 300 profiles / 30,000 fields, inline/stale hits 0, impacts 0; full 1,623/1,623; PDF 8/7/7/7 และ visual blank 0. ZIP SHA-256 `5C13B2B644945C9309E5B691C67A3978D3052BCC7DAB56F6D62604D9D00838B7`. `PENDING OWNER RE-REVIEW`; Draft, ไม่ Merge/Deploy/Firebase/Production
# PR108 OR2 owner re-review evidence (2026-08-29)

Status at evidence delivery was **PENDING OWNER RE-REVIEW**. OR1 was rejected for unverifiable 12,049-field “other” scope, assertion-only parity, duplicate Known/Unknown Web contact sheets, and capture metadata without actual scroll geometry. OR2 keeps reader-facing copy unchanged. Reconciliation classifies 13,174 historical/raw audit differences, while actual PR108 baseline-to-candidate changes are 1,587 fields (A=1,125 and B=462; C=0, E=0, F=0). D=11,587 was already present at the PR108 base and is unchanged by PR108. Parity is 262/262 and actual capture geometry is 18/18.

Implementation/test commit: `d78c5f641563ca5810c8952191e217cd31502d57`. Focused 96/96, narrative 38/38, artifact 3/3, 300-profile copy audit (30,000 fields, impacts 0), full suite 1,623/1,623, analyzer and PreCommit pass. Final Owner Review ZIP SHA-256: `D47AE77CAC12E4D924E5FF4A200786251F34B4646AE5DEAAA373D8C483F41EB1`. At evidence delivery PR #108 was Open + Draft, not merged and not deployed. Firebase/Production and `product-acceptance/` are unchanged.

## PR108 Owner Acceptance — 2026-08-29

Owner independently verified ZIP CRC/SHA256SUMS and accepted OR2 scope, copy and evidence. Accepted implementation: `d78c5f641563ca5810c8952191e217cd31502d57`; previous evidence/docs HEAD: `ec2ecbaa1f9f21fe69df6476f9d0fed0a39f5120`; acceptance docs commit: this docs-only commit (exact SHA is the final PR HEAD). Accepted results include inline/stale hits 0, parity 262/262 with error counters 0, geometry 18/18, PDF 8/7/7/7, image-only Browser-print page 5 and visual defects 0. Status: **OWNER ACCEPTED — READY FOR REVIEW — NOT MERGED — NOT DEPLOYED**.
