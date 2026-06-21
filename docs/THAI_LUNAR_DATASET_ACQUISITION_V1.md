# Thai Lunar Dataset Acquisition & Integration Plan V1

**Date:** June 2026  
**Type:** Research + Architecture Plan (No Dataset Population)  
**Prerequisite:** `THAI_LUNAR_CALENDAR_INFRASTRUCTURE_V1.md`  
**Domain Reference:** `THAI_ASTROLOGY_DOMAIN_VALIDATION_V1.md`

---

## Executive Summary

KnowMe ต้องการ **ปฏิทินจันทรคติแบบโหราศาสตร์ไทย (พรหมชาติ / หมอชิต)** — ไม่ใช่ปฏิทินหลวงสำหรับสูติบัตร และไม่ใช่ปฏิทินจีน/จุลศักราชทั่วไป

**แนวทางที่แนะนำ:** **Hybrid (D)** — ซื้อ/ขออนุญาตจาก **เขษมบรรณกิจ (ปฏิทิน 150 ปี)** เป็น primary source → Import Tool (offline) → Validator → Embedded JSON asset → `AssetThaiLunarRepository`

**ห้าม:** scrape myhora/horawej, copy หนังสือลง repo, ใช้ open-source algorithm เป็น primary โดยไม่ validate กับ domain golden cases

---

## 1. Candidate Sources

### Tier A — Domain-Aligned (พรหมชาติ / เลข 7 ตัว)

| ID | Source | Owner | Format | Coverage | Reliability (Domain) | Notes |
|----|--------|-------|--------|----------|---------------------|-------|
| **SRC-A1** | **ปฏิทิน 150 ปี — เขษมบรรณกิจ** | ร้าน/สำนักพิมพ์เขษมบรรณกิจ | หนังสือพิมพ์, อาจมีรูปแบบดิจิทัลภายในองค์กร | ~150 ปี (ตามชื่อ) | **สูง** — horawej อ้างอิงโดยตรงสำหรับฐานเดือน | แหล่งที่ practitioners ใช้จริง |
| **SRC-A2** | **ปฏิทิน 100 ปี — myhora.com** | myhora.com (เจ้าของเว็บไม่ระบุชัดในแหล่งสาธารณะ) | Web UI lookup | พ.ศ. 2300–2700 (≈ ค.ศ. 1957–2157) | **สูง** — sinsaehwang อ้างอิง; อธิบายคติพราหมณ์ ขึ้น 1 ค่ำ เดือน 5 | ฟรีออนไลน์ แต่ไม่มี bulk export สาธารณะ |
| **SRC-A3** | **หนังสือ อ.สำราญ สมุทรวานิช — เลข 7 ตัวแบบพิศดาร** | เขษมบรรณกิจ (จัดพิมพ์) | หนังสือ | ตามตำรา | **สูง** — Validation V1 เรียก "แม่บท" | ใช้ validate + golden cases ไม่ใช่ bulk dataset |
| **SRC-A4** | **horawej.com — บทความตัวอย่าง** | วิชิต เตชะเกษม / horawej | HTML articles | เฉพาะ worked examples | **สูง** สำหรับจุดที่ publish | GC-04 อยู่ที่นี่; ไม่ใช่ปฏิทินเต็ม |
| **SRC-A5** | **sinsaehwang.com — บทเรียน** | sinsaehwang | Web articles | เฉพาะตัวอย่าง | **กลาง–สูง** | GC-05; simplified pedagogy |
| **SRC-A6** | **โปรแกรมโหราเวส / โปรแกรมโหราศาสตร์เชิงพาณิชย์** | horawej, ผู้พัฒนาอื่น (พลโชติ, สมุดจดดวง ฯลฯ) | Desktop/mobile app | ตามโปรแกรม | **กลาง** — ขึ้นกับตำราที่ฝัง | ต้องขอ license export; ไม่ reverse-engineer |

### Tier B — Government / Open Data (ไม่ตรง domain โดยตรง)

| ID | Source | Owner | Format | Coverage | Reliability (Domain) | Notes |
|----|--------|-------|--------|----------|---------------------|-------|
| **SRC-B1** | **data.go.th** | สพร./DGA | CKAN API, CSV | หลากหลายชุด | **ต่ำ** สำหรับเลข 7 ตัว | ไม่มีชุด "ปฏิทินโหราศาสตร์ 100 ปี" โดยตรง |
| **SRC-B2** | **ประกาศวันพระ / ราชกิจจานุเบกษา** | รัฐบาล / ราชบัณฑิตยสภา | ประกาศรายปี | วันพระ, วันหยุด | **ต่ำ–กลาง** | ใช้ cross-check วันขึ้น/แรม 15 ได้บางส่วน ไม่มี zodiac year แบบโหราศาสตร์ |
| **SRC-B3** | **ปฏิทินวัฒนธรรม กระทรวงวัฒนธรรม** | กระทรวงวัฒนธรรม | Event API | กิจกรรมวัฒนธรรม | **ต่ำ** | ไม่มี lunar month แบบพรหมชาติ |
| **SRC-B4** | **สูติบัตร — ปฏิทินหลวง (เดือนอ้าย=1)** | กรมการปกครอง | แนวปฏิบัติราชการ | ทุกคนเกิดในไทย | **ไม่ตรง domain** | เปลี่ยนปีนักษัตร ขึ้น 1 ค่ำ **เดือนอ้าย** — ต่างจาก OQ-6 (เดือน 5) |

### Tier C — Open Source / Algorithmic

| ID | Source | Owner | Format | Coverage | Reliability (Domain) | Notes |
|----|--------|-------|--------|----------|---------------------|-------|
| **SRC-C1** | **pythaidate** (MIT) | Mark Hollow / hmmbug | Python lib | Chulasakarat + Pakkhakhananaa | **ต่ำ–กลาง** | ระบบเดือน/epoch ต่างจากพรหมชาติ; ต้อง validate ทุก field ก่อนใช้ |
| **SRC-C2** | **uposatha** | jhanarato | Python lib | Buddhist seasons/holidays | **ต่ำ** | Forest Sangha calendar — คนละมาตรฐานกับเลข 7 ตัว |
| **SRC-C3** | **Patidina (tptk.org)** | มูลนิธิมหามกุฏฯ + pythaidate | Web | ปฏิทินสุริยคติ/จันทรคติ/ปักขคณนา | **กลาง** สำหรับจันทรคติทั่วไป | ยังไม่ยืนยัน alignment กับ ฐานเดือน OQ-2 |
| **SRC-C4** | **splendidmoons / Forest Sangha iCal** | Community | iCal | Uposatha | **ต่ำ** | License ไม่ชัดในบาง repo |

### Tier D — Commercial API

| ID | Source | Owner | Format | Coverage | Reliability (Domain) | Notes |
|----|--------|-------|--------|----------|---------------------|-------|
| **SRC-D1** | **astrom8.com** | astrom8 | REST API `/api/v3/thai/calendar/day` | วันต่อวัน | **ไม่ทราบ** — ต้อง audit | มี dithi/lunar_day แต่ไม่ชัดว่า map กับ OQ-2/OQ-6 หรือไม่ |
| **SRC-D2** | **AstrologyAPI / อื่นๆ** | หลายเจ้า | REST | แตกต่างกัน | **ต่ำ–ไม่ทราบ** | มักผสม Western/Vedic |

---

## 2. Licensing Assessment

### GREEN — ใช้ได้ชัดเจน (ในขอบเขตที่ระบุ)

| Source | Allowed Use | Condition |
|--------|-------------|-----------|
| **Published golden cases** (GC-01..05) | เก็บค่าที่ publish แล้วใน test/verified entries | อ้างอิง URL/ตำรา; ไม่ copy เนื้อหาทั้งบทความ |
| **KnowMe-owned transcriptions** | ใส่ dataset ได้ | ทีมซื้อหนังสือ + ลงมือด้วย audit trail + domain review |
| **Licensed export จากเขษมบรรณกิจ** | Bulk dataset ใน asset | ต้องมีหนังสืออนุญาตเป็นลายลักษณ์อักษร |
| **pythaidate** (MIT) | ใช้เป็น helper ใน import tool | **ไม่** เป็น primary SoT จนกว่า validate ครบ golden set |

### YELLOW — ต้องขออนุญาต / ต้อง audit ก่อน

| Source | Risk | Action Required |
|--------|------|-----------------|
| **เขษมบรรณกิจ ปฏิทิน 150 ปี** (หนังสือ) | © สำนักพิมพ์ — digitize ต้องได้รับอนุญาต | ติดต่อร้าน 02-439-2339; ขอ digital license หรือ data partnership |
| **myhora.com** | ToS อาจห้าม scrape / bulk download | ติดต่อเจ้าของเว็บขอ API หรือ licensed export |
| **horawej / โปรแกรมโหราเวส** | Software EULA | ขอ export license; ไม่ decompile |
| **astrom8 API** | API ToS + caching restrictions | อ่าน ToS; อาจห้าม embed ลง asset |
| **pythaidate เป็น generated source** | MIT อนุญาต code แต่ **accuracy ไม่รับประกัน** | ใช้เฉพาะหลัง validate ≥50 golden dates |
| **Manual OCR จากหนังสือที่ซื้อ** | © ยังคงอยู่ — fair use ไม่ครอบคลุม full DB | ต้องได้รับอนุญาตจากสำนักพิมพ์ แม้ซื้อหนังสือแล้ว |

### RED — ไม่ควรใช้

| Source | Reason |
|--------|--------|
| **Scrape myhora / horawej / sinsaehwang** | ละเมิด ToS + ©; ไม่มี provenance |
| **Copy ปฏิทิน 100/150 ปี ลง git โดยไม่มี license** | ลิขสิทธิ์ชัดเจน |
| **ปฏิทินหลวง (สูติบัตร) เป็น primary** | Domain mismatch — ปีนักษัตร/เดือนไม่ตรง OQ-6/OQ-2 |
| **ปฏิทินจีน / ตรุษจีน year boundary** | Validation V1 ปิดแล้ว — ไม่ใช้ |
| **Fabricated / interpolated lunar data** | ทำลาย domain accuracy |
| **Reverse-engineer โปรแกรมโหราศาสตร์** | ผิดกฎหมาย + EULA |

---

## 3. Recommended Source

### Primary: **SRC-A1 — เขษมบรรณกิจ ปฏิทิน 150 ปี**

**เหตุผล:**

1. horawej (หมอชิต) อ้างอิงโดยตรง — ตรงกับ Foundation Engine V1.1 domain
2. อ.สำราญ สมุทรวานิช (เกษมบรรณกิจ) เป็น "แม่บท" ใน Validation V1
3. หนังสือพิมพ์ = provenance ชัด — audit ได้
4. ช่วง 150 ปี ครอบคลุม target 1900–2100 พร้อม margin

### Secondary (Validation / Cross-check): **SRC-A2 — myhora.com**

- ใช้ **manual spot-check** และขยาย golden cases
- **ไม่** scrape — เปรียบเทียบทีละวันที่ domain expert ยืนยัน

### Tertiary (Golden Case Mining): **SRC-A4, SRC-A5**

- horawej/sinsaehwang worked examples → `ThaiLunarGoldenCases` (ไม่ใช่ bulk)

### Explicitly Rejected as Primary

- Government birth-certificate calendar (SRC-B4)
- pythaidate / algorithm-only (SRC-C1) จนกว่า domain sign-off
- Commercial API with unknown field mapping (SRC-D1)

---

## 4. Dataset Schema Design

**File:** `assets/thai_astrology/lunar/thai_lunar_1900_2100.json`  
**Schema file:** `lib/features/astrology/thai/foundation/lunar/datasets/thai_lunar_dataset_schema_v1.json`

### Design Principles

1. **One record per civil day** (local Thailand) — ปฏิทิน 100/150 ปี มาตรฐานเป็นรายวัน
2. **06:00 day boundary** applied at **lookup time** in provider (not duplicated per row)
3. **Minute-level keys** สำหรับ golden cases แยกใน `thai_lunar_verified_entries.dart`
4. **Compact field names** ใน production asset เพื่อลดขนาด

### Manifest (top-level)

```json
{
  "schemaVersion": 1,
  "datasetVersion": "2026.06.0",
  "infrastructureVersion": "v1.2",
  "primarySource": {
    "id": "kasem-bannakij-150",
    "name": "ปฏิทิน 150 ปี เขษมบรรณกิจ",
    "edition": "TBD",
    "licenseRef": "docs/legal/kasem-bannakij-license.pdf"
  },
  "domainStandard": "phrommachat-seven-number-v1.1",
  "coverage": {
    "start": "1900-01-01",
    "end": "2100-12-31",
    "timezone": "Asia/Bangkok"
  },
  "fieldDefinitions": {
    "wd": "weekdayNumber อาทิตย์=1..เสาร์=7",
    "lm": "lunarMonthNumber ธันวา=1..ฤษณี=12",
    "zy": "zodiacYearIndex ชวด=1..กุน=12 (ขึ้น 1 ค่ำ เดือน 5)",
    "d15": "waxingDay 1-15",
    "ph": "phase: w=waning(แรม), x=waxing(ขึ้น)",
    "i8": "intercalaryMonth8 (เดือน 8 สองหน)"
  },
  "recordCount": 73414,
  "checksumSha256": "TBD_AFTER_POPULATE"
}
```

### Day Record (per `YYYY-MM-DD`)

```json
{
  "1900-01-01": {
    "wd": 1,
    "lm": 12,
    "zy": 4,
    "d15": 10,
    "ph": "w",
    "i8": false
  }
}
```

### Full Field Mapping → `ThaiLunarRecord`

| Schema | Model Field | Required | Notes |
|--------|-------------|----------|-------|
| `wd` | `weekdayNumber` | ✅ | จากปฏิทิน ไม่ใช่ `DateTime.weekday` |
| `lm` | `lunarMonthNumber` | ✅ | พรหมชาติ numbering |
| `zy` | `zodiacYearIndex` | ✅ | หลัง ขึ้น 1 ค่ำ เดือน 5 |
| `d15` | `waxingDay` | ✅ | 1–15 |
| `ph` | `phase` | ✅ | `waxing` / `waning` |
| `i8` | `intercalaryMonth8` | ✅ | OQ-LUNAR-8 |
| manifest `primarySource` | `sourceId`, `sourceReference` | ✅ | Provenance |
| — | `provenance` | ✅ | `embeddedDataset` |

### Size Estimate (1900–2100)

| Format | Raw | Gzip (est.) |
|--------|-----|-------------|
| 73,414 days × ~40 bytes JSON | ~3 MB | ~0.8–1.5 MB |
| Binary/msgpack (future) | ~1.5 MB | ~0.5 MB |

### Schema Versioning Rules

- `schemaVersion` breaking change → new importer + migration
- `datasetVersion` bump on re-export from source
- Golden cases must pass on every `datasetVersion` bump

---

## 5. Asset Repository Design (Not Implemented)

### Interface

```dart
/// Planned: lib/features/astrology/thai/foundation/lunar/repository/asset_thai_lunar_repository.dart

class AssetThaiLunarRepository implements ThaiLunarRepository {
  AssetThaiLunarRepository({
    required AssetBundle bundle,
    String assetPath = ThaiLunarEmbeddedDataset.assetPath,
  });

  /// Lazy-load: parse manifest on first access, mmap or index days map.
  Future<void> ensureLoaded();

  @override
  ThaiLunarDatasetManifest get manifest;

  @override
  ThaiLunarRecord? lookup(ThaiLunarLookupKey key);

  @override
  Iterable<ThaiLunarRecord> get allEntries; // audit only — do not use in prod hot path
}
```

### Lookup Algorithm

```
Input: ThaiLunarLookupKey (yyyy-MM-dd HH:mm)
  1. Apply ThaiDayBoundary if policy OQ-LUNAR-0600 resolved
  2. Extract civil date YYYY-MM-DD
  3. Index into day map (O(1))
  4. Map compact record → ThaiLunarRecord
  5. If date missing → null (caller emits LUNAR_DATE_UNVERIFIED)
```

### Repository Selection (Provider wiring)

```dart
ThaiLunarRepository createProductionRepository() {
  if (kUseAssetDataset) {
    return AssetThaiLunarRepository(bundle: rootBundle);
  }
  return InMemoryThaiLunarRepository(); // dev / golden-only fallback
}
```

### Performance Targets

| Metric | Target |
|--------|--------|
| Cold load (gzip JSON parse) | < 500ms mobile |
| Lookup | < 1ms |
| Memory | < 5 MB resident |

### Fallback Policy

- Asset missing or corrupt → `InMemoryThaiLunarRepository` (golden only) + `LUNAR_DATASET_LOAD_FAILED` warning
- **Never** fallback to guessed data

---

## 6. Import Pipeline Design

```
┌─────────────────────────────────────────────────────────────────┐
│  RAW SOURCE (licensed only)                                     │
│  • เขษมบรรณกิจ export / approved transcription                   │
│  • NOT: scraped web, NOT: unlicensed OCR                        │
└───────────────────────────┬─────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  EXTRACTOR (offline tool — NOT in Flutter app)                  │
│  tools/thai_lunar_import/                                       │
│  • parse_csv.py / parse_xlsx.py / manual_entry.yaml             │
└───────────────────────────┬─────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  NORMALIZER                                                     │
│  • Map source columns → schema v1 fields                        │
│  • Enforce: wd 1-7, lm 1-12, zy 1-12, d15 1-15, ph enum        │
│  • Reject rows with missing required fields                     │
└───────────────────────────┬─────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  VALIDATOR                                                      │
│  • ThaiLunarValidator golden cases (GC-04, GC-05, …)            │
│  • Cross-check sample against myhora (manual log)               │
│  • Intercalary month 8 spot cases                               │
│  • FAIL build if any golden case fails                          │
└───────────────────────────┬─────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  ASSET BUILDER                                                  │
│  • Write thai_lunar_1900_2100.json                              │
│  • Compute checksumSha256                                       │
│  • Strip from git if license prohibits commit → CI secret asset │
└───────────────────────────┬─────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  AssetThaiLunarRepository (Flutter runtime)                     │
└─────────────────────────────────────────────────────────────────┘
```

### Tool Location (planned, not created in V1)

```
tools/thai_lunar_import/
├── README.md
├── normalize.py
├── validate.py
├── build_asset.py
├── golden_cases.yaml      # references only — no bulk copyrighted data
└── sample_config.yaml
```

### CI Gate

```bash
python tools/thai_lunar_import/validate.py \
  --asset assets/thai_astrology/lunar/thai_lunar_1900_2100.json \
  --golden lib/.../thai_lunar_golden_cases.dart
# exit 1 if any golden case fails
```

### Git Policy for Licensed Asset

| License allows | Action |
|----------------|--------|
| Redistribute in app | Commit asset to repo (or LFS) |
| App-only, no redistribute | CI secret + build-time inject; `.gitignore` asset |
| No digital | Manual entry pipeline only — not scalable |

---

## 7. Validation Expansion Plan

### Current State: 2 Gregorian Golden Cases

| ID | Type | Has Gregorian? |
|----|------|----------------|
| GC-04 | Lunar lookup | ✅ |
| GC-05 | Lunar lookup | ✅ |
| GC-01..03 | Chart input only | ❌ (explicit lunar input) |

### Expansion Roadmap

| Phase | Target Count | Source Strategy | Storage |
|-------|--------------|-----------------|---------|
| **V1.2a** | 10+ | horawej worked examples with published birth datetime | `thai_lunar_golden_cases.dart` |
| **V1.2b** | 20+ | + sinsaehwang, + อ.สำราญ examples | golden_cases + verified_entries |
| **V1.2c** | 50+ | Domain expert manual verification vs เกษมบรรณกิจ book | `golden_cases.dart` + audit log YAML |
| **V1.3** | 100+ | Stratified sample: 10/year × 10 years + intercalary + month boundaries + ก่อน/หลัง 06:00 | `test/fixtures/lunar_references.yaml` (references only) |

### Reference Case File Format (no copyrighted bulk data)

```yaml
# test/fixtures/lunar_references.yaml
# Each entry: citation + expected fields — NOT auto-scraped

- id: GC-04
  source: https://www.horawej.com/index.php?ac=article&Id=538981149
  lookup: "1949-09-11 00:15"
  wd: 7
  lm: 10
  zy: 2
  verifiedBy: domain-validation-v1
  verifiedAt: 2026-06-01

- id: GC-06-TBD
  source: horawej article TBD
  lookup: TBD
  # populate only after manual verification
```

### Categories to Cover in 100+ Plan

| Category | Count | Why |
|----------|-------|-----|
| Ordinary days | 40 | Baseline |
| ขึ้น 1 ค่ำ month boundary | 15 | Row 2 accuracy |
| ขึ้น 1 ค่ำ เดือน 5 year boundary | 15 | Row 3 / OQ-6 |
| เดือน 8 สองหน | 10 | OQ-LUNAR-8 |
| Before/after 06:00 same civil date | 10 | OQ-LUNAR-0600 |
| Historical edge (pre-1957) | 10 | Coverage margin |

### Validation Layers (unchanged + expanded)

1. **Unit:** `ThaiLunarValidator` per case
2. **Integration:** `SevenNumberChart.calculate(birth)` end-to-end
3. **Import CI:** asset vs golden before release
4. **Manual audit log:** expert sign-off spreadsheet (external to repo)

---

## 8. Open Questions

| ID | Question | Blocks | Owner |
|----|----------|--------|-------|
| OQ-ACQ-01 | เขษมบรรณกิจยินดีให้ digital license หรือไม่? ราคา/เงื่อนไข? | Primary source | Business + Legal |
| OQ-ACQ-02 | myhora เปิด API/partnership หรือไม่? | Secondary validation | Business |
| OQ-ACQ-03 | Licensed asset ลง git ได้หรือต้อง CI secret? | Git policy | Legal |
| OQ-ACQ-04 | Edition ไหนของ ปฏิทิน 150 ปี เป็น canonical? | Dataset version | Domain expert |
| OQ-ACQ-05 | OCR/transcription workflow ใครรับผิดชอบ + audit? | Data quality | Ops + Domain |
| OQ-ACQ-06 | pythaidate ใช้เป็น cross-check ได้หรือไม่? | Optional tool | Domain + Engineering |
| OQ-LUNAR-8 | เดือน 8 สองหน — flag `i8` เพียงพอหรือต้องมี `lm=8` + metadata? | Schema | Domain expert |
| OQ-LUNAR-0600 | Lookup ใช้ civil date หรือ adjust ก่อน index? | Provider logic | Domain expert |

---

## 9. Blast Radius

| Area | Impact | Mitigation |
|------|--------|------------|
| `pubspec.yaml` | เพิ่ม asset path | เฉพาะเมื่อมี licensed file |
| `InMemoryThaiLunarRepository` | คงเป็น dev fallback | Feature flag |
| `ThaiLunarCalendarProvider` | inject repository | Already abstracted |
| Foundation Engine | **ไม่เปลี่ยน** จนกว่า dataset populate | Golden tests gate |
| Theme/Content/Resolver | **ไม่กระทบ** | — |
| Legal | สูงหากใช้ RED source | License-first workflow |
| App size | +1–2 MB | Acceptable |
| CI | +import validation step | Offline tool |

---

## 10. Recommendation

### Integration Strategy: **D — Hybrid**

| Component | Choice |
|-----------|--------|
| **Acquisition** | License from **เขษมบรรณกิจ ปฏิทิน 150 ปี** |
| **Storage** | **A — Embed Asset** (`thai_lunar_1900_2100.json` gzip) |
| **Ingestion** | **B — Import Tool** (offline Python, not in app) |
| **Runtime** | `AssetThaiLunarRepository` with `InMemory` fallback |
| **Validation** | Expand golden cases from horawej/sinsaehwang; myhora manual spot-check |
| **NOT** | External API primary, web scrape, algorithm-only, fake data |

### Action Sequence

```
1. Legal/Domain → ติดต่อเขษมบรรณกิจ ขอ digital license
2. Domain → เลือก edition + ยืนยัน OQ-LUNAR-8, OQ-LUNAR-0600
3. Engineering → สร้าง tools/thai_lunar_import/ (normalize, validate, build)
4. Data → Transcribe/export 1900-2100 ภายใต้ license
5. CI → validate golden cases → build asset
6. Engineering → implement AssetThaiLunarRepository (V1.2)
7. Release → bump infrastructureVersion v1.2, datasetVersion x.y.z
```

### Definition of Done (this plan)

- [x] Candidate sources surveyed
- [x] Licensing GREEN/YELLOW/RED assigned
- [x] One recommended source (เขษมบรรณกิจ)
- [x] Schema designed
- [x] AssetThaiLunarRepository designed (not implemented)
- [x] Import pipeline designed
- [x] Validation expansion plan (2 → 100+)
- [x] No fake data in repo
- [ ] License obtained (**next human action**)
- [ ] Asset populated (**blocked on license**)

---

## Appendix A — Source Contact Log (Template)

| Date | Party | Channel | Outcome |
|------|-------|---------|---------|
| TBD | เขษมบรรณกิจ | 02-439-2339 / หน้าร้าน | Pending |
| TBD | myhora.com | Contact form | Pending |

---

## Appendix B — Related Files

| File | Role |
|------|------|
| `docs/THAI_LUNAR_CALENDAR_INFRASTRUCTURE_V1.md` | Infrastructure V1 |
| `docs/THAI_ASTROLOGY_DOMAIN_VALIDATION_V1.md` | Domain standards |
| `lib/.../lunar/datasets/thai_lunar_dataset_schema_v1.json` | Schema spec (no data) |
| `lib/.../lunar/datasets/thai_lunar_verified_entries.dart` | GC-04, GC-05 only |
