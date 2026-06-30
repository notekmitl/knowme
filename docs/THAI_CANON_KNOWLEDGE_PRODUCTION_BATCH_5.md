# Thai Astrology Canon — Knowledge Production Batch 5

> **Outcome:** Continuous Knowledge Production. Two more archetype charts brought
> to full natal coverage. **Canon coverage increased 30 → 41 units.** This batch
> also adds a **production metric report** (reporting only — Batch 5 request). No
> platform, ontology, engine, or runtime change.

Status: **RESOLVED → Batch 6** · Knowledge production only · Platform frozen
(D-065) · D-066 / D-067 / D-068 / D-069 unchanged · No deploy.

---

## 1 · Produced this batch (+11 units → 41 total)

All units are `planet --located_in--> mahabhutPosition`, scoped by
`context = archetype_chart : <verbatim Thai chart heading>` (D-068). Strength is
read lexically from stated dignity on the same line; where no dignity word
applies to the planet's own line, strength is `—` (none). Unstated planets are
**never** inferred or eliminated by deduction.

### ดวงมหาเศรษฐี (pages 254–262)

The benefic group is stated verbatim (pp.255, 258):
*"ดาวจันทร์ … ดาวพุธ … ดาวพฤหัส … และดาวศุกร์ … สถิต(เสถียร)เรือนขุมทรัพย์, อธิบดี,
ราชา และธงชัยตามลําดับ"* — a respective (ตามลำดับ) mapping, each cross-confirmed
by its own domain section (Jupiter pp.255–257, Mercury p.261, Venus p.260).

| Planet | Position | Page | Strength |
|---|---|---|---|
| Moon | khumsap (ขุมทรัพย์) | 258 | — |
| Mercury | athibodi (อธิบดี) | 261 | high |
| Jupiter | racha (ราชา) | 256 | high |
| Venus | thongchai (ธงชัย) | 260 | high |
| Mars | marana (มรณะ) | 259 | low |

Sun and Saturn natal seats are not stated in the natal sections → **not recorded**.

### ดวงนักบริหาร (pages 113–119)

The คู่มิตร group is stated verbatim (p.113):
*"ดาวอาทิตย์ … และดาวพฤหัส … สถิตเสถียรเรือนราชาและขุมทรัพย์ตามลําดับ"*. The other
planets are confirmed by their own domain sections (Moon p.116, Mars p.116,
Venus p.118, Mercury p.119).

| Planet | Position | Page | Strength |
|---|---|---|---|
| Sun | racha (ราชา) | 113 | high |
| Jupiter | khumsap (ขุมทรัพย์) | 114 | high |
| Moon | thongchai (ธงชัย) | 116 | high |
| Mars | phangkha (ภังคะ) | 116 | low |
| Venus | marana (มรณะ) | 118 | low |
| Mercury | puti (ปูติ) | 119 | low |

Saturn natal seat is not stated in the natal sections → **not recorded**.

## 2 · Production metric report (reporting only)

These breakdowns are **derived** from the Canon units for visibility. They do
**not** affect Canon knowledge or runtime and add no platform/ontology code; the
production test recomputes them from the same units (`Production metrics` group).

### Coverage by Planet (all 41 units)

| Planet | Units |
|---|---|
| Jupiter | 10 |
| Moon | 8 |
| Mars | 7 |
| Mercury | 7 |
| Venus | 7 |
| Sun | 2 |
| Saturn | 0 |

6 of 7 classical planets covered; Saturn never inferred.

### Coverage by Archetype (38 placement units)

| Archetype chart | Units |
|---|---|
| ดวงนักวิชาการ | 6 |
| ดวงกําพร้า | 6 |
| ดวงนักบริหาร | 6 |
| ดวงมนุษย์เจ้าสําราญ | 5 |
| ดวงนักภาษา | 5 |
| ดวงเศรษฐี | 5 |
| ดวงมหาเศรษฐี | 5 |

7 archetype charts now carry natal maps.

### Coverage by Position (38 placement units)

| Mahabhut position | Units |
|---|---|
| khumsap (ขุมทรัพย์) | 6 |
| racha (ราชา) | 6 |
| phangkha (ภังคะ) | 6 |
| thongchai (ธงชัย) | 5 |
| athibodi (อธิบดี) | 5 |
| puti (ปูติ) | 5 |
| marana (มรณะ) | 5 |

All 7 Mahabhut named positions are exercised.

### Coverage by Context

| Context type | Units |
|---|---|
| archetype_chart | 38 |
| general (no context) | 3 |
| taksa_chart / lagna / life_period / other | 0 |

The 3 general units are planet→domain natural significations (Jupiter→learning,
Jupiter→career, Moon→finance).

## 3 · Deliberately NOT produced (unchanged)

- **Life-period / ทักษา-role readings** (ดวงขึ้น/ดวงตก) — deferred (rotating
  dignity roles, e.g. ดวงนักบริหาร pp.122–146).
- **Gendered significators** (ภรรยา/สามี/บุตรธิดา) — placement recorded where
  explicit; signification aliases deferred.
- **Elimination guesses** for unstated Sun/Saturn seats.

## 4 · Validation

- `thai_canon_production_sprint2_test.dart` rebuilds all 41 units through the
  real platform; injectivity asserted for ดวงกําพร้า, ดวงเศรษฐี, ดวงมหาเศรษฐี,
  and ดวงนักบริหาร; the four metric breakdowns are recomputed and asserted.
- Full Thai validation suite green; `flutter analyze` clean.

## 5 · Coverage

| Milestone | Units |
|---|---|
| Sprint 3 | 19 |
| Production Batch 4 | 30 |
| **Production Batch 5** | **41** |

Production continues on remaining archetype charts and any incomplete natal
assignments until a genuine Ontology Gap, Knowledge Modeling Gap, or
unrecoverable OCR is encountered.
