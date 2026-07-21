# Thai Period Context Normalization

Phase: **Period Context Normalization**

Prerequisites:

- Period Context Mapping (`3201bed`)
- Life Period Position Metadata Completion (`7d878b1`)
- Engine Life Period Rise/Fall Metadata Completion (`63906bd`)

---

## Feasibility audit result

**Classification: `READY_TO_NORMALIZE_PERIOD_CONTEXT`**

| Question | Answer |
| --- | --- |
| Stable period index? | **Yes** — `PeriodState.index` |
| Structured runtime age range? | **Yes** — `startAge` / `endAge` (inclusive) |
| Governing planet? | **Yes** — `PeriodState.planet` |
| Canon `life_period` labels? | **Yes** — frozen Phase D mahabhut placements |
| Digit / punctuation / spacing normalization needed? | **Yes** — Thai digits, hyphen ranges, bracket markers |
| Safe without sequence inference? | **Yes** — wire keys require explicit age structure |

Implementation proceeded. Normalization infrastructure is in place; aggregate match counts are unchanged because the dominant gap is **runtime dasha age windows ≠ Canon example-chart ages**, not label representation.

---

## Runtime period fields found

| Field | Source | Used in normalization |
| --- | --- | --- |
| `index` | `PeriodState.index` | Trace anchor only — **not** used for matching |
| `startAge` / `endAge` | `PeriodState` inclusive range | `fromRuntimePeriod` → `ageRange:start-end` wire key |
| `planet` | `PeriodState.planet` → `planet.*` | Scoped Canon unit filter (raw + normalized paths) |
| Archetype scope | `ThaiArchetypeContextMetadata.archetypeChartCanonId` | Phase D page ranges |
| Display / prose label | Consumer presenter copy | **Not** used for matching |

No hidden structural label beyond numeric ages and planet on `PeriodState`.

---

## Canon context patterns found

| Pattern | Example | Normalizer output |
| --- | --- | --- |
| Birth label | `แรกเกิด` | `birth:1` |
| Point age | `อาย ๓๒`, `อายุ 53` | `pointAge:32`, `pointAge:53` |
| Age range (Thai digits) | `อาย ๒๒ ถึง ๕๕` | `ageRange:22-55` |
| Age range (hyphen) | `อายุ 22-32` | `ageRange:22-32` |
| Age range + status marker | `อาย ๓๓ ถึง ๕๕ [ดวงขึ้น]` | `ageRange:33-55\|status:duengKhuen` |
| Prose without age structure | `ดวงนักวิชาการ` | `null` wire key (ambiguous) |

Status markers `[ดวงขึ้น]` / `[ดวงตก]` are preserved structurally on Canon keys; matching compares base age wire only (`_baseWire` strips `|status:`).

---

## Normalization rules

`ThaiLifePeriodContextNormalizer`:

1. Preserve `rawLabel` (source string unchanged).
2. Collapse whitespace.
3. Convert Thai digits `๐–๙` → Arabic `0–9`.
4. Parse `อาย` / `อายุ` + `ถึง` range, or hyphen `–` / `-` range.
5. Extract bracket status markers without discarding them from metadata.
6. Do **not** infer missing age start/end, planet, or status.
7. Return `null` wire key for ambiguous / prose-only labels.

Wire key examples:

- `ageRange:22-32`
- `pointAge:32`
- `birth:1`
- `ageRange:33-55|status:duengKhuen`

---

## Matching priority

`ThaiLifePeriodContextResolver.resolveDetailed`:

1. **Raw structural match** — existing `_matchesPeriod` on parsed Canon label + planet scope.
2. **Normalized age range + planet** — `matchesRuntimeToCanon` on scoped units; single candidate only.
3. **Normalized age range unique per archetype** — same base wire key, exactly one Canon label in archetype pages (no planet-only guess).
4. **`null`** — ambiguity, missing ages, or no Canon context.

Forbidden: period index alone, sequence order, prediction prose, easeIndex, similar Thai prose.

---

## Ambiguity rules

| Condition | Result |
| --- | --- |
| Multiple Canon contexts match one runtime period | `null`, `ambiguousCandidates` recorded |
| Runtime lacks parseable age range | `null`, `MISSING_RUNTIME_AGE_RANGE` |
| Canon label lacks age structure | skipped in normalized path; label in `periodContextMissingCanonAgeRange` |
| Multiple normalized keys collide | `null`, `AMBIGUOUS_NORMALIZED_CONTEXT` |

---

## Before / after counts (9-fixture aggregate)

| Metric | Before | After |
| --- | ---: | ---: |
| `lifePeriodsWithPeriodContextMetadata` | 8 | **8** |
| `lifePeriodsWithoutPeriodContextMetadata` | 78 | **78** |
| `lifePeriodsWithPositionMetadata` | 7 | **7** |
| `lifePeriodsWithoutPositionMetadata` | 79 | **79** |
| `lifePeriodsWithRuntimeStatus` | 7 | **7** |
| `lifePeriodsWithoutRuntimeStatus` | 79 | **79** |
| `periodContextRawMatches` | — | **8** |
| `periodContextNormalizedMatches` | — | **0** |
| `lifePeriodsWithCanonDerivedStatus` | 49 | **49** (unchanged) |

All 8 existing matches are raw-path matches (including `แรกเกิด` and exact-range cases already handled before normalization). No new periods gained context via normalized-only path in the 9-fixture suite.

---

## Remaining unmatched reasons

| Reason | Description |
| --- | --- |
| `NO_CANON_CONTEXT_FOR_PERIOD` | Runtime `[startAge,endAge]` has no Canon label with same normalized wire key in archetype scope |
| Archetype / planet scope | Canon unit exists for different planet or outside Phase D page range |
| `AMBIGUOUS_*` | Multiple Canon labels normalize to same key (returns null) |
| Prose-only Canon labels | No structured age range on Canon side |
| Dasha vs example-chart ages | User engine periods use computed dasha boundaries; Canon uses fixed example ages per archetype chart |

`periodContextNormalizationBlocker`: `NEEDS_PERIOD_CONTEXT_MAPPING` (partial coverage; normalization alone does not close the age-window gap).

---

## Public output proof

Validated by `thai_period_context_normalization_test.dart`:

- `ThaiReportCanonEvidenceEnricher.userFacingFingerprint` unchanged before/after enrich.
- Consumer timeline summaries contain no `ดวงขึ้น` / `ดวงตก`.
- All evidence attachments `userFacingAllowed: false`; remedies skipped (87).
- Full Thai validation suite: **526 / 526 pass**.

No changes to Mirror copy, prediction copy, Daily Mirror, or public UI.

---

## Recommended next phase

**Age Range Metadata**

Normalization is complete and safe, but coverage is blocked because runtime dasha windows rarely equal frozen Canon example ages. The next productive step is structured age-range metadata that bridges engine output to Canon context without sequence inference or user-facing exposure.
