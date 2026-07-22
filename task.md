# KnowMe Task

## Task ID

`thai-beta-narrative-v111-real-report-quality`

## เป้าหมาย

Real Report Quality Acceptance สำหรับ Thai Beta Narrative V1.1.1 — หากพบข้อผิดพลาดแก้เฉพาะต้นเหตุเป็น V1.1.2

## Definition of Done

- มี acceptance suite ครอบคลุมพุธกลางวัน/กลางคืน, ไม่มีเวลาเกิด, confidence, block integrity, Evidence Badge gate, mobile/desktop
- Narrative ไม่ซ้ำ block โดยไม่จำเป็น; domain why ใช้คู่กับ overview; selector เลือก unused same-domain ก่อน reuse
- focused tests + analyze + Local Gate ผ่าน
- (นอก Gate ตาม user e2e) PR → checks → merge → deploy → ตรวจ Production
