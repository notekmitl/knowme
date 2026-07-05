# Thai Remainder Calculation Model

Phase: **Remainder Calculation Model** (blocker-only — calculation not implemented)

Prerequisites: Remainder Runtime Metadata (`d652a35`).

Prior blocker: `NEEDS_REMAINDER_CALCULATION_MODEL` — runtime had no deterministic remainder source.

---

## Formula feasibility audit result

**Classification: `NEEDS_SOURCE_FORENSICS`**

| Source audited | Finding |
| --- | --- |
| Thai engine (`SevenNumberChart`) | Computes `row4Sum` (3–21) and `row4Reduced` (horawej auxiliary 1–7) — **not** documented as เศษดวง |
| `ThaiAstrologyProfile.mahabhutaChartNumbers` | Row 4 audit sums — **rejected** as remainder proxy |
| Canon p19 | Remainder **labels** → archetype chart (0–5) + Jan–Apr **adjustment** rules (`ลดหนึ่งแต้ม`) — **no primary derivation formula** |
| Canon p20 | House-digit placement grid per remainder — requires remainder input first |
| Canon pp.23–27 (`lookupTable.birthDateChart`) | **28** readable reference-table cells (`คำนวณสำเร็จรูป` / `เศษ/ดวง`) |
| OCR inventory (Phase G) | **~62** pp.23–27 birth-date rows blocked — majority of lookup table missing |

**Not** `READY_TO_IMPLEMENT_REMAINDER_CALCULATION` — no explicit source-backed formula in engine or Canon atomic units.

**Not** `READY_TO_USE_REFERENCE_TABLE_REMAINDER` — partial table only; OCR-blocked rows exceed readable cells (62 > 28); cannot resolve most birth dates without forensics.

**Not** `BLOCKED_BY_SOURCE_GAP` — partial lookup + p19 mapping prove the concept exists in source.

**Not** `BLOCKED_BY_MODELING_GAP` — internal metadata model can represent remainder once source is recovered.

---

## Formula / table source found or missing

| Candidate | Status |
| --- | --- |
| Explicit mod-7 / chart-row formula | **Not found** in engine or frozen Canon |
| p19 remainder → chart mapping | **Present** — identity table only, not calculation |
| p19 seasonal adjustment | **Present** — applies after remainder is known |
| pp.23–27 birth-date lookup | **Partial** — 28 cells; e.g. `17 เม.ย. 2490 ถึง 15 เม.ย. 2491` → `0 มหาเศรษฐี` |
| SevenNumberChart vertical sum | **Rejected** — documented as chart construction, not เศษดวง |

---

## Calculation implemented or blocked

**Blocked.** `ThaiMahabhutRemainderCalculator.calculate` returns `null`. No formula invented. No partial lookup wired until OCR recovery or full table validation.

---

## Why row4Reduced / mahabhutaChartNumbers row-4 is not used

| Field | Documented meaning | Used? |
| --- | --- | --- |
| `SevenNumberChartResult.row4Reduced` | Horawej auxiliary reduction to 1–7 | **No** — not on profile; not Canon เศษดวง |
| `mahabhutaChartNumbers` row-4 | Vertical sums 3–21 (audit) | **No** — not proven equivalent to `rotationIndex.remainderN` |

---

## Metadata fields exposed

None on profile. Internal trace only:

- `remainderCalculationFeasibilityResult`: `NEEDS_SOURCE_FORENSICS`
- `remainderFeasibilityResult`: `NEEDS_SOURCE_FORENSICS`
- `remainderMetadataBlocker`: `NEEDS_SOURCE_FORENSICS`
- `remainderSourceField`: null
- `remainderCanonId`: null

---

## Remainder metadata counts (9-fixture aggregate)

| Metric | Count |
| --- | ---: |
| `profilesWithRemainderMetadata` | **0** |
| `profilesWithoutRemainderMetadata` | **9** |

---

## Updated blocker chain

| Layer | Feasibility wire | Blocker |
| --- | --- | --- |
| Remainder calculation | `NEEDS_SOURCE_FORENSICS` | `NEEDS_SOURCE_FORENSICS` |
| Remainder metadata | `NEEDS_SOURCE_FORENSICS` | `NEEDS_SOURCE_FORENSICS` |
| Archetype context | `NEEDS_REMAINDER_METADATA` | `NEEDS_SOURCE_FORENSICS` |
| Life-period position | `NEEDS_ARCHETYPE_CONTEXT_METADATA` | `NEEDS_SOURCE_FORENSICS` |
| Rise/fall status | `NEEDS_ENGINE_POSITION_METADATA` | `NEEDS_SOURCE_FORENSICS` (upstream) |

When remainder metadata is available, archetype blocker should move to `NEEDS_CANON_ARCHETYPE_MAPPING` (p19 gaps: `remainder6`, `archetypeChart.nakwichakan`).

---

## Proof: user-facing output unchanged

- User-facing fingerprint unchanged before/after enrich.
- Consumer timeline/report text contains no remainder labels.
- Mirror copy and public UI unchanged.

Thai validation suite green (includes `thai_remainder_calculation_model_test.dart`).

---

## Recommended next phase

**Source Forensics OCR Recovery**

Recover readable pp.23–27 birth-date lookup rows (and any explicit calculation prose on pp.17–22) before wiring `ThaiMahabhutRemainderCalculator` or a reference-table resolver.

---

## Key files

| File | Role |
| --- | --- |
| `lib/features/astrology/thai/core/life_period/thai_remainder_calculation_model.dart` | Formula feasibility audit + blocked calculator stub |
| `lib/features/astrology/thai/core/life_period/thai_remainder_runtime_metadata.dart` | Chains calculation audit into remainder metadata blocker |
| `test/validation/thai/thai_remainder_calculation_model_test.dart` | Phase validation |
