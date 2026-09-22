# Western Reader V2 — authenticated generation latency repair

Date: 2026-09-22

Status: **PASS — PR #147 MERGED — BACKEND DEPLOYED — PRODUCTION ACCEPTED**

## Final Production identity

- Application PR: `https://github.com/notekmitl/knowme/pull/147`
- Application merge: `afbcb72e490512d597b69daa6ca4574c5d13c1a8`
- Application tree: `39f62b5fc6ccc27c1cbde32eaf7b2b8fa59f7c8e`
- Cloud Run revision: `knowme-astrology-api-00013-zc8`
- Cloud Run image digest:
  `sha256:8f7c41bff70ff238e09263316ffe872b6f32227d4b4f0ffb10dcf72a7dc0070d`
- Cloud Run traffic: `100%`; min/max instances `1/10`; concurrency `80`;
  `1 CPU`, `512 MiB`, timeout `120 s`; instance-based CPU allocation.
- Hosting release/version: `1790074568414000` / `d32e72678324e634`
- Hosting `main.dart.js` SHA-256:
  `46d5b86b87dfddacfbce90fd036d312e1e9372d3a7897c7d8f855fa46232f629`
- Reader revision: `western_reader_th_v2_r2`
- Contract: `knowme_western_reader_v2`

Only Backend and its Cloud Run CPU-allocation setting changed. Hosting was not
built or deployed during this repair; its release, version, and bundle remain
the readability release above. IAM, Firestore rules/schema, Functions, Auth,
Storage, Thai Astrology, BaZi, and Fusion code were not changed.

## Historical failure and pre-repair reproduction

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

## Root cause and deployed repair

Firebase Admin was initialized in the FastAPI lifespan, but the shared
Firestore client and its first RPC were created lazily inside the first save
path. An unauthenticated health/auth rejection therefore did not make
persistence ready. Structured timing after the source deploy also showed the
remaining tail precisely: one run took `4,771.632 ms`, comprising Auth
revocation verification `2,367.287 ms` and the awaited atomic Firestore commit
`2,401.013 ms`; calculation was `0.525 ms`, reader composition `0.054 ms`, and
serialization `1.257 ms`.

The default Firestore database is in `africa-south1`, while Cloud Run is in
`asia-southeast1`. Generation necessarily performs the unchanged Auth
revocation network check before an atomic Firestore commit across that region
boundary. This proves the tail was remote-RPC readiness/connection latency,
not the reader composer. The repair:

1. creates the same shared Firestore client during lifespan startup;
2. performs one read-only probe of
   `runtime_health/firestore_warmup` before the process can serve requests;
3. fails startup instead of routing traffic when Firestore connectivity is not
   ready; and
4. emits one structured Western timing record per successful generation; and
5. uses instance-based Cloud Run CPU allocation with min instance `1`, so the
   initialized Auth and gRPC clients are not CPU-suspended between requests.

The timing record contains only revision, Cloud Trace ID, HTTP status, and
milliseconds for authentication, profile/input validation, astrology
calculation, reader composition, response assembly, Firestore save, response
serialization, and total request time. It never logs tokens, UID, name, birth
data, coordinates, place, profile, chart, or reader text.

This does not change the calculation, reader text/revision, cache contract,
Firestore schema or write batch, Auth verification policy, Fusion behavior,
Thai Astrology, or BaZi. The startup probe is read-only and does not create a
document or use fire-and-forget work.

## Release validation

- Focused backend: `20/20` passed.
- Full backend: `51/51` passed.
- Python source/test compilation: passed.
- Focused Flutter: `37/37` passed.
- Full Flutter: `3,097/3,097` passed.
- Analyzer policy: exit `0` with the same `275` inherited non-fatal
  diagnostics and no changed-scope Flutter source.
- Production Web release build: passed; the bundle validator found the
  production Cloud Run host and no localhost/loopback endpoint.
- PR #147 was `CLEAN` / `MERGEABLE` and had no configured GitHub checks. It was
  merged normally; the merge tree equals the tested PR tree exactly.
- Exact merge source first deployed as `knowme-astrology-api-00012-wjt`.
  Startup warm-up completed read-only in `3,141.896 ms` before application
  readiness. A six-run gate found one server result at `4,771.632 ms`, so
  closeout stopped and the CPU-allocation repair followed.
- Revision `knowme-astrology-api-00013-zc8` reuses the exact same image digest,
  completed its startup warm-up in `2,682.369 ms` before readiness, passed
  health `200`, preserved `100%` traffic and configuration, and continued to
  reject unauthenticated generation with `401`.

## Final authenticated Production QA

Chrome CDP timestamps measured POST dispatch through response-body completion.
Cloud Run request logs supplied server latency and trace ID. Structured logs
supplied phase durations. Agent/tool wait and visual observation time are not
included.

| Viewport | Run | Click→POST ms | Body ms | Cloud Run ms | Auth ms | Input ms | Calc ms | Reader ms | Assembly ms | Save ms | Serialize ms | Trace |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Mobile 390×844 | 1 | 1,588 | 1,314 | 1,185.572 | 378.574 | 0.643 | 21.474 | 0.255 | 0.026 | 774.389 | 2.206 | `9af6fdab57d40d26f8301958a0de897d` |
| Mobile 390×844 | 2 | 1,597 | 1,061 | 1,005.381 | 266.413 | 0.040 | 0.805 | 0.094 | 0.029 | 729.329 | 1.939 | `7424c546a53a5b36aac101bada34b8d8` |
| Mobile 390×844 | 3 | 2,064 | 892 | 837.385 | 260.975 | 0.036 | 0.742 | 0.082 | 0.019 | 568.514 | 1.681 | `c5a681bf300c10d506f1ffcc9ea8043b` |
| Desktop 1535×863 | 1 | 1,576 | 3,303 | 3,229.983 | 271.272 | 0.061 | 0.981 | 0.126 | 0.026 | 2,949.434 | 2.050 | `a29e2243f5a4b38a83a3f996b7e29831` |
| Desktop 1535×863 | 2 | 1,523 | 974 | 917.707 | 342.376 | 0.034 | 0.803 | 0.124 | 0.022 | 566.415 | 2.046 | `208c9b4286187a462d0dbe6307891b6f` |
| Desktop 1535×863 | 3 | 1,527 | 889 | 834.948 | 258.569 | 0.048 | 0.787 | 0.073 | 0.019 | 567.869 | 1.748 | `337e1fdffea8633030b187a39ceb8f71` |

All six requests ran on one instance. Mobile body median/max were
`1,061/1,314 ms`; Desktop body median/max were `974/3,303 ms`. Mobile Cloud Run
median/max were `1,005.381/1,185.572 ms`; Desktop median/max were
`917.707/3,229.983 ms`. Every browser body result is below `5,000 ms`, and every
Cloud Run result is below the `4,500 ms` headroom target.

Every selected generation used one authenticated POST, returned HTTP `200`,
used zero post-response `western_natal` reads and zero browser
`astrology_fusion` traffic, and displayed Reader r2, the V2 contract, UTC
`1982-06-05T17:03:00Z`, and Gemini/Sagittarius/Pisces. Mobile and Desktop had no
console/runtime error, overflow, or stuck loading state.

The post-generation cache-hit path from Astrology Center performed one
`western_natal` browser read, zero generation POSTs, and zero
`astrology_fusion` browser traffic. It displayed the same r2 reading, contract,
UTC, and Big Three with no console/runtime error or stuck loading state.

Production acceptance is complete. Rollback was not required.
