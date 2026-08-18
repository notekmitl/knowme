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
