# BaZi generation latency repair — 2026-09-18

Status: **PASS — PRODUCTION TOTAL 4.890 SECONDS WITH ONE GENERATION POST**

## Authenticated Production baseline (2026-09-19)

The live release at application commit
`2d2125cbbf2b5e8ec9fc44fa4bb46846604cd6f2`, Cloud Run revision
`knowme-astrology-api-00007-qkk`, and Hosting pin `2d2125c` failed the
five-second acceptance target on one fresh signed-in BaZi generation through
`/beta/thai`:

- click to API start: 6.875 seconds;
- browser POST start to HTTP 200: 10.201 seconds;
- HTTP 200 to the result's final BaZi font asset completing: 5.503 seconds;
- click to readable result: 22.578 seconds.

Network inspection found exactly one successful `POST /v1/generate-bazi` and
no coordinator request, legacy generation request, repeated generation, or
late chart reload after the page settled. The browser application console had
no error after the click. Cloud Run recorded the same POST as HTTP 200 with
4.558 seconds of request latency and trace
`1b5097e271a57b76c9fb4093e0449cea`.

The timing evidence separates three independent delays. The client completed a
profile write and Fusion invalidation before starting the API request. Cloud
Run had scaled to zero, so the CORS preflight waited 5.593 seconds while a new
instance started. After the API succeeded, the result page read the just-saved
chart back from Firestore before rendering it.

## First repair Production result

PR #132 was merged as `cf06bd268ecaa231a5aa294fa5771d4d4168aeee` and
released Cloud Run first, then Hosting only. Cloud Run revision
`knowme-astrology-api-00008-gcq` is Ready with 100% traffic and one minimum
instance; Hosting release `1789797139609000` / version
`55c6a7b5191d34d4` serves pin `cf06bd2`.

The first post-release fresh run improved the phases to approximately 0.029
seconds click-to-API, 4.893 seconds for the browser POST, 1.770 seconds from
HTTP response to the final result font asset, and 6.690 seconds total. Cloud
Run measured the same successful POST at 4.568 seconds and the application at
4,565.1 ms. Exactly one generation POST succeeded; no coordinator, legacy
generation, repeated generation, late chart reload, or application console
error was observed. There was no scale-from-zero delay.

A second warm request measured the versioned POST at 3.076 seconds, but the
browser-side profile write and Fusion deletion continued for approximately
6.240 seconds and still gated navigation. Its click-total is not accepted as
timing evidence because the Playwright locator added about two seconds before
the click. The useful evidence is the independent POST and Firestore request
timing, which identifies the remaining critical path without overstating the
end-to-end number.

## Atomic save follow-up candidate

The follow-up sends the exact canonical profile with the authenticated BaZi
request. The backend verifies that every calculation-relevant profile field
matches the top-level request and then persists the profile, user marker,
chart and result while deleting stale Fusion in one Firestore batch. A
mismatch fails closed with `PROFILE_INPUT_MISMATCH`. The BaZi client no longer
performs or awaits separate Firestore profile/Fusion operations; Western keeps
its existing profile write. Calculation, report copy, PDF, Thai astrology,
Firestore rules, Functions, Auth, Storage and IAM are unchanged.

Candidate validation on Flutter 3.41.1 / Dart 3.11.0:

- complete backend suite: 35/35;
- focused API/provider/handoff/result/selection tests: 22/22;
- scoped analyzer: no issues;
- complete Windows suite: 3,036 passed / 40 failed, with all failures confined
  to the existing Windows Thai screenshot-golden comparison; no golden was
  changed and this result is not claimed as a full-suite pass;
- release Web build and Production endpoint/loopback bundle guard: pass;
- `main.dart.js`: 8,576,087 bytes, SHA-256
  `3A3125ACA50FC65DDD4A85EB8F97F5A296BF626FFC48F15A40E34F6FF0E9E3BA`.

## Final Production acceptance

PR #133 merged as application commit
`839534c3a5369ca9c111412f2ff4742fbaa6a99b`, tree
`9c306806725ad6d2eec4f1462d567c498b5a8cac`. Release order was Cloud Run
first, then Hosting only:

- Cloud Run revision `knowme-astrology-api-00009-bpw`, Ready, 100% traffic,
  minimum instances 1, image digest
  `sha256:1a0e349ce57dd5f217afdc3782b605fdf6236e9b4b406b31bba6ecf5554533cf`;
- Hosting release `1789799510184000`, version `6ab2558866d0be41`, released
  `2026-09-19T06:31:50.184Z`, cache pin `839534c`;
- live `main.dart.js` matched the local build at 8,576,087 bytes and SHA-256
  `3A3125ACA50FC65DDD4A85EB8F97F5A296BF626FFC48F15A40E34F6FF0E9E3BA`.

The accepted signed-in run used the real `/beta/thai` user flow and a new
synthetic known-time fixture. Direct-click timing at
`2026-09-19T07:20:44.510Z` was:

- click to API start: 0.038 seconds;
- browser POST start to HTTP 200: 4.721 seconds;
- HTTP 200 to final result font completion: 0.131 seconds;
- click to readable result: 4.890 seconds.

Cloud Run independently recorded one successful POST at 4.448 seconds, with
application timing 4,445.1 ms. Network inspection recorded exactly one POST
and one CORS preflight. Legacy generation, `/v1/generate-chart`, coordinator,
browser Firestore freshness requests, late network events and post-navigation
chart reloads were all zero. Browser application console errors after the
click were zero. The final report exposed the full reader sections and the
calculation-input card.

Only the authorized BaZi artifact for the signed-in test account was created.
Firestore rules, Functions, Auth users/configuration, Storage, IAM and other
Production data were not changed.

## Earlier source repair

Production was slow after a user selected Chinese BaZi because the Thai-beta
handoff invoked the cross-system coordinator, then the destination page invoked
it again and loaded the same chart twice. Backend persistence also used three
sequential Firestore writes.

The selected BaZi path now reuses the submitted profile, invalidates stale
Fusion, calls only the BaZi endpoint, and opens a prepared result that loads the
saved chart once. The backend persists the user marker, chart, and result
snapshot in one atomic batch commit. Calculation, apparent-solar-time policy,
fingerprints, models, report copy, PDF, Auth, and Firestore paths are unchanged.

Validation passes:

- Complete backend suite: 33/33.
- Focused Flutter handoff/result-page tests: 9/9.
- Complete Flutter suite: 3,074/3,074.
- Scoped analyzer: no issues.
- Complete analyzer: successful, with the unchanged baseline of 282 warnings
  and info items and no errors.
- Portable changed-scope, forbidden-text, diff, and scope-JSON checks: pass.
  The Linux runner does not provide PowerShell for the repository wrapper.

Pure Reader V3 calculation measured 8–15 ms locally. Production timing must be
measured on the authenticated user path after release; this runner's outbound
proxy adds roughly 12 seconds before TLS and is not valid latency evidence.

Release order is Cloud Run first, then Firebase Hosting only. Do not deploy
Firestore rules, Functions, Auth, Storage, IAM, or alter Production data beyond
the owner's ordinary signed-in functional test.
