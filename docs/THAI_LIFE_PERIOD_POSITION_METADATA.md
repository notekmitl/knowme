# Thai Life Period Position Metadata

Phase: **Life Period Position Metadata** (blocker-only — metadata not exposed)

Prerequisites: Engine Life Period Rise/Fall Metadata (`d1803b4`).

Prior blocker: `NEEDS_ENGINE_POSITION_METADATA` — per-period Mahabhut position absent on runtime.

---

## Feasibility audit result

**Classification: `NEEDS_ARCHETYPE_CONTEXT_METADATA`**

| Check | Result |
| --- | --- |
| Governing planet per life period | **Yes** — `PeriodState.planet` |
| Archetype chart identity on runtime | **No** — `ThaiAstrologyProfile` has no `archetypeChart.*` field; ontology entities exist but are not computed |
| Life-period context identity | **No** — `PeriodState` has numeric `startAge`/`endAge` only; Canon uses verbatim Thai `life_period` context values (e.g. `แรกเกิด`, `อาย ๓๒ [ดวงขึ้น]`) |
| Canon `life_period` mahabhut placements present | **Yes** — 215 frozen units (Phase D) |
| Can map without planet-only inference | **No** — same `(planet, life_period value)` maps to **multiple** `mahabhutPosition.*` across the 7 archetype chart sections |

**Not** `BLOCKED_BY_SOURCE_GAP` — Canon placements and ontology are frozen and present.

**Not** `BLOCKED_BY_MODELING_GAP` for the atomic model — D-068 `context` qualifier already represents scope; runtime lacks the identity inputs.

**Not yet** `NEEDS_PERIOD_CONTEXT_MAPPING` — archetype identity is the first missing prerequisite (even perfect age mapping cannot disambiguate cross-archetype conflicts).

---

## Why planet or sequence cannot disambiguate

Frozen Canon analysis (215 `life_period` + `mahabhutPosition.*` units):

- **13** distinct `(planet.*, life_period value)` pairs map to **multiple** positions.
- Example: `planet.jupiter` + `แรกเกิด` → 7 different `mahabhutPosition.*` ids (one per archetype section).
- Life-period context values such as `แรกเกิด` repeat across archetype page ranges (pp. 52–292).

Mapping requires **scoped identity**:

1. `archetypeChart.*` (which example chart section applies)
2. `life_period` context value (verbatim period header token)
3. `planet.*` (governing period planet — available)

Planet alone or period index/sequence alone is insufficient and forbidden.

---

## Source fields audited

| Runtime field | Position mapping use |
| --- | --- |
| `LifeTimeline.periods[].planet` | Available; insufficient alone |
| `LifeTimeline.periods[].startAge/endAge` | Numeric ages only; no Canon context value |
| `ThaiAstrologyProfile.mahabhutaPositionKeys` | Natal lens keys; not per-period placement |
| `ThaiAstrologyProfile.mahabhutaChartNumbers` | Row-4 audit metadata; not planet→position per period |
| Archetype chart id | **Absent** |
| Period context value | **Absent** |

---

## Resolver rules (defined, not wired to production)

`ThaiLifePeriodPositionMetadataResolver.mahabhutPositionCanonId`:

| Input | Required |
| --- | --- |
| `archetypeChartCanonId` | Yes — `archetypeChart.*` |
| `periodContextValue` | Yes — frozen Canon `life_period` context string |
| `period.planet` | Yes — maps to `planet.*` |
| Missing any input | **`null`** (no guess) |

Production wiring deferred until runtime exposes scoped identity without inference.

---

## Metadata implemented or blocked

**Blocked.** No `mahabhutPositionCanonId` on `PeriodState`. Enricher still attaches structural evidence via planet-only Canon lookup (evidence layer); deterministic **per-user** position metadata is not exposed.

Internal additions:

- `ThaiLifePeriodPositionMetadataFeasibility` + audit types
- `ThaiLifePeriodPositionMetadataResolver` (null until inputs exist)
- Trace: `lifePeriodPositionFeasibilityResult`, `lifePeriodPositionMetadataBlocker`
- Status blocker refined to root cause: `NEEDS_ARCHETYPE_CONTEXT_METADATA`
- Rise/fall feasibility delegates to position audit (`NEEDS_ENGINE_POSITION_METADATA` remains downstream)

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
| `lifePeriodPositionFeasibilityResult` | `NEEDS_ARCHETYPE_CONTEXT_METADATA` |
| `lifePeriodPositionMetadataBlocker` | `NEEDS_ARCHETYPE_CONTEXT_METADATA` |
| `lifePeriodStatusMetadataBlocker` | `NEEDS_ARCHETYPE_CONTEXT_METADATA` |
| `lifePeriodRiseFallFeasibilityResult` | `NEEDS_ENGINE_POSITION_METADATA` (downstream) |

---

## Proof: user-facing output unchanged

- `ThaiReportCanonEvidenceEnricher.userFacingFingerprint` unchanged before/after enrich.
- Consumer timeline summaries contain no position/status labels.
- Mirror copy, public UI, evidence, and remedies remain internal-only.

Thai validation suite green (includes `thai_life_period_position_metadata_test.dart`).

---

## Remaining blockers

1. **Archetype chart identity** — deterministic runtime field mapping user chart → `archetypeChart.*` without narrative inference.
2. **Period context mapping** — deterministic map from `PeriodState` ages → Canon `life_period` context value (after archetype is available).
3. **Wire position resolver** → rise/fall resolver → period-status discovery.

---

## Recommended next phase

**Archetype Context Metadata**

Expose deterministic internal archetype chart identity from existing Thai engine structures so per-period Canon placement lookup can scope beyond planet-only structural evidence.

---

## Key files

| File | Role |
| --- | --- |
| `lib/features/astrology/thai/core/life_period/thai_life_period_position_metadata.dart` | Position feasibility + resolver stub |
| `lib/features/astrology/thai/core/life_period/thai_life_period_rise_fall_metadata.dart` | Delegates to position audit |
| `test/validation/thai/thai_life_period_position_metadata_test.dart` | Phase validation |
