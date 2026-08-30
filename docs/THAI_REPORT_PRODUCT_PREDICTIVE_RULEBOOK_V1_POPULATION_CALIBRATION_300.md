# Thai Report Product Predictive Rulebook V1 — Population Calibration 300 Profiles

สถานะ: **SELECTIVITY MEASURED — SEMANTIC VALIDITY NOT ESTABLISHED — PREDICTIVE ACCURACY NOT MEASURABLE**

## Population and method

- Source: repository `ThaiBetaSyntheticMatrix.build()`, deterministic seed `20260803`
- `asOf=2026-08-03`, profiles evaluated 300/300
- Known 225; Unknown 75
- relationship-status design assignment: single/partnered/married/complicated/not_disclosed อย่างละ 60 รวม และอย่างละ 45 ใน Known
- start planets: Sun 51, Moon 43, Mars 39, Mercury 21, Jupiter 42, Venus 43, Saturn 47, Rahu 14
- stages: opening 94, peak 101, closing 105
- harmony ครอบคลุม negative, neutral และ positive
- rolling birthday segmentation correct 300/300

Relationship status เป็น design-only assignment เพื่อประเมิน branch ไม่ได้เขียนเข้า runtime หรือ fixture เดิม

## Rule-level results

`Score distribution` คือ primary metric ที่ V1 ใช้ตัดสิน rule (past harmony/bond, event strength/opportunity/risk หรือ exact boundary) ไม่ใช่ความแม่น ตาราง `Current/A/B` นับ profile ที่ยิงใน current, next12 Segment A และ Segment B; profile เดียวอาจอยู่หลายคอลัมน์

| Rule | Eligible | Fired / rate | Omit | Primary distribution min/p25/p50/p75/max | Threshold percentile | Current / A / B |
|---|---:|---:|---:|---|---:|---:|
| PAST-FAMILY | 225 | 13 / 5.8% | 94.2% | -1 / 2 / 3 / 6 / 6 | 12.7% | 0 / 0 / 0 |
| PAST-EDUCATION-SOCIAL | 225 | 22 / 9.8% | 90.2% | 0 / 1 / 1 / 1 / 3 | 83.1% | 0 / 0 / 0 |
| PAST-DOMAIN-TRANSITION | 225 | 6 / 2.7% | 97.3% | -2 / -1 / -1 / -1 / 3 | 90.9% | 0 / 0 / 0 |
| CAREER-ROLE | 225 | 85 / 37.8% | 62.2% | 46 / 68 / 79 / 87 / 100 | 26.4% | 63 / 63 / 49 |
| CAREER-OPPORTUNITY | 225 | 59 / 26.2% | 73.8% | 0 / 0 / 74 / 78 / 84 | 44.7% | 39 / 38 / 37 |
| CAREER-ENDING | 225 | 6 / 2.7% | 97.3% | 34 / 38 / 40 / 68 / 80 | 66.2% | 5 / 4 / 5 |
| INCOME | 225 | 70 / 31.1% | 68.9% | 0 / 56 / 60 / 72 / 76 | 60.0% | 50 / 48 / 42 |
| EXPENSE | 225 | 11 / 4.9% | 95.1% | 34 / 38 / 40 / 68 / 80 | 66.2% | 7 / 5 / 9 |
| RELATIONSHIP-CLARITY | 225 | 60 / 26.7% | 73.3% | 0 / 0 / 0 / 78 / 90 | 63.8% | 31 / 31 / 41 |
| RELATIONSHIP-ENTRY | 45 | 11 / 24.4% | 75.6% | 0 / 0 / 0 / 78 / 90 | 61.1% | 5 / 5 / 8 |
| RELATIONSHIP-ENDING | 135 | 5 / 3.7% | 96.3% | 34 / 38 / 46 / 68 / 80 | 65.2% | 4 / 3 / 4 |
| HEALTH-LOAD | 225 | 11 / 4.9% | 95.1% | 34 / 38 / 40 / 68 / 80 | 66.2% | 7 / 5 / 9 |
| RECOVERY | 225 | 6 / 2.7% | 97.3% | 37 / 63 / 75 / 85 / 100 | 33.8% | 5 / 4 / 5 |
| LIFE-PERIOD-TRANSITION | 225 | 225 / 100% | 0% | 100 / 100 / 100 / 100 / 100 | 100% | exact fact, not horizon event |

The exact life-period boundary firing in 100% of eligible Known profiles is expected because it is a generated timeline fact. It must not be described as a selective external event prediction.

## Threshold sensitivity ±5

`Looser` shifts all numeric gates in the permissive direction by 5; `stricter` shifts them in the restrictive direction by 5. Past bond/harmony ranges are much smaller than 0–100, so the requested ±5 test intentionally exposes that those gates are not on a comparable calibrated scale.

| Rule | Base | Looser / changed | Stricter / changed | Example profiles changed |
|---|---:|---:|---:|---|
| PAST-FAMILY | 13 | 128 / 115 | 0 / 13 | loose S005,S006,S009; strict S038,S066,S078 |
| PAST-EDUCATION-SOCIAL | 22 | 38 / 16 | 0 / 22 | loose S025,S054,S064; strict S002,S037,S050 |
| PAST-DOMAIN-TRANSITION | 6 | 0 / 6 | 36 / 30 | loose S005,S048,S062; strict S001,S025,S033 |
| CAREER-ROLE | 85 | 101 / 16 | 17 / 68 | loose S008,S010,S050; strict S006,S009,S013 |
| CAREER-OPPORTUNITY | 59 | 92 / 33 | 13 / 46 | loose S004,S005,S008; strict S013,S020,S030 |
| CAREER-ENDING | 6 | 30 / 24 | 1 / 5 | loose S009,S013,S028; strict S008,S050,S069 |
| INCOME | 70 | 99 / 29 | 12 / 58 | loose S005,S008,S036; strict S001,S009,S013 |
| EXPENSE | 11 | 31 / 20 | 0 / 11 | loose S013,S030,S049; strict S008,S009,S028 |
| RELATIONSHIP-CLARITY | 60 | 67 / 7 | 15 / 45 | loose S165,S185,S194; strict S024,S033,S046 |
| RELATIONSHIP-ENTRY | 11 | 14 / 3 | 4 / 7 | loose S196,S226,S296; strict S046,S056,S066 |
| RELATIONSHIP-ENDING | 5 | 21 / 16 | 1 / 4 | loose S009,S013,S028; strict S008,S069,S077 |
| HEALTH-LOAD | 11 | 31 / 20 | 1 / 10 | loose S013,S030,S049; strict S008,S009,S028 |
| RECOVERY | 6 | 29 / 23 | 1 / 5 | loose S009,S013,S028; strict S008,S050,S069 |
| LIFE-PERIOD-TRANSITION | 225 | 225 / 0 | 225 / 0 | none |

Nearby primary-score percentiles were also recorded at p45/p50/p55. Large result changes despite small threshold movement show sensitivity, not an optimal cutoff. A percentile chosen to preserve any desired fire rate would still be a product choice without semantic or outcome authority

## Movement and conflict findings

- Output movement distribution equals the Current/A/B counts above for current/rolling rules and fired count for past rules
- V1 produced opposing positive/negative family candidates in 2 Known profiles before conflict resolution: S009 and S028
- The V1 conflict winner relies on an arbitrary atom confidence calculation, so distribution cannot validate the chosen meaning
- V1.1 removes all product-event rules; retained-rule unresolved contradictions therefore equal 0
- Unknown leakage is 0/75 because every V1/V1.1 predictive rule remains Known-only

## What this audit proves

- **Selectivity validation:** measured exactly as shown; no product event rule fires above 80%
- **Semantic validity:** not established. The population has no labeled real-world event meaning
- **Predictive accuracy:** not measurable because no historical outcome dataset exists

This calibration must not be described as robustness PASS or evidence that the predictions are accurate
