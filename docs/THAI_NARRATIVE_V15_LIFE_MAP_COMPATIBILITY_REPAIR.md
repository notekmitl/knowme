# Thai Narrative V1.5 Life Map Compatibility Repair

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
