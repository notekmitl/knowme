# Visual QA

ตรวจไฟล์จริงทุกหน้าและภาพจริงจาก `generated-artifacts/`, `renders-final/`, `visual-qa-final/` และ `web-screenshots-final/`.

- Web: desktop 1024, tablet 768, mobile 390 Known และ mobile 360 Unknown; sticky export controls ไม่ซ้อนรายงาน, report scroll ครบ, infographic preview ไม่ล้น
- Infographic: Known/Unknown 1080×1920; Thai font ครบ, category 4 รายการไม่เกิน 2 บรรทัด, contrast อ่านได้, vector icons, ไม่มี clipping/transparent artifact/sensitive birth data
- Dedicated PDF: Known 8/8 และ Unknown 8/8; infographic หน้า 2, heading ไม่ค้างเดี่ยว, card ไม่ถูกตัดโดยไม่จำเป็น, ไม่มี disclaimer orphan
- Browser print: Known 7/7 และ Unknown 7/7; ไม่มี horizontal clipping, infographic หน้า 2, content order ตรง shared model
- Owner reproduction: dedicated PDF เดิม 7 หน้า; browser print เดิม 1 หน้าและถูกตัดตาม root-cause report

Artifact fixture generation ต้อง unmount composited `RepaintBoundary` ระหว่าง Known/Unknown เพื่อป้องกัน test raster cache เก็บ unchanged layers; raw final artifact test ยืนยันภาพทั้งสองครบหลังแก้

ผล: visual QA PASS สำหรับขอบเขตที่มีหลักฐาน; monthly timeline ไม่อยู่ในภาพเพราะ gate ยัง BLOCKED
