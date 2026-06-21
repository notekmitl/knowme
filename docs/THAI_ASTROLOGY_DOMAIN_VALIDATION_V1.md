# Thai Astrology Domain Validation V1

**Sprint type:** Research + Validation Only (no code changes)  
**Date:** June 2026  
**Purpose:** Lock calculation standards before Thai Mirror V1  
**Scope:** OQ-1, OQ-2, OQ-5, OQ-6 (Myanmar Seven + Mahabhuta Myanmar-adapted foundation)

---

## 1. Executive Summary

Research confirms that the **authentic 4-base system (เลข 7 ตัว 4 ฐาน)** used in Thai and Myanmar-adapted astrology is **not** a single-number merge formula. It is a **7-column × 4-row table**:

| Row | Name | Source |
|-----|------|--------|
| 1 | ฐานวัน (Day) | Weekday → rotated sequence 1–7 |
| 2 | ฐานเดือน (Month) | Lunar month → rotated sequence 1–7 |
| 3 | ฐานปี (Year) | Zodiac year → rotated sequence 1–7 |
| 4 | ฐานผลรวม (Sum) | **Vertical sum** of rows 1+2+3 per column |

The current KnowMe Foundation Engine uses a **PROPOSED placeholder** (`mod-7` merge of scalar month/year bases). This **does not match** authoritative sources.

**Critical source correction:**  
"หลวงวิจิตรวาทการ" is cited in KnowMe as philosophical source for **มหาภูติพม่าประยุกต์**, but the **numeric 4-base formulas** come from **พรหมชาติ / เลข 7 ตัว tradition** (manuscripts, อ.สำราญ สมุทรวานิช, อ.นภา วรบุตร, หมอชิต บางบำหรุ). หลวงวิจิตรวาทการ was a polymath/historian — not the primary author of the 7-number chart algorithm.

**Recommendation before Thai Mirror V1:**  
Freeze the **table-based 4-base standard** (rows 1–4) with lunar calendar conversion and Thai astrological day/year boundaries. Do **not** ship the current scalar merge formula to production.

| OQ | Verdict | Confidence |
|----|---------|------------|
| OQ-1 Merge formula | **Resolved** — vertical sum table, not mod-merge | **High** |
| OQ-2 Month base | **Resolved** — lunar month (จันทรคติ), paired-month reduction | **High** |
| OQ-5 Golden cases | **Partial** — 5 worked examples found; need expert sign-off | **Medium** |
| OQ-6 Year boundary | **Resolved** — ขึ้น 1 ค่ำ เดือน 5 (Thai lunar Songkran) | **High** |

---

## 2. OQ-1 Findings — Exact 4-Base Merge Formula

### 2.1 Question

What is the exact formula combining **วัน / เดือน / ปี / เวลา** for Myanmar Seven and มหาภูติพม่าประยุกต์?

### 2.2 Source & Reference

| Priority | Source | URL / Reference | Authority |
|----------|--------|-----------------|-----------|
| 1 | **ตำราพรหมชาติ** — หลักการพยากรณ์แบบเลข 7 ตัว | http://horoscope.dooasia.com/phommachat/phommachath014c001.shtml | **High** — canonical pedagogical text |
| 2 | **พระตำรับเลขเจ็ดตัว** (manuscript) | https://manuscripts.sac.or.th/article-download.php?id=28 | **High** — primary manuscript |
| 3 | **หมอชิต บางบำหรุ** — เลข 7 ตัว + ทักษา + กาลโยค | https://www.horawej.com/_m/article/content/content.php?aid=538960899 | **High** — practitioner lineage (อ.นภา วรบุตร) |
| 4 | **ซินแสหวาง** — เลข 7 ตัว 4 ฐาน พื้นฐาน 1 | https://sinsaehwang.com/.../พื้นฐาน-1/ | **Medium** — clear pedagogy, simplified calendar |
| 5 | **เลข 7 ตัว แบบพิศดาร** — อ.สำราญ สมุทรวานิช | เกษมบรรณกิจ | **High** — named "แม่บท" by practitioners |

### 2.3 Formula (Authoritative)

#### Step 1 — Build Row 1 (ฐานวัน)

Weekday number: อาทิตย์=1 … เสาร์=7

Place rotated sequence starting with weekday number across 7 columns:

```
อัตตะ  หินะ  ธะนัง  ปิตา  มาตา  โภคา  มัชฌิมา
```

| Weekday | Sequence |
|---------|----------|
| อาทิตย์ (1) | 1 2 3 4 5 6 7 |
| จันทร์ (2) | 2 3 4 5 6 7 1 |
| อังคาร (3) | 3 4 5 6 7 1 2 |
| พุธ (4) | 4 5 6 7 1 2 3 |
| พฤหัส (5) | 5 6 7 1 2 3 4 |
| ศุกร์ (6) | 6 7 1 2 3 4 5 |
| เสาร์ (7) | 7 1 2 3 4 5 6 |

**Time rule (day boundary):** Day changes at **06:00** local time.  
Before 06:00 counts as previous weekday.  
*(Sources: sinsaehwang, horawej)*

#### Step 2 — Build Row 2 (ฐานเดือน)

See OQ-2 for month-number derivation. Given month base `m` (1–7), place rotated sequence starting with `m`:

```
ตนุ  กฎุมภะ  สหัสชะ  พันธุ  ปุตตะ  อริ  ปัตนิ
```

#### Step 3 — Build Row 3 (ฐานปี)

See OQ-6 for year-number derivation. Given year base `y` (1–7), place rotated sequence starting with `y`:

```
มรณะ  ศุภะ  กัมมะ  ลาภะ  พยายะ  ทาสา  ทาสี
```

#### Step 4 — Build Row 4 (ฐานผลรวม) — THE MERGE

**This is the answer to OQ-1.**

For each column `i` (1..7):

```
base4[i] = row1[i] + row2[i] + row3[i]
```

- Minimum sum: 3 (1+1+1)  
- Maximum sum: 21 (7+7+7)  
- Row 4 values are **not** reduced to 1–7 by simple mod in canonical texts — they use a **19-meaning lookup table** (ดาวเล็ก, กำลังดาว, กำลังเทวดา) per อ.สำราญ / หมอชิต

**Optional reduction (some practitioners):**  
When reducing raw sum to 1–7 for auxiliary use:

```
while sum > 7: sum -= 7
```

Verified against horawej worked example (sums 12→5, 17→3, etc.).

#### Role of Time (เวลา)

| Time aspect | Effect | Separate row? |
|-------------|--------|---------------|
| Hour of birth | Determines weekday via **06:00 boundary** | No — affects Row 1 only |
| Advanced (พิศดาร) | Hour can define additional chart layers | Yes — beyond 4-base V1 |
| 4-base merge | Time does **not** add a 5th summand to Row 4 | — |

**Confidence: High** — consistent across พรหมชาติ, manuscript, horawej, sinsaehwang.

### 2.4 Worked Example (พรหมชาติ ตัวอย่างที่ 2)

**Input:** วันจันทร์, เดือน 5, ปีชวด (year base = 1)

| Column | อัตตะ | หินะ | ธะนัง | ปิตา | มาตา | โภคา | มัชฌิมา |
|--------|------|------|-------|------|------|------|---------|
| Row 1 (day) | 2 | 3 | 4 | 5 | 6 | 7 | 1 |
| Row 2 (month) | 5 | 6 | 7 | 1 | 2 | 3 | 4 |
| Row 3 (year) | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
| **Row 4 (sum)** | **8** | **11** | **14** | **10** | **12** | **16** | **12** |

**Source:** พรหมชาติ ตัวอย่างที่ 2 — http://horoscope.dooasia.com/phommachat/phommachath014c001.shtml

### 2.5 KnowMe Engine Gap

Current `SevenNumberChart` uses:

```
finalNumber[pos] = ((day[pos] + monthBase + yearBase - 1) mod 7) + 1
```

This is **incorrect** per authoritative sources. It collapses full rows into scalar bases.

**Confidence: High** that OQ-1 is resolved as **table + vertical sum**, not scalar mod-merge.

---

## 3. OQ-2 Findings — Month Base Table

### 3.1 Question

Does month base use lunar, solar, or special table? What is the 1–7 mapping?

### 3.2 Answer

**Primary standard: จันทรคติ (lunar calendar)** with **ขึ้น 1 ค่ำ** as month boundary.

**NOT** raw Gregorian solar month (though pedagogical sites simplify this for beginners).

### 3.3 Source & Reference

| Source | Rule |
|--------|------|
| พรหมชาติ | "ให้เริ่มนับเดือน ธันวาคม เป็นเดือน 1" — จันทรคติ |
| horawej (หมอชิต) | เดือนไทย ตามปฏิทิน 150 ปี / เกษมบรรณกิจ; เปลี่ยนเดือนทุก **ขึ้น 1 ค่ำ** |
| sinsaehwang | เปลี่ยนเดือน ขึ้น 1 ค่ำ; uses solar month proxy for teaching |

### 3.4 Mapping Table (พรหมชาติ — Authoritative)

Lunar month number (1–12) → base number (1–7) via **paired months** + subtract 7 rule:

| Lunar Month # | Thai Month Names | Month Base | Row-2 Start Sequence |
|---------------|------------------|------------|----------------------|
| 1 | ธันวาคม + กรกฎาคม | **1** | 1 2 3 4 5 6 7 |
| 2 | มกราคม + สิงหาคม | **2** | 2 3 4 5 6 7 1 |
| 3 | กุมภาพันธ์ + กันยายน | **3** | 3 4 5 6 7 1 2 |
| 4 | มีนาคม + ตุลาคม | **4** | 4 5 6 7 1 2 3 |
| 5 | เมษายน + พฤศจิกายน | **5** | 5 6 7 1 2 3 4 |
| 6 | พฤษภาคม (no pair) | **6** | 6 7 1 2 3 4 5 |
| 7 | มิถุนายน (no pair) | **7** | 7 1 2 3 4 5 6 |
| 8 | (8−7=1) | **1** | same as month 1 |
| 9 | (9−7=2) | **2** | same as month 2 |
| 10 | (10−7=3) | **3** | same as month 3 |
| 11 | (11−7=4) | **4** | same as month 4 |
| 12 | (12−7=5) | **5** | same as month 5 |

**Reduction rule (months > 7):**

```
if lunarMonth > 7:
    monthBase = lunarMonth - 7
else:
    monthBase = lunarMonth
```

**Month boundary:** Birth before **ขึ้น 1 ค่ำ** of a month → previous lunar month.  
Example: เกิด 4 เมษายน ก่อนขึ้น 1 ค่ำ → still มีนาคม (sinsaehwang).

### 3.5 Calendar Conversion Requirement

Engine must convert Gregorian birth date → Thai lunar date using:
- ปฏิทิน 100 ปี (e.g. myhora.com — cited by sinsaehwang)
- Or ปฏิทิน 150 ปี (เกษมบรรณกิจ — cited by horawej)

**Confidence: High** for lunar + paired-month table.  
**Confidence: Medium** on exact handling of เดือน 8 สองหน (intercalary month) — horawej says "ใช้เดือน 8" but expert confirmation needed.

### 3.6 KnowMe Engine Gap

Current engine uses **Gregorian solar month proxy** (`_gregorianMonthToBase`). Must be replaced with **lunar month conversion**.

---

## 4. OQ-5 Findings — Golden Reference Cases

### 4.1 Requirement

3–5 examples with birth data + expected 7-number / Mahabhuta output for regression tests.

### 4.2 Golden Cases (from authoritative sources)

#### GC-01 — พรหมชาติ ตัวอย่างที่ 1

| Field | Value |
|-------|-------|
| Weekday | อาทิตย์ |
| Lunar month | 2 (มกราคม / ยี่) |
| Zodiac year | 3 (ขาล) |
| Row 1 | 1 2 3 4 5 6 7 |
| Row 2 | 2 3 4 5 6 7 1 |
| Row 3 | 3 4 5 6 7 1 2 |
| **Row 4** | **6 9 12 15 18 14 10** |
| Source | พรหมชาติ — dooasia.com |

#### GC-02 — พรหมชาติ ตัวอย่างที่ 2

| Field | Value |
|-------|-------|
| Weekday | จันทร์ |
| Lunar month | 5 (เมษายน) |
| Zodiac year | 1 (ชวด) |
| Row 1 | 2 3 4 5 6 7 1 |
| Row 2 | 5 6 7 1 2 3 4 |
| Row 3 | 1 2 3 4 5 6 7 |
| **Row 4** | **8 11 14 10 13 16 12** |
| Source | พรหมชาติ — dooasia.com (col 5 corrected: 6+2+5=13) |

#### GC-03 — พรหมชาติ ตัวอย่างที่ 3

| Field | Value |
|-------|-------|
| Weekday | พฤหัสบดี (5) |
| Lunar month | 9 (9−7=2) |
| Zodiac year | 12→5 (กุน) |
| Row 1 | 5 6 7 1 2 3 4 |
| Row 2 | 2 3 4 5 6 7 1 |
| Row 3 | 5 6 7 1 2 3 4 |
| **Row 4** | **12 15 18 7 10 13 9** |
| Source | พรหมชาติ — dooasia.com |

#### GC-04 — หมอชิต บางบำหรุ (horawej) ตัวอย่างเต็ม

| Field | Value |
|-------|-------|
| Birth (สากล) | 11 กันยายน พ.ศ. 2492, 00:15 น. |
| Thai lunar | วันเสาร์ แรม 3 ค่ำ เดือน 10 ปีฉลู |
| Weekday | เสาร์ (7) |
| Month base | 3 (10−7) |
| Year base | 2 (ฉลู) |
| Row 1 | 7 1 2 3 4 5 6 |
| Row 2 | 3 4 5 6 7 1 2 |
| Row 3 | 2 3 4 5 6 7 1 |
| **Row 4 (raw)** | **12 8 11 14 17 13 9** |
| Row 4 (reduced)* | 5 1 4 7 3 6 2 |
| Source | https://www.horawej.com/index.php?ac=article&Id=538981149 |

*Reduced row shown in source; reduction = repeated subtract 7 while > 7.

#### GC-05 — ซินแสหวาง ตัวอย่าง

| Field | Value |
|-------|-------|
| Birth (สากล) | 4 เมษายน พ.ศ. 2515, 02:00 น. |
| Thai lunar | วันจันทร์ (ก่อน 06:00 ของอังคาร), แรม 5 ค่ำ เดือน 5 ปีชวด |
| Row 1 | 2 3 4 5 6 7 1 |
| Row 2 | 5 6 7 1 2 3 4 |
| Row 3 | 1 2 3 4 5 6 7 |
| **Row 4** | **8 11 14 10 13 16 12** |
| Source | sinsaehwang.com (matches GC-02 structure) |

### 4.3 Mahabhuta Note

Golden cases above validate **4-base numeric table**.  
**มหาภูติ 7 ตำแหน่ง** (พยาธิ, มรณะ, ทายะ, etc.) in KnowMe content layer derives from **กาลโยค + ทักษา** integration (มหาภูติพม่าประยุกต์ course), not directly from Row 4 sums.

Separate golden cases for Mahabhuta position mapping require **กาลโยค chart** examples — not found in free 4-base texts.

**Confidence: Medium** — 5 solid 4-base cases; Mahabhuta-specific golden cases still need domain expert with มหาภูติพม่าประยุกต์ course materials.

### 4.4 Suggested Regression Test Strategy

```
Phase A: Unit test row 1–3 generation (GC-01..05 inputs)
Phase B: Unit test row 4 vertical sums (exact integers)
Phase C: Integration test myanmarKeys mapping policy (requires product decision)
Phase D: Mahabhuta golden cases — pending expert
```

---

## 5. OQ-6 Findings — Year Boundary Rules

### 5.1 Question

Songkran vs Chinese New Year vs solar year for zodiac year base?

### 5.2 Answer

**Thai lunar astrological year change: ขึ้น 1 ค่ำ เดือน 5** (waxing 1st day of 5th lunar month).

This is the **Thai lunar new year / Songkran-aligned** boundary in the 7-number tradition — **not** Chinese New Year, **not** Gregorian Jan 1.

### 5.3 Source & Reference

| Source | Rule |
|--------|------|
| horawej (หมอชิต) | "ใช้เวลาขึ้น 1 ค่ำเดือน 5 เป็นเวลาเปลี่ยนปี นักษัตร ชวด–กุน" |
| sinsaehwang | "เปลี่ยนปีนักษัตรที ขึ้น 1 ค่ำ เดือน 5" |
| พรหมชาติ | 12-animal cycle with mod-7 reduction (paired years) |

**Implication:** Births in **มกราคม–มีนาคม** (Gregorian) may still belong to **previous zodiac year**.

Example (horawej): เกิด มกรา–มีนา → ระวัง ยังเป็นปีนักษัตรเดิม

### 5.4 Year Base Table (พรหมชาติ)

| Zodiac Year | Index (1–12) | Year Base (1–7) | Row-3 Start |
|-------------|--------------|-----------------|-------------|
| ชวด + มะแม | 1, 8→1 | 1 | 1 2 3 4 5 6 7 |
| ฉลู + วอก | 2, 9→2 | 2 | 2 3 4 5 6 7 1 |
| ขาล + ระกา | 3, 10→3 | 3 | 3 4 5 6 7 1 2 |
| เถาะ + จอ | 4, 11→4 | 4 | 4 5 6 7 1 2 3 |
| มะโรง + กุน | 5, 12→5 | 5 | 5 6 7 1 2 3 4 |
| มะเส็ง | 6 | 6 | 6 7 1 2 3 4 5 |
| มะเมีย | 7 | 7 | 7 1 2 3 4 5 6 |

**Reduction rule:**

```
if zodiacIndex > 7:
    yearBase = zodiacIndex - 7
else:
    yearBase = zodiacIndex
```

### 5.5 Burmese Mahabote Comparison (cross-reference only)

Burmese Mahabote uses **April 15** boundary (Thingyan) — different from Thai lunar เดือน 5 rule.  
KnowMe Thai tradition should **not** adopt Burmese April 15 rule for Thai 4-base.

**Confidence: High** for Thai ขึ้น 1 ค่ำ เดือน 5 boundary.

### 5.6 KnowMe Engine Gap

Current engine uses `(year - 4) % 12 + 1` on **Gregorian year** — incorrect.  
Must use **lunar zodiac year** with เดือน 5 boundary.

---

## 6. Recommended Standard (Freeze Proposal)

### 6.1 Freeze for Thai Mirror V1

| Parameter | Recommended Value | Status |
|-----------|-------------------|--------|
| Chart structure | 7 columns × 4 rows table | **FREEZE** |
| Row 1 | Weekday rotation (อาทิตย์=1) | **FREEZE** |
| Row 2 | Lunar month paired table (OQ-2) | **FREEZE** |
| Row 3 | Zodiac year paired table (OQ-6) | **FREEZE** |
| Row 4 merge | Vertical sum per column | **FREEZE** |
| Day boundary | 06:00 local | **FREEZE** |
| Month boundary | ขึ้น 1 ค่ำ | **FREEZE** |
| Year boundary | ขึ้น 1 ค่ำ เดือน 5 | **FREEZE** |
| Calendar input | Gregorian → Thai lunar via 100/150yr calendar | **FREEZE** |
| myanmarKeys mapping | Row 1 values → `myanmar_seven_N` per life position | **PROPOSE** |
| Row 4 interpretation | Lookup table 3–21 (not simple mod) | **DEFER** to V1.1 |
| Mahabhuta positions | กาลโยค layer separate from 4-base | **DEFER** |
| Scalar mod-merge | `((day+month+year-1) mod 7)+1` | **REJECT** |

### 6.2 myanmarKeys Output Policy (Product Decision Needed)

Authoritative texts interpret via **column-wise cross-row analysis** (รหัสดวง), not a single row.

**Recommended for KnowMe V1:**

```
myanmarKeys[i] = myanmar_seven_{ row1[i] }
```

Row 1 (ฐานวัน) at life-position columns maps directly to existing content keys.  
Row 4 provides strength/confidence metadata (future).

### 6.3 Source-of-Truth Hierarchy (Revised)

```
1. พรหมชาติ / พระตำรับเลขเจ็ดตัว (manuscript)
2. อ.สำราญ สมุทรวานิช — เลข 7 ตัวแบบพิศดาร
3. อ.นภา วรบุตร lineage (via หมอชิต บางบำหรุ)
4. มหาภูติพม่าประยุกต์ course (ทักษา + กาลโยค) — for Mahabhuta layer
5. หลวงวิจิตรวาทการ — philosophical/contextual reference, NOT numeric formula author
```

---

## 7. Confidence Assessment

| Finding | Confidence | Reason |
|---------|------------|--------|
| 4-base = table not scalar merge | **High** | 5 independent sources agree |
| Row 4 = vertical sum | **High** | Explicit in พรหมชาติ + horawej |
| Lunar month for Row 2 | **High** | พรหมชาติ + horawej + manuscript |
| Paired month table | **High** | Identical across พรหมชาติ and horawej |
| Year boundary = ขึ้น 1 ค่ำ เดือน 5 | **High** | horawej + sinsaehwang explicit |
| Day boundary = 06:00 | **High** | Multiple sources |
| GC-01..05 numeric values | **High** | Published worked examples |
| Row 4 reduced to 1–7 | **Medium** | Shown in horawej; not in พรหมชาติ |
| เดือน 8 สองหน handling | **Low** | Single mention; no worked example |
| Mahabhuta position from 4-base | **Low** | Requires กาลโยค layer |
| หลวงวิจิตรวาทการ as formula author | **Low** | No primary text found; historical figure |
| Current KnowMe engine correctness | **High (that it is wrong)** | Contradicts all authoritative sources |

---

## 8. Required Engine Changes

> **Note:** Listed for post-validation implementation. **No changes made in this sprint.**

| # | Change | Priority | Blocker for Mirror? |
|---|--------|----------|---------------------|
| E1 | Replace scalar mod-merge with 4-row table builder | **P0** | Yes |
| E2 | Add Thai lunar calendar conversion (100/150yr) | **P0** | Yes |
| E3 | Implement 06:00 day boundary | **P0** | Yes |
| E4 | Implement ขึ้น 1 ค่ำ month boundary | **P0** | Yes |
| E5 | Implement ขึ้น 1 ค่ำ เดือน 5 year boundary | **P0** | Yes |
| E6 | Add Row 4 vertical sum + metadata | **P1** | Partial |
| E7 | Replace Gregorian month/year proxy | **P0** | Yes |
| E8 | Add golden case regression tests GC-01..05 | **P1** | Yes |
| E9 | Define myanmarKeys = Row 1 mapping policy | **P1** | Yes |
| E10 | Row 4 lookup table (3–21 meanings) | **P2** | No (V1.1) |
| E11 | Mahabhuta กาลโยค layer | **P2** | No (V1.1) |
| E12 | Expert validation session sign-off | **P0** | Yes |

### 8.1 Current vs Correct (Summary)

```
CURRENT (Wrong):
  dayRotation[7] + scalar monthBase + scalar yearBase → mod 7

CORRECT (Authoritative):
  row1[7] ← weekday
  row2[7] ← lunar month
  row3[7] ← zodiac year
  row4[i] ← row1[i] + row2[i] + row3[i]
```

---

## 9. Risk Assessment

| Risk | Severity | Likelihood | Mitigation |
|------|----------|------------|------------|
| Ship current mod-merge to Mirror | **Critical** | High if unchanged | Block Mirror until E1–E7 |
| Lunar calendar conversion errors | **High** | Medium | Lock GC-01..05; use established calendar lib |
| เดือน 8 สองหน edge cases | **Medium** | Low | Expert rule + document assumption |
| Mahabhuta layer birth-invariant in engine | **Medium** | Current state | Defer Mahabhuta activation to กาลโยค |
| หลวงวิจิตรวาทการ attribution drift | **Low** | Medium | Revise docs per Section 6.3 |
| Multiple school variants (5ฐาน, 9ฐาน) | **Medium** | Medium | Freeze 4ฐาน only for V1 |
| Row 4 semantics without lookup table | **Medium** | High | Row 1 keys for theme; Row 4 for confidence later |

---

## Definition of Done (This Sprint)

| Criterion | Status |
|-----------|--------|
| OQ-1 answered with source + formula + example | ✅ |
| OQ-2 answered with mapping table | ✅ |
| OQ-5 has 5 golden cases | ✅ |
| OQ-6 answered with boundary rule | ✅ |
| Confidence levels assigned | ✅ |
| Recommended freeze standard | ✅ |
| Required engine changes documented | ✅ |
| No code / engine / UI changes | ✅ |

---

## Appendix A — Position Column Order (Frozen)

### Row 1 (Day) — Myanmar life positions

`อัตตะ | หินะ | ธะนัง | ปิตา | มาตา | โภคา | มัชฌิมา`

### Row 2 (Month)

`ตนุ | กฎุมภะ | สหัสชะ | พันธุ | ปุตตะ | อริ | ปัตนิ`

### Row 3 (Year)

`มรณะ | ศุภะ | กัมมะ | ลาภะ | พยายะ | ทาสา | ทาสี`

---

## Appendix B — References

1. พรหมชาติ — หลักการพยากรณ์แบบเลข 7 ตัว: http://horoscope.dooasia.com/phommachat/phommachath014c001.shtml  
2. พระตำรับเลขเจ็ดตัว (manuscript): https://manuscripts.sac.or.th/article-download.php?id=28  
3. หมอชิต บางบำหรุ — เลข 7 ตัว + ทักษา + กาลโยค: https://www.horawej.com/_m/article/content/content.php?aid=538960899  
4. หมอชิต บางบำหรุ — worked example 2492: https://www.horawej.com/index.php?ac=article&Id=538981149  
5. ซินแสหวาง — เลข 7 ตัว 4 ฐาน พื้นฐาน 1: https://sinsaehwang.com/เลข-7-ตัว-4-ฐาน-พื้นฐาน-1/  
6. วิชาเลข 7 ตัวทักษากาลโยค ฉบับประยุกต์ (มหาภูติพม่า): https://www.horawej.com/index.php?Id=539711610&ac=article&lay=show  
7. อ.สำราญ สมุทรวานิช — เลข 7 ตัวแบบพิศดาร (เกษมบรรณกิจ)  
8. Burmese Mahabote (cross-ref only): https://dirah.org/mahabote.htm  

---

*End of Thai Astrology Domain Validation V1*
