# Candidate 0025 — meaning-density audit

Status: **ENGINEERING VALIDATION ONLY — PENDING OWNER CONTENT JUDGMENT**

## Result

- Reader sentences / standalone factual lines: **52**
- Distinct meaning-unit identifiers: **55**
- Same-level reader-perceived duplicates: **0**
- Intentional summary sentences: **6**
- Intentional summary-to-detail relations: **6**
- Summary destination links: **11**
- Owner editorial interpretations pending: **5**
- Unsupported claims: **0**
- Blocked claims represented by deterministic controls: **6**

Sentence count is reported only as inventory. It is not used as proof of sufficient detail.

## Predictive-section accounting

| Section | Sentences | Distinct meaning units at this level | Same-level duplicates | Pending editorial interpretations | Note |
|---|---:|---:|---:|---:|---|
| ภาพรวมเส้นทางชีวิต | 6 | 12 | 0 | 0 | Six summaries connect chronology and preview named detail destinations. |
| อายุ 0–10 ปี | 2 | 2 | 0 | 0 | Guardian constraints and the child's dependence on family circumstances remain separate meanings. |
| อายุ 11–29 ปี | 2 | 3 | 0 | 0 | Period improvement, learning and career-start facts are simultaneous, not causal. |
| อายุ 30–41 ปี | 2 | 2 | 0 | 0 | Increased work/responsibility and self-directed decisions are separate facts. |
| คำทำนายปัจจุบัน — อายุ 44 ปี | 1 | 1 | 0 | 0 | One integrated meaning replaces Candidate 0024's duplicated “คล่องกว่าช่วงก่อน”. |
| การงาน | 2 | 2 | 0 | 1 | Core continuity/capacity plus a pending sustainment-versus-abrupt-change interpretation. |
| การเงิน | 2 | 3 | 0 | 1 | Core liquidity/funds-luck plus a pending daily-room interpretation and explicit scope limit. |
| ความรักและความสัมพันธ์ | 2 | 2 | 0 | 1 | Core tightening plus a pending trust-space interpretation; not a synonym-only restatement. |
| สุขภาพ | 2 | 2 | 0 | 0 | Current capacity and the insufficient-rest condition are independent authorized meanings. |
| โชคลาภและแรงสนับสนุน | 2 | 2 | 0 | 1 | Core helper groups plus a pending form-of-help interpretation; the groups are not re-listed. |
| คำทำนาย 12 เดือนข้างหน้า | 3 | 4 | 0 | 1 | Work scope and income appear once as core facts; later sentences add a pending lived meaning and an explicit non-causality boundary. |
| คำแนะนำ | 2 | 3 | 0 | 0 | Work, finance and rest advice remain outside prediction prose. |

The count of 55 distinct identifiers covers the full candidate, including profile, disclosure, personality, methodology and main-chart facts. Reuse between overview and lower detail is not counted as a second distinct meaning; it is tracked through named summary links.

## Reader-perceived repetition rule

A sentence is rejected when its section, level and semantic owner repeat an earlier sentence without a distinct lived-meaning identifier. This catches paraphrases even when the surface words change. It does not rely on edit distance, embeddings or an arbitrary similarity threshold.

The six negative controls reproduce Candidate 0024's actual duplicate patterns and filler failure modes. Each is rejected with a deterministic code and a human-readable reason; results are recorded in `CANDIDATE_0025_VALIDATION.json`.
