# Thai Life Map V1.3.4 — Narrative Quality Upgrade

**Status:** Feature branch (pending merge/deploy)  
**Predecessor:** V1.3.3 @ `dff4b43` — Technical Gate passed; Product Acceptance failed (abstract overview / Past templates / wrong Current domains)

## Scope

Narrative-only upgrade on existing evidence (`PeriodScores`, planet affinity, Life Map phase, structured claims). **No** Swiss Ephemeris, planet degrees, or house occupancy tables.

## Changes

1. **Overview hero** — phaseEssence + natal foundation; bans system openers like `พื้นฐานจากดวงไทยคู่กับ…`
2. **Past** — `PastLifeStoryComposer` synthesizes 3–4 concrete sentences from beats + scores
3. **Current** — always การงาน / การเงิน / สุขภาพ / โชคลาภ from scores + typed directions (including honest “ไม่มีสัญญาณเด่น” for fortune)

## Unchanged

Canon, Mahabhut formula, weekday/Wednesday rules, LifePeriodEngine boundaries, Ascendant calc, Auth, Firestore, invited_beta, Evidence Badge, visual theme.

## QA

- `test/validation/thai_beta/life_map/v134/`
- Artifact: `test/validation/thai_beta/life_map/v134/output/v134_product_qa.md`
- Product Acceptance: awaits owner Production text review
