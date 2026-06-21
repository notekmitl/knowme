# Thai Foundation Engine V1.1 — Implementation Notes

**Date:** June 2026  
**Type:** Domain Accuracy Upgrade (Foundation Layer Only)  
**Reference:** `THAI_ASTROLOGY_DOMAIN_VALIDATION_V1.md`

---

## What Changed (V1 → V1.1)

| Area | V1 (removed) | V1.1 (validated) |
|------|--------------|------------------|
| Merge formula | Scalar `mod-7` merge | **4-row table + vertical sum** |
| Month base | Gregorian month proxy | **Lunar month paired table** |
| Year base | `(year-4) % 12` Gregorian | **Zodiac index 1–12 with mod-7 reduction** |
| Chart output | `finalNumbers` (wrong) | `row1Day`, `row2Month`, `row3Year`, `row4Sum` |
| Myanmar keys | From merged `finalNumbers` | From **Row 1 (ฐานวัน)** |
| Mahabhuta metadata | Merged numbers | **Row 4 sums** (audit) |
| Version | `v1` | `v1.1` |

---

## New Files

| Path | Purpose |
|------|---------|
| `foundation/calendar/thai_lunar_date.dart` | Lunar input model |
| `foundation/calendar/thai_day_boundary.dart` | 06:00 day-change rule |
| `foundation/calendar/thai_month_base_table.dart` | OQ-2 paired-month table |
| `foundation/calendar/thai_zodiac_year.dart` | OQ-6 year-base table |
| `foundation/calendar/thai_lunar_calendar.dart` | Gregorian → lunar resolver (delegates to `lunar/`) |
| `foundation/lunar/` | Lunar infrastructure V1 — see `THAI_LUNAR_CALENDAR_INFRASTRUCTURE_V1.md` |

---

## Modified Files

| Path | Change |
|------|--------|
| `foundation/chart/seven_number_chart.dart` | Full 4-row implementation |
| `foundation/engines/myanmar_seven_engine.dart` | Row 1 key mapping |
| `foundation/engines/mahabhuta_engine.dart` | Row 4 audit metadata |
| `foundation/thai_foundation_engine.dart` | Lunar warnings aggregation |
| `foundation/constants/thai_calculation_standards.dart` | Version `v1.1` |
| `foundation/models/thai_astrology_profile.dart` | `row4Sum` audit field |
| `test/thai_foundation_engine_test.dart` | GC-01..GC-05 regression |

---

## Assumptions Removed

| Removed Assumption | Reason |
|------------------|--------|
| `((day+month+year-1) mod 7)+1` merge | Invalid per Validation V1 |
| Gregorian month → month base proxy | Invalid per OQ-2 |
| Gregorian year → zodiac year proxy | Invalid per OQ-6 |
| `SevenNumberChartAssumptions` PROPOSED status | OQ-1/2/6 closed |

---

## Remaining Open Questions

### Lunar Calendar Layer

| ID | Question | Status |
|----|----------|--------|
| OQ-LUNAR-ALGO | Full ปฏิทิน 100/150 ปี for arbitrary Gregorian dates | **TODO** |
| OQ-LUNAR-8 | เดือน 8 สองหน (intercalary) handling | **TODO** |
| OQ-LUNAR-WD | Weekday from 100-year calendar vs Gregorian | **TODO** |
| OQ-LUNAR-YB | ขึ้น 1 ค่ำ เดือน 5 year boundary with waxing-day data | **TODO** |

**V1.1 behaviour:** Only **verified lookup dates** (GC-04, GC-05) resolve from Gregorian.  
All other dates emit `LUNAR_DATE_UNVERIFIED` warning — **no guessing**.

### Mahabhuta Layer

| ID | Question | Status |
|----|----------|--------|
| OQ-MAHABHUTA-ACTIVATION | Which position keys are "prominent" from กาลโยค | **TODO** |
| OQ-MAHABHUTA-GOLDEN | Mahabhuta-specific golden cases | **TODO** |

**V1.1 behaviour:** Emits all 7 canonical `mahabhuta_*` keys; stores Row 4 sums as metadata.

---

## Golden Case Coverage

| Case | Test Status |
|------|-------------|
| GC-01 | ✅ Row 4 pass |
| GC-02 | ✅ Row 4 pass (col 5 = 13 per arithmetic; พรหมชาติ text shows 12) |
| GC-03 | ✅ Row 4 pass |
| GC-04 | ✅ Row 4 + reduced pass (verified lookup) |
| GC-05 | ✅ Row 4 pass (verified lookup) |

---

## Unchanged (Blast Radius)

- Thai Theme Resolver / Engine / Presenter
- Content Layer
- Fusion, Mirror, UI, Navigation
- Lagna Engine (Sidereal + Lahiri + Whole Sign)

---

*End of V1.1 Notes*
