# Verification summary

Pinned toolchain: Flutter 3.41.1 / Dart 3.11.0.

## S008 final cross-runtime result — passed

| Scope | Fresh final result | Raw evidence |
|---|---:|---|
| Stable hash/fixed-degree vectors | VM = Chrome, mismatch 0 | `stable-hash-vectors-*-s008-final.json`, `canonical-degree-vectors-*-s008-final.json` |
| VM manifests | 300/300 × 2; nondeterminism 0 | `cross-runtime-300-vm-run-*-s008-final.json` |
| Real Chrome manifests | 300/300 × 2; nondeterminism 0 | `cross-runtime-300-chrome-run-*-s008-final.json` |
| VM vs Chrome | raw finding 1 (S008 one ULP); every canonical/profile/structured/score/report/text/narrative/omission/copy mismatch 0 | `cross-runtime-300-delta-s008-final.json` |
| S008 canonical identity | units `102395602446`; snapshot/hash/narrative exact | `s008-canonicalization-repair.md` |
| Canonical five | frozen/live/repeat/Web-PDF exact 5/5 | `cross-runtime-canonical-delta-s008-final.json` |
| Copy normalization | retained; 93 profiles / 112 `summary` fields; pending Owner review | `copy-normalization-owner-review-s008.md`, `copy-normalization-owner-review-ledger-s008.json` |
| Clock/canonical/frozen/live focused | 20/20, exit 0 | `s008-final-clock-canonical-focused-result.txt` |
| Changed/new Dart analyzer | 28 items; same 5 warnings + 1 info as prior scope; no new diagnostic class | `s008-final-scoped-analyzer-result.txt` |

All results below were rerun fresh after the final S008 repair and the narrow finance semantic-classifier correction.

| Command/scope | Result | Raw evidence |
|---|---:|---|
| Targeted screenshot regression | 24/24 | `s008-final-screenshot-result.txt` |
| Life Map V1.2.6–V1.3.2 | 67/67 | `s008-final-life-map-result.txt` |
| V1.2.7 matrix | 864/864; 108/108 each weekday | `s008-final-matrix-864-result.txt` |
| Original R7 focused runner | first run 283/286 exposed classifier false negatives; narrow correction; rerun 286/286 | `s008-final-r7-focused-test-result.txt`, `s008-final-r7-focused-test-rerun-result.txt` |
| Synthetic 300 audit | 300 reports / 300 narratives unique; deterministic | `s008-final-synthetic-300-result.txt` |
| Full analyzer branch/main | 299 / 299; diagnostic-identity delta 0 | `s008-final-full-analyzer-*-result.txt`, `s008-final-analyzer-delta-result.txt` |
| Full branch/main tests | 2,910/39 vs 2,889/39; common failures 39; branch-only 0; main-only 0 | `s008-final-full-test-*-result.txt`, `s008-final-full-test-delta-result.txt` |
| Web release build | success; no deploy | `s008-final-web-release-build-result.txt` |
| R7.1 identities | ZIP 10,709,328 bytes / 80 entries; checksums 79/79; immutable archive comparison 63/63; modified paths 0; PASS | `s008-final-r71-identity-archive-result.txt` |

The full-suite process exits nonzero on both revisions because both contain the same 39 baseline failures. The deterministic failure-ID comparison is the release gate; no baseline test was changed or hidden.
