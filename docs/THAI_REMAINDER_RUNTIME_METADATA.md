# Thai Remainder Runtime Metadata

Phase: **Remainder Runtime Metadata** (blocker-only — metadata not exposed)

Prerequisites: Archetype Context Metadata (`178cdb9`).

Prior blocker: `NEEDS_REMAINDER_METADATA` — runtime lacked `rotationIndex.remainderN`.

---

## Feasibility audit result

**Classification: `NEEDS_REMAINDER_CALCULATION_MODEL`**

| Question | Result |
| --- | --- |
| Does `SevenNumberChart` compute เศษ / remainder directly? | **No** — computes `row4Sum` (vertical sum 3–21) and `row4Reduced` (horawej auxiliary 1–7) |
| Existing field equivalent to `rotationIndex.remainderN`? | **No** — no such field on `ThaiAstrologyProfile` |
| Is `mahabhutaChartNumbers` row-4 documented/tested as remainder? | **No** — documented as **Row 4 sums (audit)** per `THAI_FOUNDATION_ENGINE_V1_1_NOTES` |
| Profile exposes deterministic remainder key? | **No** |
| Can remainder be exposed without new calculation? | **No** |

**Not** `BLOCKED_BY_SOURCE_GAP` — Canon p19 defines remainder concept; OCR gaps do not block the runtime audit.

**Not** `BLOCKED_BY_MODELING_GAP` — internal metadata model can represent remainder once computed.

---

## mahabhutaChartNumbers row-4: rejected as remainder proxy

| Field | Documented meaning | Treated as remainder? |
| --- | --- | --- |
| `ThaiAstrologyProfile.mahabhutaChartNumbers` | Row 4 vertical sums (3–21) | **Rejected** — not proven equivalent to `rotationIndex.remainderN` |
| `SevenNumberChartResult.row4Reduced` | Horawej auxiliary reduction to 1–7 | **Rejected** — not on profile; not documented as เศษดวง |
| `ThaiContentKeys.mahabhutaThaya` | Runtime lens key (ทายะ) | **Rejected** — out of Canon scope; not remainder |

---

## Metadata implemented or blocked

**Blocked.** No `ThaiRemainderMetadata` attached to profile. Resolver returns `null`.

Internal additions:

- `ThaiRemainderRuntimeMetadataFeasibility` + audit types
- `ThaiRemainderMetadataResolver` (null until deterministic source exists)
- Trace: `remainderFeasibilityResult`, `remainderMetadataBlocker`, `remainderSourceField`, `remainderCanonId`, `profilesWithRemainderMetadata`, `profilesWithoutRemainderMetadata`
- Archetype blocker refined to `NEEDS_REMAINDER_CALCULATION_MODEL`

---

## Updated blocker chain

| Layer | Feasibility wire | Blocker |
| --- | --- | --- |
| Remainder metadata | `NEEDS_REMAINDER_CALCULATION_MODEL` | `NEEDS_REMAINDER_CALCULATION_MODEL` |
| Archetype context | `NEEDS_REMAINDER_METADATA` | `NEEDS_REMAINDER_CALCULATION_MODEL` |
| Life-period position | `NEEDS_ARCHETYPE_CONTEXT_METADATA` | `NEEDS_REMAINDER_CALCULATION_MODEL` |
| Rise/fall status | `NEEDS_ENGINE_POSITION_METADATA` | `NEEDS_REMAINDER_CALCULATION_MODEL` (upstream) |

When remainder metadata is implemented, archetype blocker should move to `NEEDS_CANON_ARCHETYPE_MAPPING` (p19 gaps: `remainder6`, `archetypeChart.nakwichakan`).

---

## Remainder metadata counts (9-fixture aggregate)

| Metric | Count |
| --- | ---: |
| `profilesWithRemainderMetadata` | **0** |
| `profilesWithoutRemainderMetadata` | **9** |

---

## Proof: user-facing output unchanged

- User-facing fingerprint unchanged before/after enrich.
- Consumer timeline/report text contains no remainder labels.
- Mirror copy and public UI unchanged.

Thai validation suite green (includes `thai_remainder_runtime_metadata_test.dart`).

---

## Recommended next phase

**Remainder Calculation Model**

Define and validate the approved deterministic calculation that maps existing Thai chart inputs to `rotationIndex.remainderN` before exposing internal metadata.

---

## Key files

| File | Role |
| --- | --- |
| `lib/features/astrology/thai/core/life_period/thai_remainder_runtime_metadata.dart` | Remainder feasibility + resolver stub |
| `lib/features/astrology/thai/core/life_period/thai_archetype_context_metadata.dart` | Delegates to remainder audit |
| `test/validation/thai/thai_remainder_runtime_metadata_test.dart` | Phase validation |
