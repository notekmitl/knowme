# KnowMe Task

## Task ID

`thai-beta-public-bootstrap`

## เป้าหมาย

Production ยังแสดง Login บน `/beta/thai` หลัง PR #4/#5 — แยก Public Beta เป็น shell โดยไม่มี AuthGate ใน tree และจับ launch route หลัง ensureInitialized

## Definition of Done

- Anonymous `/beta/thai` → PublicThaiBetaApp / ThaiBetaLandingPage
- Capture/screenshot ยังต้อง Login
- Gate + PR + deploy + Production ยืนยันไม่ใช่ Login
