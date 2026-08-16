# Thai Narrative V1.5 R5 Editorial Closeout

สถานะ: `V1.5 R4 OWNER ACCEPTANCE REJECTED`

R5 แก้เฉพาะข้อปฏิเสธด้าน Past Reflection, การฟันธงใน Unknown, ตัวตรวจความซ้ำภาษาไทย และ freshness source-of-truth โดยรักษา hook, 4 domains × 3 horizons, Claim traceability, Known-time facts, Unknown fail-closed, Web/PDF parity และ PDF layout ที่ R4 ผ่านแล้ว

- Past ใช้ age-band resolver จากช่วงอายุจริง ไม่อ้าง fixture ID
- วัยเด็กกล่าวถึงบ้าน ผู้ดูแล ความปลอดภัย การเรียนรู้ การเล่น และการยอมรับ ไม่ถามเรื่องงาน รายได้ หรือแผนการเงิน
- Unknown ใช้กรอบที่สังเกตได้ เช่น `หากช่วงนี้คุณสังเกตว่า...`
- Thai repetition gate ใช้ Unicode character trigrams แยก theme/question และตรวจ normalized skeleton
- Freshness คำนวณจาก units ที่ `counted=true` ใน `evidence/consumer-unit-audit.json` เท่านั้น

หลักฐานหลักอยู่ใน `evidence/`; ภาพทุกหน้าและ contact sheets อยู่ใน `renders/`

Product Acceptance ยัง pending. PR #92 ต้องคง Draft พร้อม `DO NOT MERGE` / `DO NOT DEPLOY`. Production คง V1.4.

V1.5 R5 READY FOR OWNER ACCEPTANCE
