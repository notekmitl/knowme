# KnowMe BaZi Compatibility V1 Validation

**Status:** ready for Owner testing; Draft PR #122; not deployed

**Date:** 2026-09-13

**Validated application:** commit
`afaa3a97b3a6ce82f555efbfbd79917567ebc339`, tree
`3b56c98a3d03552246acc66ca7e6830b256ba957`

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
- Deterministic reading catalog scan for forbidden event/domain promises.
- Signed-in report view and Owner fixture route.
- PDF build for all four fixtures from the same report object.
- Forbidden old personality/prediction section leakage and stale-chart hiding.

## Results

- Backend focused: **18/18 passed** in 0.23 seconds. The offline rerun used the
  pinned calculation/FastAPI dependencies and a minimal test-only
  `firebase_admin` import stub; route tests monkeypatched token verification and
  made no Firebase call or write.
- Flutter focused auth/freshness/Fusion/model/reading/report/PDF/routes: **57/57
  passed**.
- Full Flutter 3.41.1 / Dart 3.11.0 suite on Linux with `CI=true`, analytics
  suppressed and repository-required `TZ=Asia/Bangkok`: **3,055/3,055 passed**,
  failures 0. A preliminary invocation without the required timezone produced
  11 environment-driven Thai date/hash mismatches and is not counted as a gate;
  no Thai code, fixture or golden was changed.
- Repository analyzer: exit 0 with **282 existing non-fatal warning/info
  diagnostics**; scoped changed-Dart diagnostics: **0**.
- PreCommit component gates: PASS for base/scope, forbidden-text scan,
  analyzer, both focused commands and required full suite.
- The full suite rewrote 22 tracked generated validation outputs. Each exact
  path was restored individually to HEAD; no broad restore was used.
- Web release build: PASS on Flutter 3.41.1. `main.dart.js` is **8,469,824
  bytes**, SHA-256
  `3DFF3095890C8EF72E00F499AA44EC6BFA7292CF0F02B548B439699E40C5FCE8`.
  The exact Production API URL and `/beta/chinese` each occur once. Counts for
  `http://localhost`, `127.0.0.1`, `10.0.2.2` and `0.0.0.0` are zero.

The earlier Windows full-suite result is not used as a passing gate. The
authoritative result above comes from the pinned framework/engine, correct
repository timezone and unchanged Thai screenshot goldens. No Thai source or
golden was edited.

## PDF visual QA

Final PDFs are ignored by Git under
`output/pdf/knowme-bazi-symbolic-reading-linux-20260913/`:

| Fixture | Pages | Bytes | SHA-256 |
|---|---:|---:|---|
| `knowme-bazi-known.pdf` | 3 | 40,887 | `3140A215B36F7B6072F98FC0C85A4AF48D4F3C6A0885923EBF73DC784CD36ADB` |
| `knowme-bazi-unknown.pdf` | 3 | 41,040 | `553546D11B0928343FB65317F205AB238EF5D2DB6B149974FAB396A9DAF7E0DC` |
| `knowme-bazi-lichun-unknown.pdf` | 3 | 36,338 | `7AAF410FA75C0299AF160F5DAB06C0F0615EAB8661BA99210A66A201C748B666` |
| `knowme-bazi-jie-unknown.pdf` | 3 | 36,448 | `AD4678F3D396E02389980D45E0A2BDB3AED77632CBB7A5D90A0068D0DE9F27C5` |

All 12 latest pages were rendered with Poppler at 144 DPI and opened at original
resolution. Missing sections, broken Thai/Chinese glyphs, clipping, overlap,
overflow, blank pages and sparse trailing pages are all **0**. Page numbering is
complete at `1 / 3` through `3 / 3`, and the 64-character input hashes fit one
line. The final raster set is byte-identical to the visually inspected set even
though PDF metadata makes independently generated PDF bytes differ.

`pdfinfo` reports three A4 pages for every file. `pdffonts` reports embedded CID
TrueType `NotoSansSC-Regular` for all four PDFs and no Thin font. Poppler text
extraction is non-empty on every page. Known contains `15:30` and its `wu/shen`
Hour. Ordinary Unknown, Li Chun Unknown and Jie Unknown contain neither. The
ordinary Unknown report retains the three-pillar relationship section; the Li
Chun/Jie variants omit it as well as their boundary-ambiguous facts.

## Owner manual checklist

Owner manually reads Known, ordinary Unknown, Li Chun Unknown and Jie Unknown,
including the Day Master wording, visible relationship section where allowed,
source ledger and Web/PDF parity. Token/UID/revoked-token behavior,
regeneration and Fusion freshness are already automated engineering gates and
are not exercised by the no-write fixture route.

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
