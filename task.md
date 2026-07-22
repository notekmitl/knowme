# KnowMe Task

## Task ID

`thai-beta-authgate-public-bypass`

## เป้าหมาย

Production ยังแสดง Login บน `/beta/thai` หลัง PublicThaiBetaApp bootstrap — อ่าน launch route ซ้ำหลัง Firebase init, อ่าน `__knowmeLaunchRoute` ผ่าน dart:js, และดัก AuthGate ไม่ให้ paint Login เมื่อเป็น Public Beta

## Definition of Done

- Anonymous `/beta/thai` → ThaiBetaLandingPage (ไม่ใช่ Login)
- Capture / protected routes ยังต้อง Login
- Gate + PR + deploy + Production ยืนยันแบบ anonymous
