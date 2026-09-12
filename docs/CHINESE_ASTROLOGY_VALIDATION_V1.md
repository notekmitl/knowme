# KnowMe BaZi Compatibility V1 Validation

**Status:** ready for Owner testing; Draft PR #122; not deployed

**Date:** 2026-09-12

## Coverage statement

Validation is risk-based and uses equivalence classes. It does not assert that
every day, time, place or IANA timezone was executed.

### Backend equivalence classes

- Known four-pillar reference and deterministic replay.
- Exact Li Chun minute before/at boundary.
- Chinese New Year before/on day as a deliberate non-boundary under Li Chun.
- Exact Jie minute before/at boundary.
- `sect=2` representatives at 22:59, 23:00, 23:59 and next-day 00:00.
- Unknown ordinary date, Unknown Li Chun date and Unknown Jie date.
- Valid `Asia/Bangkok`, valid `Europe/London` and invalid IANA identifier.
- Bangkok/London coordinate pairs proving recorded-but-unused behavior.
- Gregorian leap day, null/blank Unknown normalization and storage projection.
- Missing/invalid bearer, revoked-check invocation, UID mismatch and verified-UID
  write paths.

### Flutter/report equivalence classes

- Known and Unknown profile readiness.
- Current, missing and stale input fingerprints.
- Unknown-time BaZi-only generation with Thai/Western/Fusion kept closed.
- Client ID-token presence, UID match and null Unknown-time transport.
- Known, ordinary Unknown, Li Chun Unknown and Jie Unknown canonical reports.
- Signed-in report view and Owner fixture route.
- PDF build for all four fixtures from the same report object.
- Forbidden old personality/prediction section leakage and stale-chart hiding.

## Results

- Backend focused: **18/18 passed**.
- Flutter focused auth/freshness/model/report/PDF/routes: **32/32 passed**.
- Full Flutter 3.41.1 / Dart 3.11.0 suite on Linux, matching the platform that
  produced the inherited screenshot baselines: **3,043/3,043 passed**, failures
  0. Required Poppler real-raster and pypdf mutation controls ran; none skipped.
- Analyzer: exit 0 with **282 existing non-fatal warning/info diagnostics**;
  scoped changed-file diagnostics: **0**.
- Web release build: PASS. `main.dart.js` is **8,424,970 bytes**, SHA-256
  `A9752E1AFB91C7BB92EDA32C0C63A03600384BE61D92D60AF8D20E7EB724E67D`.
  It contains the Production API URL and `/beta/chinese`; loopback endpoint
  counts for `127.0.0.1`, `10.0.2.2` and `0.0.0.0` are zero.
- Formatting of the 26 explicitly listed changed Dart files: PASS. `git diff
  --check`, allow-list/scope inspection and forbidden-text scan: PASS.

The same full command on Windows produced **3,003 passed / 40 failed**, all in
the two inherited Thai screenshot-golden files. A representative Windows test
image was byte-identical to the pre-recovery Windows golden, while the current
expected image is the Linux recovery golden. Re-running on the pinned Linux
framework/engine made those unchanged goldens pass. This is recorded as a
cross-platform raster limitation, not concealed as a Thai source regression;
no Thai source or golden was edited.

## PDF visual QA

The reference PDF at
`output/pdf/knowme-bazi-compatibility-v1-owner-reference.pdf` is ignored by
Git. It is **2 A4 pages**, **28,858 bytes**, SHA-256
`138E5C2AFAE97F055B5D63277BFC10C3B0A7397479E83FD852EDA77B29921293`.
Text extraction found 643/681 characters and no blank page. Both rendered pages
were opened at full size: missing text, broken Thai/Chinese glyphs, clipping,
overlap, overflow and visually blank pages were all **0**. The PDF test builds
all four Owner fixtures and checks Unknown-time leakage.

## Production guard

Production mutation is not authorized. The live bundle guard is read-only and
separate: cache pin `e6aaa98` contains one literal `localhost` in hostname
comparison code but no development/loopback endpoint URL. The strict string
guard therefore remains blocked. Draft PR #122 does not repair or deploy it.

## Regression boundary

The changed-file inventory must contain zero Thai astrology source, zero Thai
golden, zero `product-acceptance/` and zero generated validation-output delta.
The branch must remain Draft, unmerged and undeployed.
