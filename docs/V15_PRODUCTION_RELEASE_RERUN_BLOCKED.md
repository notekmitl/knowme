# V1.5 Production release rerun — blocked pre-deploy record

## Decision

The Owner authorized a single-agent Hosting Preview → Production release with mandatory rollback. The attempt stopped before build because a mandatory fresh pre-deploy functional gate failed. V1.5 is not live.

## Verified provenance

- Final source: `bf8fbd159568d521bcb0f88cd72b21e24444cd9a`.
- PR #95 merge: `e2f27be6cce02e821750110771eb461418d8af91`.
- Accepted application tree: `d65d91f79a9c3f55eaff48ef7e087eb7d4189437`.
- Final-main difference after PR #95: three Markdown files only; application delta 0.
- Toolchain: Flutter 3.41.1 / Dart 3.11.0.
- Accepted evidence: 332 files, 480,630,900 bytes, missing 0, mismatch 0, manifest SHA-256 `2E04DDC4D219203074AACD972D7FEDB2102B134E6DBFA8B2B6C0E493E5EE6DE5`.
- R7.1: 10,709,328 bytes / 80 entries / checksums 79/79 / immutable 63/63 / SHA-256 `9E541F21C68FDAD93BC595C55BD0BE23600F88454CFBA7FAB6C713FE53F79E58`.

## Rollback readiness

Production began and ended on V1.4 release `1786872330369000`, version `10af10c6d960d590`. A seven-day Preview rollback channel was cloned from live before testing:

- Channel: `v15-rerun-v14-rollback`.
- Release: `1787030431383000`.
- Version: exact `10af10c6d960d590`.
- Expiry: `2026-08-25T05:20:28.567489316Z`.

## First blocking result

Pinned Flutter command: `flutter test --no-pub --reporter expanded test/validation/thai_beta/live_asof`.

Result: 21 passed / 4 failed. The four failures are exact accepted-text comparisons where accepted fixture content has CRLF and fresh generated text has LF, first differing at offset 23. The failures cover the live oracle, Clock A/B/C diagnostic, canonical/fail-closed/Web-PDF contract and exact `owner-unknown` R7.1 comparison.

The generated 300-profile semantic audit has reader-visible delta 0, omission 0, addition 0, prediction-to-advice 0, canonical mismatch 0, Unknown fail-closed mismatch 0 and Web/PDF mismatch 0. This partial result cannot override the mandatory exact-text failure.

## Not run

- Web release build and asset manifest.
- V1.5 Hosting Preview deploy and verification.
- Real-Chrome release parity.
- Production deploy and asset verification.
- Preview/Production HTTP and browser smoke.
- Preview/Production PDF semantic comparison, hashes, rendering and visual QA.
- Fresh Preview/Production traceability.
- Rollback execution, because Production never changed.

## Firebase scope

Only a Hosting Preview rollback-readiness channel/release was created. Hosting live, Firestore, Auth, Functions, Storage, Remote Config, Rules and Indexes were not changed. Production remains V1.4. A separate repair/reconciliation authorization is required before another release attempt.
