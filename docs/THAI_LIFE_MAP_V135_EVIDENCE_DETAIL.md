# Thai Life Map V1.3.5 — Evidence-Backed Detailed Report

**Status:** UI-primary fix merged + hosted @ `1121015` (PR #56) — Technical Gate passed; **Product Acceptance ยังไม่ผ่าน—รอเจ้าของตรวจหน้า Production หลังแก้**  
**Predecessor evidence ship:** `7916af6` (PR #54) — model shipped but UI remained legacy-first → Product Acceptance **FAILED**

## Product Acceptance failure (2026-07-27)

On Production `/beta/thai`, eligible users still saw legacy chrome first (`ทำไมช่วงนี้ถึงสำคัญ`, `แปดช่วงดาวเสวยอายุ`, period domain cards). V1.3.5 `_DetailedEvidenceReport` was **appended below** the full legacy timeline in [`thai_mirror_life_timeline_section.dart`](../lib/features/astrology/thai/mirror/presentation/ui/widgets/thai_mirror_life_timeline_section.dart), so the page appeared unchanged.

**Root cause:** detailed report rendered only after all legacy cards (`lifeMapMode && detailedReport != null` append path).

**Fix (PR #56 @ `1121015`):** When `lifeMapMode && detailedReport != null`, render V1.3.5 as the primary Life Map body after the stage header; suppress legacy analysis / strip / eight-period cards. Presentation tests on `ThaiBetaReportPage` prove primary headings.

## Decision

Additive **supported-portion** evidence layer only. No Swiss Ephemeris expansion, no invented natal longitudes, no Ketu/Uranus, no planet-in-house occupancy.

## What the evidence layer does

Package: `lib/features/astrology/thai/mirror/evidence/v135/`

- Builds deterministic `ThaiEvidenceItem` atoms with stable IDs (`ev.*`) and rule version `v135.1`
- Emits `ThaiDetectedEvent` only when coded rules fire (pressure/career thresholds, natal friction, Taksa กาฬกิณี)
- Deduplicates events; keeps conflict groups with explanations
- Composes report sections: lifetime topics, past, current (age period ∪ birthday year), future from next period, single closing advice block
- Wires into Life Map UI as additive “รายงานเชิงหลักฐาน” under existing timeline chrome

## Supported calculations

| Fact | Source |
|------|--------|
| Weekday / start planet / 8 periods ages 1–108 | `LifePeriodEngine` |
| Ascendant (sidereal Lahiri) + lagna lord | `LagnaEngine` / profile |
| Whole-sign houses + lords (frame only) | `HouseEngine` (read-only) |
| Friend/enemy + combined bond | `PlanetRelationshipEngine` |
| PeriodScores | `PeriodCompositeScore` |
| Annual ทักษาจร for current Thai age | `AnnualTaksaEngine` |
| Calendar birthday-year window | `ThaiBirthdayYearWindow` (pure date math) |

## Birthday-year definition

From the most recent birthday through the day before the next birthday (local civil dates). 29 February births use 28 February in non-leap years.

## Evidence gaps (explicit)

1. Natal planetary longitudes (Flutter empty; backend SE is Western path — not wired)
2. Ketu / Uranus
3. Planet-in-house occupancy
4. Day-level transit precision beyond age period + birthday year + Taksa year

## Frozen (unchanged)

Canon corpus, Mahabhut formula, weekday/Wednesday-night Rahu start, LifePeriodEngine boundaries, Ascendant math internals, Auth, Firestore, invited_beta Evidence Badge, visual theme.

## Tests

- `test/validation/thai_beta/life_map/v135/`
- Artifact: `test/validation/thai_beta/life_map/v135/output/v135_product_qa.md`

## Invited-beta / release

Evidence Badge remains `invited_beta`. This phase is **not** a public release claim until owner Product Acceptance.

## Rollback

Revert the V1.3.5 feature commit / PR. Lifecycle engines untouched.

## Next safe step

Owner Product Acceptance on Production text **or** a separate authorized program for ephemeris-backed natal positions — do not invent them inside V1.3.5.
