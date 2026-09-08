# Actual 00:35 — semantic slot coverage

```json
{
  "required": 15,
  "applicable": 15,
  "emitted": 13,
  "supported": 2,
  "predictionSupported": 0,
  "nonPredictiveProvenanceSupported": 2,
  "missing": 2,
  "duplicate": 0
}
```

Required/applicable = 15 slots, not 22 paragraphs. Two non-predictive provenance-supported slots are advice/disclosure, not supported predictions. Past 0–10 and 11–29 are absent; actual 30–41 is emitted. First period 0–10 is the raw engine range, not a change to Candidate0011’s accepted 1–10 reader label.

| Slot | Required | Applicable | Emitted | Supported | Missing | Duplicate |
|---|---|---|---:|---|---|---:|
| ภาพรวมชีวิต | true | true | 1 | false | false | 0 |
| อดีต 0–10 | true | true | 0 | false | true | 0 |
| อดีต 11–29 | true | true | 0 | false | true | 0 |
| อดีต 30–41 | true | true | 1 | false | false | 0 |
| ปัจจุบัน | true | true | 1 | false | false | 0 |
| การงาน | true | true | 1 | false | false | 0 |
| การเงิน | true | true | 1 | false | false | 0 |
| ความสัมพันธ์ | true | true | 1 | false | false | 0 |
| สุขภาพ | true | true | 1 | false | false | 0 |
| โชคลาภ/แรงสนับสนุน | true | true | 1 | false | false | 0 |
| 12 เดือนข้างหน้า | true | true | 1 | false | false | 0 |
| ช่วงชีวิตถัดไป | true | true | 1 | false | false | 0 |
| สรุป | true | true | 1 | false | false | 0 |
| คำแนะนำ | true | true | 1 | true | false | 0 |
| ข้อจำกัด | true | true | 1 | true | false | 0 |

Summary inherits parent authority; it cannot rescue unresolved predictions. No missing slot was filled or runtime output changed.
