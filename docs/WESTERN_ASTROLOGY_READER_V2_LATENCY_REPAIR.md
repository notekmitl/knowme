# Western Reader V2 — authenticated generation latency repair

Date: 2026-09-22

Status: **PERFORMANCE-REPAIR CANDIDATE — ALL LOCAL GATES PASS — NOT YET DEPLOYED**

## Frozen live release under investigation

- Application merge: `1a48f234e4720a3e858ca0aa03944e87f6b35609`
- Application tree: `1aea5730ec4ac6c7c11770836bd51ccd1a8d1456`
- Cloud Run revision: `knowme-astrology-api-00011-s5z`
- Cloud Run image digest:
  `sha256:92f5d21f483a8ed61707a8f176357e37728aa2936ee825d116b127c52089cb01`
- Hosting release/version: `1790074568414000` / `d32e72678324e634`
- Reader revision: `western_reader_th_v2_r2`
- Contract: `knowme_western_reader_v2`

Production remains on this release while the latency repair is validated. No
rollback is authorized unless data, security, or availability is at risk.

## Observed failure and current-revision reproduction

The first authenticated stale-cache refresh returned the correct chart and
reader but exceeded the API gate. Chrome Network measured `5,550 ms` from POST
dispatch through response-body completion. The matching Cloud Run request log
reported `5.327094231 s` server latency and trace
`13b6ce787c62dd81f5af0d6cd433b416`.

Six subsequent selected-generation runs were made against the same live
revision and the same Cloud Run instance. Agent wait time is excluded; browser
durations come from CDP Network timestamps.

| Viewport | Run | Click→POST ms | POST→body ms | Server ms | Trace |
| --- | ---: | ---: | ---: | ---: | --- |
| Mobile 390×844 | 1 | 2,044 | 2,950 | 2,830 | `5e8af5717995e713f7e82153cc88f747` |
| Mobile 390×844 | 2 | 1,562 | 1,059 | 1,003 | `8380d639b696ad9c499daefdef5f85f7` |
| Mobile 390×844 | 3 | 2,032 | 3,135 | 3,079 | `82f937c9ed0cad3d01b3bc0dc4205c36` |
| Desktop 1535×863 | 1 | 1,521 | 908 | 853 | `6287aa24c67433b017e31c1c17ba5e20` |
| Desktop 1535×863 | 2 | 2,510 | 1,058 | 1,000 | `e89eae7bfdad8273bfd1de551c2a6da3` |
| Desktop 1535×863 | 3 | 2,468 | 1,066 | 1,010 | `0f2ffb7325755eca6a38b025b29a8a81` |

Every run used one authenticated POST and returned HTTP 200, Reader r2, the V2
contract, UTC `1982-06-05T17:03:00Z`, and Gemini/Sagittarius/Pisces. Browser
Fusion traffic, runtime errors, and stuck-loading findings were zero. The
single failed first request and all later requests came from instance
`0010dd8607bf106643929b09727e38c4e4ce0613ef0500c33d26fbde890c9b1d127f5a7e0c680eb77c5a3769b388b8fefd8e6ff807dfb7d101da3c857ee8715494a6d070933644823f5f559ac66d199208`.

## Source finding and candidate repair

Firebase Admin is initialized in the FastAPI lifespan, but the shared
Firestore client and its first RPC are currently created lazily inside the
first save path. An unauthenticated health/auth rejection therefore does not
make persistence ready. The candidate:

1. creates the same shared Firestore client during lifespan startup;
2. performs one read-only probe of
   `runtime_health/firestore_warmup` before the process can serve requests;
3. fails startup instead of routing traffic when Firestore connectivity is not
   ready; and
4. emits one structured Western timing record per successful generation.

The timing record contains only revision, Cloud Trace ID, HTTP status, and
milliseconds for authentication, profile/input validation, astrology
calculation, reader composition, response assembly, Firestore save, response
serialization, and total request time. It never logs tokens, UID, name, birth
data, coordinates, place, profile, chart, or reader text.

This does not change the calculation, reader text/revision, cache contract,
Firestore schema or write batch, Auth verification policy, Fusion behavior,
Thai Astrology, or BaZi. The startup probe is read-only and does not create a
document or use fire-and-forget work.

## Candidate validation

- Focused backend: `20/20` passed.
- Full backend: `51/51` passed.
- Python source/test compilation: passed.
- Focused Flutter: `37/37` passed.
- Full Flutter: `3,097/3,097` passed.
- Analyzer policy: exit `0` with the same `275` inherited non-fatal
  diagnostics and no changed-scope Flutter source.
- Production Web release build: passed; the bundle validator found the
  production Cloud Run host and no localhost/loopback endpoint.
- PR review, exact-merge Backend-only deployment, structured Production phase
  evidence, and final browser/cache acceptance remain required before
  closeout.

No docs-only closeout PR may be opened until every Production acceptance gate
passes.
