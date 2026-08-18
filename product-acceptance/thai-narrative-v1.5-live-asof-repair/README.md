# V1.5 live as-of contract repair evidence

Status: **COPY SEMANTIC SAFETY VERIFIED** against pinned main `075ddfc6eeb8fbe4e3a0aaade9c4c2d5711340b9`; PR #95 may proceed to Ready for review, but is not merged or deployed. Production remains V1.4 Hosting version `10af10c6d960d590`.

The Owner authorization for this repair was narrow: replace only two stale broad-normalization expectations in `thai_beta_copy_normalization_scope_test.dart`. The test file was retained, no test was skipped or suppressed, and its replacement contract exercises fresh pipeline output across all 300 corpus profiles. Broad reader-visible normalization is no longer accepted product behavior.

## Finding

The initial `asOf` hypothesis was disproved. Clock A (`2026-08-07`) and Clock B (the narrowest evidenced Production interval on `2026-08-16`) produced the same accepted canonical output in the Dart VM. The exact rollback Production mismatch was reproduced by the pre-repair compiled Web application with the same source and fixture. The cause was release-visible selection logic based on runtime-dependent `String.hashCode` and `Object.hash`, whose values are not stable between the Dart VM and compiled JavaScript.

The repair replaces those selection inputs with the Dart 3.11 VM-compatible stable string hash, normalizes two equivalent structured opportunity forms to the already accepted cautious sentence, and makes the submit-time `asOf` contract explicit. S008 then exposed a one-ULP raw ascendant double at the snapshot/hash/seed boundary. The final repair keeps the engine raw double intact and uses a shared 1e9-unit fixed-point degree only for snapshot/hash/research equivalence. `startedAt` remains the session-duration clock. Web and PDF reuse the one computed analysis/document and never read the clock during export.

## Gate summary

### Final cross-runtime gate

- VM run 1/run 2: 300/300 each; nondeterminism 0.
- Chrome run 1/run 2: 300/300 each; nondeterminism 0.
- VM versus Chrome: canonical degree 0, profile 0, structured 0, period score 0, report/content hash 0, canonical text 0, narrative 0, Unknown omission 0 and copy-normalization impact 0.
- S008 raw audit remains disclosed: `102.39560244592322` in VM and `102.39560244592323` in Chrome. Both canonicalize to exact integer `102395602446`; snapshot, report hash, narrative and canonical text identities are exact.
- Stable-hash and exact-integer vectors match 100% between VM and Chrome.
- Canonical five: frozen accepted exact 5/5; cross-runtime frozen/live/repeat/Web-PDF exact 5/5.
- The former broad normalization would have affected 93/300 profiles and 112 `summary` fields. It is removed from the reader-visible pipeline. Fresh output has exact reader-visible delta 0, omission 0, addition 0 and prediction-to-advice transformation 0 against the accepted baseline.
- The `owner-unknown` canonical text remains exact without a profile/case exception. Known and Unknown use the same semantic-source rule.
- The mandatory gate passes. Every `copy-semantic-final-*` focused/full-suite/analyzer/build result below is a fresh post-test-migration run; earlier diagnostic attempts remain preserved and are not reused as final evidence.

| Gate | Final result |
|---|---|
| Final copy-contract focused scope | 6/6 passed |
| Frozen canonical parity | exact 5/5 at explicit `2026-08-07` |
| Live oracle parity | Web/PDF exact 5/5 at explicit `2026-08-16T16:19:44.454535` Asia/Bangkok civil time; repeat exact 5/5 |
| Targeted screenshots | 24/24 |
| Life Map V1.2.6-V1.3.2 | 67/67 |
| Matrix | 864/864; each weekday 108/108 |
| Original R7 focused runner | 286/286 |
| Synthetic audit | 300 unique reports / 300 unique narratives; deterministic |
| Scoped analyzer | 5 changed/new Dart files; no issues |
| Full analyzer | branch 299 / exact main 299 / normalized delta 0 |
| Full repository suite | branch 2,914 passed / 39 failed; main 2,889 passed / 39 failed; common failure IDs 39; branch-only 0; main-only 0 |
| Web release build | success; no deploy |
| R7.1 identity | 10,709,328 bytes; 80 ZIP entries; SHA-256 `9E541F21C68FDAD93BC595C55BD0BE23600F88454CFBA7FAB6C713FE53F79E58`; checksums 79/79; R7 immutable 63/63 |
| Acceptance invariants | Aquarius 19°19′; regression 00:03 Aquarius 9°24′; Unknown fail-closed; traceability 170/170 |
| Live PDF visual QA | 34/34 pages; no blank/footer-only page, clipping, overlap, truncation, broken wrapping, or border escape |

The 39 full-suite failures are the exact pinned-main baseline set. They are disclosed debt, not branch regressions.

## Evidence map

- `root-cause.md`: causal conclusion and compiled-Web proof.
- `code-path.md`: `startedAt → asOf → pipeline → presenter → Web/PDF` path.
- `clock-matrix.md`: Clock A/B/C behavior and evidence window.
- `timezone-resolution.md`: Bangkok civil-time contract.
- `structured-material-comparison.md`: time/material comparison and runtime selection trace.
- `canonical-diffs.md`: exact accepted/Production phrases and hashes.
- `release-contract.md`: frozen and live Production verification rules.
- `test-summary.md`: commands and final counts.
- `hash-usage-audit.md`: complete finding classification.
- `stable-hash-spec.md` and `integer-arithmetic-audit.md`: owned algorithm and exact arithmetic contract.
- `s008-canonicalization-repair.md`: exact S008 causal path, numeric contract and final identities.
- `copy-semantic-safety-final-repair.md`: final semantic-source repair, audit conclusions and current product contract.
- `copy-semantic-test-contract-migration.md`: exact scope and rationale of the Owner-authorized two-test migration.
- `copy-normalization-owner-review-s008.md` and its JSON ledger: preserved 112-field pre-repair review scope, now superseded by zero-delta final output.
- `visual-qa.md`: all-page inspection result.
- `acceptance-identity-result.txt`: fresh ZIP/checksum/immutable/acceptance identity verification.
- `full-test-delta-result.txt` and `analyzer-delta-result.txt`: normalized branch/main comparisons.
- `live-oracle/`: five live-date PDFs and exact Web/PDF texts.
- `live-oracle-renders/`: all 34 rendered pages and five contact sheets.
- Raw UTF-8 logs are retained alongside these reports. Earlier failed diagnostic attempts are retained and are not represented as passing evidence.

No Firebase deploy, merge, accepted artifact rewrite, golden update, expected-output update, or Production change occurred. R1–R7.1 are unchanged. Technical and copy-semantic gates are verified; this evidence authorizes only moving PR #95 to Ready for review, not merging or deploying it.
