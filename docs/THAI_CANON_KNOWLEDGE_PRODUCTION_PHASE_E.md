# Thai Astrology Canon — Knowledge Production Phase E (Prediction Rules)

> **Outcome:** Mahabhut **prediction rules** extracted as structured atomic knowledge
> under D-073 Phase E charter. **Coverage increased 678 → 683 units** (+5).
> **Phase E closed** at documented stop conditions — per-period narrative effects
> and one OCR-blocked example remain unextracted.

Status: **CLOSED (Phase E)** · Knowledge production only · Platform frozen (D-065) ·
D-066–D-075 unchanged · D-076 ontology expansion · No deploy.

---

## 1 · Produced this phase (+5 units → 683 total)

| Unit | Page | Model |
|---|---|---|
| `periodStatus.duengTok --produces--> predictionEffect.weak` | 40 | Universal fall-position weakness rule |
| `periodStatus.duengKhuen --produces--> predictionEffect.strong` | 41 | Universal rise-position strength rule |
| `taksaRole.kalakini --opposes--> periodStatus.duengTok` | 40 | Exception: `condition` = `อยู่เรือนภังคะ-มรณะ-ปูติ` |
| `taksaRole.kalakini --opposes--> periodStatus.duengKhuen` | 41 | Exception: `condition` = `อยู่เรือนธงชัย-ขุมทรัพย์-ราชา-อธิบดี` |
| `planet.jupiter --produces--> domain.learning` (strength low) | 40 | Illustrative example: fall positions |

**Ontology (D-076):** `predictionEffect.weak` (อ่อนแอ), `predictionEffect.strong` (เข้มแข็ง).

**Relations used:** existing V2 `produces`, `opposes` — no `influences` / `strengthens` wire
added to `AtomicRelation` (ontology registry only).

---

## 2 · Source coverage (pp.40–41)

### p40 — หลักการทํานาย (ดวงตก / fall positions)

- Universal: planets/taksa in ภังคะ-มรณะ-ปูติ → `predictionEffect.weak` (verbatim อ่อนแอ)
- Exception: กาฬกิณี in fall positions → opposes `periodStatus.duengTok`
- Example: ดาวพฤหัส in fall → `domain.learning` with strength low

### p41 — หลักการทํานาย (ดวงขึ้น / rise positions)

- Universal: planets/taksa in ธงชัย-ขุมทรัพย์-ราชา-อธิบดี → `predictionEffect.strong` (verbatim เข้มแข็ง)
- Exception: กาฬกิณี in rise positions → opposes `periodStatus.duengKhuen`

---

## 3 · Stop conditions (Phase E closed)

### OCR Block — not produced

| Source | Reason |
|---|---|
| p41 Jupiter learning rise example | Planet name / learning clause corrupted in OCR (`พฤห(4)ตกิตฏ…`) — recorded in `tool/output/phase_e_ocr_blocked.json` |

### Knowledge Modeling Gap — not produced

| Material | Reason |
|---|---|
| Per-period domain effects (pp.44+) | Life-period pages state effects as compound narrative (`สุขภาพ…การงาน…การเงิน` in one breath; `มักจะ` / `ส่งผลให้` markers) — not splittable without inference |
| Long pp.40–41 prediction prose lists | Multi-clause weakness/strength enumerations — not atomic single facts |
| `influences` / `strengthens` / `weakens` as graph wires | Registered in ontology vocabulary but **not** in V2 `AtomicRelation` enum — used `produces` / `opposes` + `strength` instead |

### Charter exclusions (deferred)

| Material | Deferred to |
|---|---|
| Remedy / สะเดาะเคราะห์ blocks | Phase F |
| Lookup tables (p18 → p23 rotation detail) | Phase G |

---

## 4 · Production metrics

| Metric | Value |
|---|---|
| Total units | **683** |
| Phase E prediction-rule units | **5** |
| Universal rules (no context) | **2** |
| Conditional rules (`condition` field) | **3** |

---

## 5 · Validation

Pipeline: Working Source → `tool/extract_phase_e_prediction_rules.py` → generated
Dart fixtures → ontology resolution → workspace gates → `foundation_v1.knowme.json`.

**Tests:** page provenance, universal vs conditional scoping, no remedy import,
`predictionEffect` alias resolution, full `test/validation/thai/` green.

---

## 6 · Commits

| Commit | Contents |
|---|---|
| `Mahabhut Canon Phase E Prediction Rule Ontology` | D-076 `predictionEffect` + ontology tests |
| `Mahabhut Canon Phase E Prediction Rules Batch 01` | +5 units, tooling, production tests, this doc |

---

## Related documents

- [`THAI_CANON_KNOWLEDGE_PRODUCTION_PHASE_D.md`](THAI_CANON_KNOWLEDGE_PRODUCTION_PHASE_D.md)
- [`THAI_MAHABHUT_CANON_COMPLETION_PROGRAM.md`](THAI_MAHABHUT_CANON_COMPLETION_PROGRAM.md)
