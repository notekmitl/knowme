# Thai Life Map V1.3.3 — Holistic Overview + Life Story + Current Domains

**Status:** Feature branch (pending merge/deploy)  
**Predecessor:** V1.3.2 @ `c1c0cbc` / docs tip `5073771` — Technical Gate passed; Product Acceptance failed on Production UI

## Root causes

1. **Hero personality-only:** `ThaiBetaNarrativeHero` + Personal Core merge used curated trait blocks only; life-period labels existed but were unused in the opening card.
2. **Past template rhythm:** `_pastBeats` always ordered context → change → support → pressure → response → lingering with shared `ก่อนหน้านั้น` openers.
3. **Current heading overload:** `_PeriodDetail` rendered system semantic slots (`สรุปช่วงนี้`, `สิ่งที่ทำให้ลำบาก`, …) as user hierarchy.

## Fix

- `ThaiBetaHolisticOverviewComposer` — natal foundation + life trajectory + current focus/challenge from approved evidence (no verbatim timeline paste)
- Past beat pattern rotation + opener variety (no `ในช่วงนั้น` / invented events)
- `LifeMapCurrentDomainComposer` — map structured claims → ≤4 domains: การดำเนินชีวิต / การงาน / ความรัก / สุขภาพ
- Current UI uses domain blocks; Future keeps slot layout

## Unchanged

Canon, formulas, Mahabhut, weekday/Wednesday rules, period calculation/classification, Auth, Firestore, invited_beta, Evidence Badge, Unified Synthesis, styling.

## QA

- Focused tests: `test/validation/thai_beta/life_map/v133/`
- Artifact: `test/validation/thai_beta/life_map/v133/output/v133_product_qa.md`
- 864/864 matrix: pass, skipped = 0
- Product Acceptance: awaits owner Production visual check
