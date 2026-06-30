# Thai Astrology Canon — Knowledge Production Sprint 3 (Continuous Production)

> **Outcome:** D-068 committed; production is now **continuous** — extraction →
> validation → review → import → coverage, repeated without pausing per batch.
> This sprint produced two complete **natal placement assignments** from
> `หลักมหาภูต`: the archetype charts **ดวงกําพร้า** and **ดวงนักภาษา**.
> **Canon coverage increased 9 → 19 units.** No platform, ontology, engine,
> runtime, Rule-Engine, Workspace, Authoring or Canon-DB change.

Status: **CURRENT** · Knowledge production only · Platform frozen (D-065) ·
D-066 / D-067 / D-068 unchanged · No deploy.

---

## 1 · Mode

Per the Sprint 3 brief, the project priority is **Knowledge Coverage**, not
platform development. Production runs continuously and stops **only** on:

1. a genuine **Ontology Gap** (a verified Canon fact the ontology cannot name);
2. a genuine **Knowledge Modeling Gap** (a fact the Atomic model cannot shape);
3. **OCR quality** that makes deterministic extraction impossible.

None of these occurred this sprint. Deferred items stay deferred — the ontology
was **not** expanded merely because new terms appeared (see §4).

## 2 · What the book's chapters actually contain

Each archetype-chart chapter has two distinct kinds of material:

- **Natal analysis sections** (e.g. `ภูมิปัญญา/การเรียน`, `การงาน`, `การเงิน`,
  `คู่ครอง/สภาพครอบครัว`, `เกี่ยวกับบุตรธิดา`, `มิตรสหาย`). These state a planet's
  fixed seat with an explicit `…สถิต(เสถียร)เรือน <ตำแหน่ง>` — clean, deterministic,
  chart-scoped placements.
- **Life-period readings**, sub-divided by birth weekday (`คนเกิดวัน…`), which
  narrate the timeline using **ทักษา dignity roles** (`บริวาร`, `มูละ`, `อุตสาหะ`…).
  These rotate, are interpretive, and the OCR shows role/position ambiguity.

**This sprint extracts only the natal-analysis placements.** The life-period /
ทักษา material remains **deferred** (it needs the ทักษา-role ontology vocabulary,
itself a separate future Ontology Expansion decision — not taken here).

## 3 · Produced this sprint (+10 units → 19 total)

All units are `planet --located_in--> mahabhutPosition`, scoped by
`context = archetype_chart : <verbatim Thai chart heading>` (D-068). Strength is
read lexically from the stated dignity on the same line (`เข้มแข็ง / กำลังมาก` →
`high`; `อ่อน / อ่อนแอ` → `low`). Provenance is a page reference only (D-057).

### ดวงกําพร้า (pages 43–50)

| Planet | Position | Page | Strength |
|---|---|---|---|
| Sun (อาทิตย์) | phangkha (ภังคะ) | 43 | low |
| Moon (จันทร์) | puti (ปูติ) | 43 | low |
| Mars (อังคาร) | khumsap (ขุมทรัพย์) | 47 | high |
| Mercury (พุธ) | marana (มรณะ) | 47 | low |
| Venus (ศุกร์) | racha (ราชา) | 48 | high |
| Jupiter (พฤหัส) | athibodi (อธิบดี) | 50 | — *(already in Canon, Sprint 2C)* |

Saturn's natal seat is **not stated** in these sections → **not recorded** (no
guessing by elimination).

### ดวงนักภาษา (pages 83–88)

| Planet | Position | Page | Strength |
|---|---|---|---|
| Moon (จันทร์) | phangkha (ภังคะ) | 83 | low |
| Jupiter (พฤหัส) | marana (มรณะ) | 83 | — |
| Mars (อังคาร) | puti (ปูติ) | 84 | low |
| Venus (ศุกร์) | athibodi (อธิบดี) | 85 | high |
| Mercury (พุธ) | khumsap (ขุมทรัพย์) | 87 | high |

Sun and Saturn natal seats are not stated in the natal sections → not recorded.

The same general signification on p.83 (`ดาวจันทร์อันเป็นดาวแห่งการเงิน`) was
already imported as the *general* fact `moon --owns--> finance`; here only its
chart-scoped *placement* (`moon → phangkha @ ดวงนักภาษา`) is new.

## 4 · Deliberately NOT produced (and why)

- **Gendered significators** `ภรรยา` (wife / Venus), `สามี` (husband / Mars),
  `บุตรธิดา` (children / Mercury), `บิดามารดา` (parents / Sun, Moon): the *placement*
  is recorded, but the *signification* term does not resolve to an existing
  ontology alias. Adding aliases is an ontology decision; per the Sprint 3 rule
  ("do not expand ontology simply because a new term appears") this is
  **deferred**, not invented.
- **ทักษา dignity roles** (`บริวาร / อายุ / เดช / ศรี / มูละ / อุตสาหะ`): deferred
  ontology vocabulary, unchanged from Sprint 2B.
- **Life-period narrative effects**: interpretive prose, never atomic facts.

## 5 · Validation (through the real platform)

- `thai_canon_production_sprint2_test.dart` rebuilds all 19 units via the real
  `AtomicKnowledgeGraph` / `AtomicExtractionRules` / `CanonCompletenessReport`,
  and asserts: placements stay chart-scoped, significations stay general, each
  chart maps positions injectively (no position holds two planets in one chart),
  and one position (athibodi) legitimately holds different planets across charts.
- Planet Library now covers **6 of 9** planets (Sun, Moon, Mars, Mercury,
  Jupiter, Venus); status `partial`.
- **237 Thai validation tests pass**; `flutter analyze` clean.

## 6 · Coverage

| Milestone | Units |
|---|---|
| Sprint 2A | 7 |
| Sprint 2B | 8 |
| Sprint 2C | 9 |
| **Sprint 3** | **19** |

Production continues on the next archetype chapters' natal sections until a
genuine stop condition.
