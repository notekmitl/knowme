# BaZi generation latency repair — 2026-09-18

Status: **PRODUCTION BASELINE FAILED; CLIENT FIX VALIDATED; RELEASE PENDING**

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

## Release candidate

The scoped repair starts the profile write, Fusion invalidation, and BaZi API
generation concurrently; returns the authenticated API chart to the result
page; and renders that chart without a Firestore reload. The result still waits
for all freshness operations and fails closed if any of them fails. The Cloud
Run deployment setting changes from zero to one minimum instance so the public
preflight and authenticated POST are not gated by scale-from-zero startup.
Calculation, report copy, PDF, Thai astrology, Firestore rules, Functions,
Auth, Storage, and IAM are unchanged.

Candidate validation on Flutter 3.41.1:

- focused API/provider/handoff/result/selection tests: 22/22;
- scoped analyzer: no issues; complete analyzer exits successfully with the
  unchanged 282 warning/info baseline;
- complete Windows suite: 3,036 passed / 40 failed, with all failures confined
  to the existing Windows Thai screenshot-golden comparison; no golden was
  changed and this result is not claimed as a full-suite pass;
- release Web build and Production endpoint/loopback bundle guard: pass;
- `main.dart.js`: 8,576,633 bytes, SHA-256
  `0CDDA3F3C0F1AE0EB12C7A1DB43C461D8736B72AC7C76CECEBDC6901EA7EE137`.

Post-merge Production acceptance remains required. Deploy Cloud Run first with
minimum instances set to one, verify the Ready revision, then build and deploy
Firebase Hosting only from the merge commit. Do not run the repository deploy
wrappers as written because they also enable services, grant IAM, or deploy
Firestore rules.

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
