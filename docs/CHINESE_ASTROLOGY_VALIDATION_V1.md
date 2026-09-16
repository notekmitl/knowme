# KnowMe BaZi Compatibility V1 Validation

## Production release evidence (2026-09-16)
**Status:** deployed and verified in Production.
- Release provenance: remote `https://github.com/notekmitl/knowme.git`, commit `664c8656a2028cf266745f9c1c3a0567989266ec`, tree `bee0a7c8ea07035920bc58b2524aa9b68ab96df6`, project `knowme-app-694e1`.
- Final Cloud Run revision: `knowme-astrology-api-00003-b29` in `asia-southeast1`, created `2026-09-16T05:00:07.320990Z`, image digest `sha256:99c1831eb7bda8135cfa9593bf39d074b059588196bc5736aaeb26946701e0df`.
- Firebase Hosting release: `sites/knowme-app-694e1/releases/1789470114786000`, version `sites/knowme-app-694e1/versions/e915f14591fb48f2`, released `2026-09-15T11:01:54.786Z`.
- API QA: `/health` 200; unauthenticated `/v1/generate-bazi` 401; unauthenticated `/v1/generate-chart` 401; authenticated empty-payload probe 422, proving token verification completed before body validation; focused repository auth/UID tests 8/8.
- Production browser QA: Thai, BaZi and Western choices were visible; authenticated BaZi generation returned 200 at `2026-09-16T05:01:45.265470Z` and the full Thai-language BaZi report rendered. No Flutter/API application exception was observed; browser-extension message-channel noise was excluded.
### Deployment record
- Cloud Run source deploy started `2026-09-15T10:41:25Z`; Cloud Build `3403ae33-b227-476a-aa70-2e170c5fbf1a` completed `2026-09-15T10:45:18.323052Z`; source revision `knowme-astrology-api-00002-p8b` used the release image above.
- Real browser QA found that the valid Firebase project token was rejected before persistence because Firebase Admin was initialized lazily only inside the save service. The final configuration-only mitigation initializes Admin before Uvicorn and created revision `knowme-astrology-api-00003-b29` at `2026-09-16T05:00:07.320990Z`; the image digest and release tree remain unchanged.
- Hosting deployment ran `2026-09-15T11:01:39Z`–`11:02:17Z`; release time was `2026-09-15T11:01:54.786Z`. Only Hosting was deployed.
### Web artifact
- Flutter `3.41.1`, Dart `3.11.0`; `ASTROLOGY_API_BASE_URL=https://knowme-astrology-api-avbyttircq-as.a.run.app`; `THAI_PUBLIC_EVIDENCE_BADGE_BETA=public_beta`; `--no-tree-shake-icons`.
- `main.dart.js`: 8,511,604 bytes; SHA-256 `ee11caf2001c75aa86f9cb0018e893d0d76f60ea479d35c8a7a818071e3b874d`.
- `flutter_bootstrap.js?v=664c865` and `main.dart.js?v=664c865` were present on `web.app` and `firebaseapp.com`. Both domains returned 200 for root, bootstrap and `/beta/thai` cache-bypass checks.
- The bundle contains the Production API exactly once and both `/v1/generate-bazi` and `/v1/generate-chart`; the loopback endpoint scan returned no match.
### Production QA
- Missing-token checks returned 401 for both v1 routes, not 404. Authenticated empty-payload probing returned 422, confirming successful token verification without a data write.
- Focused repository QA `test_bazi_route_auth.py` plus `test_astrology_route_auth.py`: 8/8 passed. This verifies bearer validation, revoked-token checking, UID mismatch rejection and verified-UID persistence binding.
- Signed-in UI showed Thai, BaZi and Western systems. BaZi generation completed with HTTP 200 in 7.382 seconds and the full report rendered, including overview, five life areas, Day Master evidence, calculated pillars, source ledger and limitations.
- No Flutter/API application exception appeared during the passing flow. The only console noise was unrelated browser-extension message-channel logging.
- No Firestore rules, Functions, Auth configuration or Storage configuration was deployed. The only Production data write was the signed-in BaZi result required by the explicit acceptance test.


**Pre-release status (2026-09-14):** validated and merged in PR #122;
Production deployment was still pending an authenticated runner.

**Pre-release validation date:** 2026-09-14

**Merged release source:** commit
`664c8656a2028cf266745f9c1c3a0567989266ec`, tree
`bee0a7c8ea07035920bc58b2524aa9b68ab96df6`. The merge tree is
identical to the validated PR head tree.

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

- Backend focused calculation/BaZi-auth/Western-auth: **22/22 passed** in 0.41
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
- Web release build: PASS on Flutter 3.41.1. `main.dart.js` is **8,511,604
  bytes**, SHA-256
  `ee11caf2001c75aa86f9cb0018e893d0d76f60ea479d35c8a7a818071e3b874d`.
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

## Production guard and release attempt

The Owner authorized Ready, merge and Production release. PR #120 merged as
`d8245cd29e94641151988da33800670acbb8866a`; PR #122 merged as
`664c8656a2028cf266745f9c1c3a0567989266ec`.

Actual forbidden loopback endpoint findings are 0. The local bundle retains one
literal `localhost` only in
`window.location.hostname == "localhost"`, which is a host-mode comparison and
not an API endpoint. The repository's endpoint-focused Production validator
passes; the prior strict-policy blocker is closed by contextual classification.

Deployment did not complete. Google account/device verification and Google
Cloud SDK consent succeeded, but the local CLI required an out-of-band
credential that cannot be handled through chat. The runner network also denied
Google Cloud Console and standalone Cloud Shell. No new Cloud Run revision,
Firebase Hosting release, Firestore rule or Firebase data mutation occurred.

Resume from an authenticated runner at exact commit `664c8656`: deploy backend
v1 beside legacy paths, verify health/auth/UID behavior, then build and deploy
the cache-pinned client to Firebase Hosting only. Adoption verification and
legacy-Western retirement remain separate follow-up work.

## Regression boundary

The changed-file inventory contains one intentional Thai-route navigation seam
and one date-aware assertion. Thai calculation/report source, Thai goldens,
`product-acceptance/` and generated validation-output deltas are zero. The
implementation is merged. Production remains undeployed by this closeout.
