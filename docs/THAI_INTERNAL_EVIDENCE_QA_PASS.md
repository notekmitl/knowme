# Thai Internal Evidence QA Pass

**Phase:** Internal Evidence QA Pass  
**Status:** Complete  
**Prerequisite commit:** `e078cec` — Internal Evidence Badge Prototype

## QA scope

Formal internal QA over Canon evidence attachments, badge assignment, trace reporting, and review panel readiness across the deterministic 9-fixture harness. No public UI, engine, Canon, or copy changes.

**Core question answered:** Yes — the internal evidence panel can be trusted by reviewers for QA triage, with documented residual risks below.

## Fixtures audited

| Fixture | ID |
|---------|-----|
| QA sample (Bangkok 1972-04-04) | `qa_sample` |
| Weekday harness A–H | `harness_a` … `harness_h` |

No random fixtures. No current-date dependency. No Firestore. No network.

## Badge correctness summary

| Check | Result |
|-------|--------|
| Badge mismatches (9 fixtures) | **0** |
| Weak evidence promoted to `CANON_SUPPORTED` | **0** |
| All 10 categories supported by assigner | **Pass** (synthetic + fixture probes) |
| Core categories on fixtures | `CANON_SUPPORTED`, `RUNTIME_METADATA_SUPPORTED`, `CANON_DERIVED_INTERNAL`, `OUT_OF_CANON_SCOPE`, `BLOCKED_AMBIGUOUS`, `BLOCKED_SOURCE_CONFLICT`, `REMEDY_HIDDEN` |

**Aggregate badge counts (9 fixtures):**

| Badge | Count |
|-------|------:|
| `CANON_SUPPORTED` | 177 |
| `RUNTIME_METADATA_SUPPORTED` | 65 |
| `CANON_DERIVED_INTERNAL` | 10 |
| `OUT_OF_CANON_SCOPE` | 99 |
| `BLOCKED_AMBIGUOUS` | 36 |
| `BLOCKED_SOURCE_CONFLICT` | 12 |
| `REMEDY_HIDDEN` | 9 |
| `PARTIAL_CANON_SUPPORT` | 0 (fixtures; assigner supports via trace/weak rules) |
| `INTERNAL_ONLY` | 0 (fixtures; assigner supports via skip/trace rules) |
| `NO_CANON_EVIDENCE` | 0 (fixtures; assigner supports via unmapped trace) |

Rules verified: strong match → `CANON_SUPPORTED` (except runtime period status → `RUNTIME_METADATA_SUPPORTED`); canon-derived → `CANON_DERIVED_INTERNAL`; ambiguous/conflict blockers surfaced; remedies → `REMEDY_HIDDEN` only.

## Evidence provenance summary

| Check | Result |
|-------|--------|
| Provenance gaps | **0** |
| Every row has unit id, subject, relation, object, source page | **Pass** |
| All rows `userFacingAllowed = false` | **Pass** |
| Source prose displayed | **None** |

Aggregate evidence refs audited: **5,115** across 9 fixtures (245 attachments).

## Runtime metadata summary

| Metric | Aggregate (9 fixtures) |
|--------|------------------------|
| `lifePeriodsWithRuntimeStatus` | **65** |
| `lifePeriodsWithoutRuntimeStatus` | **21** |
| `blockedAmbiguous` (period anchors) | **18** |
| `blockedSourceConflict` (period anchors) | **3** |
| `blockedMissingPosition` | **0** |
| `blockedNoP17Rule` | **0** |
| Unique `conflictedArchetypePlanetPairs` | **1** (`archetypeChart.nakwichakan:planet.jupiter`) |

Per-fixture breakdown is in `tool/output/thai_internal_evidence_qa_summary.json`. Blockers are explicit in trace — nothing hidden silently.

## Remedy safety summary

| Check | Result |
|-------|--------|
| Remedy attachments on report | **0** |
| Remedy `userFacingAllowed` rows | **0** |
| Skipped remedy count per fixture | **87** (aggregate **783**) |
| Remedy procedure text / advice | **None** |
| Public pages import remedy display | **None** |

## Public isolation summary

| Check | Result |
|-------|--------|
| `thai_beta_report_page.dart` imports badge/review layer | **No** |
| `thai_mirror_result_page.dart` imports badge/review layer | **No** |
| `userFacingFingerprint` unchanged after enrichment | **Pass** |
| Consumer timeline text unchanged (no ดวงขึ้น/ดวงตก) | **Pass** |
| Thai validation suite | **590 / 590 pass** |

## Reviewer usability

Internal panel at `/internal/thai-canon-evidence` (admin-guarded):

- Badge summary chips (including `INTERNAL_ONLY` when present)
- Coverage chips: runtime status + QA blocker counts
- Evidence table with Badge column (scrollable)
- Trace panel: `QA blockers (internal)` section with ambiguous/conflict labels

Small readability fixes applied; no public redesign.

## Remaining QA risks

1. **Legacy hardcoded Mirror copy** — Mahabhut/planet `STRONG_MATCH` evidence exists while sections still render legacy prose (false-confidence pattern documented in alignment audit).
2. **Single source-conflict pair** — `ดวงนักวิชาการ` + Jupiter blocks 3 period anchors; not auto-resolved by design.
3. **18 ambiguous placements** — Require Canon/OCR disambiguation before runtime rise/fall expansion.
4. **`PARTIAL_CANON_SUPPORT` / `NO_CANON_EVIDENCE` not fixture-populated** — Assigner supports them; fixtures currently attach strong/runtime/canon-derived evidence only.
5. **Taksa / lookup tables** — Skipped internally; not wired to report signals.

## Implementation

- `lib/features/astrology/thai/knowledge/canon/integration/qa/thai_internal_evidence_qa_validator.dart`
- `lib/features/astrology/thai/knowledge/canon/integration/qa/thai_internal_evidence_qa_runner.dart`
- `lib/features/astrology/thai/knowledge/canon/integration/qa/thai_internal_evidence_qa_report.dart`
- `test/validation/thai/thai_internal_evidence_qa_pass_test.dart`
- `tool/output/thai_internal_evidence_qa_summary.json` (aggregate counts only)

## Recommended next phase

**Internal Evidence Review Freeze**

Badge layer and QA pass are green. Freeze internal evidence semantics and panel contract before Taksa/Khumsap runtime mapping or any user-facing integration.
