# V1.5 live as-of contract repair evidence

Status: verified locally from base `075ddfc6eeb8fbe4e3a0aaade9c4c2d5711340b9`; Draft PR only; not merged; not deployed. Production remains V1.4.

## Finding

The initial `asOf` hypothesis was disproved. Clock A (`2026-08-07`) and Clock B (the narrowest evidenced Production interval on `2026-08-16`) produced the same accepted canonical output in the Dart VM. The exact rollback Production mismatch was reproduced by the pre-repair compiled Web application with the same source and fixture. The cause was release-visible selection logic based on runtime-dependent `String.hashCode` and `Object.hash`, whose values are not stable between the Dart VM and compiled JavaScript.

The repair replaces those selection inputs with the Dart 3.11 VM-compatible stable string hash, normalizes two equivalent structured opportunity forms to the already accepted cautious sentence, and makes the submit-time `asOf` contract explicit. `startedAt` remains the session-duration clock. Web and PDF reuse the one computed analysis/document and never read the clock during export.

## Gate summary

| Gate | Final result |
|---|---|
| New root-cause/date contract | 11/11 passed (10 non-oracle + 1 live-oracle test; form clock file 7/7) |
| Frozen canonical parity | exact 5/5 at explicit `2026-08-07` |
| Live oracle parity | Web/PDF exact 5/5 at explicit `2026-08-16T16:19:44.454535` Asia/Bangkok civil time; repeat exact 5/5 |
| Targeted screenshots | 24/24 |
| Life Map V1.2.6-V1.3.2 | 67/67 |
| Matrix | 864/864; each weekday 108/108 |
| Original R7 focused runner | 286/286 |
| Synthetic audit | 300 unique reports / 300 unique narratives; deterministic |
| Scoped analyzers | original R7 scope 0 issues; new contract scope 0 issues |
| Full analyzer | branch 299 / exact main 299 / normalized delta 0 |
| Full repository suite | branch 2,899 passed / 39 failed; main 2,889 / 39; common failure IDs 39; branch-only 0; main-only 0 |
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
- `visual-qa.md`: all-page inspection result.
- `acceptance-identity-result.txt`: fresh ZIP/checksum/immutable/acceptance identity verification.
- `full-test-delta-result.txt` and `analyzer-delta-result.txt`: normalized branch/main comparisons.
- `live-oracle/`: five live-date PDFs and exact Web/PDF texts.
- `live-oracle-renders/`: all 34 rendered pages and five contact sheets.
- Raw UTF-8 logs are retained alongside these reports. Earlier failed diagnostic attempts are retained and are not represented as passing evidence.

No Firebase deploy, merge, accepted artifact rewrite, golden update, or Production change occurred.
