# Copy review summary — Revision 2

Candidate copy เป็น reader-visible change และยังไม่ได้รับ Owner approval จึงไม่เขียนทับ accepted V1.5/R1–R7.1

| Metric | Result |
|---|---:|
| Profiles audited | 300 |
| Known / Unknown | 225 / 75 |
| Profiles changed | 300 |
| Fields changed | 4,003 |
| Active grouped rules | 45 |
| Omission | 0 |
| Addition | 0 |
| Semantic change | 0 |
| Prediction → advice | 0 |
| Advice → prediction | 0 |
| Traceability impact | 0 |
| Owner decision | Pending |

รายการ Revision 2 ครบทุก field อยู่ใน `copy-before-after-ledger-revision-2.json` โดยมี profile ID, Known/Unknown, field path, before/after, exact textual diff, source template, rule IDs, semantic intent, claim trace IDs, canonical impact, Web/PDF impact และ decision. ตาราง [owner-copy-curated-review-revision-2.md](owner-copy-curated-review-revision-2.md) group 45 rulesที่ active จาก ledger ทั้งชุดเพื่อให้ Owner อ่านได้สะดวก โดยไม่ใช้ sampling

Ledger เดิม `copy-before-after-ledger.json` จำนวน 2,105 fields ยังคงอยู่เพื่อรักษา provenance ของรอบก่อนและไม่ได้ถูกแก้ย้อนหลัง

Revision 2 แก้ถ้อยคำแข็ง/ศัพท์ภายในและคำเชื่อมใน infographic โดยคงแนวโน้ม คำแนะนำ evidence boundaries, claim IDs และ trace IDs เดิม Candidate เปิดด้วย `applyReaderCopy=true`; accepted default `fromAnalysis` ไม่เปลี่ยนจนกว่า Owner จะตัดสิน
