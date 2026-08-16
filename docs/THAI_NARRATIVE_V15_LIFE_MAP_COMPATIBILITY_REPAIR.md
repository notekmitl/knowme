# Thai Narrative V1.5 Life Map Compatibility Repair

**Live as-of repair update:** The Life Map compatibility repair and accepted R7/R7.1 output remain immutable. Root-cause work after the Production rollback proved the text mismatch came from VM/Web runtime hash selection, not a Life Map or `asOf` boundary. The Draft repair stabilizes reader-visible hashing and records submit-time Bangkok `analysis.asOf`; Life Map still passes 67/67 and 864/864 with every weekday 108/108, Owner Known remains Aquarius 19°19′ and regression 00:03 remains Aquarius 9°24′. Full branch and exact main retain the same 39 failure IDs with branch-only 0. No Life Map golden, accepted PDF/render or R1–R7.1 artifact changed. No merge/deploy is authorized; Production remains V1.4.

**Production release update:** The compatibility repair and R7/R7.1 acceptance remain immutable, but the 2026-08-16 Hosting-only Production release failed exact canonical replay on the first real `owner-known-0035` PDF. Release `1786871603892000` / version `a5721c17f758aa6d` was rolled back to V1.4 version `10af10c6d960d590` as release `1786872330369000` at `2026-08-16T09:25:30.369Z`. Production is V1.4. Hosting baseline identity and browser smoke pass after rollback. The 39 common baseline failures remain disclosed, and no Life Map source/test/golden or R1–R7.1 artifact changed. Evidence is under `product-acceptance/thai-narrative-v1.5-production-release/`.

**Historical post-merge status before Production release:** PR #92 was merged to `main` as regular merge commit `a574fcb65437013e98c64b1fc9af19f50723534b` from accepted source HEAD `e8cc382fa950e581b4da5ec0ff6b93202a1cd4ee`. The Final Merge Gate passed against pinned main `22cbb3cfcb583b63fe8d48a164d5083d9ee32163`; the 39 common baseline failures remain disclosed and unchanged. R7/R7.1 acceptance and immutable identities remain intact. At this historical checkpoint no deployment or Firebase change had occurred; Production remained V1.4 and Production Release required separate Owner authorization.

**Status:** `FINAL MERGE GATE PASSED AGAINST PINNED MAIN BASELINE`

**Starting HEAD:** `5b2e4cf84ed67f4b1cbe1e66ac296caa995ff3c7`

**Pinned main:** `22cbb3cfcb583b63fe8d48a164d5083d9ee32163`

The Owner-authorized repair restores exactly four Life Map `_TextId` strings (`prs_love`, `sit_home`, `prs_learn`, `sit_opp`) to the frozen V1.2.6-V1.3.2 product language. The product-code diff is limited to `life_map_semantic_mapper.dart` with 4 additions and 4 deletions. No test, threshold, tolerance, allowlist, fixture, narrative composer, astrology engine, canonical Web/PDF text, PDF, accepted render, or R1-R7.1 artifact was changed.

The repair removes all 14 original branch-only Life Map failures. The isolated scope passes 67/67; the 864-profile matrix passes 864/864 and every weekday passes 108/108. R7 focused tests pass 286/286; synthetic output remains 300 unique reports and 300 unique narratives; determinism and Unknown fail-closed checks pass. Scoped analyzer is clean, full analyzer is 299 branch / 299 pinned main / delta 0, and the Web release build succeeds without deployment.

## Controlled golden reconciliation

Fresh actuals were rendered without `--update-goldens` for the exact Owner allowlist of 18 Life Timeline screenshots: profiles A/D/E/F/G/H at desktop/tablet/mobile. All repaired actuals match the pinned-main dimensions and pixels exactly (18/18, pixel difference 0). Original-resolution visual review passes 18/18 with no clipping, overflow, overlap, missing content, abnormal blank region, or responsive defect.

This is **Case A**. The exact 18 tracked goldens were restored byte-for-byte from pinned main and their SHA-256 values match 18/18. No other golden or test file changed. The targeted screenshot regression then passed 24/24 and no `.failure` artifact remained.

## Final baseline gate

The complete branch suite reports 2,889 passed / 39 failed; the isolated pinned-main suite reports 2,861 passed / 39 failed. Their exact failure-ID sets match: common 39, branch-only 0, main-only 0. The known 39-item baseline debt remains visible and was neither fixed nor hidden in this PR. The gate therefore passes under the Owner-authorized pinned-main criterion despite both raw suite commands exiting 1.

R7/R7.1 acceptance remains valid and immutable. The R7.1 ZIP is 10,709,328 bytes / 80 entries / SHA-256 `9E541F21C68FDAD93BC595C55BD0BE23600F88454CFBA7FAB6C713FE53F79E58`; checksums pass 79/79, immutable comparison passes 63/63 with mismatch 0, canonical parity is 5/5, claim traceability is 170/170, Owner Known remains Aquarius 19°19′, regression 00:03 remains Aquarius 9°24′, and Unknown remains fail-closed.

Evidence is in `product-acceptance/thai-narrative-v1.5-final-merge-gate-golden-rerun/`. PR #92 may move to Ready for Review after the evidence commit and non-force push. This task does not authorize merge or deployment. Firebase was not changed; Production remains V1.4.
