# Thai Engine Life Period Rise/Fall Metadata Completion

Phase: **Engine Life Period Rise/Fall Metadata Completion**

Prerequisites: Life Period Position Metadata Completion (`7d878b1`).

---

## Exact resolver rule

Runtime rise/fall metadata is produced **only** when all prerequisites are present:

```
ThaiLifePeriodPositionMetadata
+ mahabhutPositionCanonId
+ Canon p17 structural rule (ThaiLifePeriodRiseFallP17Rules)
→ periodStatus.duengKhuen | periodStatus.duengTok
```

Resolver: `ThaiLifePeriodRiseFallResolver`.

Mapping:

| Mahabhut position set | Status Canon id | Label |
| --- | --- | --- |
| thongchai, khumsap, racha, athibodi | `periodStatus.duengKhuen` | ดวงขึ้น |
| phangkha, marana, puti | `periodStatus.duengTok` | ดวงตก |

`null` when position metadata is absent or position is outside p17 sets. No planet-only, sequence, or narrative inference.

Canon-derived `[ดวงขึ้น]` / `[ดวงตก]` context markers remain fallback evidence only — not runtime metadata.

---

## Input prerequisites

| Prerequisite | Source |
| --- | --- |
| Position metadata | `ThaiLifePeriodPositionMetadata` |
| p17 rule | `ThaiLifePeriodRiseFallP17Rules` |
| Status provenance | Canon `periodStatus.*` units via repository |

---

## Status metadata fields exposed (internal)

`ThaiLifePeriodRiseFallRuntimeMetadata`:

| Field | Description |
| --- | --- |
| `periodIndex` | Runtime period index |
| `periodStatusCanonId` | `periodStatus.duengKhuen` or `.duengTok` |
| `periodStatusLabel` | `ดวงขึ้น` or `ดวงตก` |
| `mahabhutPositionCanonId` | From position metadata |
| `positionEvidenceUnitId` | Position provenance |
| `statusEvidenceUnitId` | p17 status unit when present |
| `sourcePage` | Canon page |
| `source` | `runtime_position_plus_canon_rule` |
| `confidence` | `deterministic` |

Not rendered in UI. Not attached to prediction or Mirror copy.

---

## Evidence discovery priority

1. **Runtime rise/fall metadata** (position + p17 rule)
2. **Canon-derived exact context marker** (annotation only)
3. **None**

Periods with runtime status use runtime-derived evidence attachments. Periods without runtime may still receive canon-derived marker annotations when unambiguous.

---

## Updated counts (9-fixture aggregate)

| Metric | Count |
| --- | ---: |
| `lifePeriodsWithPositionMetadata` | **7** |
| `lifePeriodsWithoutPositionMetadata` | **79** |
| `lifePeriodsWithRuntimeStatus` | **7** |
| `lifePeriodsWithoutRuntimeStatus` | **79** |
| `lifePeriodsWithCanonDerivedStatus` | **49** |
| `lifePeriodsWithoutCanonStatusMarker` | **30** |

`lifePeriodsWithRuntimeStatus <= lifePeriodsWithPositionMetadata`.

---

## Blocker status

| Layer | Status |
| --- | --- |
| Period context | `NEEDS_PERIOD_CONTEXT_MAPPING` |
| Life-period position | `PARTIAL_POSITION_METADATA` |
| Rise/fall runtime | **`PARTIAL_RUNTIME_STATUS_METADATA`** |

---

## Why ineligible periods were not inferred

- **79 periods** lack position metadata (no p17 input).
- **1 period** has context but no resolvable placement (`harness_g`).
- Planet, sequence, age order, prediction prose, and Canon-derived markers are forbidden as runtime status inputs.

---

## Proof: user-facing output unchanged

- User-facing fingerprint unchanged before/after enrich.
- Consumer timeline/report text contains no `ดวงขึ้น` / `ดวงตก`.
- Remedies remain internal (87 skipped per fixture).

Thai validation suite green (includes `thai_engine_life_period_rise_fall_metadata_completion_test.dart`).

---

## Recommended next phase

**Period Context Normalization**

---

## Key files

| File | Role |
| --- | --- |
| `lib/features/astrology/thai/core/life_period/thai_life_period_rise_fall_metadata.dart` | Resolver + feasibility |
| `lib/features/astrology/thai/core/life_period/life_period_status_metadata.dart` | Status audit + label export |
| `lib/features/astrology/thai/knowledge/canon/integration/thai_report_canon_evidence_enricher.dart` | Runtime priority wiring |
| `test/validation/thai/thai_engine_life_period_rise_fall_metadata_completion_test.dart` | Phase validation |
