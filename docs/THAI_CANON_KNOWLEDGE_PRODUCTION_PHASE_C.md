# Thai Astrology Canon — Knowledge Production Phase C (Taksa)

> **Outcome:** Mahabhut **ทักษา** vocabulary, role meanings (where atomic),
> Tuesday-born rotation, and per-chart role assignments extracted under D-073
> Phase C charter. **Coverage increased 357 → 452 units** (+95).
> **Phase C closed** at documented stop conditions — no further representable
> Taksa facts without modeling fix or OCR recovery.

Status: **CLOSED (Phase C)** · Knowledge production only · Platform frozen (D-065) ·
D-066–D-073 unchanged · D-074 ontology expansion · No deploy.

---

## 1 · Produced this phase (+95 units → 452 total)

| Category | Units | Pages / scope | Model |
|---|---|---|---|
| Tuesday-born rotation | 8 | p38 (`คนเกิดวันอังคาร`) | `planet --located_in--> taksaRole.*` · `context: other` |
| Role meanings (atomic) | 4 | p39 | `taksaRole --owns--> domain.*` |
| Per-chart role assignments | 83 | 61 life-period / archetype pages | `planet --located_in--> taksaRole.*` · `context: archetype_chart` or `life_period` |

**Ontology (D-074):** eight `taksaRole.*` entities — vocabulary only, no meaning
fields: `boriwan`, `ayu`, `det`, `sri`, `mula`, `utsaha`, `montri`, `kalakini`.

**Relation:** existing `located_in` (no new relation wire). **Context:** existing
`archetype_chart`, `life_period`, and `other` (D-068) — no `taksa_chart` type added;
charter-allowed context types suffice.

---

## 2 · Role meanings extracted (p39)

| Role | Domain | Source line (verbatim anchor) |
|---|---|---|
| อายุ | `domain.health` | สุขภาพ, ไรคภัยไข้เจ็บ |
| เดช | `domain.career` | ตําแหน่งหน้าที่การงาน |
| ศรี | `domain.finance` | ทรัพย์สินเงินทอง |
| มนตรี | `domain.career` | เจ้านาย, ผู้บังคับบัญชา |

---

## 3 · Stop conditions (Phase C closed)

### Knowledge Modeling Gaps — role meanings (not produced)

| Role | Page | Reason |
|---|---|---|
| บริวาร | 39 | Compound enumeration (บุตรธิดา, ภรรยา, สามี, ญาติมิตร, …) — no single `domain.*` |
| มูละ | 39 | Compound (บ้านเรือน, บิดามารดา, หลักฐาน, ทรัพย์มรดก, การเดินทาง, …) |
| อุตสาหะ | 39 | OCR garbled (`จลาจขยันตนี้หเพีย7)`) + compound (การงาน, การศึกษา) |
| กาฬกิณี | 39 | Compound predictive / ritual tone (อุปสรรค, สิ่งชั่วร้าย, …) |

### OCR Blocks — rotation tables (not produced)

| Source | Reason |
|---|---|
| p38 `คนเกิดวันอาทิตย์` / `คนเกิดวันจันทร์` tables | Planet↔role grid corrupted; planet tokens not recoverable |
| 18 per-chart lines (pages 54, 60, 64, 91, …) | `ดาวแห่ง…` phrase present but planet token not resolvable on line or predecessor |

**Extracted instead:** clean Tuesday-born prose example on p38 (8 assignments).

### Out of Phase C scope (deferred)

| Source | Deferred to |
|---|---|
| pp.40–41 prediction / interpretation rules | Phase E — Prediction Rules |

### Not representable without chart context (not produced)

72 OCR pages contain `ดาวแห่ง…` phrases inside narrative life-period prose **without**
a recoverable `ดวง…` chart header on the page. Assigning these would require inferring
chart scope → forbidden (no inference from missing rows).

---

## 4 · Production metrics (D-070, reporting only)

| Metric | Value |
|---|---|
| Total units | **452** (was 357) |
| Taksa `located_in` assignments | **91** |
| Taksa `owns` role meanings | **4** |
| Mahabhut natal placements (unchanged) | **40** |

### Coverage by Taksa role (assignments only)

| Role | Assignments |
|---|---|
| บริวาร | 21 |
| อายุ | 14 |
| เดช | 18 |
| ศรี | 17 |
| มูละ | 15 |
| อุตสาหะ | 4 |
| มนตรี | 1 |
| กาฬกิณี | 1 |

### Coverage by context (all 452 units)

| Context | Units |
|---|---|
| general | 321 |
| archetype_chart | 43 |
| life_period | 80 |
| other | 8 |

---

## 5 · Validation

Pipeline exercised: Working Source → deterministic extraction
(`tool/extract_phase_c_taksa.py`) → generated Dart fixtures → ontology resolution →
workspace validation gates → `foundation_v1.knowme.json` import.

**Tests added/updated:**

- Ontology: 8 taksa roles resolve from Thai aliases (D-074)
- Production: context-scoped taksa placements, no unscoped taksa import, page
  provenance on every Phase C unit, injectivity guards split mahabhut vs taksa

**Suite:** `flutter test test/validation/thai/` — all pass.

---

## 6 · Tooling (deterministic, reproducible)

| Tool | Purpose |
|---|---|
| `tool/extract_phase_c_taksa.py` | OCR → atomic units JSON |
| `tool/generate_phase_c_dart.py` | JSON → `phase_c_taksa_units.dart` |
| `tool/merge_phase_c_foundation.py` | Merge into `foundation_v1.knowme.json` |

Working Source: `D:\MahabhutOCR\txt\page_NNN.txt` (external OCR corpus).

---

## 7 · Commits

| Commit | Contents |
|---|---|
| `Mahabhut Canon Phase C Taksa Ontology` | D-074 `taksaRole` category + 8 entities + ontology tests |
| `Mahabhut Canon Phase C Taksa Batch 01` | +95 production units, extraction tooling, production tests, this doc |

---

## Related documents

- [`THAI_MAHABHUT_CANON_COMPLETION_PROGRAM.md`](THAI_MAHABHUT_CANON_COMPLETION_PROGRAM.md) — D-073 program of record
- [`THAI_CANON_PRODUCTION_VOLUME_1_CLOSURE.md`](THAI_CANON_PRODUCTION_VOLUME_1_CLOSURE.md) — 357-unit baseline
- [`THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_2B.md`](THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_2B.md) — original Taksa gap analysis
