# Thai Engine Life Period Rise/Fall Metadata

Phase: **Engine Life Period Rise/Fall Metadata** (blocker-only — metadata not exposed)

Prerequisites: Mahabhut Canon Complete, Canon Evidence Mapping, Thai Report Canon Evidence Upgrade, Thai Canon Period Status Mapping, Thai Life Period Status Metadata Layer, Thai Canon-Derived Period Status Evidence Annotation.

---

## Feasibility audit result

**Classification: `NEEDS_ENGINE_POSITION_METADATA`**

| Check | Result |
| --- | --- |
| Governing planet per life period | **Yes** — `PeriodState.planet` on every period in `LifeTimeline` |
| Mahabhut position per life period | **No** — not computed at runtime; `ThaiAstrologyProfile.mahabhutaPositionKeys` are natal birth positions only |
| Archetype/chart context per life period | **No** — exists on frozen Canon `life_period` units only (evidence layer) |
| Rise/fall already on engine models | **No** — no `riseFallStatus` / label field on `PeriodState` |
| p17–18 rules classifiable from existing fields alone | **No** — frozen p17 maps `periodStatus.*` ↔ `mahabhutPosition.*` at `life_period` context; requires per-period planet placement |

Canon structural rules (p17) are **present and not OCR-blocked** — not `BLOCKED_BY_SOURCE_GAP`.

Current model cannot represent per-period Mahabhut placement without new engine output — not `BLOCKED_BY_MODELING_GAP` for the whole stack, but **position metadata is the specific missing layer**.

**Implementation decision:** Do **not** populate `PeriodState` rise/fall fields or wire production discovery from engine metadata until per-period Mahabhut position is available. Internal resolver and p17 rule constants are defined for deterministic use once inputs exist.

---

## Source fields audited

| Source | Used for rise/fall today |
| --- | --- |
| `LifeTimeline.periods[].planet` | Available; insufficient alone |
| `LifeTimeline.periods[].startAge/endAge/strength` | Sequence only; not status |
| `ThaiAstrologyProfile.mahabhutaPositionKeys` | Natal only; not keyed by period index |
| Frozen Canon p17 position sets | Rule reference in `ThaiLifePeriodRiseFallP17Rules` |
| Canon `life_period` context markers | Fallback via `ThaiCanonPeriodStatusFromEvidence` (prior phase) |
| `easeIndex` / narrative copy | **Not used** |

---

## Status resolver rules (defined, not wired to production)

`ThaiLifePeriodRiseFallResolver.canonIdForMahabhutPosition`:

| Mahabhut position (frozen p17) | Canon status id |
| --- | --- |
| `mahabhutPosition.thongchai` | `periodStatus.duengKhuen` |
| `mahabhutPosition.khumsap` | `periodStatus.duengKhuen` |
| `mahabhutPosition.racha` | `periodStatus.duengKhuen` |
| `mahabhutPosition.athibodi` | `periodStatus.duengKhuen` |
| `mahabhutPosition.phangkha` | `periodStatus.duengTok` |
| `mahabhutPosition.marana` | `periodStatus.duengTok` |
| `mahabhutPosition.puti` | `periodStatus.duengTok` |
| Missing / unknown position | **`null`** (no guess) |

Discovery priority (when metadata becomes available):

1. Runtime engine metadata (`ThaiCanonPeriodStatusDiscovery` → `LifePeriodStatusMetadataResolver.byPeriodIndex`)
2. Canon-derived evidence marker (`ThaiCanonPeriodStatusFromEvidence`)
3. None

---

## Metadata implemented or blocked

**Blocked.** No `riseFallStatus` on `PeriodState`. Production enricher does not attach `:periodStatus:` from engine metadata.

Internal additions:

- `ThaiLifePeriodRiseFallFeasibility` + audit types
- `ThaiLifePeriodRiseFallResolver` (null unless Mahabhut position supplied)
- Trace: `lifePeriodRiseFallFeasibilityResult`, `lifePeriodsWithRuntimeStatus`
- Blocker refined: `NEEDS_ENGINE_POSITION_METADATA` (replaces `BLOCKED_BY_RUNTIME_STATUS_ABSENCE` string)

---

## Updated counts (9-fixture aggregate)

| Metric | Count |
| --- | ---: |
| `lifePeriodsWithRuntimeStatus` | **0** |
| `lifePeriodsWithCanonDerivedStatus` | **52** |
| `lifePeriodsWithoutRuntimeStatus` | **86** |
| `lifePeriodsWithoutCanonStatusMarker` | **34** |

QA override (`periodStatusLabelsByIndex: {0: 'ดวงขึ้น'}`) populates `lifePeriodsWithRuntimeStatus` for that fixture only.

---

## Blocker status

| Field | Value |
| --- | --- |
| `lifePeriodRiseFallFeasibilityResult` | `NEEDS_ENGINE_POSITION_METADATA` |
| `lifePeriodStatusMetadataBlocker` | `NEEDS_ENGINE_POSITION_METADATA` |

Blocker remains visible on enricher trace and alignment classifier — not silently hidden.

---

## Proof: user-facing output unchanged

- `ThaiReportCanonEvidenceEnricher.userFacingFingerprint` unchanged before/after enrich (all fixtures).
- Thai Consumer Report life-timeline summaries contain no `ดวงขึ้น` / `ดวงตก`.
- Mirror copy, Daily Mirror, and public Thai beta pages unchanged.
- Canon evidence and remedies remain internal-only (`userFacingAllowed: false`).

Thai validation suite: **388+ tests green** (includes `thai_engine_life_period_rise_fall_metadata_test.dart`).

---

## Remaining blockers

1. **Per-period Mahabhut position** — engine must expose governing-planet placement per life-period index (and archetype context if required by frozen Canon life_period units).
2. **Wire resolver output** to `LifePeriodStatusMetadataResolver.byPeriodIndex` once inputs exist.
3. **Clear** `lifePeriodStatusMetadataBlocker` only when all periods have deterministic status or explicit partial trace.

---

## Recommended next phase

**Life Period Position Metadata**

Compute and expose per-life-period Mahabhut position (and any required archetype context) from existing Thai engine structures without changing user-facing copy — enabling `ThaiLifePeriodRiseFallResolver` on the production path.

---

## Key files

| File | Role |
| --- | --- |
| `lib/features/astrology/thai/core/life_period/thai_life_period_rise_fall_metadata.dart` | Feasibility audit, p17 rules, resolver |
| `lib/features/astrology/thai/core/life_period/life_period_status_metadata.dart` | Metadata audit + resolver entry |
| `lib/features/astrology/thai/knowledge/canon/integration/thai_canon_period_status_discovery.dart` | Discovery priority wiring |
| `test/validation/thai/thai_engine_life_period_rise_fall_metadata_test.dart` | Phase validation |
