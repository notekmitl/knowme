# KnowMe Task

## Task ID

`thai-beta-public-route-anonymous-v2`

## เป้าหมาย

Production ยังแสดง Login บน `/beta/thai` หลัง PR #4 — แก้ต้นเหตุที่เหลือ: path URL strategy แข่งกับ `home:`, และ early capture ผ่าน `dart:js` อ่านไม่เสถียร ต้องให้ anonymous เห็น ThaiBetaLandingPage จริงบน Production

## สิ่งที่ต้องทำ

- อ่าน early capture จาก data-attribute + sessionStorage (dart:html)
- ใช้ `initialRoute` + `onGenerateInitialRoutes` แทน `home:`
- resolve deep link ผ่าน WebLaunchRouter ก่อน route อื่น
- regression tests + Gate + PR + deploy + ทดสอบ Production แบบ anonymous

## สิ่งที่ห้ามทำ

- ห้ามขอ credential / เปลี่ยน allow-list
- ห้ามรายงาน Login บน `/beta/thai` เป็น PASS
