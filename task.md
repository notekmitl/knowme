# KnowMe Task

## Task ID

`thai-beta-web-cache-bust`

## เป้าหมาย

Production ยังแสดง Login เพราะเบราว์เซอร์ cache `main.dart.js` แบบ `immutable` (header `**/*.js` ทับ entrypoint) — แก้ Cache-Control และ cache-bust entrypoint ใน deploy

## Definition of Done

- `main.dart.js` / bootstrap ได้ `no-cache` จริง
- Deploy ใส่ `?v=<sha>` ที่ bootstrap + main entrypoint
- Anonymous `/beta/thai` แสดง ThaiBetaLandingPage บน Production
