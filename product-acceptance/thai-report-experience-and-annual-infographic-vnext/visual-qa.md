# Visual QA — Revision 2 repaired

ตรวจจาก artifact จริง ไม่ใช่ widget preview อย่างเดียว

- Web mobile: Known และ Unknown ที่ viewport 360×800 และ 390×844; `scrollWidth == innerWidth`, report scroll ครบ, infographic ไม่ล้น และ browser console ไม่มี warning/error
- Infographic: 15 fixtures, PNG ทุกไฟล์ 1080×1920, title/year/category/opportunity/caution/advice/disclaimer ครบ, ไม่มี clipping/ellipsis/transparent artifact หรือข้อมูลวันเวลาเกิด
- ลายเส้นโค้งและดอกสี่กลีบเป็น decoration เท่านั้น ไม่มีแกน เดือน จุดข้อมูล หรือ label ที่อาจทำให้เข้าใจว่าเป็น monthly chart
- Canonical five และ stress fixtures มี contact sheet แยก; stress ครอบคลุมข้อความยาว, Thai multiline, opportunity/caution, disclaimer และ regression ปี 1972
- Dedicated PDF: 7 fixtures × 8 หน้า; browser print: 7 fixtures × 7 หน้า; Poppler render ตรวจครบ 105/105 หน้าและมี contact sheet ทุกไฟล์
- Known/Unknown ใช้ hierarchy, spacing และ font size ชุดเดียวกัน โดยปรับเฉพาะ decorative spacing ให้รองรับข้อความยาว

หลักฐานอยู่ใน `generated-artifacts/revision-2/`, `renders/revision-2-repaired/`, `visual-qa/revision-2-repaired/` และ `web-screenshots-repaired/` ผล QA ทางเทคนิคผ่าน แต่การอนุมัติด้าน copy/visual ยังเป็น **Pending Owner Review**

Monthly timeline ไม่อยู่ในภาพเพราะ gate ยัง BLOCKED และไม่มีการสร้างข้อมูลรายเดือนขึ้นเอง
