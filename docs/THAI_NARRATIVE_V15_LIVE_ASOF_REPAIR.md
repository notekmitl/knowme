# Thai Narrative V1.5 Live As-Of Contract Repair

## Current status

The rollback Production mismatch is causally explained and repaired on `codex/v15-live-asof-contract-repair` from exact main `075ddfc6eeb8fbe4e3a0aaade9c4c2d5711340b9`. The initial `asOf` hypothesis was disproved: explicit `2026-08-07` and the narrowest evidenced `2026-08-16` Production interval produce the same accepted VM output. The actual mismatch was reproduced byte-for-byte by the pre-repair compiled Web runtime and traced to reader-visible selection based on runtime-dependent `String.hashCode`/`Object.hash`.

The repair supplies a Dart 3.11 VM-compatible stable hash across VM and compiled JavaScript and separates the time contracts: `startedAt` measures session duration; the form captures submit time once; `analysis.asOf` stores the resolved Asia/Bangkok civil timestamp used by pipeline, presenter, Web and PDF. Export does not recompute the clock.

## Verification

- Frozen R7.1 canonical Web/PDF parity: exact 5/5 at explicit `2026-08-07`.
- Live-date oracle parity: exact Web/PDF 5/5 and repeat exact 5/5.
- Owner Known Aquarius 19°19′; regression 00:03 Aquarius 9°24′; Unknown fail-closed; traceability 170/170.
- Targeted screenshots 24/24; Life Map 67/67; matrix 864/864 and weekday 108/108; R7 focused 286/286; synthetic 300 unique reports/narratives and deterministic.
- Scoped analyzers: 0 issues. Full analyzer: branch 299 / main 299 / normalized delta 0.
- Full suite: branch 2,899 passed / 39 failed; exact main 2,889 / 39; common failures 39; branch-only 0; main-only 0.
- Production-equivalent Web release build succeeds without deployment.
- R7.1 ZIP remains 10,709,328 bytes / 80 entries / SHA-256 `9E541F21C68FDAD93BC595C55BD0BE23600F88454CFBA7FAB6C713FE53F79E58`; 79/79 checksums and 63/63 immutable comparison pass; R1–R7.1 modified paths are zero.
- Five live-oracle PDFs total 34 pages; every page passes visual QA.

## Release rule

Frozen acceptance remains an exact gate only at its explicit frozen `asOf`. A live Production report must be compared to a same-source, same-input, same-assets and same-`asOf` deterministic oracle. Frozen-vs-live exact text is not a valid gate when `asOf` differs; only invariant engine, omission, schema, safety and immutable-identity contracts cross dates.

Evidence is in `product-acceptance/thai-narrative-v1.5-live-asof-repair/`.

This branch is for Owner review only. It is not merged or deployed. Production remains V1.4 and the prior rollback remains successful.
