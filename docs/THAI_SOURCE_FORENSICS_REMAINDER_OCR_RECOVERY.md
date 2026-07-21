# Thai Source Forensics — Remainder / เศษดวง OCR Recovery

Phase: **Source Forensics OCR Recovery** (documentation + forensics artifacts only)

Prerequisites: Remainder Calculation Model (`ca02e35`).

Prior blocker: `NEEDS_SOURCE_FORENSICS` — formula/table not reliably available from OCR text alone.

Sources reviewed: `D:/MahabhutOCR/pages/page_{018..027,038}.png`, `D:/MahabhutOCR/txt/page_{018..027,038}.txt`, repo PDF `ตำราดูและแก้ดวงชะตาด้วยตนเอง หลักมหาภูต ฉบับสมบูรณ์.pdf`.

**Note:** PDF/OCR file index ≠ book printed page number. Canon evidence `page` fields in frozen units refer to PDF/OCR index (e.g. index 19 = printed book page 4 in section **วิธีใช้ตำรา**).

---

## Pages reviewed

| PDF index | Book p. | Section | Remainder relevance |
| ---: | ---: | --- | --- |
| 18 | 3 | คำเบื้องต้น — dasha ages | Reviewed; not linked to เศษ |
| 19 | 4 | วิธีใช้ตำรา — **formula + mapping + adjustment** | **Primary derivation recovered** |
| 20 | 5 | หลักการวางเลข 7 ตัว | Placement grid; เศษ 4 row recovered |
| 21 | 6 | คำนวณสำเร็จรูป intro | Lookup method prose |
| 22 | 7 | Lookup example | Layout-blocked in OCR; example recovered from image |
| 23 | 8 | Lookup table | **RECOVERED** (2470–2490) |
| 24 | 9 | Lookup table | **PARTIAL_RECOVERY** (2490–2510) |
| 25 | 10 | Lookup table | **RECOVERED** (2510–2530) |
| 26 | 11 | Lookup table | **RECOVERED** (2530–2550) |
| 27 | 12 | Lookup table | **PARTIAL_RECOVERY** (2550–2570; one typo row) |
| 38 | 23 | มหาทักษา | Reviewed; no remainder mechanics |

---

## Formula search result

**Classification: `FORMULA_FOUND`**

Recovered on PDF page **19** (book p. 4):

```
[1] เอาปีเกิด พ.ศ. ตั้ง ลบด้วย 1181 เศษที่ได้เป็นปี จ.ศ.
[2] เอาปี จ.ศ. ดังกล่าวตั้ง หารด้วย 7 โปรดสังเกตเศษที่ได้...
```

| Field | Value |
| --- | --- |
| Required inputs | Birth year **พ.ศ.**; birth date for adjustment window |
| Operation | `(birthYearBE - 1181) mod 7` → raw remainder 0–6 |
| Month/date adjustment | **1 ม.ค.–15 เม.ย.**: subtract 1 from raw remainder (0→6 wrap) |
| Output range | **0–6** |
| Examples | p22 narrative example: raw 2 → adjusted 1 → ดวงกำพร้า |
| Exception | **16 เม.ย.**: `ต้องดูกับอาจารย์เท่านั้น` — outside deterministic automation |

OCR text alone was **`FORMULA_OCR_BLOCKED`** for remainder-6 mapping line and Apr-16 date digit; page **image review** resolved both.

---

## Lookup table recovery result

**Table:** `lookupTable.birthDateChart` / **คำนวณสำเร็จรูป** / column **เศษ/ดวง**

| PDF pages | Classification | Rows recovered (approx.) |
| --- | --- | ---: |
| 23 | RECOVERED | 20 |
| 24 | PARTIAL_RECOVERY | 19 (+ 1 gap) |
| 25 | RECOVERED | 20 |
| 26 | RECOVERED | 20 |
| 27 | PARTIAL_RECOVERY | 20 (+ 1 typo end-year) |
| 22 | LAYOUT_BLOCKED (OCR) | Example row only |

Row key pattern (all recovered rows): `17 เม.ย. {year} ถึง 15 เม.ย. {year+1}`

Remainder→chart labels from table (consistent all pages):

| Remainder | Chart label |
| ---: | --- |
| 0 | มหาเศรษฐี |
| 1 | กำพร้า |
| 2 | นักภาษา |
| 3 | นักบริหาร |
| 4 | มนุษย์เจ้าสำราญ |
| 5 | เศรษฐี |
| 6 | นักวิชาการ |

Prior Phase G pipeline reported **28 readable / ~62 OCR-blocked** cells from **text OCR only**. Forensics from **page images** shows most blocked rows are **source-present** — blocker was OCR quality, not missing book content.

**Alternate path:** `READY_TO_USE_REFERENCE_TABLE_REMAINDER` once rows are validated and date-range resolver is approved (not implemented this phase).

---

## p19 mapping recovery result

| Question | Result |
| --- | --- |
| remainder 6 mapped? | **Yes** — handwritten on formula page image; confirmed on all lookup pages as `6 นักวิชาการ` |
| `archetypeChart.nakwichakan` mapped? | **Yes via table** — `6 นักวิชาการ` ↔ `nakwichakan` |
| Jan–Apr adjustment timing? | **After division, before chart label** — `ลดจากเศษที่หารได้จริง` |
| p19 explains primary derivation? | **Yes on PDF p.19 image**; frozen Canon atoms captured mapping/adjustment only |

No p19 gaps were **repaired** in Canon this phase.

---

## p20 placement row recovery

**`เศษ 4` row: RECOVERED** — `4-0-3-6-2-5-1` (PDF p.20 image).

Relevance: **downstream house-digit placement only** — not remainder calculation.

---

## p18 dasha recovery

Planet age table **recovered from image** (Sun 6, Moon 15, Mars 8, Mercury 17, Jupiter 19, Venus 21, Saturn 10, Rahu 12).

**Not linked** to remainder / เศษดวง in source prose — excluded from remainder model.

---

## Final source-forensics classification

**`READY_TO_IMPLEMENT_REMAINDER_CALCULATION`**

Explicit source-backed formula recovered. Lookup-table path also viable (`READY_TO_USE_REFERENCE_TABLE_REMAINDER`) but formula is primary.

Remaining human-review items (do not block formula implementation):

- Handwritten `เศษ 6` line on formula page — table corroborates
- 16 เม.ย. exception policy
- Minor table typos / one gap on p24

---

## Artifacts (forensics only — not Canon import)

| File | Purpose |
| --- | --- |
| `tool/output/source_forensics_remainder_recovered_lines.json` | Verbatim recovered lines |
| `tool/output/source_forensics_remainder_tables.json` | Table structure + sample rows |
| `tool/output/source_forensics_remainder_blockers.json` | Residual blockers + classification |

---

## Proof: public output unchanged

No runtime, engine, Mirror, or UI changes in this phase.

Thai validation suite green (448 tests — no new parser code).

---

## Recommended next phase

**Canon Archetype Mapping Completion**

Forensics confirms `rotationIndex.remainder6` → `archetypeChart.nakwichakan` from source tables; frozen p19 Canon gap can be closed in a controlled Canon phase after human review of handwritten formula-page line.

Implementation of `ThaiMahabhutRemainderCalculator` remains a separate phase (not done here).

---

## Key files

| File | Role |
| --- | --- |
| `docs/THAI_SOURCE_FORENSICS_REMAINDER_OCR_RECOVERY.md` | This report |
| `tool/output/source_forensics_remainder_*.json` | Machine-readable forensics |
