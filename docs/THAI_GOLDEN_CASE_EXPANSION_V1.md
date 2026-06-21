# Thai Astrology Golden Case Expansion V1

**Status:** Complete  
**Date:** 2026-06-08  
**Scope:** Expand golden reference cases from 5 → 20 using published sources only.

---

## 1. Cases Added

| ID | Source | Type | wd | lm | zy | Row4 |
|----|--------|------|----|----|-----|------|
| GC-01 | พรหมชาติ ตย.1 | chart | 1 | 2 | 3 | 6 9 12 15 18 14 10 |
| GC-02 | พรหมชาติ ตย.2 | chart | 2 | 5 | 1 | 8 11 14 10 13 16 12 |
| GC-03 | พรหมชาติ ตย.3 | chart | 5 | 9 | 12 | 12 15 18 7 10 13 9 |
| GC-04 | horawej 538981149 | gregorian | 7 | 10 | 2 | 12 8 11 14 17 13 9 |
| GC-05 | sinsaehwang 4/04/2515 | gregorian | 2 | 5 | 1 | 8 11 14 10 13 16 12 |
| GC-06 | horawej 538977480 | chart | 1 | 1 | 1 | 3 6 9 12 15 18 21 |
| GC-07 | พรหมชาติ 016c004 | chart | 3 | 1 | 1 | 5 8 11 14 17 13 16 |
| GC-08 | พรหมชาติ 016c004 | chart | 3 | 6 | 1 | 10 13 9 12 15 11 14 |
| GC-09 | sinsaehwang 22/09/2510 | chart+date | 6 | 10 | 8 | 10 13 9 12 15 11 14 |
| GC-10 | horawej Myanmar ex1 | chart | 5 | 2 | 1 | 8 11 14 10 13 16 12 |
| GC-11 | horawej Myanmar ex2 | chart+date | 7 | 6 | 5 | 18 14 10 6 9 12 15 |
| GC-12 | พรหมชาติ Sun+m5+z1 | chart | 1 | 5 | 1 | 7 10 13 9 12 15 18 |
| GC-13 | พรหมชาติ Tue+m5+z1 | chart | 3 | 5 | 1 | 9 12 15 11 14 10 13 |
| GC-14 | พรหมชาติ Wed+m5+z1 | chart | 4 | 5 | 1 | 10 13 16 12 8 11 14 |
| GC-15 | พรหมชาติ Fri+m5+z1 | chart | 6 | 5 | 1 | 12 15 11 7 10 13 16 |
| GC-16 | พรหมชาติ Sat+m5+z1 | chart | 7 | 5 | 1 | 13 9 12 8 11 14 17 |
| GC-17 | พรหมชาติ m12+z12 | chart | 4 | 12 | 12 | 14 17 20 9 5 8 11 |
| GC-18 | พรหมชาติ m7+z6 | chart | 3 | 7 | 6 | 16 12 8 11 14 10 13 |
| GC-19 | พรหมชาติ m3+z3 | chart | 2 | 3 | 3 | 8 11 14 17 20 9 5 |
| GC-20 | พรหมชาติ m11+z11 | chart | 5 | 11 | 11 | 13 16 19 15 4 7 10 |

**Total:** 20 cases (15 new chart-input, 2 verified gregorian lookup, 2 gregorian chart-only).

---

## 2. Sources Used

| Source | Cases | Notes |
|--------|-------|-------|
| horoscope.dooasia.com/phommachat | GC-01..03, GC-07..08, GC-12..20 | Published worked examples + rotation tables |
| horawej.com | GC-04, GC-06, GC-10, GC-11 | Id=538981149, aid=538977480, Id=420241 |
| sinsaehwang.com | GC-05, GC-09 | พื้นฐาน 1 article |

**Not used:** payakorn, myhora bulk, scraped datasets, invented lunar dates.

---

## 3. Coverage Analysis

| Boundary | Cases |
|----------|-------|
| January (lunar) | GC-01, GC-19 |
| April / Songkran season | GC-02, GC-05, GC-11 |
| June (lunar month 6–7) | GC-08, GC-18 |
| September | GC-03, GC-04, GC-09 |
| December (lunar month 1) | GC-06, GC-07, GC-17 |
| Zodiac year boundary | GC-02, GC-05, GC-17 |
| Songkran season | GC-05, GC-11 |
| Lunar month boundary | GC-06, GC-07 |
| Before 06:00 | GC-04, GC-05 |
| Ordinary days | all |

---

## 4. Validation Results

- **Chart regression:** `test/thai_golden_cases_test.dart` — 20 parameterized row4 tests
- **Lunar lookup:** GC-04, GC-05 pass via `ThaiLunarValidator` (unchanged)
- **Foundation engine:** existing GC-01..05 tests retained

---

## 5. Files Created

- `lib/features/astrology/thai/foundation/lunar/validation/thai_golden_case.dart`
- `lib/features/astrology/thai/foundation/lunar/validation/thai_golden_cases.dart`
- `test/thai_golden_cases_test.dart`
- `docs/THAI_GOLDEN_CASE_EXPANSION_V1.md`

---

## 6. Files Modified

- `test/fixtures/lunar_references.yaml` — expanded GC-01..GC-20

---

## 7. Remaining Gaps

| Gap | Reason |
|-----|--------|
| Gregorian lookup for GC-09, GC-11 | Birth times published but not in verified lunar repository (dataset V1.2+) |
| Chiang Mai 2492 case | Lunar row4 not found in allowed horawej article fetch |
| MyHora worked examples | No additional independently verified examples added this sprint |
| Explicit ขึ้น 1 ค่ำ / แรม 15 boundary | Requires full lunar date + time from licensed dataset |
| December **Gregorian** month | Cases use lunar month 1 (ธันวา), not civil December |

---

## 8. Blast Radius

| Area | Impact |
|------|--------|
| `SevenNumberChart` | None — read-only validation |
| `ThaiLunarRepository` | None — still 2 verified entries |
| `ThaiLunarGoldenCases` | None — infra validator unchanged |
| Tests | +23 tests in `thai_golden_cases_test.dart` |
| Production runtime | None |

---

## 9. Definition of Done

- [x] Golden Cases ≥ 20
- [x] No fake data — all inputs traceable to published sources
- [x] No bulk dataset
- [x] `test/fixtures/lunar_references.yaml` populated
- [x] Parameterized regression tests
- [x] `flutter analyze` clean
- [x] `flutter test` green
- [x] Ready for Thai Mirror V1 (chart layer validated; lunar lookup awaits dataset)

---

## Row4 Provenance

- **published:** Row 4 explicitly printed in source (GC-01..04, GC-06)
- **arithmeticFromPublishedInputs:** Rows 1–3 or wd/lm/zy inputs published; row4 = vertical sum per Foundation Engine V1.1 standard
