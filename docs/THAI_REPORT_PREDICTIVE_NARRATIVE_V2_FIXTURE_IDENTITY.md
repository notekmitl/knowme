# Thai Report Predictive Narrative V2 — Fixture Identity

ตรวจจาก `origin/main` และ local base `d857308eb8635899e468dab5e22a3a53f87fced1` ด้วย pipeline จริงของ repository วันที่ 30 สิงหาคม 2569 โดยไม่มี source หรือ test delta

## คำสั่งยืนยัน

`flutter test test/validation/thai_beta/narrative/thai_beta_input_fixture_separation_test.dart --reporter expanded`

ผล: **4/4 PASS**

## Fixture A — Golden Owner Style

- Input: `1982-06-06`, `00:03`, Chiang Mai, male
- Pinned asOf: `2026-08-29 Asia/Bangkok`
- Normalized birth time: `00:03`
- Thai-day boundary: วันเสาร์
- Lagna key: `lagna_aquarius`
- Sidereal ascendant: `309.396069063126°`
- Display within sign: Aquarius `9°24′`
- Candidate: `docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0003.md`

## Fixture B — Canonical regression

- Input: `1982-06-06`, `00:35`, Chiang Mai
- Normalized birth time: `00:35`
- Thai-day boundary: วันเสาร์
- Expected and verified display: Aquarius `19°19′`
- Fixture A and Fixture B remain separate; no Candidate Full Report was written for Fixture B

## Fixture C — Unknown time

- Input: `1982-06-06`, Chiang Mai, birth time unknown
- Normalized birth time: empty
- Sidereal ascendant: null
- No noon substitution: export does not contain `12:00`
- No asserted Thai astrological day
- No ascendant, houses, or time-dependent positions
- Forecast material ownership is `life-period-score-without-lagna`
- Every material fingerprint reports `e=noLagna` and `td=false`
- Short candidate outline is included at the end of the Candidate document

## Horizon and monthly boundary

- Known 00:03 has 12 material fingerprints: 3 horizons × 4 domains
- Horizons: `current`, `next12Months`, `nextLifePeriod`
- Rolling date label: `29 ส.ค. 2569 – 28 ส.ค. 2570`
- `monthlyTimelineAvailable=false`
- Engine gap reason: engine มีกรอบ 12 เดือนและทักษาจรรายปี แต่ไม่มีคะแนนหรือหลักฐานที่ผูกกับเดือนปฏิทินทั้ง 12 เดือน
- Therefore the Golden early, middle, and late 12-month buckets are style examples only

## Traceable sources

- `test/validation/thai_beta/narrative/thai_beta_input_fixture_separation_test.dart`
- `lib/features/thai_beta/application/thai_beta_analysis.dart`
- `lib/features/birth_normalization/application/birth_normalizer.dart`
- `lib/features/birth_normalization/application/adapters/thai_engine_adapter.dart`
- `lib/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart`
- `lib/features/astrology/thai/mirror/presentation/prediction/prediction_composer.dart`
- `lib/features/astrology/thai/mirror/presentation/prediction/prediction_section_model.dart`
- `lib/features/thai_beta/application/thai_beta_report_export_document.dart`
