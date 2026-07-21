# Thai Astrology Canon — Knowledge Production Batch 8

> **Outcome:** Planet Library attributes (pp.30–36) extracted using the new D-072
> attribute ontology. **Coverage increased 56 → 349 units** (+293
> `planet --relates_to--> attribute.*` facts). Ontology expansion committed
> separately (`cc3f728`). No platform, engine, or runtime change.

Status: **RESOLVED → Batch 9** · Knowledge production only · Platform frozen

---

## 0 · Prerequisite — Ontology Expansion (D-072, separate commit)

| Category id | Source section heading (alias) |
|---|---|
| `attributeCategory.color` | สี / แสดงถึงสี |
| `attributeCategory.gemstone` | อัญมณี / เพชรพลอย |
| `attributeCategory.metal` | แร่ธาตุ / แสดงถึงแร่ธาตุ |
| `attributeCategory.taste` | รส / แสดงถึงรส |
| `attributeCategory.disease` | โรค / เกี่ยวกับโรค |
| `attributeCategory.bodyPart` | ส่วนร่างกาย (vocabulary reserved) |
| `attributeCategory.place` | สถานที่ / เกี่ยวกับสถานที่ |
| `attributeCategory.profession` | บุคคล / เกี่ยวกับบุคคล |
| `attributeCategory.direction` | ทิศ (vocabulary reserved) |
| `attributeCategory.season` | ฤดู (vocabulary reserved) |
| `attributeCategory.gender` | เพศ / แสดงถึงเพศ |

**285 attribute value tokens** (`attribute.<category>.<slug>`) added in this batch
with verbatim Thai aliases and `parentId` → category. Vocabulary only — no
meanings or planet links in the ontology layer.

---

## 1 · Produced this batch (+293 units)

Model: `planet --relates_to--> attribute.*` · `objectKind: keyword` ·
`context: null` (general planet-library facts) · one explicit list item or scalar
per unit.

| Attribute category | Units |
|---|---|
| profession (person types) | 119 |
| place | 83 |
| disease | 62 |
| color | 7 |
| taste | 7 |
| metal | 7 |
| gender | 7 |
| gemstone | 1 |

**First Rahu production:** 20 units (pp.36). **Saturn** expanded from 1 → 32
units (attributes beyond p28 family role).

### Scalar highlights (clean OCR)

| Planet | color | taste | metal / gemstone | gender | Page |
|---|---|---|---|---|---|
| Sun | สีแดงสด | รสเผ็ดร้อน | แร่ธาตุทองคำ | เพศชาย | 31 |
| Moon | สีขาว | รสเค็ม | แร่เงิน + เพชรพลอยที่สีขาว | เพศหญิง | 31–32 |
| Mars | สีแดงแก่ (ชมพู) | รสขม | ธาตุเหล็ก | เพศชาย | 32–33 |
| Mercury | สีเขียวใบไม้ | รสผสมหลายชนิด | ปรอท | เพศกลางๆ… | 33 |
| Jupiter | สีเหลืองแก่ | รสหวาน | สังกะสี | เพศชาย | 34 |
| Venus | — | — | — | เพศหญิง | 35 |
| Saturn | สีดำ | รสเปรี้ยว | ธาตุตะกั่ว | — | 36 |
| Rahu | — | — | — | — | 36 |

## 2 · Deliberately NOT produced

| Content | Gap / reason |
|---|---|
| **เครื่องอุปโภคบริโภค** lists (pp.30–36) | No `commodity` category in D-072 scope — deferred |
| **รูปพรรณสัณฐาน** composite descriptions | Compound physique phrases — modeling gap (not split) |
| Venus **color / taste / metal** (p35) | **OCR blocked** (`ee A`, truncated lines) |
| Saturn **gender** (p36) | **OCR garbled** — not recordable verbatim |
| **bodyPart**, **direction**, **season** | Category vocabulary seeded; no clean standalone facts in pp.30–36 |
| **Ketu** planet-library section | Not on pp.30–36 (Rahu only on p36) |
| Life-period / ทักษา (pp.37+) | Out of scope (Batch 8 charter) |
| ดวงมนุษย์เจ้าสำราญ Sun seat | Still ambiguous — not resolved |

## 3 · Production metrics (D-070, reporting only)

| Metric | Value |
|---|---|
| Total units | **349** |
| Placements (`located_in`) | 40 |
| General significations (`owns` domain) | 16 |
| Planet Library attributes (`relates_to`) | 293 |
| Planets covered (incl. Rahu) | 8 |

### Coverage by Planet (all 349 units)

| Planet | Units |
|---|---|
| Mars | 59 |
| Moon | 57 |
| Mercury | 49 |
| Sun | 48 |
| Venus | 44 |
| Jupiter | 40 |
| Saturn | 32 |
| Rahu | 20 |

## 4 · Coverage by Source Page (D-071)

| Page range | Status | Note |
|---|---|---|
| **30–36** | **Completed (partial)** | **+293 attribute units**; commodity + physique deferred; Venus/Saturn OCR gaps noted |
| 1–29 | Completed (partial) | Batch 7 general significations |
| 37–41 | Deferred | ทักษา / rules — modeling gap |
| 42+ natal | Completed / In Progress | unchanged from Batch 6–7 |

## 5 · Validation

- `thai_canon_production_sprint2_test.dart` — 349 units; Batch 8 generated
  from `tool/output/batch8_planet_library.json`
- `thai_canon_ontology_test.dart` — 11 categories + 285 value tokens validate
- Full Thai suite green; analyze clean

## 6 · Coverage milestone

| Milestone | Units |
|---|---|
| Production Batch 7 | 56 |
| **Production Batch 8** | **349** |

**Next frontier:** pp.37–41 ทักษา roles (modeling gap) or commodity/physique
ontology if those lists are approved for representation.
