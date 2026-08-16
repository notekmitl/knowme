# Thai Narrative V1.5 Golden Reconciliation and Final Merge Gate Rerun

**Gate result:** `PASS AGAINST PINNED MAIN BASELINE`  
**Decision:** `Case A — repaired actual is pixel-identical to pinned main for all 18 images`  
**Starting branch/remote HEAD:** `5b2e4cf84ed67f4b1cbe1e66ac296caa995ff3c7`  
**Pinned main:** `22cbb3cfcb583b63fe8d48a164d5083d9ee32163`  
**Toolchain:** Flutter 3.41.3 / Dart 3.11.1 / Windows x64

The authorized four-string Life Map compatibility repair changes only `life_map_semantic_mapper.dart` (4 additions / 4 deletions). Fresh repaired renders were first produced without `--update-goldens`. Each of the 18 repaired actuals has the same dimensions, SHA-256, and pixels as its pinned-main golden (pixel difference 0 and no changed bounding box). All 18 original-resolution images passed visual review. The 18 tracked goldens were therefore restored byte-for-byte from pinned main; no broad golden update was used.

## Golden reconciliation

| Check | Result |
|---|---|
| Failing IDs versus allowlist | 18/18 exact |
| Branch-vs-main changed golden paths versus allowlist | 18/18 exact |
| Fresh repaired actual versus pinned main | 18/18 pixel-identical; dimensions equal |
| Visual QA | 18/18 PASS |
| Targeted screenshot regression | 24/24 passed, exit 0 |
| Final changed golden scope | Exactly 18 allowlisted files |
| Other test/golden changes | 0 |
| `.failure` artifacts after verification | 0 |

The preflight found 42 ignored failure images left by the earlier blocked run. Before fresh rendering, those exact files were hash-preserved under `preflight-existing-failures/`; only those validated originals were removed from the harness failure directory. Fresh candidate output was then copied to `repaired-actual/`, compared, and reviewed. This preserves the inherited dirty-worktree evidence without allowing stale files to contaminate the rerun.

## Final gate commands and results

| Gate | Command | Raw exit | Result |
|---|---|---:|---|
| Candidate render | `flutter test --no-pub test/validation/thai_mirror_qa_harness/screenshot_regression_test.dart --reporter expanded` before reconciliation | 1 | Expected: 6 unaffected tests passed and the exact 18 allowlisted comparisons failed; actual images captured without updating goldens |
| Targeted golden verification | same command after Case A restoration | 0 | 24/24 passed |
| Life Map V1.2.6-V1.3.2 | `flutter test --no-pub test/validation/thai_beta/life_map/v126 .../v132 --reporter expanded` | 0 | 67/67 passed |
| 864 matrix | `flutter test --no-pub test/validation/thai_beta/life_map/v127/thai_life_map_v127_matrix_test.dart --reporter expanded` | 0 | 864/864 profiles; 108/108 for each weekday; 8/8 test cases |
| Original R7 focused runner | `pwsh -NoProfile -File tool/thai_narrative_r7_capture_tests.ps1 -OutputPath .../focused-test-result.txt` | 0 | 286/286 passed |
| Synthetic audit | `flutter test --no-pub test/validation/thai_beta/synthetic_audit/thai_beta_synthetic_audit_300_test.dart --reporter expanded` | 0 | 6/6 tests; 300 unique reports and narratives; determinism, fail-closed and parity checks passed |
| Scoped analyzer | `pwsh -NoProfile -File tool/thai_narrative_r7_capture_analyzer.ps1 -OutputPath .../scoped-analyzer-result.txt` | 0 | No issues found |
| Full branch analyzer | `flutter analyze --no-pub` | 1 | 299 repository diagnostics |
| Full pinned-main analyzer | same command in detached `22cbb3c` worktree | 1 | 299 repository diagnostics |
| Normalized analyzer comparison | severity/message/path/line/column/code set comparison | 0 | branch-only 0; main-only 0 |
| Web release build | `flutter build web --release --no-pub` | 0 | `build/web` built; not deployed |
| Full branch suite | `flutter test --no-pub --reporter expanded` | 1 | 2,889 passed / 39 failed |
| Full pinned-main suite | same command in detached `22cbb3c` worktree | 1 | 2,861 passed / 39 failed |
| Failure-ID comparison | test path + description set comparison | 0 | common 39; branch-only 0; main-only 0; Life Map V1.2.6-V1.3.2 failures 0 |
| R7.1 identity and acceptance regression | read-only ZIP, checksum, immutable, canonical, facts and traceability verifier | 0 | PASS |

The two raw full suites correctly exit 1 because the repository has 39 pinned-main failures. The owner-authorized gate passes because the branch and pinned main have the exact same 39 failure IDs. The 39-item baseline debt is retained verbatim in `full-test-delta-result.txt`; no test, expectation, threshold, tolerance, fixture, or allowlist was weakened.

## Acceptance preservation

- R7.1 ZIP: 10,709,328 bytes, 80 entries, SHA-256 `9E541F21C68FDAD93BC595C55BD0BE23600F88454CFBA7FAB6C713FE53F79E58`.
- ZIP checksums 79/79 and folder checksums 79/79; zero mismatch and zero unsafe ZIP entry.
- R7-to-R7.1 immutable comparison: 63/63, mismatch 0.
- R1-R7.1 modified paths: 0.
- Canonical Web/PDF parity: 5/5.
- Claim traceability: 170/170.
- Owner Known: Aquarius 19°19′; regression 00:03: Aquarius 9°24′.
- Unknown remains fail-closed with no Lagna claim.
- R7/R7.1 Owner and Product Acceptance remain valid.

## Evidence map

- `golden-allowlist.txt`: exact 18 paths.
- `main-branch-repaired-sha256-manifest.tsv`: dimensions and identities for all three image sources.
- `pixel-comparison-metrics.json` / `.md`: exact pixels, percentages and bounding boxes.
- `visual-review-table.md`: 18 original-resolution verdicts.
- `contact-sheets/`, `triptychs/`, `diff-actual-vs-main/`, `diff-actual-vs-branch/`: visual evidence.
- `candidate-render-test-log.txt` and `targeted-golden-test-result.txt`: raw screenshot test logs.
- `life-map-isolated-result.txt`, `matrix-864-result.txt`, `focused-test-result.txt`, `synthetic-result.txt`: focused raw logs.
- `full-test-branch-result.txt`, `full-test-main-result.txt`, `full-test-delta-result.txt`: complete suites and deterministic comparison.
- `scoped-analyzer-result.txt`, `full-analyzer-branch-result.txt`, `full-analyzer-main-result.txt`, `analyzer-delta-result.txt`: analyzer evidence.
- `web-release-build-result.txt`: production-equivalent build evidence.
- `acceptance-identity-result.txt`: immutable package and acceptance regression evidence.
- `git-scope-validation.txt`: authorized diff scope.

No merge, deployment, Firebase change, or Production change was performed. Production remains V1.4.
