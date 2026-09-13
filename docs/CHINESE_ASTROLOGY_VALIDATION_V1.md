# KnowMe BaZi Compatibility V1 Validation

**Status:** ready for Owner testing; Draft PR #122; not deployed

**Date:** 2026-09-13

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
- Signed-in report view and Owner fixture route.
- PDF build for all four fixtures from the same report object.
- Forbidden old personality/prediction section leakage and stale-chart hiding.

## Results

- Backend focused: **18/18 passed** in 0.40 seconds.
- Flutter focused auth/freshness/Fusion/model/report/PDF/routes: **51/51
  passed**.
- Full Flutter 3.41.1 / Dart 3.11.0 suite on Linux, matching the inherited
  screenshot baseline platform: **3,049/3,049 passed**, failures 0.
- Repository analyzer: exit 0 with **282 existing non-fatal warning/info
  diagnostics**; scoped changed-Dart diagnostics: **0**.
- PreCommit gate: PASS for branch/worktree/base/scope, forbidden-text scan,
  analyzer, both focused commands and required full suite.
- The full suite rewrote 23 tracked generated validation outputs. Each exact
  path was restored individually to HEAD; no broad restore was used.
- Web release build: PASS on Flutter 3.41.1. `main.dart.js` is **8,428,317
  bytes**, SHA-256
  `F30256BE2AF1725DF933ECA7D9228341BBA980D07C6FA058AC08418132AE2959`.
  The exact Production API URL and `/beta/chinese` each occur once. Counts for
  `http://localhost`, `127.0.0.1`, `10.0.2.2` and `0.0.0.0` are zero.

These application results are pinned to commit
`8fe3c68e2c60ec9a1511e75bc22982a1d854c007`, tree
`a478defae8cd8f88435e8f5fda7c908db4a11773`.

The later Owner-QA clarification is Markdown-only. Its docs-required PreCommit
reverified exactly eight approved document paths, forbidden text, `git diff
--check`, the pinned application commit/tree, the Web bundle hash and all four
PDF hashes. Analyzer, Flutter tests, PDF generation and Web build were not
rerun because runtime, tests and artifacts did not change.

The earlier Windows full-suite result is not used as a passing gate. The
authoritative result above comes from the pinned Linux framework/engine and the
unchanged Thai screenshot goldens pass there. No Thai source or golden was
edited.

## PDF visual QA

Final PDFs are ignored by Git under
`output/pdf/knowme-bazi-fusion-linux-20260913/`:

| Fixture | Pages | Bytes | SHA-256 |
|---|---:|---:|---|
| `knowme-bazi-known.pdf` | 2 | 28,887 | `D2BE7BC941B0C0A848BD1766E7F9EE7909E2FE9211B2A083D5DAC53789A3DBA4` |
| `knowme-bazi-unknown.pdf` | 2 | 28,984 | `68AC206E4CF285C3A955CB9D161F4DCFAB5F3007D18ECAC5A1DC685A0980D5D7` |
| `knowme-bazi-lichun-unknown.pdf` | 2 | 28,217 | `76607BEF322605DB950B434AFD4D393FC83A3483B3700CC76D348AE7516CE2A3` |
| `knowme-bazi-jie-unknown.pdf` | 2 | 28,493 | `BA723E00E3CBB0AFE1DB561A1A792B17E83B052980F561336A40723D41BF987A` |

All eight pages were rendered with Poppler at 144 DPI and opened at original
resolution. Missing sections, broken Thai/Chinese glyphs, clipping, overlap,
overflow and blank pages are all **0**. Page numbering is complete at `1 / 2`
and `2 / 2`, and the 64-character input hashes fit one line.

`pdfinfo` reports two A4 pages for every file. `pdffonts` reports embedded CID
TrueType `NotoSansSC-Regular` for all four PDFs and no Thin font. pypdf reports
non-empty text on every page. Known contains `15:30` and its `wu/shen` Hour;
ordinary Unknown, Li Chun Unknown and Jie Unknown contain neither value. The
Li Chun/Jie variants visibly omit their boundary-ambiguous fields.

## Owner manual checklist

Owner manually checks Known, ordinary Unknown, Li Chun Unknown, Jie Unknown and
Web/PDF parity only. Token/UID/revoked-token behavior, regeneration and Fusion
freshness are already automated engineering gates and are not exercised by the
no-write fixture route.

## Production guard

Production mutation is not authorized. Actual loopback endpoint findings are 0
for both the new local release bundle and live cache pin `e6aaa98`. Each retains
one literal `localhost` in hostname comparison code; the local context is
`window.location.hostname == "localhost"`, which is not an endpoint. Improving
this strict classification is a future shared guard-quality task that policy
still requires before Production. Draft PR #122 does not repair shared runtime
or deploy it.

The release build is evidence only. Client-first followed by immediate backend
enforcement is not accepted sequencing because cached/open legacy clients may
still omit the token. Release remains blocked pending a separately implemented
parallel authenticated versioned endpoint, new-client migration, adoption
verification and later legacy-endpoint retirement.

## Regression boundary

The changed-file inventory contains zero Thai astrology source, zero Thai
golden, zero `product-acceptance/` and zero generated validation-output delta.
The branch remains Draft, unmerged and undeployed.
