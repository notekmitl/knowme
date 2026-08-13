# Task: Thai Report Reading Flow and Friendly Voice V1

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
