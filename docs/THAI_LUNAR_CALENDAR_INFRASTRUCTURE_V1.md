# Thai Lunar Calendar Infrastructure V1

> **HISTORICAL (June 2026).** Lunar-lookup infrastructure record. Coverage remains limited to verified entries; uncovered dates degrade gracefully. Dataset plan: [`THAI_LUNAR_DATASET_ACQUISITION_V1.md`](THAI_LUNAR_DATASET_ACQUISITION_V1.md) · index: [`PROJECT_INDEX.md`](PROJECT_INDEX.md).

**Date:** June 2026  
**Type:** Architecture + Prototype Scaffold (No Fake Data)  
**Reference:** `THAI_ASTROLOGY_DOMAIN_VALIDATION_V1.md`, `THAI_FOUNDATION_ENGINE_V1_1_NOTES.md`

---

## 1. Current State Audit

### What the Lunar Layer Supports Today

| Capability | Status | Location |
|------------|--------|----------|
| Chart input model (`ThaiLunarDate`) | ✅ | `foundation/calendar/thai_lunar_date.dart` |
| 06:00 day-boundary helper | ✅ | `foundation/calendar/thai_day_boundary.dart` |
| Lunar month base table (OQ-2) | ✅ | `foundation/calendar/thai_month_base_table.dart` |
| Zodiac year base table (OQ-6) | ✅ | `foundation/calendar/thai_zodiac_year.dart` |
| Gregorian → lunar resolver | ⚠️ Partial | `foundation/calendar/thai_lunar_calendar.dart` |
| Verified lookups | ✅ 2 cases | GC-04, GC-05 only |
| Arbitrary birth dates | ❌ | Returns `LUNAR_DATE_UNVERIFIED` |
| Weekday from ปฏิทิน 100 ปี | ❌ | Not implemented |
| Waxing-day / phase data | ❌ | Not in model yet |
| Intercalary month 8 (สองหน) | ❌ | OQ-LUNAR-8 open |
| Ephemeris / calendar package | ❌ | No dependency in `pubspec.yaml` |

### Data Flow (Current)

```
Gregorian DateTime (ThaiBirthData.localDateTime)
        ↓
ThaiLunarCalendar.resolve()
        ↓
  [verified map hit?] ──yes──→ ThaiLunarDate
        │
        no
        ↓
  LUNAR_DATE_UNVERIFIED warning
        ↓
SevenNumberChart.calculate() → chart = null (myanmar/mahabhuta blocked)
```

### What Is Missing

1. **Authoritative dataset** — ปฏิทิน 100/150 ปี for general Gregorian dates
2. **Repository abstraction** — was inline `Map` in `ThaiLunarCalendar`
3. **Validation layer** — golden-case regression against repository
4. **Dataset versioning** — no manifest / schema
5. **Extended lunar fields** — waxing day, phase, intercalary flag (needed for year boundary)
6. **Day-boundary integration in lookup** — 06:00 rule exists but lookup uses raw civil datetime (matches GC-05 by design)

### Hard Dependencies

| Dependency | Why Hard | Blocks |
|------------|----------|--------|
| Thai lunar date (weekday, month, zodiac year) | Row 1–3 of 4-row chart | Myanmar + Mahabhuta |
| Weekday from 100-year calendar | OQ-1 closed — not `DateTime.weekday` | Row 1 accuracy |
| Lunar month at ขึ้น 1 ค่ำ boundary | OQ-2 closed | Row 2 accuracy |
| Zodiac year at ขึ้น 1 ค่ำ เดือน 5 | OQ-6 closed | Row 3 accuracy |
| Licensed calendar source | Cannot guess lunar data | All real user births |
| `SevenNumberChart` | Consumes `ThaiLunarDate` | Foundation Engine V1.1 |
| `ThaiFoundationEngine` | Orchestrates chart + engines | Theme resolver bridge |

**Not blocked by lunar (independent):** Lagna (sidereal), Lord of Lagna, Theme Resolver, Content.

---

## 2. Architecture Design

### Layer Position

```
Gregorian DateTime
        ↓
┌─────────────────────────────────────┐
│  Thai Lunar Infrastructure (NEW)    │
│  lunar/models, repository,          │
│  providers, validation, datasets    │
└─────────────────────────────────────┘
        ↓ ThaiLunarDate
┌─────────────────────────────────────┐
│  Thai Foundation Engine V1.1        │
│  SevenNumberChart → Myanmar/Mahabhuta│
└─────────────────────────────────────┘
```

### Module Structure (V1 Prototype)

```
foundation/lunar/
├── models/
│   ├── thai_lunar_lookup_key.dart      # Canonical yyyy-MM-dd HH:mm key
│   ├── thai_lunar_record.dart          # Full record + provenance
│   └── thai_lunar_dataset_manifest.dart
├── datasets/
│   ├── thai_lunar_verified_entries.dart   # GC-04, GC-05 only
│   └── thai_lunar_embedded_dataset.dart   # Placeholder spec (empty)
├── repository/
│   └── thai_lunar_repository.dart      # InMemoryThaiLunarRepository
├── providers/
│   └── thai_lunar_calendar_provider.dart
└── validation/
    ├── thai_lunar_golden_cases.dart
    └── thai_lunar_validator.dart
```

### Data Source

| Phase | Source | Notes |
|-------|--------|-------|
| V1 (now) | Verified golden cases only | GC-04 (horawej), GC-05 (sinsaehwang) |
| V1.2 | Licensed ปฏิทิน 100/150 ปี export | เกษมบรรณกิจ / myhora — **requires domain expert + license** |
| Future | Generated from validated algorithm | Only after algorithm is domain-approved |

### Storage Format (Planned)

**Schema version 1** — per-day record:

```json
{
  "key": "1972-04-04 02:00",
  "weekdayNumber": 2,
  "lunarMonthNumber": 5,
  "zodiacYearIndex": 1,
  "waxingDay": 5,
  "phase": "waning",
  "intercalaryMonth8": false,
  "source": "ปฏิทิน 100 ปี",
  "datasetVersion": "2026.06"
}
```

V1 stores verified entries as Dart `const` records (audit trail in code).  
V1.2 will add compressed JSON asset at `assets/thai_astrology/lunar/thai_lunar_1900_2100.json`.

### Lookup Strategy

1. Normalize `ThaiBirthData.localDateTime` → `ThaiLunarLookupKey`
2. Exact match on canonical key `yyyy-MM-dd HH:mm`
3. Future V1.2: optional day-boundary pre-adjustment before lookup (06:00 rule)
4. Future: date-only fallback tier (when birth time unknown) — **separate policy, not in V1**

### Versioning Strategy

| Version | Scope |
|---------|-------|
| `infrastructureVersion` | Lunar module release (`v1`, `v1.2`, …) |
| `schemaVersion` | JSON record shape (integer) |
| `datasetVersion` | Source export date / calendar edition |
| `ThaiCalculationStandards.version` | Foundation chart standard (`v1.1`) — **unchanged** |

Dataset updates are **additive** — new asset file, new manifest entry. Old datasets retained for regression.

### Validation Strategy

- `ThaiLunarValidator.validateGoldenCases(repository)` — CI regression
- Golden cases: GC-04, GC-05 (published citations)
- Future: expand golden set as more dates are verified from horawej/sinsaehwang
- **No synthetic dates** in validation fixtures

---

## 3. Dataset Strategy Comparison

### Option A — Embedded Dataset (1900–2100 in Assets)

| Aspect | Assessment |
|--------|------------|
| **Pros** | Offline, deterministic, fast O(1) lookup, no runtime deps |
| **Cons** | Large asset (~73k days × ~40 bytes ≈ 3–5 MB raw; compressible), manual regeneration on calendar edition change |
| **Size estimate** | ~1–2 MB gzip for 200 years (weekday + month + year + phase) |
| **Maintenance** | Re-export when ปฏิทิน edition updates; version in manifest |
| **Accuracy** | **High** if sourced from licensed ปฏิทิน 100/150 ปี |

### Option B — Generated Dataset (Runtime Algorithm)

| Aspect | Assessment |
|--------|------------|
| **Pros** | Smaller binary, infinite range in theory |
| **Cons** | Algorithm must be domain-validated; intercalary month 8 is complex; high risk of drift vs practitioners |
| **Size** | Code only (~10–50 KB) |
| **Maintenance** | Bug fixes require domain re-validation |
| **Accuracy** | **Unknown** until full OQ-LUNAR-* closed — **not recommended for V1.2 without expert sign-off** |

### Option C — Hybrid (Recommended)

| Aspect | Assessment |
|--------|------------|
| **Pros** | Verified entries in code for CI; embedded asset for coverage; optional generation later |
| **Cons** | Two storage paths to keep in sync for overlap dates |
| **Size** | Small code seed + asset when populated |
| **Maintenance** | Validator ensures seed matches asset for golden keys |
| **Accuracy** | **Highest** — golden cases always pinned; bulk from licensed export |

---

## 4. Recommended Approach for KnowMe

**Choose: Option C — Hybrid**

**Reasons:**

1. Aligns with project rule: **no guessing** — golden cases stay hard-coded with citations
2. Real user births need bulk data — embedded asset from licensed ปฏิทิน is the proven practitioner path (horawej cites เกษมบรรณกิจ 150 ปี)
3. Repository interface already abstracts storage — swap `InMemoryThaiLunarRepository` → `AssetThaiLunarRepository` in V1.2 without touching Foundation Engine
4. Validation layer catches regressions when asset is populated
5. Avoids premature algorithm risk (Option B) before OQ-LUNAR-8 and weekday rules are fully validated

---

## 5. Files Created

| Path | Purpose |
|------|---------|
| `foundation/lunar/models/thai_lunar_lookup_key.dart` | Canonical lookup key |
| `foundation/lunar/models/thai_lunar_record.dart` | Record + provenance |
| `foundation/lunar/models/thai_lunar_dataset_manifest.dart` | Coverage metadata |
| `foundation/lunar/datasets/thai_lunar_verified_entries.dart` | GC-04, GC-05 |
| `foundation/lunar/datasets/thai_lunar_embedded_dataset.dart` | Asset placeholder spec |
| `foundation/lunar/repository/thai_lunar_repository.dart` | Repository interface + in-memory impl |
| `foundation/lunar/providers/thai_lunar_calendar_provider.dart` | Resolution facade |
| `foundation/lunar/validation/thai_lunar_golden_cases.dart` | Golden expectations |
| `foundation/lunar/validation/thai_lunar_validator.dart` | Regression validator |
| `test/thai_lunar_infrastructure_test.dart` | Infrastructure tests |
| `docs/THAI_LUNAR_CALENDAR_INFRASTRUCTURE_V1.md` | This document |

---

## 6. Files Modified

| Path | Change |
|------|--------|
| `foundation/calendar/thai_lunar_calendar.dart` | Delegates to `ThaiLunarCalendarProvider` |
| `foundation/calendar/thai_lunar_date.dart` | Added `embeddedDataset`, `generated` source enums |

**Not modified (by design):** Theme, Content, Resolver, Mirror, Fusion, Myanmar/Mahabhuta formulas, `SevenNumberChart` math.

---

## 7. Coverage Plan

### V1 (Current)

| Range | Coverage | Count |
|-------|----------|-------|
| All Gregorian dates | Golden cases only | **2 entries** |

### V1.2 Target

| Range | Coverage | Rationale |
|-------|----------|-----------|
| **1900-01-01 → 2100-12-31** | Full embedded dataset | Covers typical user birth years (≈ age 0–200) with margin; matches common ปฏิทิน 100 ปี scope |

### Exclusions (V1.2 planning)

- Pre-1900 births: defer unless product requires
- Sub-minute birth times: lookup at minute precision (current key format)
- Unknown birth time: separate date-only policy (future OQ)

### Validation Milestones for V1.2

1. GC-04, GC-05 pass (mandatory)
2. Add 10+ horawej worked examples (domain expert curated)
3. Spot-check 100 random dates against myhora / เกษมบรรณกิจ manual lookup
4. Intercalary month 8 cases explicitly verified (OQ-LUNAR-8)

---

## 8. Validation Strategy (Detail)

### Layers

```
┌────────────────────────────────────────┐
│  ThaiLunarValidator (golden cases)   │  ← CI, every PR
├────────────────────────────────────────┤
│  thai_lunar_infrastructure_test.dart │
├────────────────────────────────────────┤
│  thai_foundation_engine_test.dart      │  ← GC-04/05 end-to-end
└────────────────────────────────────────┘
```

### Golden Case Contract

| ID | Key | weekday | lunarMonth | zodiacYear | Source |
|----|-----|---------|------------|------------|--------|
| GC-04 | 1949-09-11 00:15 | 7 | 10 | 2 | horawej |
| GC-05 | 1972-04-04 02:00 | 2 | 5 | 1 | sinsaehwang |

### Failure Modes

| Failure | Action |
|---------|--------|
| Missing entry | Block dataset release |
| Field mismatch | Block dataset release |
| Unverified user date | `LUNAR_DATE_UNVERIFIED` (current behaviour) |

---

## 9. Open Questions

| ID | Question | Impact | Owner |
|----|----------|--------|-------|
| OQ-LUNAR-SOURCE | Which licensed ปฏิทิน edition (100 vs 150 ปี)? | Dataset accuracy | Domain expert |
| OQ-LUNAR-8 | เดือน 8 สองหน — use month 8 or special flag? | Row 2 for affected dates | Domain expert |
| OQ-LUNAR-WD | Confirm weekday always from calendar table, not ephemeris | Row 1 | Domain expert |
| OQ-LUNAR-0600 | Apply 06:00 boundary before or after lookup key? | GC-05 depends on pre-06:00 key | Domain expert |
| OQ-LUNAR-NOTIME | Policy when `hasBirthTime == false` | Coverage for time-unknown births | Product + domain |
| OQ-LUNAR-ASSET | JSON vs binary (protobuf/msgpack) for 200-year asset | Load time / size | Engineering |
| OQ-LUNAR-TZ | Non-Bangkok timezones — local civil vs fixed offset | International users | Product |

---

## 10. Blast Radius Assessment

| Area | Risk | Notes |
|------|------|-------|
| `ThaiLunarCalendar.resolve()` | **Low** | Same public API; delegates internally |
| `SevenNumberChart.calculate()` | **None** | Unchanged |
| `ThaiFoundationEngine` | **None** | Unchanged |
| Theme / Content / Resolver | **None** | Not touched |
| Myanmar / Mahabhuta formulas | **None** | Not touched |
| Tests | **Low** | +8 infrastructure tests; existing 88 must pass |
| Future V1.2 dataset load | **Medium** | New asset + pubspec entry; isolated to repository impl |

**Regression risk:** Minimal — verified entries moved to `ThaiLunarVerifiedEntries` with identical values.

---

## 11. Definition of Done

- [x] Current state audit documented
- [x] Architecture design with data source, storage, lookup, versioning, validation
- [x] Dataset strategy comparison (A / B / C)
- [x] One recommended approach (Hybrid)
- [x] Prototype folder structure created
- [x] No fake / guessed lunar data
- [x] `ThaiLunarCalendar` delegates to repository (backward compatible)
- [x] Validation layer for golden cases
- [x] Coverage plan defined
- [x] `flutter analyze` clean
- [x] `flutter test` — all Thai tests pass
- [ ] V1.2: Populate 1900–2100 asset from licensed source (**out of scope V1**)
- [ ] V1.2: `AssetThaiLunarRepository` implementation (**out of scope V1**)

---

## 13. Success Criteria Check

| Criterion | Status |
|-----------|--------|
| Clear architecture | ✅ |
| Clear dataset strategy | ✅ Hybrid recommended |
| No fake data | ✅ Only GC-04/GC-05 verified |
| No domain regression | ✅ Validator + existing GC tests |
| Ready for Foundation V1.2 | ✅ Repository interface ready |
| Ready for Thai Mirror V1 | ✅ Lunar SoT layer defined (data pending) |

---

## Related Documents

- **Dataset acquisition plan:** `THAI_LUNAR_DATASET_ACQUISITION_V1.md`
- **JSON schema (no data):** `lib/.../lunar/datasets/thai_lunar_dataset_schema_v1.json`

---

## Appendix: V1.2 Integration Checklist

1. Obtain licensed ปฏิทิน 100/150 ปี export
2. Generate `assets/thai_astrology/lunar/thai_lunar_1900_2100.json`
3. Implement `AssetThaiLunarRepository` with lazy load + canonical map
4. Register asset in `pubspec.yaml`
5. Run `ThaiLunarValidator` + expanded golden set
6. Update manifest `coverageStatus` → `complete`
7. Bump `infrastructureVersion` → `v1.2`
