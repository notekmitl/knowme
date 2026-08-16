# Verification summary

Pinned toolchain: Flutter 3.41.1 / Dart 3.11.0.

| Command/scope | Result | Raw evidence |
|---|---:|---|
| New `test/validation/thai_beta/live_asof` diagnostics/contracts plus explicit oracle | 11 passed | `live-asof-contract-test-result.txt`, `date-aware-contract-test-result.txt`, `live-oracle-test-result.txt` |
| Targeted screenshot regression | 24/24 | `targeted-screenshot-result.txt` |
| Life Map V1.2.6–V1.3.2 | 67/67 | `life-map-isolated-result.txt` |
| V1.2.7 matrix | 864/864; 108/108 each weekday | `matrix-864-result.txt` |
| Original R7 focused runner | 286/286 | `r7-focused-test-result.txt` |
| Synthetic 300 audit | 300 reports / 300 narratives unique; deterministic | `synthetic-300-result.txt` |
| Original R7 scoped analyzer | 0 issues | `r7-scoped-analyzer-result.txt` |
| New contract scoped analyzer | 0 issues | `new-contract-analyzer-result.txt` |
| Broad changed legacy files analyzer | six existing warnings in `thai_mirror_consumer_copy.dart`; no new warning class | `changed-files-analyzer-result.txt` |
| Full analyzer branch/main | 299 / 299; normalized delta 0 | `full-analyzer-*-result.txt`, `analyzer-delta-result.txt` |
| Full branch/main tests | 2,899/39 vs 2,889/39; common failures 39; branch-only 0; main-only 0 | `full-test-*-result.txt`, `full-test-delta-result.txt` |
| Web release build | success | `web-release-build-result.txt` |
| R7.1 identities | PASS | `acceptance-identity-result.txt` |

The full-suite process exits nonzero on both revisions because both contain the same 39 baseline failures. The deterministic failure-ID comparison is the release gate; no baseline test was changed or hidden.
