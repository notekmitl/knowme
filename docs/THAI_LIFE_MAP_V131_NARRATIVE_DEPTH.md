# Thai Life Map V1.3.1 — Narrative Depth & Natural Thai

**Status:** Implementation (product-failure fix over V1.3.0)  
**Runtime predecessor:** V1.3.0 @ `ad1e948` failed Product Acceptance (Past too short / Current abstract duel / hero disclaimer)

## Root causes

1. **Past short:** renderer used only 3 slots; `secondary` was null; no context/lingering beats.
2. **Current unnatural:** pressure bank used `A กับ B แย่งกันอยู่` compression.
3. **Disclaimer:** hero curated blocks ended with soft-sell line on ดวงไทยของคุณ.

## Fix

- Past `beats` (context → change → support → pressure → response → lingering) when evidence supports
- Natural actor-led pressures; ban `แย่งกัน`
- Remove hero disclaimer; no replacement filler

## Unchanged

Canon, formulas, period math, classifications, Auth, Firestore, invited_beta, Evidence Badge, hero chips/body except removed disclaimer.
