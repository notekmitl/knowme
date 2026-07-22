# KnowMe Task

## Task ID

`thai-beta-public-route-anonymous`

## เป้าหมาย

แก้ Production FAIL ที่ `https://knowme-app-694e1.web.app/beta/thai` แสดง Login แทน ThaiBetaLandingPage — ให้ anonymous เปิด Public Beta ได้โดยไม่ล็อกอิน โดยไม่แตะ invite allow-list / badge rollout

## สิ่งที่ต้องทำ

- หาและแก้ต้นเหตุ routing/init ที่ทำให้ path `/beta/thai` หายก่อน WebLaunchRouter
- รักษา auth ของ capture/admin และ AuthGate flow ปกติ
- เพิ่ม regression tests สำหรับ anonymous public route + protected routes
- PreCommit → commit → PostCommit → PR → merge → deploy → ทดสอบ Production แบบ anonymous

## สิ่งที่ห้ามทำ

- ห้ามขออีเมล/credential หรือเพิ่ม UID / เปลี่ยน allow-list
- ห้ามรายงานว่า anonymous เห็น Login เป็น PASS
- ห้ามใช้ KnowMe AI Worker

## Definition of Done

- Focused tests ผ่าน + Local Gate ผ่าน
- merge เข้า main + deploy Firebase Hosting
- Production `/beta/thai` แสดง Thai Beta ไม่ใช่ Login
