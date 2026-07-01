# Thai Astrology Canon — Knowledge Production Phase F (Remedies)

> **Outcome:** Mahabhut **remedy / สะเดาะเคราะห์** knowledge extracted as structured
> atomic Canon units under D-073 Phase F charter. **Coverage increased 683 → 770 units**
> (+87). **Phase F closed** at documented stop conditions — mantra prose, compound
> ritual procedures, and OCR-blocked image pages remain unextracted.

Status: **CLOSED (Phase F)** · Knowledge production only · Platform frozen (D-065) ·
D-077 ontology expansion · No runtime/engine/Mirror changes.

---

## 1 · Produced this phase (+87 units → 770 total)

| Layer | Count | Pages |
|---|---|---|
| Universal procedure (trigger + items) | 5 | 294 |
| Birth-weekday ritual directions | 7 | 294 |
| Birth-weekday ritual symbols | 7 | 295–297 |
| Buddha-day image targets | 6 | 298–304 |
| Embedded life-period remedy facts | 62 | 14 life-period pages |

**Ontology (D-077):** `remedy.sadoeKhroh`; six `remedyItem.*`; thirteen
`ritualTarget.*` (weekday symbols + พระปาง captions).

**Relations used:** existing V2 `requires`, `relates_to` — no new `AtomicRelation`
enum entries.

**Domain:** `KnowledgeDomain.remedies`.

---

## 2 · Source coverage

### p294 — โลกียะสุตาลังการ universal procedure

- Trigger: `remedy.sadoeKhroh --relates_to--> periodStatus.duengTok`
  (`condition`: `ดวงตกหนัก`)
- Required items: พระประจำวัน, แจกัน ๓ ลูก, ดอกไม้เกินอายุ/แจกัน, เทียนขี้ผึ้งเกินอายุ
- Seven birth-weekday ritual directions (`context`: `คนเกิดวัน…`)

### pp.295–297 — weekday ritual symbols (atomic only)

- Seven `remedy.sadoeKhroh --relates_to--> ritualTarget.*` with verbatim
  `มี…เป็นสัญลักษณ์` conditions per birth weekday

### pp.298–304 — พระประจำวัน image captions

- Six buddha-posture targets scoped to birth weekday (`พระปางถวายเนตร` … `นาคปรก`)

### Embedded blocks (14 pages)

- Atomic `requires` / `relates_to` facts from explicit `วิธีแก้` blocks on life-period
  pages (54, 58, 62, 66, 71, 74, 91, 98, 100, 107, 160, 191, 202, 244)
- `life_period` context when period heading is OCR-readable; otherwise
  `other` / `ว่าด้วยการแก้ดวง=สะเดาะเคราะห์`

---

## 3 · Stop conditions (Phase F closed)

### OCR Block — not produced

| Source | Reason |
|---|---|
| p300 | พระประจำวันอังคาร image caption unreadable |
| p293 | Remedy chapter intro unreadable |

### Knowledge Modeling Gap — not produced

| Material | Reason |
|---|---|
| pp.295–297 คำอธิษฐาน | Multi-clause mantra / ritual prose — not splittable without losing meaning |
| Embedded multi-step fallbacks | Compound instructions (e.g. alternate direction when image missing) — not atomic |
| User-facing “ควรทำพิธี…” recommendations | Advice markers only — no explicit remedy structure |

### Charter exclusions (unchanged)

- No user-facing remedy advice imported
- No medical-treatment claims
- No inferred planet→remedy mapping
- No runtime / Mirror / engine connection

---

## 4 · Production metrics

| Metric | Value |
|---|---|
| Total units | **770** |
| Phase F remedy units | **87** |
| Universal (no context) | **5** |
| Context-scoped remedy units | **82** |
| Embedded source pages | **14** |
| Thai validation suite | **278 tests green** |

---

## 5 · Toolchain

| Step | Artifact |
|---|---|
| Extract | `tool/extract_phase_f_remedies.py` → `tool/output/phase_f_remedy_units.json` |
| Generate | `tool/generate_phase_f_dart.py` → `test/validation/thai/generated/phase_f_remedy_units.dart` |
| Import | `tool/merge_phase_f_foundation.py` → `knowledge/canon/production/foundation_v1.knowme.json` |
| OCR blocked | `tool/output/phase_f_ocr_blocked.json` |
| Modeling gaps | `tool/output/phase_f_modeling_gaps.json` |

---

## 6 · Related decisions

- **D-073** — Mahabhut Canon Completion Program
- **D-077** — Remedy / remedyItem / ritualTarget ontology (Phase F)
