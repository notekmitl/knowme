# Thai Astrology Canon — Knowledge Production Batch 6

> **Outcome:** Continuous Knowledge Production. The remaining cleanly-stated natal
> Sun seats are extracted, completing Sun coverage for two charts. **Canon
> coverage increased 41 → 43 units.** Adds a new **Coverage by Source Page**
> reporting layer (D-071). No platform, ontology, engine, or runtime change.

Status: **RESOLVED → Batch 7** · Knowledge production only · Platform frozen

---

## 1 · Produced this batch (+2 units → 43 total)

Both units are `planet --located_in--> mahabhutPosition`, scoped by
`context = archetype_chart : <verbatim Thai chart heading>` (D-068). Each Sun
seat comes from a **clean 2-planet / 2-position ตามลำดับ group** in the chart's
`เหตุที่ชื่อว่า` intro, and the alignment is **anchored** by an already-recorded
Mercury placement (so the respective mapping is verified, not reconstructed).

| Chart | Planet | Position | Page | Strength | Anchor (already in Canon) |
|---|---|---|---|---|---|
| ดวงนักภาษา | Sun | thongchai (ธงชัย) | 77 | high | Mercury→ขุมทรัพย์ (p87) |
| ดวงนักวิชาการ | Sun | khumsap (ขุมทรัพย์) | 219 | high | Mercury→ราชา (p225) |

### Source-internal tension recorded faithfully (ดวงนักวิชาการ)

For ดวงนักวิชาการ the intro (p219) and two p220 lines state **Jupiter→ธงชัย**,
while the p220 *การงาน* line states **Jupiter→ขุมทรัพย์** (`jupiter_in_khumsap`,
already in Canon since Sprint 2C). The intro additionally places **Sun→ขุมทรัพย์**.
All three statements are verbatim in the source. Per Canon rules they are
recorded as-is (a genuine source tension, resolved downstream by
`CanonConflictResolver`) — **never deleted, never inferred away**. This is *not*
a stop condition: the Atomic model represents it directly. Injectivity is
therefore **not** asserted for this chart.

## 2 · Deliberately NOT produced (unchanged + new)

- **ดวงมนุษย์เจ้าสําราญ — Sun seat (p149 intro):** the ตามลำดับ enumeration is
  structurally ambiguous (4 planets named, 3 named positions, with `ฯลฯ`).
  Aligning it would require reconstructing a dropped term → **deferred**, not
  recorded (no OCR-gap filling, no inference). The 5 stated planets for this
  chart remain complete from Batch 4.
- **Saturn** — named "เด่น/เข้มแข็ง" in several charts (e.g. นักภาษา p81,
  นักวิชาการ) but **no เรือน is ever stated** → not recordable; never inferred.
- **Life-period / ทักษา-role readings** (ดวงขึ้น/ดวงตก) — deferred.
- **Gendered significator aliases** (ภรรยา/สามี/บุตรธิดา) — deferred.

## 3 · Production metric report (reporting only — D-070)

Recomputed and asserted in the production test from the same units; no
runtime/Canon impact.

### Coverage by Planet (all 43 units)

| Planet | Units |
|---|---|
| Jupiter | 10 |
| Moon | 8 |
| Mars | 7 |
| Mercury | 7 |
| Venus | 7 |
| Sun | 4 |
| Saturn | 0 |

### Coverage by Archetype (40 placement units)

| Archetype chart | Units |
|---|---|
| ดวงนักวิชาการ | 7 |
| ดวงกําพร้า | 6 |
| ดวงนักภาษา | 6 |
| ดวงนักบริหาร | 6 |
| ดวงมนุษย์เจ้าสําราญ | 5 |
| ดวงเศรษฐี | 5 |
| ดวงมหาเศรษฐี | 5 |

### Coverage by Position (40 placement units)

| Mahabhut position | Units |
|---|---|
| khumsap (ขุมทรัพย์) | 7 |
| thongchai (ธงชัย) | 6 |
| racha (ราชา) | 6 |
| phangkha (ภังคะ) | 6 |
| athibodi (อธิบดี) | 5 |
| puti (ปูติ) | 5 |
| marana (มรณะ) | 5 |

### Coverage by Context

| Context type | Units |
|---|---|
| archetype_chart | 40 |
| general (no context) | 3 |
| taksa_chart / lagna / life_period / other | 0 |

## 4 · Coverage by Source Page (NEW reporting layer — D-071)

Reporting layer **only** — derived from evidence pages and the production plan.
It does **not** affect Canon knowledge, ontology, runtime, or validation (it is
documentation, not a test gate). Status legend: **Completed** (natal extraction
done), **In Progress** (partially extracted, item(s) deferred), **Deferred**
(out of current natal scope by policy), **OCR Blocked** (unrecoverable text),
**Not Started**.

| Page range | Section | Status | Note |
|---|---|---|---|
| 1–41 | Front matter / มหาภูต theory & planet significations | Not Started | Theory; general significations only (3 recorded so far) |
| 42–51 | ดวงกําพร้า — natal | Completed | 6 planets; Saturn not stated |
| 52–75 | ดวงกําพร้า — life-period (ดวงขึ้น/ดวงตก) | Deferred | ทักษา-role material |
| 76–88 | ดวงนักภาษา — natal | Completed | 6 planets incl. **Sun (this batch)** |
| 89–111 | ดวงนักภาษา — life-period | Deferred | ทักษา-role material |
| 112–120 | ดวงนักบริหาร — natal | Completed | 6 planets (Batch 5) |
| 121–147 | ดวงนักบริหาร — life-period | Deferred | ทักษา-role material |
| 148–156 | ดวงมนุษย์เจ้าสําราญ — natal | In Progress | 5 planets done; **Sun seat deferred (ambiguous p149 enumeration)** |
| 157–179 | ดวงมนุษย์เจ้าสําราญ — life-period | Deferred | ทักษา-role material |
| 180–187 | ดวงเศรษฐี — natal | Completed | 5 planets; Sun/Saturn not stated |
| 188–217 | ดวงเศรษฐี — life-period | Deferred | ทักษา-role material |
| 218–225 | ดวงนักวิชาการ — natal | Completed | incl. **Sun (this batch)**; source tension at khumsap noted |
| 226–253 | ดวงนักวิชาการ — life-period | Deferred | ทักษา-role material |
| 254–262 | ดวงมหาเศรษฐี — natal | Completed | 5 planets (Batch 5) |
| 263–292 | ดวงมหาเศรษฐี — life-period | Deferred | ทักษา-role material |
| 293–308 | แก้ดวง / สะเดาะเคราะห์ (remedies) | Not Started | Ritual remedies — not natal-analysis |

**Summary:** all 7 archetype natal sections are **Completed** except
ดวงมนุษย์เจ้าสําราญ (**In Progress**, one deferred Sun seat). No pages are
**OCR Blocked**. Remaining bulk is **Deferred** life-period/ทักษา material.

## 5 · Validation

- `thai_canon_production_sprint2_test.dart` rebuilds all 43 units through the
  real platform; the four D-070 metric breakdowns are recomputed and asserted.
- Full Thai validation suite green; `flutter analyze` clean.

## 6 · Coverage

| Milestone | Units |
|---|---|
| Production Batch 4 | 30 |
| Production Batch 5 | 41 |
| **Production Batch 6** | **43** |

Natal-analysis extraction across the 7 archetype charts is now essentially
complete. The next genuine extraction frontier is **deferred** life-period/ทักษา
material (a Knowledge Modeling decision, not a defect) and front-matter general
significations — both await an explicit go-ahead.
