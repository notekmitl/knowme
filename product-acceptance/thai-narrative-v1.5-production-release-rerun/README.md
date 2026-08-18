# V1.5 Production release rerun — blocked before build

Status: **PRE-DEPLOY GATE BLOCKED**. Production remains V1.4 Hosting version `10af10c6d960d590`. V1.5 was not built, deployed to a V1.5 Preview channel, or deployed to Production.

The release ran from isolated final main `bf8fbd159568d521bcb0f88cd72b21e24444cd9a` with the pinned Flutter 3.41.1 / Dart 3.11.0 toolchain. PR #95 and PR #96 were confirmed merged, application paths were unchanged from accepted HEAD `3934de20852c6a3b733299c93ba029edb8334ea4`, and accepted tree `d65d91f79a9c3f55eaff48ef7e087eb7d4189437` remained authoritative.

The mandatory fresh `test/validation/thai_beta/live_asof` run ended at 21 passed / 4 failed. All four failures are exact canonical-text identity failures at offset 23: accepted fixture files read with CRLF while fresh pipeline text uses LF. The failing tests were:

1. `frozen and live-date oracle parity are exact 5/5`
2. `Clock A/B/C disproves as-of as the Production mismatch cause`
3. `canonical, fail-closed, Web/PDF, and S008 contracts stay exact`
4. `owner-unknown remains exact R7.1 canonical and deterministic`

The generated 300-profile copy audit still records semantic deltas, omissions, additions, prediction-to-advice changes, canonical fixture mismatches, Unknown fail-closed mismatches and Web/PDF mismatches as 0. That partial evidence does not override the mandatory exact-text failure.

Per Owner policy, work stopped immediately. The Web build, V1.5 Preview deploy, Preview browser/PDF gate, Production deploy and Production verification were not run. No rollback was required because Production never changed.

A seven-day Hosting Preview rollback-readiness channel was created before the test run by cloning the current live V1.4 channel. It references the exact existing V1.4 version `10af10c6d960d590`, release `1787030431383000`, URL `https://knowme-app-694e1--v15-rerun-v14-rollback-lkagsja1.web.app`, and expires `2026-08-25T05:20:28.567489316Z`. The Production live release remains `1786872330369000`.

Only Firebase Hosting Preview state changed. Firestore, Auth, Functions, Storage, Remote Config, Rules, Indexes and the live Hosting channel were not changed.

Final status: `V1.5 DEPLOYMENT BLOCKED — SOURCE OR ROLLBACK BASELINE NOT VERIFIED — PRODUCTION V1.4` does not apply because source and rollback provenance passed. The actual stop point is the mandatory fresh pre-deploy functional gate.

`V1.5 PRE-DEPLOY GATE BLOCKED — PRODUCTION REMAINS V1.4`
