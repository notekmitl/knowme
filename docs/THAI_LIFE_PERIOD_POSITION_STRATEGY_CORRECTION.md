# Thai Life Period Position Strategy Correction

Phase: **Life Period Position Strategy Correction**

Prerequisites:

- Remainder metadata complete
- Archetype context metadata complete
- Period context normalization (`d46d316`)

Prior blocker: exact `life_period` age-context matching capped position metadata at 7/86 periods.

---

## Why Age Range Metadata is not the right next step

Age Range Metadata would bridge user dasha windows to Canon example-chart age labels. That remains a valid long-term modeling path, but it does **not** unblock Mahabhut **position** when Canon already records a unique planet placement per archetype chart.

Runtime periods always expose `archetypeChartCanonId` + governing `planet`. Frozen Canon exposes `planet.* --located_in--> mahabhutPosition.*` under `archetype_chart` context and under `life_period` context on archetype-scoped pages. Resolving position from archetype + planet is source-backed without inventing age alignment.

---

## Placement index audit result

**Classification: `PARTIAL_READY_WITH_AMBIGUITIES`**

Index built from page-provenanced units only (`located_in` → `mahabhutPosition.*`), scoped by:

1. `archetype_chart` context label → ontology `archetypeChart.*`
2. `life_period` context when evidence page falls in frozen Phase D archetype section range

| Classification | Count |
| --- | ---: |
| `UNIQUE_POSITION` | **44** |
| `MISSING_POSITION` | **0** |
| `AMBIGUOUS_POSITION` | **11** |
| `SOURCE_CONFLICT` | **1** |
| `OCR_BLOCKED` | **0** |
| Total indexed pairs | **56** |

Known conflict (not hidden): `archetypeChart.nakwichakan:planet.jupiter` — Canon retains verbatim `ธงชัย` vs `ขุมทรัพย์` tension on p.220. Resolver returns `null`.

---

## Implemented resolver

**Yes** — `ThaiLifePeriodArchetypePlanetPositionResolver` + `ThaiArchetypePlanetPlacementIndex`.

`ThaiLifePeriodPositionMetadataResolver.resolveCombined` priority:

1. `exact_life_period_context` (unchanged path when period context metadata exists)
2. `archetype_planet_unique_position` (new path)

Rules enforced:

- archetype + planet + Canon evidence required
- `UNIQUE_POSITION` only
- `null` for missing, ambiguous, source conflict
- no sequence, age order, or planet-alone fallback

---

## Before / after counts (9-fixture aggregate)

| Metric | Before | After |
| --- | ---: | ---: |
| `lifePeriodsWithPositionMetadata` | 7 | **65** |
| `lifePeriodsWithoutPositionMetadata` | 79 | **21** |
| `lifePeriodsWithRuntimeStatus` | 7 | **65** |
| `lifePeriodsWithoutRuntimeStatus` | 79 | **21** |
| `lifePeriodsWithPeriodContextMetadata` | 8 | **8** (unchanged) |

Match methods now traced via `positionMatchMethods` (`exact_life_period_context` + `archetype_planet_unique_position`).

---

## Conflict handling

| Pair / case | Behavior |
| --- | --- |
| `archetypeChart.nakwichakan:planet.jupiter` | `SOURCE_CONFLICT` — `null`, listed in `conflictedArchetypePlanetPairs` |
| Ambiguous pairs (11) | `null`, listed in `ambiguousArchetypePlanetPairs` |
| Periods without unique placement | `null`, reasons in `positionMetadataMissingReasons` |

Conflicts are traced, never resolved manually or hidden.

---

## Remaining unmatched reasons (21 periods)

- No Canon placement for planet in archetype (unindexed pair)
- `AMBIGUOUS_ARCHETYPE_PLANET_PLACEMENT`
- `SOURCE_CONFLICT_ARCHETYPE_PLANET_PLACEMENT` (Jupiter in นักวิชาการ when archetype applies)
- `NO_P17_RULE_FOR_POSITION` after position resolves (blocks runtime rise/fall only)

---

## Public output proof

Validated by `thai_life_period_position_strategy_correction_test.dart` and existing public-surface isolation tests:

- `ThaiReportCanonEvidenceEnricher.userFacingFingerprint` unchanged
- Consumer timeline summaries contain no `ดวงขึ้น` / `ดวงตก`
- Remedies internal/skipped (87)
- Full Thai validation suite: **540 / 540 pass**

---

## Recommended next phase

**Engine Life Period Rise/Fall Metadata Re-run**

Position metadata coverage increased from 7 → 65; runtime rise/fall metadata attached for the same 65 periods via existing `ThaiLifePeriodRiseFallResolver`. A dedicated re-run phase should validate p17 rule coverage for newly resolved positions, trace gaps for the remaining 21 periods, and confirm no user-facing leakage.
