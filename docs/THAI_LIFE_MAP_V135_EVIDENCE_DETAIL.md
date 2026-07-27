# Thai Life Map V1.3.5 — Evidence-Backed Detailed Report

**Status:** Merged + hosted @ `7916af6` (PR #54) — Technical Gate passed; Product Acceptance pending owner Production text review  
**Predecessor:** V1.3.4 @ `7a3d07d` — narrative quality on PeriodScores; Product Acceptance still pending owner

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
