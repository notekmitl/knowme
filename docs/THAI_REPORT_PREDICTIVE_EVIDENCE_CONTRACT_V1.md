# Thai Report Predictive Evidence Contract V1

## OR3 final rule-validity gate (2026-08-30)

Owner retains Option B and accepts the Event Ontology/Evidence Architecture for further design, but rejects Rulebook V1 and Candidate 0005 Known/Unknown as implementation, content, or expected-output targets. V1 has a blanket `currentAge+1` rolling-timing defect, unsourced 64/68/46 thresholds, arbitrary fixed 75/80 confidence labels, and event movements without sufficient Canon/engine authority.

The corrected rolling design splits at the actual birthday and passed boundary/coverage checks 300/300. Population calibration used the repository 300-case matrix: Known 225, Unknown 75, all eight supported start planets, opening/peak/closing, all harmony directions, and all five relationship-status design values. It measures selectivity only; semantic validity is not established and predictive accuracy cannot be measured without historical outcomes.

Rulebook V1.1 retains one exact life-period fact rule and two engine-semantic tendency projections, with product event rules 0, unsourced retained thresholds 0, arbitrary fixed confidence 0, and unsupported event claims 0. Candidate 0006 Known therefore has exact facts 2, tendencies 1, event predictions 0, visible duplicates 0 and Golden supported-content coverage 2/4. Unknown is a short reduced report with one limitation, empty predictive headings 0 and duplicate hits 0.

Final decision: **NO-GO — DOMAIN AUTHORITY OR CALIBRATION BLOCKER RECORDED**. Runtime implementation and expected-output creation remain blocked pending an expert-authored/approved event mapping or a validated outcome dataset. `monthlyTimelineAvailable=false`; G05/G10 remain blocked; no application, engine, UI, generator, report, infographic, PDF/export, Firebase/Production or `product-acceptance/` change is authorized.


สถานะ: **OR2 OPTION B SELECTED — PRODUCT RULEBOOK PROPOSED — OWNER RULE REVIEW REQUIRED — NOT IMPLEMENTED**

OR2 correction: past family duty and education/social transitions are no longer classified as career events Product rule IDs, exact thresholds and convergence formulas live in `THAI_REPORT_PRODUCT_PREDICTIVE_RULEBOOK_V1.md` Candidate 0004 remains content direction only

สัญญานี้กำหนดรูปข้อมูลที่ต้องมี ก่อนข้อความใดจะยกระดับจาก theme ระดับโดเมนเป็นคำทำนายเหตุการณ์ ห้ามสร้าง atom ย้อนหลังจาก Golden หรือ Candidate เพื่อให้ข้อความผ่าน

## Typed evidence atom

```text
PredictiveEvidenceAtom {
  evidenceAtomId: String
  calculationMethod: String
  sourcePath: List<String>
  horizon: past | current | next12Months | nextLifePeriod
  startBoundary: InstantOrAge
  endBoundary: InstantOrAge
  ageBoundary: AgeRange?
  domain: career | finance | relationship | health | crossDomain
  eventFamily: EventFamily
  movement: opening | increasing | peak | decreasing | closing | transition | steady
  expectedOutcome: String
  strength: Integer[0..100]
  priority: Integer[0..100]
  certaintyRole: fact | prediction | risk | opportunity
  knownTimeRequired: Boolean
  relationshipStatusRequired: Boolean
  provenance: List<TraceReference>
  semanticOwner: String
  dedupeKey: String
  allowedPredictionLanguage: List<String>
  prohibitedEscalation: List<String>
  unknownBehavior: omit | downgrade_to_non_time_atom | available
  supportStatus: CURRENTLY_DERIVABLE | REQUIRES_APPROVED_RULE |
                 REQUIRES_NEW_INPUT | NOT_SUPPORTED | PROHIBITED_PSYCHOLOGY
}
```

`expectedOutcome` ต้องเป็นค่าจาก calculation rule ที่อนุมัติ ไม่ใช่ประโยคที่ copywriter เติม `strength` และ `priority` ต้องมาจาก field จริงหรือสูตรที่ Owner อนุมัติ ห้ามแปลงชื่อดาว ชื่อช่วง หรือคำว่า strong เป็น event โดยตรง

## Event-family registry

| Event family | ความหมายที่อนุญาต | หลักฐานปัจจุบัน | Status | Unknown behavior |
|---|---|---|---|---|
| `family_duty_or_constraint` | ภาระ/กฎในครอบครัว | มี period/Taksa/bond แต่ไม่มีกฎ classical event | `REQUIRES_APPROVED_RULE` | omit |
| `education_or_social_transition` | การเรียนหรือกลุ่มสังคมเปลี่ยน | มี boundary/Taksa/bond แต่ไม่มีกฎ classical event | `REQUIRES_APPROVED_RULE` | omit |
| `career_role_change` | หน้าที่หรืออำนาจตัดสินใจเปลี่ยน | มี career score/house/period แต่ไม่มีกฎ event | `REQUIRES_APPROVED_RULE` | omit |
| `career_opportunity` | โอกาสงานที่ระบุ outcome family ได้ | มี generic opportunity magnitude เท่านั้น | `REQUIRES_APPROVED_RULE` | omit |
| `career_ending_or_transfer` | งานจบ ลด หรือส่งต่อ | ไม่มี outcome rule | `REQUIRES_APPROVED_RULE` | omit |
| `income_change` | รายรับเพิ่ม/ลดจาก source ที่ระบุได้ | มี finance score เท่านั้น | `REQUIRES_APPROVED_RULE` | ตาม source dependency |
| `expense_or_obligation` | ภาระจ่ายหรือข้อผูกพันใหม่/สิ้นสุด | มี generic finance risk | `REQUIRES_APPROVED_RULE` | ตาม source dependency |
| `relationship_entry` | บุคคลหรือความสัมพันธ์ใหม่เข้าสู่ชีวิต | ไม่มี status input หรือ encounter rule | `REQUIRES_NEW_INPUT` | omit เมื่อ input/status ไม่ครบ |
| `relationship_clarity` | สถานะ/ข้อตกลงชัดขึ้น | มี editorial agreement motif ไม่มี outcome rule | `REQUIRES_APPROVED_RULE` | ตาม source dependency |
| `relationship_ending` | ความสัมพันธ์จบหรือถอย | ไม่มี ending rule | `REQUIRES_APPROVED_RULE` | ตาม source dependency |
| `health_load` | ภาระต่อการพัก/พลังชีวิต ไม่ใช่วินิจฉัย | มี health score/risk | `REQUIRES_APPROVED_RULE` | ห้ามใช้ time-dependent source เมื่อ Unknown |
| `recovery_pressure` | แรงกดต่อ recovery ที่ไม่ใช่ diagnosis | มี generic risk/magnitude | `REQUIRES_APPROVED_RULE` | ใช้ได้เฉพาะ atom ที่ไม่พึ่งเวลาเกิด |
| `life_period_transition` | การเปลี่ยนจาก period หนึ่งสู่อีก period | start/end/planet คำนวณได้ | `CURRENTLY_DERIVABLE` เฉพาะ boundary | omit เมื่อฐานวันโหราศาสตร์คำนวณไม่ได้ |

## Support statuses

- `CURRENTLY_DERIVABLE`: มี calculation method, field, boundary และ trace จริงครบแล้ว
- `REQUIRES_APPROVED_RULE`: มีวัตถุดิบบางส่วน แต่ยังไม่มีกฎ Canon/Owner-approved ที่แปลงเป็น event
- `REQUIRES_NEW_INPUT`: ต้องรู้ข้อมูลผู้ใช้เพิ่ม เช่น relationship status ก่อนเลือก branch
- `NOT_SUPPORTED`: ไม่มีทั้งข้อมูลและกฎในขอบเขตผลิตภัณฑ์ปัจจุบัน
- `PROHIBITED_PSYCHOLOGY`: เป็นข้อสรุปบุคลิก แผลใจ survival pattern หรือ self-concept ที่ห้ามอยู่ในรายงานโหราศาสตร์นี้

## Proposed atom registry for Candidate 0004

รายการ `PEV-*` เป็น ID แบบออกแบบเพื่อ trace ข้อเสนอ ไม่ใช่ evidence ที่ runtime สร้างแล้ว

| Atom | Event family / horizon | Proposed calculation inputs | Expected outcome vocabulary | Status | Canon decision |
|---|---|---|---|---|---|
| `PEV-PST-01` | `family_duty_or_constraint` / past 1–10 | life period + annual Taksa + natal bond | family duty/constraint | `REQUIRES_APPROVED_RULE` | `PPR-PAST-FAMILY-DUTY-001` pending Owner |
| `PEV-PST-02` | `life_period_transition` / past 11–29 | exact period boundary | Jupiter period begins/ends | `CURRENTLY_DERIVABLE` เฉพาะ boundary | none for boundary; event wording blocked |
| `PEV-PST-03` | `education_or_social_transition` / past 11–29 | boundary + annual Taksa + previous bond | education/social setting changes | `REQUIRES_APPROVED_RULE` | `PPR-PAST-EDUCATION-SOCIAL-001` pending Owner |
| `PEV-PST-04` | resolved career/finance/relationship transition / past 30–41 | boundary + annual Taksa + previous bond + domain affinity | one resolved domain moves | `REQUIRES_APPROVED_RULE` | `PPR-PAST-DOMAIN-TRANSITION-001` pending Owner |
| `PEV-CUR-WRK-01` | `career_role_change` / current | career prediction + annual Taksa + natal structure + timing | authority/duty changes | `REQUIRES_APPROVED_RULE` | `PPR-CAREER-ROLE-001` pending Owner |
| `PEV-CUR-WRK-02` | `career_opportunity` / current | career opportunity + annual Taksa + natal structure + timing | career opportunity | `REQUIRES_APPROVED_RULE` | `PPR-CAREER-OPPORTUNITY-001` pending Owner |
| `PEV-CUR-FIN-01` | `income_change` / current | finance score + source resolver | income movement | `REQUIRES_APPROVED_RULE` | `OWNER_ASTROLOGY_RULE_DECISION_REQUIRED` |
| `PEV-CUR-FIN-02` | `expense_or_obligation` / current | finance risk + obligation resolver | expense/obligation movement | `REQUIRES_APPROVED_RULE` | `OWNER_ASTROLOGY_RULE_DECISION_REQUIRED` |
| `PEV-CUR-REL-01` | `relationship_clarity` / current | relationship score + event rule | agreement/status clarity | `REQUIRES_APPROVED_RULE` | `OWNER_ASTROLOGY_RULE_DECISION_REQUIRED` |
| `PEV-CUR-REL-02` | `relationship_entry` / current | status input + encounter resolver | relationship entry | `REQUIRES_NEW_INPUT` | relationship input + astrology rule required |
| `PEV-CUR-REL-03` | `relationship_ending` / current | relationship score + ending rule | ending/withdrawal | `REQUIRES_APPROVED_RULE` | `OWNER_ASTROLOGY_RULE_DECISION_REQUIRED` |
| `PEV-CUR-HLT-01` | `health_load` / current | health score/risk + safe outcome rule | workload/rest pressure | `REQUIRES_APPROVED_RULE` | medical-safety review required |
| `PEV-CUR-HLT-02` | `recovery_pressure` / current | health risk + recovery resolver | recovery pressure movement | `REQUIRES_APPROVED_RULE` | medical-safety review required |
| `PEV-N12-WRK-01` | `career_role_change` / next12Months | annual horizon + career/annual/natal signals | role expands/contracts | `REQUIRES_APPROVED_RULE` | `PPR-CAREER-ROLE-001` pending Owner |
| `PEV-N12-WRK-02` | `career_ending_or_transfer` / next12Months | annual horizon + risk/annual/natal signals | work contracts/transfers | `REQUIRES_APPROVED_RULE` | `PPR-CAREER-ENDING-001` pending Owner |
| `PEV-N12-FIN-01` | `income_change` / next12Months | timing + finance event rule | income movement | `REQUIRES_APPROVED_RULE` | timing and event decisions required |
| `PEV-N12-FIN-02` | `expense_or_obligation` / next12Months | timing + finance event rule | obligation movement | `REQUIRES_APPROVED_RULE` | timing and event decisions required |
| `PEV-N12-REL-01` | `relationship_clarity` / next12Months | timing + relationship rule | clarity movement | `REQUIRES_APPROVED_RULE` | timing and event decisions required |
| `PEV-N12-HLT-01` | `recovery_pressure` / next12Months | timing + health-safe rule | recovery pressure movement | `REQUIRES_APPROVED_RULE` | timing and medical-safety decisions required |
| `PEV-NXT-01` | `life_period_transition` / nextLifePeriod | exact next period boundary | Venus to Sun period transition | `CURRENTLY_DERIVABLE` | none for boundary |
| `PEV-NXT-WRK-01` | `career_role_change` / nextLifePeriod | next period + career score + event rule | work moves toward direction/quality | `REQUIRES_APPROVED_RULE` | no approved next-period event rule in V1 |

## Certainty and language rules

| Status | Allowed prediction language | Prohibited escalation |
|---|---|---|
| `CURRENTLY_DERIVABLE` fact | “เริ่ม”, “สิ้นสุด”, “อยู่ในช่วง”, exact boundary | ห้ามเติม social event หรือ outcome |
| approved direct event atom | ประโยคบอกเล่าตรงตาม movement/outcome ที่ atom ระบุ | ห้ามเพิ่ม source, count, actor, amount หรือ exact date ที่ atomไม่มี |
| approved risk/opportunity atom | บอกความเสี่ยงหรือโอกาสเป็นประเภทเดียวกับ atom | ห้ามรับรองผลหรือเปลี่ยน risk เป็นเหตุการณ์แน่นอน |
| `REQUIRES_APPROVED_RULE` | ใช้ได้เฉพาะใน design Candidate พร้อมป้าย proposal | ห้ามเข้า runtime, expected-output test หรือ acceptance baseline |
| `REQUIRES_NEW_INPUT` | ใช้ได้หลัง input branch ถูกส่งมาจริง | ห้ามเดาสถานะผู้ใช้ |
| `NOT_SUPPORTED` / `PROHIBITED_PSYCHOLOGY` | ไม่สร้างข้อความ | ห้าม paraphrase เพื่อหลบ gate |

## Dedupe and provenance invariants

1. `semanticOwner` มีค่าเดียวต่อ claim; summary อ้าง owner เดิมและไม่สร้าง owner ใหม่
2. `dedupeKey` ต้องเกิดจาก event family + horizon + boundaries + domain + outcome ไม่ใช่ string similarity
3. ทุก atom มี source path ไปยัง calculation output และ Canon unit/rule เมื่อใช้ Canon
4. Unknown กรอง atom ก่อน composition; ไม่สร้าง Known text แล้วลบภายหลัง
5. Atom ที่ยังเป็น proposal ต้องติด status ใน Matrix และห้ามถูกนับเป็น supported
6. Golden เป็น language/style reference ไม่ใช่แหล่ง calculation evidence
