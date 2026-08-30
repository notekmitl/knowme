# Thai Report Product Predictive Rulebook V1 — Authority Audit

สถานะ: **V1 REJECTED AS IMPLEMENTATION RULE SET — AUDIT COMPLETE**

Owner รับ Ontology/Evidence Architecture เพื่อพัฒนาต่อ แต่ไม่รับ Rulebook V1 ค่า distribution ด้านล่างบอกได้เพียง selectivity ไม่ใช่ semantic validity หรือ predictive accuracy

## Authority distinction

- Canon unit ที่อธิบายความหมายของดาว บทบาททักษา หรือความสัมพันธ์ของดาว รองรับ provenance ของ input แต่ไม่พิสูจน์ว่า input เหล่านั้นทำให้ event family ใดเกิดขึ้น
- Engine รองรับ life-period boundary, stage, harmony, domain affinity, opportunity/risk structure, strength และ proximity/structural score ตาม source semantics ของมัน
- Engine ไม่มี resolver ที่เปลี่ยน signal เหล่านี้เป็น family duty, career opportunity, income increase, relationship entry/ending หรือ health/recovery event
- ไม่มี historical outcome dataset จึงวัด predictive accuracy ไม่ได้

## Per-rule audit

| ruleId | Event family | Role set / threshold / score | Supported unit or semantic | Canon/engine supports | Product inference and missing authority | Disposition |
|---|---|---|---|---|---|---|
| `PPR-PAST-FAMILY-DUTY-001` | family duty/constraint | บริวาร/กาฬกิณี; harmony ≤0; hit years ≥2; fixed 75 | period ages, Taksa roles, harmony | คำนวณค่าแต่ละตัวได้ | ไม่มี rule ว่าค่ารวมนี้หมายถึงภาระครอบครัว; 2 และ 75 ไม่มีที่มา | `UNSOURCED_PRODUCT_INFERENCE` |
| `PPR-PAST-EDUCATION-SOCIAL-001` | education/social transition | เดช/อุตสาหะ/มนตรี; abs bond ≥1; fixed 75 | exact period boundary, bond, Taksa role | คำนวณ boundary/relationship ได้ | ไม่มี event mapping ไปการเรียนหรือสังคม; 1 และ 75 ไม่มี authority | `UNSOURCED_PRODUCT_INFERENCE` |
| `PPR-PAST-DOMAIN-TRANSITION-001` | past career/finance/relationship transition | กาฬกิณี/มูละ/อุตสาหะ; bond <0; fixed 80 | boundary, bond, planet affinity | คำนวณ inputs ได้ | argmax domain และ ending movement ไม่อยู่ใน Canon/engine; relationship branchขาด status | `REJECT` |
| `PPR-CAREER-ROLE-001` | career role change | 68/60/60; เดช/อุตสาหะ/มนตรี | career strength, engine proximity score, affinity, harmony, Taksa | รองรับ tendency signals | ไม่มี authority ว่า convergence ทำให้หน้าที่หรืออำนาจเปลี่ยน; 68 ไม่มีที่มา | `UNSOURCED_PRODUCT_INFERENCE` |
| `PPR-CAREER-OPPORTUNITY-001` | career opportunity | 64/60/60; ศรี/มนตรี/เดช | career/opportunity structures | รองรับ opportunity tendency | ไม่รองรับ external opportunity event; 64 ไม่มีที่มา | `UNSOURCED_PRODUCT_INFERENCE` |
| `PPR-CAREER-ENDING-001` | career contraction | risk 46; เดช/อายุ | risk/harmony/role | รองรับ risk structure | 46 และ contraction movement ไม่มี authority | `UNSOURCED_PRODUCT_INFERENCE` |
| `PPR-INCOME-001` | income increase | 64/60; ศรี/มูละ/มนตรี | finance strength, money opportunity | รองรับ finance tendency | ไม่มี income movement/source resolver; 64 ไม่มีที่มา | `UNSOURCED_PRODUCT_INFERENCE` |
| `PPR-EXPENSE-001` | expense/obligation | 48/46; เดช/อายุ | finance strength/risk | รองรับ risk tendency | ไม่มี expense/obligation event mapping; 48/46 ไม่มีที่มา | `UNSOURCED_PRODUCT_INFERENCE` |
| `PPR-RELATIONSHIP-CLARITY-001` | relationship clarity | 64/60; 4-role set | relationship/love tendency | รองรับ domain tendency | clarity/agreement event ไม่ได้คำนวณ; 64 ไม่มีที่มา | `UNSOURCED_PRODUCT_INFERENCE` |
| `PPR-RELATIONSHIP-ENTRY-001` | relationship entry | clarity fires + single; cap 80 | explicit design status | status ป้องกัน branch ผิดได้ | status ไม่ทำให้ love tendency กลายเป็นคนใหม่; cap 80 ไม่มีที่มา | `REJECT` |
| `PPR-RELATIONSHIP-ENDING-001` | relationship ending | risk 46; เดช/อายุ; partnered states | status/risk/harmony | inputs ตรวจได้ | ไม่มี ending event resolver; 46 ไม่มีที่มา | `REJECT` |
| `PPR-HEALTH-LOAD-001` | health load | risk 46; เดช/อายุ | health risk/harmony | รองรับ non-medical risk tendency | event movement และ 46 ไม่มี authority | `UNSOURCED_PRODUCT_INFERENCE` |
| `PPR-RECOVERY-001` | recovery pressure | strength <68; risk ≥46; เดช/อายุ | health strength/risk | รองรับ tendency inputs | recovery timing/outcome ไม่ได้คำนวณ; 68/46 ไม่มีที่มา | `REJECT` |
| `PPR-LIFE-PERIOD-TRANSITION-001` | life-period transition fact | exact generated boundary | `LifePeriodEngine`, period ring/strength Canon | exact inclusive age boundary | ห้ามต่อยอดเป็น external event consequence | `CANON_SUPPORTED` |

## Threshold and score audit

| Value/name | Finding | Disposition |
|---|---|---|
| 64 | ไม่มี Canon, engine decision boundary, expert rule หรือ outcome calibration | unsourced; remove from retained rules |
| 68 | ไม่มี authority; การตรงกับ distribution ไม่สร้าง semantic meaning | unsourced; remove |
| 46 | ไม่มี authority;เป็นค่าที่อยู่ใกล้ cluster risk แต่ไม่ได้บอก event | unsourced; remove |
| fixed 75/80 | ไม่ได้วัด empirical probability หรือ prediction confidence | reject |
| engine `confidence` | source code คำนวณจาก horizon proximity, lagna availability, period tier, harmony magnitude และ transition | เรียก `engineProximityStructuralScore`; ห้ามนำเสนอเป็นความน่าจะเป็น/ความแม่น |
| atom `confidence=min(engine,60+5×groups)` | จำนวนกลุ่มไม่ใช่ confidence calibration และ conflict winner จึงไม่มี authority | reject |

Population percentilesไม่สามารถเปลี่ยนค่าเหล่านี้เป็น `DISTRIBUTION_CALIBRATED_PRODUCT_INFERENCE` เพราะไม่มี labeled outcome และไม่มี product criterion ที่ Owner อนุมัติ ทุก V1 product-event rule จึงถูกถอดจาก V1.1 แทนการปรับ threshold เพื่อให้ fixture ยิง
