# Thai Remainder Calculation Model

Phase: **Remainder Calculation Model Completion**

Prerequisites: Source Forensics OCR Recovery (`5ee43b7`).

Prior blocker: `NEEDS_SOURCE_FORENSICS` — formula recovered from PDF p.19 / book p.4.

---

## Completion (implemented)

### Formula implemented

Source-backed internal calculation in `ThaiMahabhutRemainderCalculator`:

1. `csYear = buddhistEraYear - 1181` (พ.ศ. − 1181)
2. `rawRemainder = csYear % 7` → values **0–6** (not 1–7)
3. Birth dates **1 Jan – 15 Apr** inclusive: subtract 1; wrap `0 → 6`
4. Birth date **16 Apr**: blocked — teacher-only exception (`TEACHER_ONLY_EXCEPTION_APR_16`)
5. **17 Apr – 31 Dec**: use `rawRemainder` unchanged

Ontology: `rotationIndex.remainder0` … `rotationIndex.remainder6` (D-078).

### Exact source page

- Formula: PDF **p.19** / book p.4
- Remainder → chart labels corroborated on pp.23–27 (lookup tables; not used as primary calculator in this phase)

### Metadata fields exposed (internal trace only)

| Field | Example |
| --- | --- |
| `remainderCalculationFeasibilityResult` | `READY_TO_IMPLEMENT_REMAINDER_CALCULATION` |
| `remainderFeasibilityResult` | `READY_TO_EXPOSE_REMAINDER_METADATA` |
| `remainderMetadataBlocker` | null (normal dates) |
| `remainderSourceField` | `ThaiBirthData.localDateTime` |
| `remainderCanonId` | e.g. `rotationIndex.remainder3` |
| `ThaiRemainderMetadata.source` | `source_backed_calculation` |
| `ThaiRemainderMetadata.sourcePage` | `19` |
| `ThaiRemainderMetadata.confidence` | `deterministic` |

No user-facing field exposes เศษ / เศษดวง / rotationIndex / remainder / ดวงขึ้น / ดวงตก.

### Remainder metadata counts (9-fixture aggregate)

| Metric | Count |
| --- | ---: |
| `profilesWithRemainderMetadata` | **9** |
| `profilesWithoutRemainderMetadata` | **0** |

### Updated blocker chain

| Layer | Feasibility wire | Blocker |
| --- | --- | --- |
| Remainder calculation | `READY_TO_IMPLEMENT_REMAINDER_CALCULATION` | null |
| Remainder metadata | `READY_TO_EXPOSE_REMAINDER_METADATA` | null |
| Archetype context | `NEEDS_CANON_ARCHETYPE_MAPPING` | `NEEDS_CANON_ARCHETYPE_MAPPING` |
| Life-period position | `NEEDS_ARCHETYPE_CONTEXT_METADATA` | `NEEDS_CANON_ARCHETYPE_MAPPING` |
| Rise/fall status | `NEEDS_ENGINE_POSITION_METADATA` | upstream archetype blocker |

Apr 16 only: remainder metadata blocked with `TEACHER_ONLY_EXCEPTION_APR_16` (no fallback).

Archetype mapping **not** performed in this phase (p19 gap: `remainder6` → `archetypeChart.nakwichakan`).

### Rejected proxies (unchanged)

| Field | Used? |
| --- | --- |
| `row4Reduced` | **No** |
| `mahabhutaChartNumbers` row-4 | **No** |
| Archetype / report copy | **No** |

### Proof: user-facing output unchanged

- User-facing fingerprint unchanged before/after enrich.
- Consumer timeline/report text contains no remainder labels.
- Mirror copy and public UI unchanged.

Thai validation suite green (includes `thai_remainder_calculation_model_test.dart`).

### Recommended next phase

**Canon Archetype Mapping Completion**

---

## Prior audit (blocked — superseded)

Earlier phase returned `NEEDS_SOURCE_FORENSICS` because no explicit formula was wired. Source forensics (`5ee43b7`) recovered the p.19 formula; this document’s **Completion** section reflects the implemented state.

---

## Key files

| File | Role |
| --- | --- |
| `lib/features/astrology/thai/core/life_period/thai_remainder_calculation_model.dart` | Source-backed calculator + feasibility audit |
| `lib/features/astrology/thai/core/life_period/thai_remainder_runtime_metadata.dart` | Metadata resolver + runtime feasibility |
| `lib/features/astrology/thai/mirror/runtime/thai_mirror_pipeline_result.dart` | Passes `birthData` for remainder inputs |
| `test/validation/thai/thai_remainder_calculation_model_test.dart` | Phase validation |
