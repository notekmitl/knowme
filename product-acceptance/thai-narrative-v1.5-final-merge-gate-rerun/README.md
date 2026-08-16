# Thai Narrative V1.5 Final Merge Gate Rerun

**Status:** `BLOCKED`  
**Starting branch HEAD:** `5b2e4cf84ed67f4b1cbe1e66ac296caa995ff3c7`  
**Main baseline:** `22cbb3cfcb583b63fe8d48a164d5083d9ee32163`  
**Toolchain:** Flutter 3.41.3, Dart 3.11.1, Windows x64

The authorized compatibility repair restores exactly four `_TextId` strings in `life_map_semantic_mapper.dart`. No test, threshold, allow-list, fixture, canonical Web/PDF text, PDF, render, R1-R7.1 artifact, Firebase resource, or Production resource was changed.

## Gate results

| Gate | Command | Exit | Result |
|---|---|---:|---|
| Life Map V1.2.6-V1.3.2 isolated scope | `flutter test --no-pub test/validation/thai_beta/life_map/v126 test/validation/thai_beta/life_map/v127 test/validation/thai_beta/life_map/v128 test/validation/thai_beta/life_map/v129 test/validation/thai_beta/life_map/v130 test/validation/thai_beta/life_map/v131 test/validation/thai_beta/life_map/v132 --reporter expanded` | 0 | 67/67 passed; prior 14 failures removed |
| V1.2.7 matrix | `flutter test --no-pub test/validation/thai_beta/life_map/v127/thai_life_map_v127_matrix_test.dart --reporter expanded` | 0 | 864/864 profiles; 108/108 per weekday; 8/8 test cases |
| Original R7 focused scope | `pwsh -NoProfile -File tool/thai_narrative_r7_capture_tests.ps1 -OutputPath .../focused-test-result.txt` | 0 | 286/286 passed |
| Synthetic 300 | `flutter test --no-pub test/validation/thai_beta/synthetic_audit/thai_beta_synthetic_audit_300_test.dart --reporter expanded` | 0 | 6/6 tests; 300 unique reports and 300 unique narratives; deterministic and fail-closed contracts passed |
| Scoped analyzer | `pwsh -NoProfile -File tool/thai_narrative_r7_capture_analyzer.ps1 -OutputPath .../scoped-analyzer-result.txt` | 0 | No issues found |
| Full branch analyzer | `flutter analyze --no-pub` | 1 | 299 repository diagnostics |
| Full main analyzer | `flutter analyze --no-pub` | 1 | 299 repository diagnostics |
| Normalized analyzer delta | deterministic severity/message/path/line/code comparison | 0 | branch-only 0; main-only 0 |
| Web release build | `flutter build web --release --no-pub` | 0 | Built `build/web`; not deployed |
| Full branch suite | `flutter test --no-pub --reporter expanded` | 1 | 2,871 passed / 57 failed |
| Full main suite | `flutter test --no-pub --reporter expanded` | 1 | 2,861 passed / 39 failed |
| Failure-set delta | deterministic test path + description comparison | 1 | common 39; branch-only 18; main-only 0; Life Map V1.2.6-V1.3.2 failures 0 |
| R7.1 identity and acceptance preservation | read-only ZIP, checksum, immutable-file, canonical-pair and evidence verification | 0 | PASS |

## Blocking result

The original 14 Life Map contract failures are fixed, but the full-suite gate is still blocked. All 18 new branch-only failures are `screenshot_regression_test.dart` Life Timeline goldens for profiles A, D, E, F, G and H at desktop, tablet and mobile widths. Those exact 18 golden PNGs differ between the branch and main, and the old gate had zero screenshot branch-only failures. Restoring the authorized Life Map copy therefore invalidates the branch's existing V1.5 Life Timeline golden baselines.

This task prohibits test or golden changes. The next repair requires separate Owner authorization to regenerate and visually review only those 18 golden PNGs against the approved four-string restoration, followed by the entire gate again. PR #92 must remain Open Draft and unmerged.

## Preserved acceptance identities

- R7.1 ZIP: 10,709,328 bytes, 80 entries, SHA-256 `9E541F21C68FDAD93BC595C55BD0BE23600F88454CFBA7FAB6C713FE53F79E58`.
- ZIP checksums: 79/79; staging-folder checksums: 79/79.
- R7-to-R7.1 immutable comparison: 63/63, mismatch 0.
- Canonical Web/PDF byte parity: 5/5.
- Owner Known: Aquarius 19°19′; regression 00:03: Aquarius 9°24′.
- Unknown remains fail-closed; claim traceability remains 170/170.
- R1-R7.1 were not modified.

## Not performed

- No PDF, render, canonical text, or acceptance artifact generation.
- No test or golden update.
- No commit, push, Draft-to-Ready transition, merge, deployment, Firebase, or Production change because the mandatory gate is blocked.
- Production remains V1.4.
