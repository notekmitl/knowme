# Thai Narrative V1.5 Live As-Of Contract Repair

## S008 final canonical parity — verified 2026-08-17

The remaining S008 one-ULP raw degree divergence is repaired at the snapshot/hash/research boundary with a 1e9-unit fixed-point integer while preserving the raw engine degree and all engine decisions. Final VM×2 and real-Chrome×2 300-profile runs have only the disclosed raw S008 finding; canonical degree, profile, structured material, period scores, report/content hash, canonical text, narrative, omission and copy-impact mismatches are all zero, with nondeterminism zero. Every fresh final gate passes against pinned main, R1–R7.1 are unchanged, and Production remains V1.4. PR #95 stays Draft only because the retained 93-profile/112-summary copy normalization awaits Owner review; no merge or deployment is authorized.

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

## Historical pre-S008 cross-runtime parity gate — blocked

The reader-visible cause remains runtime-dependent hashing, not `asOf`. The application-owned stable string and exact integer contracts now produce identical fixed vectors in VM and compiled JavaScript/Chrome. VM 300-profile runs are identical to each other; Chrome 300-profile runs are identical to each other; each run executes 300 cases, yields 300 unique reports/narratives, and passes Unknown omission 75/75.

The pre-repair comparison had one failing profile: S008. Its serialized `siderealAscendantDeg` was `102.39560244592322` in VM and `102.39560244592323` in Chrome. That one-ULP upstream numeric difference changed the report snapshot/hash and the report-hash-derived narrative seed. This historical result is retained as causal evidence and is superseded by the final fixed-point gate above.

The cautious future-opportunity normalization is retained because disabling it breaks the accepted frozen `owner-unknown` fixture. It affects exactly 93/300 profiles and 112 `summary` fields, so it remains explicit Owner-review scope. The later S008 gate and complete fresh final rerun pass; this earlier failure log remains preserved and is not reused as a passing result. PR #95 remains Draft, unmerged and undeployed. Firebase is unchanged and Production remains V1.4.
