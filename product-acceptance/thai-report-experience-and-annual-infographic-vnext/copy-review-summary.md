# Copy review summary

Candidate copy เป็น reader-visible change และยังไม่ได้รับ Owner approval จึงไม่เขียนทับ accepted V1.5/R1–R7.1

| Metric | Result |
|---|---:|
| Profiles audited | 300 |
| Known / Unknown | 225 / 75 |
| Profiles changed | 300 |
| Fields changed | 2,105 |
| Omission | 0 |
| Addition | 0 |
| Semantic change | 0 |
| Prediction → advice | 0 |
| Advice → prediction | 0 |
| Traceability impact | 0 |
| Owner decision | Pending |

รายการครบทุก field อยู่ใน `copy-before-after-ledger.json` โดยมี profile ID, Known/Unknown, field path, before/after, exact textual diff, source template, rule IDs, semantic intent, claim trace IDs, canonical impact, Web/PDF impact และ decision.

กลุ่มแก้หลักคือถอดศัพท์ภายใน/สำนวนแข็ง เช่น “แปลเป็นภาษาคน”, “หลักฐาน” ในคำอ่านทั่วไป, ประโยคอำนาจตัดสินใจ/ภาระ, เงินสำรอง, เวลาฟื้นตัว, “จุดกระตุ้น” และ “ธาตุขัดกัน” โดยคงแนวโน้ม คำแนะนำ และ evidence boundaries เดิม

Accepted default `fromAnalysis` ไม่เปลี่ยน; candidate เปิดด้วย `applyReaderCopy=true` เท่านั้น จนกว่า Owner จะอนุมัติ ledger
