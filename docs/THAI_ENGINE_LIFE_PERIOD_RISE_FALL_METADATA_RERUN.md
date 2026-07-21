# Thai Engine Life Period Rise/Fall Metadata Re-run

Phase: **Engine Life Period Rise/Fall Metadata Re-run**

Prerequisites:

- Engine Life Period Rise Fall Metadata Completion
- Period Context Normalization (`d46d316`)
- Life Period Position Strategy Correction (`c6a8355`)

---

## Why re-run was needed

Life Period Position Strategy Correction raised position metadata from 7 → 65 periods via the archetype+planet unique-placement path. Rise/fall runtime status attached in the same enricher loop, but trace did not distinguish:

- status source (`exact_life_period_context` vs `archetype_planet_unique_position`)
- explicit blocker classification for the remaining 21 periods
- separation from Canon-derived `[ดวงขึ้น]` / `[ดวงตก]` marker fallback

This re-run verifies every resolved position produces p17-backed runtime status and hardens QA trace without changing public output.

---

## Position strategy correction impact

| Metric | Before correction | After correction | After re-run |
| --- | ---: | ---: | ---: |
| `lifePeriodsWithPositionMetadata` | 7 | 65 | **65** |
| `lifePeriodsWithoutPositionMetadata` | 79 | 21 | **21** |
| `lifePeriodsWithRuntimeStatus` | 7 | 65 | **65** |
| `lifePeriodsWithoutRuntimeStatus` | 79 | 21 | **21** |

Re-run confirms: **65 position = 65 runtime** — every position metadata entry has a matching p17 structural rule. Zero `NO_P17_RULE_FOR_POSITION` cases.

---

## Status source breakdown (9-fixture aggregate)

| Source | Count |
| --- | ---: |
| `runtimeStatusFromExactLifePeriodContext` | **7** |
| `runtimeStatusFromUniqueArchetypePlanetPosition` | **58** |
| Runtime `periodStatus` evidence attachments (non-derived) | **≥ 65** |
| Canon-derived marker fallback (`:periodStatus:canonDerived:`) | **10** (separate) |

Canon-derived fallback is **not** promoted into runtime metadata. Periods with runtime status do not receive canon-derived attachments for the same signal.

---

## Remaining 21 blockers

Every period without runtime status has an explicit `periodIndex:blocker` entry in `runtimeStatusWithoutPositionBreakdown`:

| Blocker | Count | Description |
| --- | ---: | --- |
| `AMBIGUOUS_POSITION` | **18** | Multiple Canon placements for archetype+planet pair |
| `SOURCE_CONFLICT` | **3** | Source-internal tension (includes ดวงนักวิชาการ Jupiter) |
| `MISSING_POSITION` | **0** | No indexed placement evidence |
| `NO_P17_RULE` | **0** | Position resolved but no p17 classification |

No unknown bucket. No inference attempted.

---

## Conflict handling

- `archetypeChart.nakwichakan:planet.jupiter` — `SOURCE_CONFLICT`, resolver returns `null`, listed in `runtimeStatusBlockedBySourceConflict` and `conflictedArchetypePlanetPairs`
- Conflict is traced, never resolved manually or hidden

---

## Public output proof

Validated by `thai_engine_life_period_rise_fall_metadata_rerun_test.dart`:

- `ThaiReportCanonEvidenceEnricher.userFacingFingerprint` unchanged
- Consumer timeline summaries contain no `ดวงขึ้น` / `ดวงตก`
- All `periodStatus` attachments `userFacingAllowed: false`
- Remedies internal/skipped (87)
- Full Thai validation suite: **551 / 551 pass**

---

## Recommended next phase

**Internal Evidence Badge Prototype**

Rise/fall internal metadata is stable at 65/86 with explicit blocker trace. Next productive step is a non-user-facing evidence badge prototype for QA/review surfaces only.
