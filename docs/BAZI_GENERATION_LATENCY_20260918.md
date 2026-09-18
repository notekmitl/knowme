# BaZi generation latency repair — 2026-09-18

Status: **SOURCE READY; RELEASE PENDING**

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
