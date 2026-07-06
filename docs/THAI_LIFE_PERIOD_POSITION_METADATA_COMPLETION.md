# Thai Life Period Position Metadata Completion

Phase: **Life Period Position Metadata Completion**

Prerequisites: Period Context Mapping (`3201bed`).

---

## Exact matching rule

A runtime life period receives Mahabhut position metadata **only** when all prerequisites are present:

```
archetypeChartCanonId
+ canonLifePeriodContextValue (from ThaiLifePeriodContextMetadata)
+ runtime period planet (exact match)
+ Canon unit:
    planet.<planet> --located_in--> mahabhutPosition.<position>
    context.type = life_period
    context.value = exact canonLifePeriodContextValue
    source page within frozen archetype Phase D range
```

Resolver: `ThaiLifePeriodPositionMetadataResolver`.

`null` is returned when period context metadata is absent, planet mismatches, Canon placement is missing, or multiple positions are ambiguous.

No sequence-only, age-order-only, planet-only, or narrative inference.

---

## Input prerequisites

| Prerequisite | Source |
| --- | --- |
| Archetype chart identity | `ThaiArchetypeContextMetadata` |
| Life-period context value | `ThaiLifePeriodContextMetadata` |
| Governing planet | `PeriodState.planet` |
| Canon evidence | `ThaiCanonEvidenceIndex` placement units |

Only periods with existing period context metadata are eligible.

---

## Metadata fields exposed (internal)

`ThaiLifePeriodPositionMetadata`:

| Field | Description |
| --- | --- |
| `periodIndex` | Runtime period index |
| `runtimePlanet` | Governing planet name |
| `archetypeChartCanonId` | Frozen archetype chart id |
| `canonLifePeriodContextValue` | Exact Canon `life_period` label |
| `mahabhutPositionCanonId` | Resolved `mahabhutPosition.*` |
| `canonEvidenceUnitId` | Provenance unit id |
| `sourcePage` | Canon source page |
| `contextType` | `life_period` |
| `contextValue` | Same as canon life_period label |
| `confidence` | `deterministic` |

Not rendered in UI. Not attached to prediction or Mirror copy.

---

## Updated counts (9-fixture aggregate)

| Metric | Count |
| --- | ---: |
| `lifePeriodsWithPeriodContextMetadata` | **8** |
| `lifePeriodsWithoutPeriodContextMetadata` | **78** |
| `lifePeriodsWithPositionMetadata` | **7** |
| `lifePeriodsWithoutPositionMetadata` | **79** |

`lifePeriodsWithPositionMetadata <= lifePeriodsWithPeriodContextMetadata` (one fixture has context without resolvable placement).

---

## Blocker status

| Layer | Status |
| --- | --- |
| Remainder metadata | Cleared |
| Archetype context | Cleared |
| Period context | `NEEDS_PERIOD_CONTEXT_MAPPING` (78 unmatched) |
| Life-period position | **`PARTIAL_POSITION_METADATA`** (7 matched; 79 without) |
| Rise/fall status | `NEEDS_ENGINE_POSITION_METADATA` — 7 periods eligible, 79 ineligible |

---

## Why unmatched periods were not inferred

- **78 periods** lack exact Canon `life_period` context labels for user dasha windows (carried from Period Context Mapping).
- **1 additional period** has context but no unambiguous Canon placement unit (`harness_g` first period).
- Sequence, age order, planet alone, and prediction prose are forbidden inputs.

---

## Proof: user-facing output unchanged

- User-facing fingerprint unchanged before/after enrich.
- Consumer timeline/report text contains no `ดวงขึ้น` / `ดวงตก` or Canon position labels.
- Remedies remain internal (87 skipped per fixture).

Thai validation suite green (includes `thai_life_period_position_metadata_completion_test.dart`).

---

## Recommended next phase

**Engine Life Period Rise/Fall Metadata Completion**

---

## Key files

| File | Role |
| --- | --- |
| `lib/features/astrology/thai/core/life_period/thai_life_period_position_metadata.dart` | Resolver + feasibility |
| `lib/features/astrology/thai/knowledge/canon/integration/thai_report_canon_evidence_enricher.dart` | Internal trace wiring |
| `test/validation/thai/thai_life_period_position_metadata_completion_test.dart` | Phase validation |
