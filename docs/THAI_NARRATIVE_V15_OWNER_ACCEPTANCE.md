# Thai Narrative V1.5 Owner Acceptance

**Decision date:** 2026-08-16  
**PR:** `notekmitl/knowme#92`  
**Accepted source HEAD:** `a6eb5fa02d48dabce5ff809f90abc88b658c5dfc`

## Authoritative owner decision

- `V1.5 R7.1 OWNER ACCEPTANCE PASSED`
- `V1.5 PRODUCT ACCEPTANCE PASSED`
- R7 narrative is accepted for text and visual quality.
- R7.1 evidence is accepted for encoding, accuracy, and identity preservation.
- No further narrative or acceptance-package work is requested.
- R1 through R7.1 artifacts are immutable.

The accepted R7.1 ZIP is `product-acceptance/thai-narrative-v1.5-r7.1.zip`: 10,709,328 bytes, 80 entries, SHA-256 `9E541F21C68FDAD93BC595C55BD0BE23600F88454CFBA7FAB6C713FE53F79E58`, with 79/79 checksums verified. The R7-to-R7.1 immutable comparison covers 63 files with mismatch 0.

## Final Merge Gate status

### Life Map compatibility rerun

The Owner-authorized restoration of four Life Map copy strings fixes all 14 original Life Map failures without touching tests or R7.1. Isolated Life Map passes 67/67, matrix passes 864/864 with 108/108 for each weekday, focused passes 286/286, synthetic remains 300/300 unique, analyzer delta is 0, and Web build passes. The full suite remains **BLOCKED**: branch is 2,871 passed / 57 failed versus main 2,861 / 39, with 39 common failures, 18 branch-only and 0 main-only. All 18 branch-only failures are Life Timeline golden screenshots for profiles A/D/E/F/G/H at desktop/tablet/mobile; no Life Map V1.2.6-V1.3.2 test now fails. Tests and goldens were not changed because that is outside this authorization. PR #92 remains Draft and unmerged; Production remains V1.4.

Owner Acceptance remains fully valid. R7.1 ZIP, checksums, 63-file immutable comparison, five canonical pairs, PDFs and renders are unchanged. Evidence for this blocked rerun is in `product-acceptance/thai-narrative-v1.5-final-merge-gate-rerun/`.

Owner acceptance does not waive the full-suite gate. The Final Merge Gate run at the accepted source HEAD is **BLOCKED**:

- Original R7 focused suite: 286 passed, 0 failed, exit 0.
- Full branch suite: 2,875 passed, 53 failed, exit 1.
- `origin/main` diagnostic comparison: 2,861 passed, 39 failed; the branch has 14 additional Life Map failures across V1.2.6-V1.3.2. An isolated rerun reproduced 53 passed / 14 failed.
- Scoped analyzer: no issues, exit 0.
- Full analyzer: branch 299 diagnostics, main 299 diagnostics, deterministic delta 0.
- Production-equivalent Web release build: exit 0; no deployment was performed.
- Aquarius 19°19′, Aquarius 9°24′, Unknown fail-closed behavior, canonical parity 5/5, claim traceability 170/170, and R7.1 identities remain preserved.

The 14 branch-only failures indicate that accepted V1.5 narrative output conflicts with historical Life Map V1.2.6-V1.3.2 copy/policy assertions. A separate owner-authorized repair must decide whether implementation or the historical specification is authoritative; tests must not be weakened merely to obtain a pass. Because the mandatory full suite is not green, PR #92 must remain Draft and must not be merged or deployed.

Raw evidence is in `product-acceptance/thai-narrative-v1.5-final-merge-gate/`.

Production remains V1.4. This task did not merge, deploy, modify Firebase, or change Production.

## Controlled golden reconciliation and final rerun

This section supersedes the two historical blocked gate records above. Owner Acceptance remains unchanged: R7 narrative and R7.1 evidence are accepted, and V1.5 Product Acceptance has passed.

The exact 18 Owner-authorized Life Timeline screenshots were rendered fresh without bulk golden updates. Every repaired actual equals pinned main `22cbb3cfcb583b63fe8d48a164d5083d9ee32163` by dimensions and pixels (18/18, difference 0), and original-resolution visual QA passes 18/18. Case A restored only those 18 tracked goldens byte-for-byte from main; the targeted screenshot suite passes 24/24 and no other test or golden changed.

The complete fresh gate now passes against the pinned main baseline: Life Map 67/67; matrix 864/864 and weekday 108/108; R7 focused 286/286; synthetic 300 unique reports / 300 unique narratives with determinism and fail-closed contracts; scoped analyzer clean; full analyzer 299 branch / 299 main / delta 0; Web release build successful. Full branch is 2,889 passed / 39 failed and main is 2,861 passed / 39 failed, with exact failure IDs common 39, branch-only 0 and main-only 0. The 39 baseline failures remain disclosed and unmodified.

R7.1 identity re-verification passes: ZIP 10,709,328 bytes / 80 entries / SHA-256 `9E541F21C68FDAD93BC595C55BD0BE23600F88454CFBA7FAB6C713FE53F79E58`; checksums 79/79; immutable comparison 63/63, mismatch 0; canonical parity 5/5; claim traceability 170/170; Owner Known Aquarius 19°19′; regression 00:03 Aquarius 9°24′; Unknown fail-closed. R1-R7.1 modified paths remain 0.

PR #92 may be marked Ready for Review after intentional commit and non-force push. Merge and deploy still require separate explicit Owner authorization. Firebase and Production were not changed; Production remains V1.4.
