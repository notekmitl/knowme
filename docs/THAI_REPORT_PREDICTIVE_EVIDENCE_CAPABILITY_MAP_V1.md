# Thai Report Predictive Evidence Capability Map V1

## OR3 final rule-validity gate (2026-08-30)

Owner retains Option B and accepts the Event Ontology/Evidence Architecture for further design, but rejects Rulebook V1 and Candidate 0005 Known/Unknown as implementation, content, or expected-output targets. V1 has a blanket `currentAge+1` rolling-timing defect, unsourced 64/68/46 thresholds, arbitrary fixed 75/80 confidence labels, and event movements without sufficient Canon/engine authority.

The corrected rolling design splits at the actual birthday and passed boundary/coverage checks 300/300. Population calibration used the repository 300-case matrix: Known 225, Unknown 75, all eight supported start planets, opening/peak/closing, all harmony directions, and all five relationship-status design values. It measures selectivity only; semantic validity is not established and predictive accuracy cannot be measured without historical outcomes.

Rulebook V1.1 retains one exact life-period fact rule and two engine-semantic tendency projections, with product event rules 0, unsourced retained thresholds 0, arbitrary fixed confidence 0, and unsupported event claims 0. Candidate 0006 Known therefore has exact facts 2, tendencies 1, event predictions 0, visible duplicates 0 and Golden supported-content coverage 2/4. Unknown is a short reduced report with one limitation, empty predictive headings 0 and duplicate hits 0.

Final decision: **NO-GO — DOMAIN AUTHORITY OR CALIBRATION BLOCKER RECORDED**. Runtime implementation and expected-output creation remain blocked pending an expert-authored/approved event mapping or a validated outcome dataset. `monthlyTimelineAvailable=false`; G05/G10 remain blocked; no application, engine, UI, generator, report, infographic, PDF/export, Firebase/Production or `product-acceptance/` change is authorized.


สถานะ: **PHASE 1 OR2 OPTION B CAPABILITY BASELINE — NO RUNTIME IMPLEMENTATION**

OR2: Owner selected Option B The Product Rulebook now proposes transparent `OWNER_APPROVED_PRODUCT_INFERENCE` rules, but current engine capability is unchanged and no proposed event is relabeled as currently derivable

เอกสารนี้แยก “สิ่งที่ระบบคำนวณได้” ออกจาก “ข้อความที่บรรณาธิการเขียนให้อ่านง่าย” อย่างเคร่งครัด คำบรรยายที่มีอยู่ใน composer, Candidate หรือ Golden ไม่ถือเป็นหลักฐานการคำนวณ

## คำตอบหลัก

Engine มีความละเอียดมากกว่าแถบ `strong / active / quiet` จริง `PredictionScore` เก็บ `strength` และ `confidence` แบบจำนวนเต็ม 0–100 พร้อม weighted score ขณะที่ `PredictionEvidence`, `PredictionOpportunity`, `PredictionRisk` และ reason code เก็บสัญญาณประกอบระดับโดเมน อย่างไรก็ตามข้อมูลเหล่านี้บอกระดับแรง สนับสนุน ความเสี่ยง และเหตุผลเชิงระบบ ไม่ได้ระบุว่า “เกิดเหตุการณ์อะไร” “ใครเกี่ยวข้อง” “เกิดเมื่อไรภายในปี” หรือ “จบลงอย่างไร” จึงยังไม่รองรับคำทำนายเหตุการณ์แบบ traceable ตาม Golden

Canon Production มี 854 produced units ณ HEAD ที่ตรวจ แบ่งเป็น planet/library, remedies, lookup table และ life-period rule มี provenance ถึงหนังสือ/หน้า แต่ไม่พบ token ของ event family ที่สัญญา V1 กำหนดทั้ง 11 รายการ Canon บอกความสัมพันธ์ เช่น ดาวหรือทักษาเชื่อมกับโดเมนใด และตำแหน่งในบริบทบางชนิด ไม่ได้ให้กฎอนุมานเหตุการณ์หรือเวลาเกิดเหตุการณ์โดยตรง

## Capability inventory

| Capability | Source path | Input | Output จริง | Resolution | Known / Unknown | Deterministic / editorial | Trace / provenance | รองรับ Golden |
|---|---|---|---|---|---|---|---|---|
| Birth normalization | `lib/features/birth_normalization/application/adapters/thai_engine_adapter.dart` | civil date, optional time, place, timezone | exact instant เมื่อ Known; normalized date/place | นาทีเมื่อมีเวลา; วันเมื่อ Unknown | ทั้งคู่ โดยไม่เติม noon | deterministic | input และ normalized profile | G00 เฉพาะ fact |
| Ascendant | `lib/features/astrology/thai/foundation/models/thai_astrology_profile.dart` และ foundation pipeline | exact birth instant/place | sign, degree, lord | chart position | Known เท่านั้น | deterministic | calculated profile | G00; ไม่ใช่ event |
| Whole-sign houses | `lib/features/astrology/thai/foundation/v2/engines/house_engine.dart` | lagna/sign placements | house number, sign, lord | domain structure ไม่มีเวลาเหตุการณ์ | Known เท่านั้น | deterministic | calculated profile | ใช้เป็นองค์ประกอบ rule ได้ แต่ยังไม่รองรับ event |
| Thai-day basis | adapter และ normalized Thai birth data | exact birth time, sunrise basis | astrological weekday/date | วัน | Known เท่านั้น | deterministic | normalized profile | G00 |
| Life-period boundaries | `lib/features/astrology/thai/core/life_period/life_period_engine.dart` | astrological day, age/asOf | planet, age start/end, phase | ช่วงอายุหลายปี | Known; Unknown ต้องไม่สร้าง weekday | deterministic | timeline output | G01, G02, G11, G33, G35 แบบ rewrite |
| Annual Taksa | `lib/features/astrology/thai/core/life_period/annual_taksa_engine.dart` | age year, birth-day rotation | annual house, boriwan planet, Taksa roles | ปีอายุ | Known เมื่อฐานวันรองรับ | deterministic | annual result | ยังไม่พอสำหรับ event; ใช้เป็น proposed input หลัง Owner อนุมัติกฎ |
| Period intelligence | `period_intelligence.dart`, `life_timeline_intelligence.dart` | life period, planet/element, natal/lagna bonds | strength tier, harmony, bonds, influences | life period/current period | Known มี lagna bond; Unknown เฉพาะ non-lagna | deterministic | timeline bundle | theme/strength เท่านั้น |
| Future-period preview | `future_period_preview.dart` | current/next period | years until, transition quality, element shift, top opportunity/challenge domains | next life period | Known/Unknown ตาม input ที่เหลือ | deterministic | preview bundle | G35 แบบ rewrite; ไม่มี event |
| Forecast score | `prediction_score.dart`, `prediction_intelligence_engine.dart` | timeline intelligence, horizon, category | strength 0–100, confidence 0–100, weighted score, band | horizon × domain | Known/Unknown แยก source ownership | deterministic | score fields | ละเอียดกว่า band แต่ไม่ใช่ event |
| Forecast evidence | `prediction_evidence.dart`, `prediction_reason.dart` | affinity, harmony, period strength, timing/transition | typed source+magnitude+planet/domain/bond, reasons, opportunity/risk | horizon × domain | ทั้งคู่ตาม evidence availability | deterministic | evidence list/reason code | รองรับเหตุผลของ tendency; ไม่รองรับชื่อเหตุการณ์/ผลลัพธ์ |
| Forecast material serialization | report fingerprint/material layer referenced by Candidate matrix | prediction output | horizon, domain, band, risk, availability, transition, evidence key, ownership | horizon × domain | Known `lagna-house-and-life-period-score`; Unknown `life-period-score-without-lagna` | deterministic projection | evidence key | สูญเสีย exact score/evidence atom; ไม่รองรับ event |
| Canon production graph | `knowledge/canon/production/foundation_v1.knowme.json` | approved extracted units | 854 units; relation/context/domain/provenance | fact/relation จากหน้าอ้างอิง | applicability ตาม context | deterministic lookup; source extracted | book/edition/page/unit id | บอก signification/position แต่ไม่มีกฎ event/timing |
| Canon runtime attachment | `lib/features/astrology/thai/knowledge/canon/integration/thai_report_canon_evidence_enricher.dart` และ integration mapping | calculated/report claim key | Canon reference attachments | claim/source reference | ตาม signal scope | deterministic mapping | evidence ref/trace | เพิ่ม provenance ไม่ได้สร้าง calculation evidence |
| Narrative plan | `lib/features/thai_beta/application/narrative/thai_beta_report_narrative_plan.dart` | forecast materials | primary/secondary motif, decision plan | editorial organization | ทั้งคู่ | editorial projection | material ownership | ไม่ใช่หลักฐานคำนวณ |
| Past reflection | `lib/features/thai_beta/application/narrative/thai_beta_past_reflection.dart` | life periods | คำถาม/ข้อความชวนทบทวน | age period | ทั้งคู่ตาม facts | editorial | period source only | ไม่ยืนยันว่า event เกิดจริง |

## Event-resolution audit

| Event family | Current engine output | Canon rule found | Current status |
|---|---|---|---|
| `family_duty_or_constraint` | period/Taksa/bond inputs | ไม่พบ classical event mapping; OR2 product inference proposed | `REQUIRES_APPROVED_RULE` |
| `education_or_social_transition` | boundary/Taksa/bond inputs | ไม่พบ classical event mapping; OR2 product inference proposed | `REQUIRES_APPROVED_RULE` |
| `career_role_change` | career score/risk only | OR2 convergence rule proposed; not approved | `REQUIRES_APPROVED_RULE` |
| `career_opportunity` | generic opportunity domain/magnitude | OR2 convergence rule proposed; not approved | `REQUIRES_APPROVED_RULE` |
| `career_ending_or_transfer` | generic risk only | OR2 convergence rule proposed; not approved | `REQUIRES_APPROVED_RULE` |
| `income_change` | finance score/risk only | ไม่พบ income event rule | `REQUIRES_APPROVED_RULE` |
| `expense_or_obligation` | finance risk only | ไม่พบ expense category/event rule | `REQUIRES_APPROVED_RULE` |
| `relationship_entry` | relationship score only | ไม่พบ encounter rule และไม่มี relationship-status input | `REQUIRES_NEW_INPUT` |
| `relationship_clarity` | agreement-consistency editorial motif | ไม่พบ status-outcome rule | `REQUIRES_APPROVED_RULE` |
| `relationship_ending` | relationship risk only | ไม่พบ ending rule | `REQUIRES_APPROVED_RULE` |
| `health_load` | health score/recovery-risk motif | ไม่พบ medical/event rule | `REQUIRES_APPROVED_RULE` |
| `recovery_pressure` | health risk/magnitude | ไม่พบ outcome/timing rule | `REQUIRES_APPROVED_RULE` |
| `life_period_transition` | period start/end and planet are exact | period boundary itself derivable; social event outcomeไม่ derivable | `CURRENTLY_DERIVABLE` เฉพาะ boundary |

## Provenance boundary

- Canon reference ยืนยันว่าหน่วยความรู้มาจากแหล่งใด ไม่ได้ยืนยันว่ากฎ runtime ใช้หน่วยนั้นคำนวณ event แล้ว
- ชื่อดาว ชื่อช่วง phase essence หรือ domain affinity เป็น metadata/theme ไม่ใช่หลักฐานว่าเหตุการณ์เฉพาะเกิดขึ้น
- Advice, motif, summary และ reader copy เป็น editorial output ไม่ใช่ calculation atom
- การเพิ่ม event family ต้องเริ่มจากกฎที่ Owner อนุมัติและมี negative case ก่อนเขียน Candidate expected output ห้ามสร้างกฎย้อนหลังเพื่อให้ตรง Golden

## ข้อสรุปเชิงสถาปัตยกรรม

ระบบพร้อมจัดลำดับ timeline และบอกแรงระดับโดเมนอย่างตรวจย้อนกลับได้ OR2 เพิ่ม ontology, convergence design, optional relationship-status contract และ proposed Product Rulebook แต่ยังไม่มี approved event resolver หรือ within-year timing engine Candidate 0004 เป็น content direction และ Candidate 0005 เป็น review target เท่านั้น
