# Thai Astrology Canon — Knowledge Production Phase D (Life Period)

> **Outcome:** Mahabhut **life-period** structural knowledge extracted under D-073
> Phase D charter. **Coverage increased 452 → 678 units** (+226).
> **Phase D closed** at documented stop conditions — narrative effects, remedies,
> and ambiguous OCR remain blocked.

Status: **CLOSED (Phase D)** · Knowledge production only · Platform frozen (D-065) ·
D-066–D-073 unchanged · D-075 ontology expansion · No deploy.

---

## 1 · Produced this phase (+226 units → 678 total)

| Category | Units | Pages / scope | Model |
|---|---|---|---|
| Rise/fall position rules | 7 | p17 | `periodStatus.* --relates_to--> mahabhutPosition.*` (general) |
| Planet dasha durations | 4 | p18 | `planet --relates_to--> agePeriod.dasha*y` (general) |
| Life-period mahabhut placements | 215 | 141 pages, all 7 archetype sections | `planet --located_in--> mahabhutPosition.*` · `context: life_period` |

**Ontology (D-075):** `periodStatus.duengKhuen`, `periodStatus.duengTok`;
`agePeriod.dasha5y`, `.dasha10y`, `.dasha12y`, `.dasha15y` — vocabulary only.

**Rise/fall classification in period scope:** embedded verbatim in `life_period`
context value when stated on the header line (e.g. `อายุ ๒๒ ถึง ๓๒ [ดวงขึ้น]`).

**Phase C carryover:** 80 taksa `located_in` units with `life_period` context remain
in dataset (295 total `life_period` context units after Phase D).

---

## 2 · Universal rules extracted (pp.17–18)

### ดวงขึ้น / ดวงตก (p17)

| Classification | Positions (explicit on page) |
|---|---|
| ดวงขึ้น | ธงชัย, ขุมทรัพย์, ราชา, อธิบดี |
| ดวงตก | ภังคะ, มรณะ, ปูติ |

### เสวยอายุ (p18 — recoverable OCR only)

| Planet | Dasha age |
|---|---|
| จันทร์ | ๑๕ ปี |
| อังคาร | ๕ ปี |
| เสาร์ | ๑๐ ปี |
| ราหู | ๑๒ ปี |

---

## 3 · Archetype life-period coverage (mahabhut placements)

| Section (page range) | Life-period placements |
|---|---|
| ดวงกำพร้า (52–75) | 28 |
| ดวงนักภาษา (89–111) | 24 |
| ดวงนักบริหาร (121–147) | 28 |
| ดวงมนุษย์เจ้าสำราญ (157–179) | 23 |
| ดวงเศรษฐี (188–217) | 38 |
| ดวงนักวิชาการ (226–253) | 24 |
| ดวงมหาเศรษฐี (263–292) | 41 |

---

## 4 · Stop conditions (Phase D closed)

### Knowledge Modeling Gaps — not produced

| Material | Reason |
|---|---|
| Per-period narrative effects (`ส่งผลให้…`, career/health prose) | Interpretive / compound — not atomic `produces domain.*` without inference |
| Planet governorship as separate fact when redundant with placement paragraph | Same planet stated in authority + placement prose — duplicate atomic encoding |
| `lifePeriod.<id> belongs_to archetype_chart` as separate units | Single `context` qualifier (D-068); chart traceable via page + section header |

### OCR Blocks — not produced

| Source | Reason |
|---|---|
| p18 Sun / Mercury / Jupiter / Venus dasha ages | Digit corruption (`๒»`, `๑ซ`, `๑«`, incomplete Venus line) |
| 49 explicit-placement lines | Planet token not resolvable within 4-line window |
| Period headers failing atomic token rule (>6 words or garbled age range) | Recorded in `tool/output/phase_d_ocr_blocked.json` |

### Charter exclusions (deferred)

| Material | Deferred to |
|---|---|
| Remedy / สะเดาะเคราะห์ blocks inside life-period pages | Phase F |
| pp.40–41 prediction rules | Phase E |
| Lookup tables (p18 rotation detail → p23) | Phase G |

---

## 5 · Production metrics (D-070, reporting only)

| Metric | Value |
|---|---|
| Total units | **678** |
| Life-period context units | **295** |
| Life-period mahabhut placements (Phase D) | **215** |
| Natal archetype mahabhut placements (unchanged) | **40** |
| Taksa placements | **91** |
| General universal rules (Phase D) | **11** |

### Coverage by context (all units)

| Context | Units |
|---|---|
| general | 332 |
| life_period | 295 |
| archetype_chart | 43 |
| other | 8 |

---

## 6 · Validation

Pipeline: Working Source → `tool/extract_phase_d_life_period.py` → generated Dart
fixtures → ontology resolution → workspace gates → `foundation_v1.knowme.json`.

**Tests added/updated:**

- D-075 ontology: period status + dasha age resolution
- Life-period placements context-scoped; no unscoped mahabhut placement
- Universal rules (p17–18) remain general (no context)
- Page provenance on every Phase D unit

**Suite:** `flutter test test/validation/thai/` — all pass.

---

## 7 · Commits

| Commit | Contents |
|---|---|
| `Mahabhut Canon Phase D Life Period Ontology` | D-075 vocabulary + ontology tests |
| `Mahabhut Canon Phase D Life Period Batch 01` | +226 units, tooling, production tests, this doc |

---

## Related documents

- [`THAI_CANON_KNOWLEDGE_PRODUCTION_PHASE_C.md`](THAI_CANON_KNOWLEDGE_PRODUCTION_PHASE_C.md)
- [`THAI_MAHABHUT_CANON_COMPLETION_PROGRAM.md`](THAI_MAHABHUT_CANON_COMPLETION_PROGRAM.md)
