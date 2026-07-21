# Thai Archetype Context Metadata

Phase: **Archetype Context Metadata** (blocker-only — metadata not exposed)

Prerequisites: Life Period Position Metadata (`5df3f91`).

Prior blocker: `NEEDS_ARCHETYPE_CONTEXT_METADATA` — runtime lacked scoped archetype chart identity.

---

## Feasibility audit result

**Classification: `NEEDS_REMAINDER_METADATA`**

| Check | Result |
| --- | --- |
| `rotationIndex.remainderN` on runtime | **No** — not computed or exposed on `ThaiAstrologyProfile` |
| `archetypeChart.*` on runtime | **No** — no internal archetype chart id field |
| `mahabhutaChartNumbers` / row-4 sums | Present as audit metadata only — **not** treated as remainder identity (would be inference) |
| `mahabhuta_thaya` content key | Explicitly **not** used; no mapping to `mahabhutPosition.khumsap` |
| Frozen p19 remainder → chart mapping | Present for remainders 0–5; **incomplete** (see below) |

Runtime does not expose deterministic remainder / เศษดวง / archetype chart identity → stop at **`NEEDS_REMAINDER_METADATA`** (not `NEEDS_CANON_ARCHETYPE_MAPPING`, which applies only after remainder is exposed).

---

## Canon mapping status (for when remainder exists)

Frozen p19 (`ThaiArchetypeContextP19Rules`):

| Remainder | Archetype chart |
| --- | --- |
| `rotationIndex.remainder0` | `archetypeChart.mahasethi` |
| `rotationIndex.remainder1` | `archetypeChart.kamphra` |
| `rotationIndex.remainder2` | `archetypeChart.naksas` |
| `rotationIndex.remainder3` | `archetypeChart.nakbarihan` |
| `rotationIndex.remainder4` | `archetypeChart.manussachaosamran` |
| `rotationIndex.remainder5` | `archetypeChart.sethi` |
| `rotationIndex.remainder6` | **Not in Canon prose** (Phase G gap) |
| `archetypeChart.nakwichakan` | **No p19 remainder row** (Phase G gap) |

If runtime later exposes remainder but mapping gaps remain → `NEEDS_CANON_ARCHETYPE_MAPPING`.

---

## Forbidden inference paths

| Path | Status |
| --- | --- |
| Archetype from section / narrative copy | **Forbidden** |
| Archetype from `mahabhuta_thaya` | **Forbidden** |
| `mahabhuta_thaya` → `mahabhutPosition.khumsap` | **Forbidden** (documented in `ThaiCanonEvidenceSignalScope`) |
| Row-4 chart numbers as remainder proxy | **Forbidden** — not proven equivalent to `rotationIndex.remainderN` |

---

## Metadata implemented or blocked

**Blocked.** No `archetypeChartCanonId` on profile or life-period models.

Internal additions:

- `ThaiArchetypeContextMetadataFeasibility` + audit types
- `ThaiArchetypeContextMetadataResolver` (p19 lookup stub — null without remainder input)
- `ThaiArchetypeContextP19Rules` frozen mapping constants
- Trace: `lifePeriodArchetypeFeasibilityResult`, `lifePeriodArchetypeMetadataBlocker`
- Position/status blockers refined to `NEEDS_REMAINDER_METADATA`

---

## Updated counts (9-fixture aggregate)

| Metric | Count |
| --- | ---: |
| `lifePeriodsWithRuntimeStatus` | **0** |
| `lifePeriodsWithCanonDerivedStatus` | **52** |
| `lifePeriodsWithoutRuntimeStatus` | **86** |
| `lifePeriodsWithoutCanonStatusMarker` | **34** |

---

## Blocker status

| Field | Value |
| --- | --- |
| `lifePeriodArchetypeFeasibilityResult` | `NEEDS_REMAINDER_METADATA` |
| `lifePeriodArchetypeMetadataBlocker` | `NEEDS_REMAINDER_METADATA` |
| `lifePeriodPositionMetadataBlocker` | `NEEDS_REMAINDER_METADATA` |
| `lifePeriodStatusMetadataBlocker` | `NEEDS_REMAINDER_METADATA` |
| `lifePeriodPositionFeasibilityResult` | `NEEDS_ARCHETYPE_CONTEXT_METADATA` (position layer wire) |
| `lifePeriodRiseFallFeasibilityResult` | `NEEDS_ENGINE_POSITION_METADATA` (downstream) |

---

## Proof: user-facing output unchanged

- User-facing fingerprint unchanged before/after enrich.
- Consumer timeline contains no archetype chart headings.
- Mirror copy and public UI unchanged.

Thai validation suite green (includes `thai_archetype_context_metadata_test.dart`).

---

## Remaining blockers

1. **Compute/expose `rotationIndex.remainderN`** deterministically from approved engine structures (not row-4 proxy without proof).
2. **Resolve p19 gaps** — `remainder6` and `archetypeChart.nakwichakan` mapping.
3. **Wire archetype id** into position metadata resolver chain.

---

## Recommended next phase

**Remainder Runtime Metadata**

Compute and expose deterministic `rotationIndex.remainderN` (เศษดวง) from existing Thai chart infrastructure without changing user-facing copy — enabling p19 archetype lookup on the internal evidence path.

---

## Key files

| File | Role |
| --- | --- |
| `lib/features/astrology/thai/core/life_period/thai_archetype_context_metadata.dart` | Archetype feasibility + p19 resolver |
| `lib/features/astrology/thai/core/life_period/thai_life_period_position_metadata.dart` | Delegates archetype audit |
| `test/validation/thai/thai_archetype_context_metadata_test.dart` | Phase validation |
