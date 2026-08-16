# Thai Narrative V1.5 Final Merge Gate

**Status:** `BLOCKED`  
**Gate source HEAD:** `a6eb5fa02d48dabce5ff809f90abc88b658c5dfc`  
**Analyzer/test baseline:** `origin/main` `22cbb3cfcb583b63fe8d48a164d5083d9ee32163`  
**Toolchain:** Flutter 3.41.3, Dart 3.11.1, Windows x64

Owner acceptance is authoritative: `V1.5 R7.1 OWNER ACCEPTANCE PASSED` and `V1.5 PRODUCT ACCEPTANCE PASSED`. This gate does not alter R1-R7.1, product code, tests, canonical text, PDFs, renders, Firebase, or Production.

## Commands and results

| Gate | Actual command | Exit | Result |
|---|---|---:|---|
| Original R7 focused scope | `pwsh -NoProfile -File tool/thai_narrative_r7_capture_tests.ps1 -OutputPath product-acceptance/thai-narrative-v1.5-final-merge-gate/focused-test-result.txt` (runs `flutter test --no-pub test/validation/thai_beta/narrative test/validation/thai_beta/core_reading test/validation/thai_beta/thai_beta_report_export_test.dart test/validation/thai_beta/synthetic_audit/thai_beta_synthetic_audit_300_test.dart --reporter expanded`) | 0 | 286 passed / 0 failed |
| Full branch suite | `flutter test --no-pub --reporter expanded` | 1 | 2,875 passed / 53 failed — BLOCKED |
| Full main baseline, diagnostic only | `flutter test --no-pub --reporter expanded` | 1 | 2,861 passed / 39 failed |
| Isolated branch-only Life Map scope | `flutter test --no-pub test/validation/thai_beta/life_map/v126 test/validation/thai_beta/life_map/v127 test/validation/thai_beta/life_map/v128 test/validation/thai_beta/life_map/v129 test/validation/thai_beta/life_map/v130 test/validation/thai_beta/life_map/v131 test/validation/thai_beta/life_map/v132 --reporter expanded` | 1 | 53 passed / 14 failed; reproduces every branch-only failure |
| Original scoped analyzer | `pwsh -NoProfile -File tool/thai_narrative_r7_capture_analyzer.ps1 -OutputPath product-acceptance/thai-narrative-v1.5-final-merge-gate/scoped-analyzer-result.txt` | 0 | No issues found |
| Full branch analyzer | `flutter analyze --no-pub` | 1 | 299 repository diagnostics |
| Full main analyzer | `flutter analyze --no-pub` | 1 | 299 repository diagnostics |
| Analyzer delta | deterministic normalized diagnostic comparison | 0 | branch-only 0; main-only 0 |
| Web release build | `flutter build web --release --no-pub` | 0 | built `build/web`; no deploy |
| R7.1 strict UTF-8 validation | `pwsh -NoProfile -File tool/thai_narrative_r7_1_validate_utf8.ps1 -Root product-acceptance/thai-narrative-v1.5-r7.1 -ReportPath product-acceptance/thai-narrative-v1.5-final-merge-gate/r7.1-utf8-validation-result.json -RequireIdentityTargets` | 0 | 36 files; all finding counts 0 |

## Required acceptance preservation

- Owner Known remains Aquarius 19°19′.
- Regression 00:03 remains Aquarius 9°24′.
- Unknown time remains fail-closed.
- Accepted Web/PDF canonical parity remains 5/5.
- Accepted claim traceability remains 170/170.
- R7.1 ZIP remains 10,709,328 bytes, 80 entries, SHA-256 `9E541F21C68FDAD93BC595C55BD0BE23600F88454CFBA7FAB6C713FE53F79E58`.
- R7-to-R7.1 immutable comparison remains 63 files with mismatch 0; 79/79 package checksums pass.

These claims are supported by the fresh focused test log plus read-only identity and checksum verification of the accepted artifacts. PDFs and renders were not regenerated because this task explicitly prohibits doing so.

## Blocking result and repair boundary

The branch has the same 39 broad failures already present on `origin/main`, plus 14 branch-only failures in Life Map V1.2.6-V1.3.2 copy/policy assertions. The isolated run reproduces those 14 failures, including the 864-profile matrix dropping to 48 passing cases for at least one weekday category and historical copy gates rejecting accepted V1.5 phrases.

No product repair was attempted. A separate owner-authorized task must decide whether the accepted V1.5 implementation or the historical Life Map specification is authoritative, make the corresponding product/specification repair without weakening tests merely to pass, and rerun the complete Final Merge Gate. The current mandatory full suite is not green, so PR #92 must remain Draft and unmerged.

## Not run or changed

- No PDF or render generation.
- No golden update.
- No merge, deploy, Firebase, or Production action.
- No product code, composer, engine, canonical text, or test edit.
- Production remains V1.4.
