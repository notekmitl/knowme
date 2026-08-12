# Thai Report Natural Narrative V1.2 + Pagination Repair

> **V1.4 PDF PAGINATION HOTFIX DEPLOYED AND PRODUCTION VERIFIED (2026-08-12).** PR #90 removed the forced semantic page break and merged as `effab1bffcb410891ae5361908392c92188da8b7`; Production verification then exposed the badge-inclusive exact-boundary spacer condition. PR #91 removed spacing after the final section and merged as `bbdb209b8c2573b16a49d445dd214f7cdfe5fd30`. A clean deployment of `bbdb209` ran 08:17:11Z-08:18:09Z with exit 0 and released 77 files. Fresh real Production downloads passed: Known `(22)` is 36,839 bytes / SHA-256 `1D4A599B9089A7B6F22EEA6E68862B5839F151B05EC8CE35D890F46209D54881` / 6 pages; Unknown `(23)` is 32,756 bytes / SHA-256 `A7CC414114EDD21566F701A8B10B7101779C6AB74DA7D3880C86CC4D5F93FB4D` / 5 pages. Every one of the 11 raster pages passed direct visual inspection, including correct 1/6-6/6 and 1/5-5/5 numbering. Canonical hashes remain unchanged, Unknown remains fail-closed, and cache-bypassed Production HTTP/assets/API checks passed. Rollback remains available from Firebase Hosting release history.

> **V1.4 HOTFIX PRODUCTION FOLLOW-UP (2026-08-12).** PR #90 deployment fixed Unknown to 5 pages but Known remained 7 pages. Production evidence showed the public evidence-badge disclosure filled page 6 exactly; the exporter's final content-free 14-point section spacer then created a footer-only page 7. The follow-up removes spacing after the final section and exercises the badge-inclusive Production fixture. Production remains defective until follow-up merge and redeploy.

> **V1.4 PDF PAGINATION HOTFIX — LOCAL FIX VERIFIED (2026-08-12).** The minimum exporter fix removes a forced continuation `pw.NewPage()` and keeps its heading with the intended paragraph in one atomic unit. Production-fixture output is now Known 6 pages / SHA-256 `30ED523F28DFCAFF04DD1615103859183BD799511CE2FF2AA2E653B8C73CF87B` and Unknown 5 pages / SHA-256 `5FE3C84669F82CD0DB28D43C43E0420BF67F42677F8EF6308D2E92871AD67E88`. All 11 pages passed visual inspection. Accepted Web/PDF canonical hashes remain byte-identical. Focused gates passed 93/93; full suite is 2,861 passed / the same 39 baseline failures, zero new; analyzer remains the 299-finding baseline. Production is not fixed until this branch is merged and deployed.

> **V1.4 DEPLOYED — PRODUCTION DEFECT FOUND (2026-08-12).** Firebase Hosting deployment of accepted merge `0c3d1ef9d083502aa5f1ddae67b9acd23acecbed` completed successfully at 07:26:31Z for project `knowme-app-694e1`. Production and `/beta/thai` return HTTP 200, the deployed bundle is pinned to `0c3d1ef`, uses the Production API, and contains no localhost/test endpoint. Known and Unknown Web flows rendered without fatal console errors; Unknown remained fail-closed. Real Production downloads were inspected on every page: Known is 7 pages (page 7 empty), SHA-256 `5CE22BC8B80B00DE0ECF693DC9F52EA85186D1C4A5AF7CBFA0B169E56F015A30`; Unknown is 6 pages, SHA-256 `87D0B21982B1929BA3DD1F7674EC2611DB586639C398C03A5EFF8968B750B8E6`. This fails the required 6/5-page Production gate. No application files were changed. Firebase Hosting release history is the rollback reference.

> **V1.4 PRODUCT ACCEPTANCE — PASSED (2026-08-12).** Owner acceptance covers r16 evidence packet `thai-report-natural-narrative-v1-4-final-r16-evidence-24c10f5.zip`, 23,386,793 bytes, 45 entries, SHA-256 `9DF9C2B414BF2B8EF6ADA64AD53056AF8F7AD4D157A57597390E6906AFD343D3`; accepted evidence-report SHA-256 is `50AC460E5C1A745725AF98D31F8B4B4A6A36C500F72DA50C93DD114A397226B1`. Known 6 pages and Unknown 5 pages were independently inspected across all 11 renders. PDFs, canonical texts, and renders remain byte-for-byte identical to approved r15 output. PR #89 is approved for merge. No deployment or Production change has occurred. Earlier pending/rejection entries remain as history and are superseded for V1.4.

> V1.4 r15 evidence correction: all 11 renders were reopened and recorded with real headings, last lines, named sections/cards, split/continuation state, geometry results, whitespace, and footer. Four fail-closed regressions protect the generator. Approved hashes remain Known PDF `11A8238AAD42B50216A51BFD1D97D94F14150B500C585D0E172C58B4BBAE4DCE`, Unknown PDF `6E413EED71491793D687C1FCF0C87E25B2FBACDD0E7347255A04F4F0D4BF56AE`, Known canonical `AAB53A53DD8699365E5EDAD1F57C61ABCB4A7A69FD90D6E99E4B940C0987FC10`, Unknown canonical `43274E0CEDAA187CFF51879B77547D1C6746E497FF57CCB2ECDB0540F87FDF99`; all render hashes match r15. Corrected report hash: `50AC460E5C1A745725AF98D31F8B4B4A6A36C500F72DA50C93DD114A397226B1`. **PENDING OWNER RE-ACCEPTANCE**; no merge/deploy/Production change.

Final packet: `C:\Users\USER\Downloads\thai-report-natural-narrative-v1-4-final-r16-evidence-24c10f5.zip`, 23,386,793 bytes, 45 unique entries, SHA-256 `9DF9C2B414BF2B8EF6ADA64AD53056AF8F7AD4D157A57597390E6906AFD343D3`.

> V1.4 owner-rejection revision (2026-08-12): candidate-r14 removes the three cited Unknown repetitions, restores supported forecast-before-advice copy, and adds deterministic PDF continuation orientation. The complete audit passes with cross 18 exact/5 near (23 allowed), Known internal 0/0, Unknown internal 0 exact/6 near (all explicitly enumerated fail-closed omissions), and zero substantive violations. All 11 PDF pages were opened; Product Acceptance remains pending.

> V1.4 completion result (2026-08-11): the Owner-approved baseline-delta gate passes. A fresh JSON-reporter run reconciles clean HEAD at 2,856 passed / 40 failed with V1.4 at 2,858 passed / 39 failed: 39 unchanged, one now passing, zero new, zero worsened, and zero unmatched. Focused V1.4 gates pass 109/109; the repository scoped suite passes 1,535/1,535; golden regression passes 24/24; analyzer remains exactly the 299-finding baseline. Fresh candidate-r6 passes all 5,070 narrative comparisons with zero substantive violations and its Known 6-page / Unknown 5-page PDFs pass every-page visual inspection. Product Acceptance remains pending.

Final acceptance ZIP: `C:\Users\USER\Downloads\thai-report-natural-narrative-v1-4-final-r6-179c5c9.zip`; size 22,399,505 bytes; 45 unique safe entries; SHA-256 `9C63DCB66CCD938AB013B09FA90CCC986FBB63A53EE5AB66EE7B04624CFC5F7A`. Known PDF SHA-256 is `E2F68B456EDCAF016AB0BC7F18ECE7457FA77EBBDF8F409BF8B5EC6A64BA61A6`; Unknown PDF SHA-256 is `EB5B96855FC2193376AFA0830137670BDA03BF5EBB6D9A95AB5DED8B4EE2E0A0`. Cross-fixture audit JSON SHA-256 is `619C2843F2CF70E8315A84C6188B3FB1BC98598CC725A49BB7FC85757B64F1F4`. Product Acceptance remains pending; no merge, deploy, or Production change occurred.

## Result

Draft PR #89 is being reworked on `agent/thai-report-reading-flow-v1` after the Owner rejected the actual V1.1 packet. V1.1 is immutable historical evidence. Status is `PENDING OWNER RE-ACCEPTANCE`; this branch is not merged or deployed.

The V1.2 root cause analysis is recorded in `docs/PR89_V12_ROOT_CAUSE.md`. The composer still concatenated timed claim, impact, bridge, risk, action, fallback, and transition fragments after labels were removed. The PDF semantic-block renderer then treated each split block as a continuation and unconditionally prefixed the parent title with `(ต่อ)`. The previous audit split only complete sentences, while the previous visual checklist did not record first/last lines or continuation counts per page; both therefore missed the Owner-visible failures.

V1.2 retains typed Claim/Risk/Decision/Action semantics but selects only the material needed for one finished reader-facing thought. Current domains are limited to two short paragraphs and one practical focus; twelve-month and next-period domains are limited to one short paragraph, with one observable sign or one preparation item. Parent headings render once, and paragraph chunks no longer create separately headed cards.

## Preserved contracts

- No engine, Canon, calculation, astrological-day boundary, ascendant, house, timeline boundary, factual provenance, Auth, flag, audience, or Production change.
- Known-time facts remain exact; Unknown-time remains fail-closed with no assumed time, Lagna, house, or astrological-day conclusion.
- Web/PDF consume the same analysis and shared presentation values.
- Fortune remains separate from health; ISO date tokens remain atomic.
- Round 9 remains completed historical evidence; existing `product-acceptance/` and the rejected first PR #89 packet were not changed.

## Factual verification

- Exact Known fixture: 1982-06-06 00:03, Chiang Mai, standard `ThaiBetaAnalysisRunner`.
- Canonical ascendant: Aquarius 9°24′.
- The separate 00:35 fixture produces Aquarius 19°19′; this is input-driven, not a regression.

## Validation

- Focused narrative/core/export/pipeline tests: 251/251 passed.
- Synthetic/parity tests: 16/16 passed, including 300 synthetic cases and 20 exact Web/PDF parity cases.
- Golden/story tests: 32/32 passed (24 screenshot profiles and 8 story profiles); no golden update was needed.
- Full required Flutter suite: 1,532/1,532 passed.
- Repository PreCommit gate: passed.
- Analyzer: completed with the repository baseline of 299 warning/info findings and no fatal gate failure.
- Deterministic Known/Unknown V1.2 audit: zero duplicate internal clauses, reused normalized sentence skeletons, repeated action/fallback constructions, forbidden transition families, or content-budget breaches. The V1.1-style negative fixture fails as required.
- Known Web/PDF canonical text parity: byte-identical.
- Unknown Web/PDF canonical text parity: byte-identical; fail-closed behavior preserved.
- Acceptance PDFs from source-tested commit `fa2664f`: Known 6 pages / 36,543 bytes / SHA-256 `4DBEAFC51239398C7ED8ACF42584CFE7CE95B0F71DDFB41A2C4A5A427E796601`; Unknown 5 pages / 33,512 bytes / SHA-256 `EFD5BAA9E9E0FBBE6CF2B3C3EF9EAAABE967758F346AE1839D7BBC6676F492FE`.
- Visual QA: all 11 final rendered PDF pages and four final Web desktop/mobile captures inspected without blank/orphan page, repeated continuation heading, clipping, overflow, footer overlap, or missing glyph. The evidence log records every page's first heading, last visible line, and continuation count (all zero).
- New acceptance folder: `C:\Users\USER\Documents\Knowme\thai-report-natural-narrative-v1-2-fa2664f-acceptance`.
- ZIP: `C:\Users\USER\Downloads\thai-report-natural-narrative-v1-2-fa2664f.zip`, 2,436,006 bytes, 28 safe unique entries, SHA-256 `8EA21BB2AEB98BBD36DDE28B8F958E4693A58F0C49A03D72C7D7B49249BEC673`; 26 checksum lines verified with zero mismatch.

The acceptance ZIP and Draft PR metadata are recorded after packaging and push complete. Do not merge or deploy before explicit Owner approval.
# PR #89 V1.3 status (2026-08-11)

Owner rejected V1.2 (`thai-report-natural-narrative-v1-2-fa2664f.zip`, SHA-256 `8EA21BB2AEB98BBD36DDE28B8F958E4693A58F0C49A03D72C7D7B49249BEC673`). Root causes and the invalid V1.2 visual-review conclusion are recorded in `docs/PR89_V13_ROOT_CAUSE.md`. V1.3 repairs cross-fixture/horizon selection, repeated past fragments, Unknown omission wording, and PDF disclaimer geometry. Status: **PENDING OWNER RE-ACCEPTANCE**. Do not merge or deploy.
# V1.5 narrative quality result (Draft)

Implementation and acceptance evidence are proposed under
`product-acceptance/thai-narrative-v1.5-r1/`. Automated checks are supporting
evidence only; narrative quality remains pending Owner reading. Production was
not changed. See `docs/THAI_NARRATIVE_V15_ROOT_CAUSE_AND_SPEC.md`.
