# KnowMe BaZi Compatibility V1 Validation

**Status:** ready for Owner testing; Draft PR #122; not deployed

**Date:** 2026-09-14

**Validated application:** the runtime commit containing the post-form chooser,
versioned API migration and natal-reading expansion; exact commit/tree are
recorded in the final docs-only closeout.

## Coverage statement

Validation is risk-based and uses equivalence classes. It does not assert that
every day, time, place or IANA timezone was executed.

The backend and Flutter lists below are automated engineering gates. They are
not instructions for Owner fixture testing.

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
- Fusion version invalidation when the BaZi fingerprint changes while the Day
  Master is unchanged, and when a Known lens disappears after Unknown time.
- Client ID-token presence, UID match and null Unknown-time transport.
- Known, ordinary Unknown, Li Chun Unknown and Jie Unknown canonical reports.
- All ten Day Master profiles in Thai and English.
- All five visible-element relationship mappings for each Day Master element.
- Known four-pillar versus ordinary Unknown three-pillar relationship counts.
- Boundary-partial Unknown omission of chart-wide relationship emphasis.
- Five reader-facing natal areas with Day Master/family/count evidence,
  joint-highest tie preservation, zero-Wealth caution and boundary omission.
- Deterministic reading catalog scan for forbidden event/domain promises.
- Signed-in report view and Owner fixture route.
- PDF build for all four fixtures from the same report object.
- Forbidden old personality/prediction section leakage and stale-chart hiding.
- `/beta/thai` submit-to-selector navigation and preservation of the accepted
  Thai executor/start/as-of contract.
- Authenticated canonical-profile handoff for BaZi/Western, empty Unknown-time
  storage, Western Unknown/province gate and cancelled-sign-in no-write path.
- Versioned BaZi/Western client paths, bearer/UID binding, explicit legacy path
  identities and verified-UID backend writes.
- Forced Western regeneration and pre-refresh Fusion invalidation.

## Results

- Backend focused calculation/BaZi-auth/Western-auth: **22/22 passed** in 0.42
  seconds. Route tests stub calculations and persistence and make no Firebase
  call or write. Firestore initialization is now lazy at the Western
  persistence boundary, so importing the route cannot trigger metadata
  credentials.
- Flutter focused auth/handoff/chooser/freshness/Fusion/model/reading/report/
  PDF/routes: **79/79 passed**.
- Full Flutter 3.41.1 / Dart 3.11.0 suite on Linux with the
  repository-required `TZ=Asia/Bangkok`: **3,070/3,070 passed**, failures 0.
- Repository analyzer: exit 0 with **282 existing non-fatal warning/info
  diagnostics**; scoped changed-Dart diagnostics: **0**.
- PreCommit-equivalent component gates: PASS for base/scope, forbidden-text
  scan, analyzer, both focused commands and required full suite.
- The full suite rewrote 22 tracked generated validation outputs. Each exact
  path was restored individually to HEAD; no broad restore was used.
- Web release build: PASS on Flutter 3.41.1. `main.dart.js` is **8,511,596
  bytes**, SHA-256
  `B0C183CBB39FFB965DD2DC7CC53E2B6E7FDF8FFCB89E5EADE0221B1BDA95FD9A`.
  The bundle contains `/beta/thai`, `/beta/chinese`, both `/v1` endpoint paths
  and the exact Production API URL. Actual loopback URL count and forbidden
  service/secret count are zero.

The earlier Windows full-suite result is not used as a passing gate. The
authoritative result above comes from the pinned framework/engine, correct
repository timezone and unchanged Thai screenshot goldens. No Thai source or
golden was edited.

## PDF visual QA

Final PDFs are ignored by Git under
`output/pdf/knowme-bazi-natal-reading-v1/`:

| Fixture | Pages | Bytes | SHA-256 |
|---|---:|---:|---|
| `knowme-bazi-known.pdf` | 5 | 45,343 | `1B25943D15A6BCA5A423844A4C2A3C1469D087734FDA929AA9C149E266D0935B` |
| `knowme-bazi-unknown.pdf` | 4 | 44,509 | `A9BB90A7AB320E0353BC481CDFCA2465BAEEA775B47BC3763937FD4BBB100AC5` |
| `knowme-bazi-lichun-unknown.pdf` | 3 | 36,123 | `D41924C063A380072C47C047B2968AFA1CB979A94F1BDA255DFD0F10860E9139` |
| `knowme-bazi-jie-unknown.pdf` | 3 | 36,263 | `330D2763A2CF329D34B72A84F06F443863C260F22D8F001C1693DC011713B1D3` |

All 15 latest pages were rendered with Poppler and opened at original
resolution. Missing sections, broken Thai/Chinese glyphs, clipping, overlap,
overflow and blank pages are all **0**. A first render exposed unsupported
bullet-glyph substitution and a dense two-column life-area layout; the final
export replaces PDF bullets with an embedded-font dash and lets each life area
flow as its own labelled card. The 15-page set above is the post-repair set that
was inspected.

`pdfinfo` reports A4 for every file. `pdffonts` reports embedded
`NotoSansThai-Regular`, `NotoSansThai-Bold` and `NotoSansSC-Regular`, with no
Thin font. Poppler text extraction is non-empty on every page. Known contains
`15:30`, `戊申` and all five natal areas. Ordinary Unknown contains all five
natal areas but neither `戊申` nor any Hour result. Li Chun/Jie variants contain
no natal-area section and omit their boundary-ambiguous facts.

## Owner manual checklist

Owner manually submits one birth form to confirm the Thai/Chinese/Western
choice, then reads Known, ordinary Unknown, Li Chun Unknown and Jie Unknown.
The content check covers the overview, five natal areas where allowed, evidence
lines, source ledger and Web/PDF parity. Token/UID/revoked-token behavior,
profile persistence, regeneration and Fusion freshness are automated
engineering gates and are not exercised by the no-write fixture route.

## Production guard

Production mutation is not authorized. Actual loopback endpoint findings are 0
for both the new local release bundle and live cache pin `e6aaa98`. Each retains
one literal `localhost` in hostname comparison code; the local context is
`window.location.hostname == "localhost"`, which is not an endpoint. Improving
this strict classification is a future shared guard-quality task that policy
still requires before Production. Draft PR #122 does not repair shared runtime
or deploy it.

The release build is evidence only. PR #122 contains parallel authenticated v1
endpoints and migrated bearer clients, but no release occurred. Backend v1 must
be deployed before the client, followed by adoption verification and later
legacy-Western retirement under separate authorization.

## Regression boundary

The changed-file inventory contains one intentional Thai-route navigation seam
and one date-aware assertion. Thai calculation/report source, Thai goldens,
`product-acceptance/` and generated validation-output deltas are zero. The
branch remains Draft, unmerged and undeployed.
