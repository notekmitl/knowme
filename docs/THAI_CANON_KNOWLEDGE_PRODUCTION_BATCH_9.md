# Thai Astrology Canon — Knowledge Production Batch 9

> **Outcome:** Planet **direction** attributes from p37 using D-072 ontology.
> **Coverage increased 349 → 357 units** (+8). **Body part** and **season**
> scopes surveyed — no extractable standalone facts without forbidden splitting.
> Relation model unchanged (`relates_to`). No platform change.

Status: **CURRENT** · Knowledge production only · Platform frozen (D-065) ·
D-066–D-072 unchanged · No deploy.

---

## 0 · Deferred modeling note (documentation only — NOT a platform task)

Current representation:

```text
planet --relates_to--> attribute.<category>.<token>
```

may later be specialized into **typed attribute relations** (e.g. per-category
relation wires). This is a possible future modeling refinement only; **not**
scheduled, **not** implemented, and **not** a stop condition for current
production. Batch 9 continues to use `relates_to` throughout.

---

## 1 · Produced this batch (+8 units → 357 total)

All units are general (`context = null`) `planet --relates_to-->
attribute.direction.*` from p37 **ครองทิศ…** lines (one direction per planet,
verbatim Thai). Symbol phrases on the same lines (e.g. ครุฑี=พญาครุฑ) are **not**
extracted — separate attribute category, not stated as direction values.

| Planet | Direction (verbatim) | Page |
|---|---|---|
| Sun | ตะวันออกเฉียงเหนือ | 37 |
| Moon | ตะวันออก | 37 |
| Mars | ตะวันออกเฉียงใต้ | 37 |
| Mercury | ใต้ | 37 |
| Saturn | ตะวันตกเฉียงใต้ | 37 |
| Jupiter | ตะวันตก | 37 |
| Rahu | ตะวันตกเฉียงเหนือ | 37 |
| Venus | เหนือ | 37 |

**Ketu** has no **ครองทิศ** line on p37 → not recorded; never inferred.

**+8 attribute value tokens** added under `attributeCategory.direction`.

---

## 2 · Scope outcomes: body part & season

### Body part — Knowledge Modeling Gap (not produced)

Full OCR survey of pp.1–41 and the planet-library disease sections (pp.30–36)
shows anatomical references **only inside `โรค…` disease list items** already
recorded as `attribute.disease.*` in Batch 8 (e.g. `โรคเกี่ยวกับหัวใจ`,
`โรคที่เกี่ยวกับเท้า-ต้นขาและโคนขา`). Producing separate
`attribute.bodyPart.*` units would require **splitting or re-categorizing** those
compound disease phrases → forbidden (inference / dual categorization of one
atomic statement). No standalone `เกี่ยวกับส่วนร่างกาย` or equivalent section
exists in the working source.

### Season — not in Canon source (not produced)

Exhaustive OCR search finds **no** `ฤดู` / `ฤดูกาล` (or equivalent season
vocabulary) anywhere in `หลักมหาภูต`. `attributeCategory.season` remains
vocabulary-only (D-072); **zero season units** until the source states them.

---

## 3 · Deliberately NOT produced (unchanged charter)

- **ทักษา role meanings** (pp.39–41) — life-period / Taksa modeling; out of scope
- **Commodity** lists (pp.30–36) — no commodity category
- **Physique** (`รูปพรรณสัณฐาน`) — compound descriptions; deferred
- **ดวงมนุษย์เจ้าสำราญ Sun seat** — still ambiguous
- **Planet symbols** on p37 (ครุฑี, พยัคฆ์, …) — not direction/category tokens

---

## 4 · Production metrics (D-070, reporting only)

| Metric | Value |
|---|---|
| Total units | **357** |
| Attribute `relates_to` units | 301 |
| Direction units (this batch) | 8 |

### Coverage by Planet (all 357 units)

| Planet | Units |
|---|---|
| Mars | 60 |
| Moon | 58 |
| Mercury | 50 |
| Sun | 49 |
| Venus | 45 |
| Jupiter | 41 |
| Saturn | 33 |
| Rahu | 21 |

## 5 · Coverage by Source Page (D-071)

| Page range | Status | Note |
|---|---|---|
| 37 | **Completed (partial)** | **Directions (+8 this batch)**; ทักษา rotation table pp.38–39 still deferred |
| 30–36 | Completed (partial) | Batch 8 attributes; body part / season N/A |
| 39–41 | Deferred | ทักษา role meanings + prediction rules |

## 6 · Validation

- Production test rebuilds 357 units; full Thai suite green; analyze clean.

## 7 · Milestone

| Batch | Units |
|---|---|
| Batch 8 | 349 |
| **Batch 9** | **357** |

**Next frontier:** ทักษา role meanings (pp.39–41) — requires explicit modeling
decision; or revisit body part only if a future source page states standalone
anatomy significations.
