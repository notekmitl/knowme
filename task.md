# Task: Thai Report Reading Flow and Friendly Voice V1

> **CURRENT — V1.5 FINAL MERGE GATE PASSED AGAINST PINNED MAIN (2026-08-16):** The controlled Case A repair reconciles exactly 18 Owner-authorized Life Timeline goldens after fresh actuals matched pinned main `22cbb3cfcb583b63fe8d48a164d5083d9ee32163` by dimensions, SHA-256, and pixels 18/18; visual QA passes 18/18 and targeted regression passes 24/24. Life Map passes 67/67 and matrix 864/864; focused passes 286/286; synthetic remains 300/300; analyzer delta is 0; Web build passes. Full branch 2,889/39 and pinned main 2,861/39 have identical failure IDs, branch-only 0 and main-only 0. R1-R7.1 remain immutable. Merge/deploy are out of scope; Production remains V1.4.

> **HISTORICAL — V1.5 LIFE MAP COMPATIBILITY REPAIR GATE BLOCKED (2026-08-16):** The exact four-string restoration fixed the prior 14 Life Map regressions with no test weakening: isolated 67/67, matrix 864/864 and weekday 108/108. Focused was 286/286, synthetic was 300 unique reports / 300 unique narratives, analyzer delta was 0 and Web build passed. The full suite was then branch 2,871/57 vs main 2,861/39: common 39, branch-only 18, main-only 0. That task kept goldens/tests frozen and PR #92 Draft pending separate authorization.

> **V1.5 FINAL MERGE GATE — BLOCKED (2026-08-16):** Owner decision is authoritative: `V1.5 R7.1 OWNER ACCEPTANCE PASSED` and `V1.5 PRODUCT ACCEPTANCE PASSED`; R7 narrative and R7.1 evidence are accepted and R1-R7.1 remain immutable. Fresh focused rerun passes 286/286; scoped analyzer is clean; full analyzer is 299 branch / 299 main / delta 0; Web release build and acceptance-preservation checks pass. The mandatory full suite fails at 2,875 passed / 53 failed; compared with main 2,861 passed / 39 failed, 14 branch-only Life Map V1.2.6-V1.3.2 failures remain and reproduce in isolation. Do not change product code/tests under this task. Full-suite repair requires separate authorization and a new gate rerun. Keep PR #92 Open Draft; DO NOT MERGE; DO NOT DEPLOY; Production remains V1.4.

> **V1.5 R7.1 EVIDENCE-ONLY REPAIR (2026-08-16):** `R7 NARRATIVE ACCEPTED`; `R7 ACCEPTANCE PACKAGE REJECTED` เฉพาะ evidence encoding/accuracy. R7.1 does not change product code, product tests, canonical text, PDFs, renders, or R7 audit JSON. Strict staging and extracted-ZIP validation report zero UTF-8/BOM/U+FFFD/C0/C1/tab/mojibake/identity findings; 63 immutable files match R7; 79/79 checksums pass. The R7 focused 286/286 result was not rerun; full suite was not run. Product Acceptance remains pending; PR #92 stays Open Draft; DO NOT MERGE; DO NOT DEPLOY; Production remains V1.4.

> **V1.5 R7 (2026-08-15):** `V1.5 R6 OWNER ACCEPTANCE REJECTED`. R7 removes motif/phase injection and repairs human-readable Thai while preserving Known evidence, Unknown fail-closed, factual anchors and canonical Web/PDF output. Focused tests pass 286/286; analyzer is clean; synthetic reports/narratives are unique 300/300; traceability is 170/170; parity is 5/5; all 34 PDF pages were inspected. Full suite was not run. Owner Acceptance is pending; PR #92 remains Open Draft; DO NOT MERGE; DO NOT DEPLOY; Production remains V1.4.

> **V1.5 R6 (2026-08-15):** `V1.5 R5 OWNER ACCEPTANCE REJECTED`. R6 gives each report one central thesis and separates Hook/Core/Current/12-month/Next-phase/Closing responsibilities. Clause-level exact/prefix/suffix/skeleton and Unicode similarity gates pass with 0/222 exact reuse, 0 cross-profile exact sentences and 0 flagged clause pairs; traceability is 170/170; focused tests pass 280/280; analyzer is clean; all 37 PDF pages were inspected. Full suite was not run. Owner Acceptance is pending; PR #92 remains Open Draft; DO NOT MERGE; DO NOT DEPLOY; Production remains V1.4.

> **V1.5 R5 (2026-08-15):** `V1.5 R4 OWNER ACCEPTANCE REJECTED`. R5 uses a deterministic age-band resolver for Past, cautious observable framing for Unknown, Unicode character/skeleton repetition gates, and one consumer-unit freshness source. Focused tests pass 226/226; analyzer is clean; 170/170 claims retain Web/PDF traceability; all 34 PDF pages were inspected. Owner Acceptance is pending; PR #92 remains Draft; no merge/deploy; Production remains V1.4.

> **V1.5 R4 (2026-08-15):** `V1.5 R3 OWNER ACCEPTANCE REJECTED`. R4 corrects report-level hook reuse, templated suffix repetition, current-claim traceability, incomplete freshness accounting and non-portable ZIP paths. Final evidence has 170/170 expressed claims present, 300/300 narrative-distinct synthetic outputs and 34 visually inspected PDF pages. Owner Acceptance is pending; PR #92 remains Draft; no merge/deploy; Production remains V1.4.

> **V1.4 PDF PAGINATION HOTFIX DEPLOYED AND PRODUCTION VERIFIED (2026-08-12).** Hotfix PRs #90 and #91 were merged as `effab1bffcb410891ae5361908392c92188da8b7` and `bbdb209b8c2573b16a49d445dd214f7cdfe5fd30`. The final clean `origin/main` revision was deployed to Firebase project/site `knowme-app-694e1` with `scripts/deploy_web.ps1` (08:17:11Z-08:18:09Z, exit 0, 77 Hosting files). Cache-bypassed `/` and `/beta/thai` returned HTTP 200 and assets were pinned to `bbdb209`. Fresh Production downloads are Known `knowme-thai-report (22).pdf` (36,839 bytes, SHA-256 `1D4A599B9089A7B6F22EEA6E68862B5839F151B05EC8CE35D890F46209D54881`, 6 pages) and Unknown `knowme-thai-report (23).pdf` (32,756 bytes, SHA-256 `A7CC414114EDD21566F701A8B10B7101779C6AB74DA7D3880C86CC4D5F93FB4D`, 5 pages). All 11 pages were raster-inspected: page numbering is correct and there is no blank/footer-only page, clipping, overlap, truncation, broken Thai wrapping, or card-border escape. Unknown remains fail-closed; canonical Web/PDF hashes are unchanged. Historical defect entries below remain as the audit trail. Rollback remains available through Firebase Hosting release history.

> **V1.4 PDF PAGINATION HOTFIX — LOCAL FIX VERIFIED (2026-08-12).** The Production 7/6-page defect was caused by an unconditional `pw.NewPage()` added at a semantic continuation marker after `MultiPage` had already performed measured pagination. The fix keeps the continuation heading atomic with its paragraph and removes the forced break. Real-export local fixtures now produce Known 6 pages and Unknown 5 pages; all 11 pages were raster-inspected. Accepted canonical hashes are unchanged. Production remains defective until merge and redeploy; rollback remains available.

> **V1.4 DEPLOYED — PRODUCTION DEFECT FOUND (2026-08-12).** PR #89 was merged as `0c3d1ef9d083502aa5f1ddae67b9acd23acecbed` and that exact revision was deployed to Firebase project `knowme-app-694e1` at `https://knowme-app-694e1.web.app` using `scripts/deploy_web.ps1` (2026-08-12 07:26:02Z–07:26:31Z). Build, focused V1.4 tests (123/123), synthetic narrative audit (300/300), API smoke, Firestore rules compilation, endpoint guards, HTTPS, cache-pin, Known/Unknown Web flows, and real PDF downloads passed. Production PDF pagination did not retain the accepted 6/5-page contract: the downloaded Known PDF is 7 pages with an empty page 7, and Unknown is 6 pages. No source repair was made in this deployment-record task. Rollback is available from Firebase Hosting release history.

> **V1.4 PRODUCT ACCEPTANCE — PASSED (2026-08-12).** The Owner independently accepted `thai-report-natural-narrative-v1-4-final-r16-evidence-24c10f5.zip` (23,386,793 bytes; 45 unique entries; ZIP SHA-256 `9DF9C2B414BF2B8EF6ADA64AD53056AF8F7AD4D157A57597390E6906AFD343D3`; evidence-report SHA-256 `50AC460E5C1A745725AF98D31F8B4B4A6A36C500F72DA50C93DD114A397226B1`). Known is 6 pages, Unknown is 5 pages, and all 11 renders were independently inspected and accepted. Product artifacts remain byte-for-byte identical to approved r15 output. PR #89 is approved for merge. Deployment is outside this task and Production remains unchanged. Historical pending/rejection statements below describe earlier checkpoints and are superseded for V1.4.

> V1.4 r15 evidence correction (2026-08-12): Owner inspection passes the r15 product output but rejects `page-by-page-visual-review.json`. The generator used the first extracted PDF line (a footer) as the heading and hard-coded generic review fields. The evidence-only r16 workflow now requires validated manual observations for all 11 pages and preserves the r15 PDFs, canonical texts, renders, facts, and narrative audit byte-for-byte. Status: **PENDING OWNER RE-ACCEPTANCE**; PR #89 stays Draft with no merge, deploy, or Production change.

> V1.4 owner-rejection revision (2026-08-12): r6 was rejected because its cross-fixture-only audit missed three Unknown internal repetitions, the Known future copy read like a tracking worksheet, and two PDF continuations lacked orientation. The corrected audit covers cross-fixture, Known-internal, Unknown-internal, and same-passage advice stems; r6 fails with 4 substantive violations while candidate-r14 passes with 0. Status: **PENDING OWNER RE-ACCEPTANCE**; no merge, deploy, or Production change.

> V1.4 completion status (2026-08-11): **REVISION COMPLETE — PENDING OWNER RE-ACCEPTANCE**. Absolute zero was inappropriate for this scoped PR because clean HEAD `23fe2c2` itself has 40 failures. Machine-readable comparison proves V1.4 has 39 unchanged baseline failures, one baseline failure now passing, zero new failures, zero worsened failures, and zero unmatched failures. All V1.4-specific gates pass; final candidate-r6 is packaged from implementation commit `179c5c9a3f6318d799b0be8c2233be7013b89c1c`. PR #89 remains Draft.

## Owner-rejection recovery Round 2 — Natural Narrative V1.2 + pagination repair

The Owner rejected the actual V1.1 packet (`f9945a5`) because its paragraphs still exposed a shared fragment chain and Known PDF pages 6–8 repeatedly emitted parent continuation headings. The prior statement that every page had passed visual review is invalid. V1.2 selects one finished thought per domain/horizon, enforces strict paragraph budgets, removes generic action/fallback/transition suffixes, and repairs pagination at the semantic-block renderer. Status is `PENDING OWNER RE-ACCEPTANCE`; PR #89 stays open and Draft. No merge or deployment is authorised.

Owner feedback after the completed Round 9 release requires a new Product Narrative and Information Architecture pass for the Thai Beta Web/PDF report. This task does not change astrology calculations, Canon, factual provenance, ascendant/houses, timeline boundaries, beta policy, Auth, or Production.

## Delivery contract

- Baseline: `c34a1c088b555160707577308c281570b570752a` (`origin/main`).
- Branch: `agent/thai-report-reading-flow-v1`.
- Reader-facing interpretation leads; calculation method and chart structure move to final collapsed transparency controls.
- Web and PDF consume the same `ThaiBetaAnalysis`, core reading, timeline, and forecast state.
- Thai voice is warm, direct, plain, and uses `คุณ`; typed Risk → Decision Impact → Action semantics remain intact.
- Known-time facts remain unchanged; Unknown-time remains fail-closed.
- Round 9 is retained as completed historical evidence. Existing `product-acceptance/` is not changed.
- Final state for this revision: `V1.4 PRODUCT ACCEPTANCE — PASSED`; PR #89 is approved for merge. Do not deploy in this task.
- Current domains: at most two short paragraphs and one practical focus. Twelve-month and next-period domains: at most one short paragraph, with one review sign or one preparation item respectively.
- The deterministic quality gate covers internal duplicate clauses, normalized sentence skeletons, repeated construction families, semantic-fragment budgets, and per-page continuation-heading counts.
- Manual PDF review must record the first heading, last visible line, and continuation-heading count for every Known and Unknown page.

## Acceptance

- New reader-facing order is enforced for Web and PDF.
- `หลักการนับวันทางโหราศาสตร์ไทย` and `โครงสร้างดวงหลัก` are absent from the opening flow and available only near the end.
- Forecast fields use natural labels without weakening typed semantic ownership.
- Focused, full, analyzer, screenshot/golden, PDF raster, documentation, secret/PII, PreCommit, and PostCommit gates pass.
- A separate Known/Unknown acceptance packet is generated, hashed, rendered, visually reviewed, and copied to the Windows delivery location.
- Push a non-force branch and open a Draft PR. Do not merge or deploy.
# PR #89 V1.3 owner-rejection recovery (2026-08-11)

V1.2 was rejected for cross-fixture duplication, repeated Known past claims, an Unknown displayed-versus-omitted wording contradiction, and a malformed Known limitation card. V1.3 allocates evidence-led claims by horizon, qualifies Unknown omissions as Lagna/house-only, and uses full-width bordered disclaimer units. Status: **PENDING OWNER RE-ACCEPTANCE**. Earlier packets and `product-acceptance/` remain immutable; Round 9 remains historical completed evidence. No merge or deploy.
# V1.5 Thai narrative quality (Draft)

Owner rejected the narrative quality of live V1.4. Work is isolated on
`codex/thai-narrative-v1-5` from verified `origin/main` `22cbb3c`. The rejected
seven-page PDF identity is preserved in the new acceptance packet. Correctness
gate passed: `00:03` Chiang Mai legitimately produces Aquarius `9°24′`; the
accepted `19°19′` result used `00:35`. V1.5 introduces report-level claim
ownership, one forecast home per domain, a chart-specific opening, single
domain syntheses and prioritised advice. Owner Acceptance is pending. Do not
merge or deploy; V1.4 remains live.
# V1.5 R2 owner-rejection recovery (2026-08-12)

## Acceptance-evidence correction (2026-08-13)

The final R2 packet corrects the rendered-page count from 29 to 30 and rebuilds all five contact sheets from the final six-page renders. PDFs, narrative source and tests are unchanged. The exact focused command was rerun at 261 passed / 0 failed / exit 0. Final ZIP SHA-256: `610E69A38E2CA012BE4698E266E465EA8B17F44275761812050854A47F9B36CD`. PR #92 remains Draft; Owner Acceptance is pending; no merge/deploy; Production remains V1.4.

R1 owner acceptance is rejected. Its stale focused log contradicted the summary. R2 restores all four domains in all three horizons, adds evidence-signature Claim Ledger and a new acceptance packet. PR #92 remains Draft; owner acceptance is pending; no merge/deploy; Production remains V1.4.

# V1.5 R3 owner-acceptance recovery (2026-08-13)

`V1.5 R2 OWNER ACCEPTANCE REJECTED`. R3 replaces the block-level paraphrase path with an evidence-led report plan, opens Known/Unknown with a report-specific “ลายเซ็นของคำอ่าน”, separates horizon functions, removes system labels, and turns past biography-like assertions into cautious reflection. Final gates report 4×3 coverage, zero internal exact duplicates/callback-without-delta/system-language/unsupported-biography hits, and 0/26 exact strong-claim reuse across materially different fixtures. PR #92 stays Draft; no merge/deploy; Production remains V1.4.

# V1.5 Final Merge Gate rerun (2026-08-16)

The Owner-authorized exact-18 reconciliation is Case A: repaired actuals equal pinned-main goldens 18/18 by dimensions, SHA-256 and pixels; visual QA passes 18/18 and the targeted suite passes 24/24. The four-string Life Map repair passes 67/67 and matrix 864/864; R7 focused passes 286/286; synthetic remains 300/300 unique and deterministic; analyzer delta is 0; Web release build passes. Full branch 2,889/39 and pinned main 2,861/39 have the exact same 39 failure IDs (branch-only 0, main-only 0). Preserve R1-R7.1. Ready-for-review transition is allowed only after intentional commit/non-force push. Do not merge or deploy; Firebase unchanged; Production remains V1.4.
