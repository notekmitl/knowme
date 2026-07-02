# Thai Astrology Canon — Knowledge Production Phase G (Lookup Tables)

> **Outcome:** Mahabhut **lookup-table / reference-table** knowledge extracted under
> D-073 Phase G charter. **Coverage increased 770 → 825 atomic units** (+55) plus
> **28 reference-table cells**. **Phase G closed** at documented stop conditions.

Status: **CLOSED (Phase G)** · Knowledge production only · D-078 ontology + reference
table model · No runtime/engine/Mirror changes.

---

## 1 · Produced this phase

| Layer | Count | Source |
|---|---|---|
| Remainder → archetype chart (atomic) | 6 | p19 |
| Jan–Apr remainder adjustment (atomic) | 7 | p19 |
| House digit placement grid (atomic) | 42 | p20 (6×7; เศษ 4 excluded) |
| Birth-date chart lookup (reference cells) | 28 | pp.23–27 |

**Total atomic units:** 825 (was 770)  
**Reference-table cells:** 28 (`lookupTable.birthDateChart`)

---

## 2 · Modeling approach

### Atomic-representable (imported)

- **p19** `rotationIndex.remainderN --relates_to--> archetypeChart.*` under `เศษ/ดวง`
- **p19** seasonal adjustment rows under `1 ม.ค.–15 เม.ย.` / `ลดหนึ่งแต้ม`
- **p20** `mahabhutPosition.* --relates_to--> placementDigit.dN` per `เศษ N` × house column

### Reference-table layer (D-078)

- **pp.23–27** precomputed birth-date rows stored as `CanonReferenceTableCell`
  (table id, title, row key, column key, cell value, page evidence)
- **No calculation** inside the reference layer — preservation only

---

## 3 · Stop conditions (Phase G closed)

### OCR blocked

| Source | Reason |
|---|---|
| p18 dasha ages (Sun, Mercury, Jupiter, Venus) | Digit corruption |
| p20 เศษ 4 placement sequence | Row OCR corrupted |
| pp.23–27 (majority of rows) | Birth-date / chart cell unreadable |
| p38 Sun/Mon Taksa grids | Planet tokens not recoverable (Phase C carryover) |

### Knowledge modeling gaps

| Material | Reason |
|---|---|
| p19 เศษ 6 → chart | Not listed on p19 prose — not inferred from table rows |
| p18 planet transit rotation | Procedural sequence, not a static lookup cell |
| p22 split layout | Column alignment broken — partial recovery via p24 parser only |

---

## 4 · Ontology (D-078)

- `rotationIndex.remainder0`–`remainder6`
- `archetypeChart.*` (7 charts)
- `placementDigit.d0`–`d6`
- `lookupTable.birthDateChart`
- `KnowledgeDomain.lookupTables`

---

## 5 · Production metrics

| Metric | Value |
|---|---|
| Atomic units | **825** |
| Reference cells | **28** |
| Thai validation suite | **287 tests green** |

---

## 6 · Toolchain

| Step | Artifact |
|---|---|
| Extract | `tool/extract_phase_g_lookup_tables.py` |
| Generate | `tool/generate_phase_g_dart.py` |
| Import | `tool/merge_phase_g_foundation.py` |
| OCR blocked | `tool/output/phase_g_ocr_blocked.json` |
| Modeling gaps | `tool/output/phase_g_modeling_gaps.json` |

---

## 7 · Related decisions

- **D-073** — Mahabhut Canon Completion Program
- **D-078** — Lookup table ontology + Canon Reference Table cell model
