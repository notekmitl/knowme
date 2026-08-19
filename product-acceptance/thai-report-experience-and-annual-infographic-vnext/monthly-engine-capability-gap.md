# Monthly engine capability gap

## ผล audit

Engine ปัจจุบันมี annual/next-12-month window, life-period narrative, domain band และ trace IDs แต่ไม่มี contract ที่ผูกผลกับ calendar month ทั้ง 12 เดือนอย่าง deterministic พร้อม Bangkok civil `asOf`.

ข้อความอย่าง “กลางปี”, “ช่วงถัดไป” หรือ narrative ทั่วไปไม่ใช่หลักฐานระดับเดือน และไม่ถูกแปลงเป็นเดือนด้วย hash, random, hard-code หรือ AI

## Gate

- `monthlyTimelineAvailable = false`
- Known/Unknown infographic ไม่แสดงเดือนดีหรือเดือนระวัง
- Web/PDF/browser print ใช้ omission rule เดียวกัน
- ต้องมี Owner authorization แยกก่อนเพิ่ม astrology logic หรือ validated monthly engine contract

Monthly timeline จึง BLOCKED โดยตั้งใจ ไม่ใช่ feature ที่เสร็จสมบูรณ์

Revision 3 เปลี่ยนเฉพาะ candidate copy/layout/artifacts และ PDF evidence gate สำหรับ Owner review ไม่ได้เพิ่มหรือจำลอง monthly engine. ลายเส้นและดอกสี่กลีบบน infographic เป็น decoration ที่ไม่มีเดือน แกน หรือค่าข้อมูล. PR #100 ต้องคง Draft และ Production ยังคง V1.5 `5f98dfffef913e38`.
