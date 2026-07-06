# Thai Taksa Source Forensics — OCR Recovery

**Phase:** Taksa Source Forensics OCR Recovery (documentation + forensics artifacts only)  
**Baseline:** `5a337cc` — Taksa Rotation Model  
**Final classification:** `READY_FOR_POST_FREEZE_PATCH_TAKSA_ROTATION`

No Canon edits. No rotation implementation. No public output changes.

---

## Sources reviewed

| PDF index | Book p. | Section | Rotation relevance |
| ---: | ---: | --- | --- |
| 37 | 22 | มหาทักษา intro + planet↔direction legend | Digit 1–8 → planet names (source-backed) |
| 38 | 23 | มหาทักษา tables + clockwise rule | **Primary** — Sun/Mon grids + Tue example |
| 39 | 24 | ความหมายของแต่ละภูมิ | Role meanings only |
| 40 | 25 | หลักการทำนาย | Prediction rules (Phase E) — no rotation |
| 41 | 26 | หลักการทำนาย (cont.) | Prediction rules — no rotation |

**Assets:** `D:/MahabhutOCR/pages/page_{037..041}.png`, `D:/MahabhutOCR/txt/page_{037..041}.txt`, repo copy `tool/output/source_forensics_page_038.txt`.

**Planet digit legend (p37, source-backed):** grid digits 1–8 map to อาทิตย์ จันทร์ อังคาร พุธ พฤหัส ศุกร์ เสาร์ ราห via direction positions on the มหาทักษา diagram — not external astrology.

---

## Weekday recovery results

### Sunday — `RECOVERED_PARTIAL`

**Image (p38):** `คนเกิดวันอาทิตย์` 3×3 grid with digits + role labels.

| Digit | Planet (p37) | Role (image) | Canon id |
| ---: | --- | --- | --- |
| 1 | อาทิตย์ | บริวาร | `taksaRole.boriwan` |
| 2 | จันทร์ | **[empty cell]** | — |
| 3 | อังคาร | เดช | `taksaRole.det` |
| 4 | พุธ | ศรี | `taksaRole.sri` |
| 5 | พฤหัส | อุตสาหะ | `taksaRole.utsaha` |
| 6 | ศุกร์ | กาฬกิณี | `taksaRole.kalakini` |
| 7 | เสาร์ | มูละ | `taksaRole.mula` |
| 8 | ราห | มนตรี | `taksaRole.montri` |

**Blocker:** digit-2 cell empty on page image — `planet.moon` → อายุ not recoverable (`LAYOUT_BLOCKED`).  
**OCR:** Sunday table planet tokens `OCR_BLOCKED` in `page_038.txt`.

### Monday — `RECOVERED_COMPLETE`

**Image (p38):** full 3×3 grid for `คนเกิดวันจันทร์`.

| Digit | Planet | Role | Canon id |
| ---: | --- | --- | --- |
| 1 | อาทิตย์ | กาฬกิณี | `taksaRole.kalakini` |
| 2 | จันทร์ | บริวาร | `taksaRole.boriwan` |
| 3 | อังคาร | อายุ | `taksaRole.ayu` |
| 4 | พุธ | เดช | `taksaRole.det` |
| 6 | ศุกร์ | มนตรี | `taksaRole.montri` |
| 8 | ราห | อุตสาหะ | `taksaRole.utsaha` |
| 5 | พฤหัส | มูละ | `taksaRole.mula` |
| 7 | เสาร์ | ศรี | `taksaRole.sri` |

**Patch-ready:** 8 assignments — `source_forensics_patch` candidate (not imported in this phase).

### Tuesday — `RECOVERED_COMPLETE` (verification)

**Prose on p38** matches frozen Canon exactly:

| Planet | Role | Frozen unit |
| --- | --- | --- |
| อังคาร | บริวาร | `mahabhut.p38.mars_located_in_boriwan_tuesday_birth` |
| พุธ | อายุ | `mahabhut.p38.mercury_located_in_ayu_tuesday_birth` |
| เสาร์ | เดช | `mahabhut.p38.saturn_located_in_det_tuesday_birth` |
| พฤหัส | ศรี | `mahabhut.p38.jupiter_located_in_sri_tuesday_birth` |
| ราหู | มูละ | `mahabhut.p38.rahu_located_in_mula_tuesday_birth` |
| ศุกร์ | อุตสาหะ | `mahabhut.p38.venus_located_in_utsaha_tuesday_birth` |
| อาทิตย์ | มนตรี | `mahabhut.p38.sun_located_in_montri_tuesday_birth` |
| จันทร์ | กาฬกิณี | `mahabhut.p38.moon_located_in_kalakini_tuesday_birth` |

**Result:** `CONFIRMED` — no `SOURCE_FORENSICS_PATCH_REQUIRED`.

### Wednesday daytime — `NOT_IN_SOURCE`

Zero OCR hits for `พุธกลางวัน` / `กลางวัน` across Mahabhut corpus. No p38 table for Wednesday daytime birth.

### Wednesday night / Rahu — `NOT_IN_SOURCE`

Zero OCR hits for `พุธกลางคืน`. `ราหู` appears in Tuesday **example sequence** only — not as a separate birth-weekday case. **Not collapsed** with daytime Wednesday.

### Thursday — `NOT_IN_SOURCE`

No rotation table. General clockwise rule prose only (`สำหรับวันที่เหลือ`).

### Friday — `NOT_IN_SOURCE`

Same as Thursday.

### Saturday — `NOT_IN_SOURCE`

Same as Thursday.

---

## Decision

**`READY_FOR_POST_FREEZE_PATCH_TAKSA_ROTATION`**

- **Monday:** 8 new source-backed assignments recoverable from p38 image + p37 digit legend.
- **Sunday:** 7/8 recoverable; digit-2 gap needs `NEEDS_MANUAL_HUMAN_REVIEW` before patch.
- **Wed–Sat:** not in source as explicit rotation tables; applying clockwise rule would be inference — **not done**.

**This commit:** forensics docs + JSON artifacts only. No `foundation_v1.knowme.json` edit.

---

## Machine-readable artifacts

| File | Contents |
| --- | --- |
| `tool/output/taksa_source_forensics_recovered_lines.json` | Minimal recovered lines + Tuesday verification |
| `tool/output/taksa_source_forensics_rotation_candidates.json` | Patch candidates (Mon ready, Sun partial) |
| `tool/output/taksa_source_forensics_blockers.json` | Per-weekday classifications + final result |

---

## Safety boundary

- No Canon mutation
- No rotation resolver changes
- No inference from Tuesday pattern for other weekdays
- No Wednesday daytime/night collapse
- No external Thai astrology knowledge
- Public Thai output unchanged

---

## Recommended next phase

**No User-Facing Integration Yet**

Approved post-freeze patch (`Mahabhut Canon Post-Freeze Patch 002 Taksa Rotation Evidence`) for Monday rotation, then Taksa Rotation Model expansion to consume patched Canon — before any user-facing Taksa integration.
