# Thai Life Map V1.3.5 — Evidence Infrastructure (internal)

**Status:** Customer-facing detailed report **FAILED Product Acceptance** and was **removed from the ordinary user render path**. Accepted pre-V1.3.5 Life Map UX restored and **hosted** @ `0eb7bdb` (PR #58; behavioral baseline merge `7a3d07d` / docs tip `14ed096`). V1.3.5 evidence models/calculations remain **internal only**.  
**Product Acceptance:** ยังไม่ผ่าน—รอเจ้าของตรวจหน้า Production หลังคืนรูปแบบเดิม

## Product Acceptance failures

### Append-only ship (PR #54 @ `7916af6`)

V1.3.5 `_DetailedEvidenceReport` was appended **below** the full legacy timeline, so Production still looked like the old report first.

### UI-primary ship (PR #56 @ `1121015`) — worse

Making the evidence dump the primary Life Map body exposed technical/debug content to customers (`sidereal Lahiri`, `whole-sign`, `career=` / `pressure=` scores, friend/enemy/neutral classifications, house-lord implementation notes, long uniform age-1–108 cards). The page read like a QA/debug report and was **materially worse** than the previously accepted human-readable report.

**Root cause:** treating the evidence composer’s internal facts as finished customer-facing copy.

**Restoration:** Do **not** render `_DetailedEvidenceReport` (or raw evidence cards) on `/beta/thai`. Keep building `detailedReport` on the timeline state for tests/QA/future narrative composition only.

## Decision

Additive **supported-portion** evidence layer only. No Swiss Ephemeris expansion, no invented natal longitudes, no Ketu/Uranus, no planet-in-house occupancy.

**Customer UI:** restored accepted Life Map (`ทำไมช่วงนี้ถึงสำคัญ`, `แปดช่วงดาวเสวยอายุ`, readable period cards/accordions).  
**Any future customer-facing evidence report requires a separate narrative and UX design phase** — do not ship raw evidence cards again.

## What the evidence layer does (internal)

Package: `lib/features/astrology/thai/mirror/evidence/v135/`

- Builds deterministic `ThaiEvidenceItem` atoms with stable IDs (`ev.*`) and rule version `v135.1`
- Emits `ThaiDetectedEvent` only when coded rules fire (pressure/career thresholds, natal friction, Taksa กาฬกิณี)
- Deduplicates events; keeps conflict groups with explanations
- Composes report sections for automated tests / QA artifacts / future composition
- **Must not** be treated as finished customer-facing copy

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

- `test/validation/thai_beta/life_map/v135/` — includes restoration UI tests proving detailed evidence report is **absent** from the customer path while the model may still exist
- Artifact: `test/validation/thai_beta/life_map/v135/output/v135_product_qa.md` (QA/internal only)

## Invited-beta / release

Evidence Badge remains `invited_beta`. Do **not** describe the rejected detailed report as shipped customer functionality.

## Rollback

Customer path already restored to accepted UX. Evidence package may remain for internal use; do not re-wire raw evidence cards without a new authorized UX design.

## Next safe step

Owner Product Acceptance on Production after restore **or** a separate authorized program for narrative UX over evidence — do not invent ephemeris-backed natal positions inside V1.3.5.
