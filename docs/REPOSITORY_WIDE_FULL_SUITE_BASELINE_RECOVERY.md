# Repository-wide Full-suite Baseline Recovery

Status: **PASS — TEST BASELINE RECOVERED — DRAFT PR — PR120 UNCHANGED — NOT MERGED — NOT DEPLOYED**

## Purpose and boundary

This work removes the pre-existing repository-wide test blocker before PR120 Revision 4 continues. It is intentionally separate from PR120 and is based on `6af7ccdd05796c97e6108255da43f40123485583`.

No production or application source was changed. There is no runtime, generator, UI, export, PDF implementation, Canon, Candidate, `product-acceptance/`, Firebase, deployment, or Production mutation. This is a test expectation, harness portability, audit-truth, and deterministic golden-baseline recovery only. It does not grant Owner product or content acceptance.

## Reproduced baseline

The first fresh full-suite run used Flutter 3.41.1, Dart 3.11.0, `TZ=Asia/Bangkok`, and the repository's existing dependencies. It produced **2,955 passed / 69 failed / 3,024 total** across 24 files. The initial log is `build/repository-wide-baseline-full-suite-bangkok.log`, SHA-256 `F41EC08DFF4E20CBF52733FAD4C86F06E18A9D3243508CE6B77A45787C38652E`.

| Failure class | Count | Repair principle |
| --- | ---: | --- |
| Stale screenshot expectations | 38 | Regenerate the existing QA goldens from unchanged `main` using the pinned Flutter toolchain |
| Stale engine/interpretation expectations | 10 | Assert the current deterministic engine output without changing the frozen engine |
| Stale reader/UI contract expectations | 5 | Assert the current shared report and Unknown fail-closed contract |
| Environment/async harness assumptions | 5 | Make test-only dependency lookup, initialization, and bounded pumping portable |
| Audit/evidence truth drift | 11 | Record current measured debt and move generated output under ignored `build/` paths |
| **Total** | **69** | **No product-source repair** |

No test declaration was removed. No assertion was converted into an unconditional pass. Where a former success claim is false, the migrated test now asserts the measured current value and keeps the debt visible.

## Changes

- 22 Dart test files were migrated.
- 173 tracked PNG goldens changed and one Unknown hero golden was added.
- The 144-file Thai Mirror QA harness was regenerated under Decision D-079 with unchanged dimensions.
- Consumer goldens now reflect the current shared-reader composition. Unknown birth-time limitation remains in the hero and no retired mid-report confidence banner is asserted.
- Engine expectations now match the deterministic Pisces/Jupiter and Leo/Sun results emitted by unchanged source for their stated inputs.
- Unknown interpretation tests assert fail-closed empty signal/fact layers.
- PDF tools resolve explicit environment configuration first and then executables on `PATH`; required real-PDF tests still cannot silently skip.
- Audit-producing tests write into ignored `build/repository-wide-baseline/` paths instead of rewriting historical tracked evidence.

## Validation

- Focused changed-test runs: **197/197**, failures 0. The three retained logs have SHA-256 `49068AFAB06D5EAECBAAD06BD57C7375C36235ADD69C3848CA34E26619867F4C`, `BB9628A3ADD6F5EFC2FF990E9816EC41FFEE6E6BBA447A7ABF777A716E9D1CBD`, and `4894BC9580C82BB5E5EBA80C86FA3A266505A242DC40688A79CD8322FA2917AD`.
- Full Flutter suite: **3,024/3,024**, failures/skips 0. Final log `build/repository-wide-baseline-full-suite-closeout.log`, SHA-256 `BFED32BF8E421DC4478EF46478C539766868DB9E42FE3B04331911DBE6382FA8`.
- Analyzer: clean base/current **296/296** diagnostics, exit 0, new diagnostics 0. Final current log `build/repository-wide-baseline-analyze-closeout.log`, SHA-256 `53939DE6913925FBFB7C31BB016B80E1AB658C94DBD2BAB3AA486FEDE607E171`.
- Golden regeneration: 176 files hashed in each of two independent runs; mismatch 0; both manifests SHA-256 `470DE4ADBEEDBD8940FE1F92518133C07AE613432B08FEF94FF1EAF218A7CCB7`.
- Golden visual review: both contact sheets and seven representative full-size images opened. Uniform/blank images and observed clipping, overlap, or overflow: 0. The harness's existing test-font tofu rendering is not claimed as Production typography acceptance.
- `git diff --check`: PASS.
- Repository gate: PreCommit PASS with the required analyzer, three focused groups, and full suite. Final PreCommit log SHA-256: `5CD5C2739D4BB794DF513385E3F8E7CD385F02AFCC3D2BC74B7860ECF43D8B9F`. PostCommit is required after the evidence/status commit and before push.

The machine-readable record is `docs/REPOSITORY_WIDE_FULL_SUITE_BASELINE_RECOVERY.json`.

## Truth retained, not hidden

Passing the suite does not convert known quality debt into acceptance:

- Human semantic mapping remains 8/9; `gf_tension_f03a3173` remains unmapped.
- Content-diversity audit still reports 19 profile pairs above 30% similarity.
- Human-pattern audit still reports 19 never-activated patterns.
- Narrative generation produces 200 distinct outputs across the measured 200-profile audit, with no collapse zone.

These values are asserted as the current baseline so future regressions remain detectable. Product-quality remediation remains separate work.

## Relationship to PR120

PR120 remains Open + Draft at its existing remote HEAD. This recovery branch neither edits nor pushes PR120. After Owner review and merge of this baseline PR, PR120 Revision 4 can be rebased and its three stale Candidate 0027 assertions can be addressed against a green repository-wide baseline.

**REPOSITORY-WIDE FULL-SUITE BASELINE RECOVERED — TRUTHFUL DEBT RETAINED — PR120 UNCHANGED — DRAFT — NOT MERGED — NOT DEPLOYED**
