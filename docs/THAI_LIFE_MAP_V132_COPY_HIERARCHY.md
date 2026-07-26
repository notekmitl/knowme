# Thai Life Map V1.3.2 — Product Copy & Information Hierarchy

**Status:** Implementation (product-failure fix over V1.3.1)  
**Runtime predecessor:** V1.3.1 @ `41d7988` failed Product Acceptance (duplicate core card / success banner / Past soft opener / abstract Current)

## Root causes

1. **Duplicate cards:** Thai Beta composed both hero (`ดวงไทยของคุณ`) and Personal Core (`แก่นที่พอเห็นได้…`) from overlapping curated evidence.
2. **Success banner:** complete birth-data confidence was rendered between narrative cards.
3. **Past soft opener:** renderer forced `ในช่วงนั้น` onto the first Past sentence.
4. **Abstract Current:** relationship claim bank used `รูปแบบ…เปลี่ยน` / `ตั้งขอบเขตใหม่`.

## Fix

- Synthesize unique Personal Core paragraphs into the single hero card; empty separate signature card
- Complete birth data = silent; incomplete limitation on `hero.identitySubtitle`
- Remove Past soft openers; ban vague relationship form-change jargon; omit vague claims

## Unchanged

Canon, formulas, period math, classifications, Auth, Firestore, invited_beta, Evidence Badge, Unified Synthesis, styling.
