# PR #149 · r6.3 ข้อความตอนยุบและขยาย

เจ้าของอ่าน r6.2 แล้วยังไม่เข้าใจ โดยเฉพาะย่อหน้าแรกของการ์ด ผลอ่านจากเจ้าของสำหรับ r6.3 ยังไม่มี [ก่อน–หลัง](READINGS.md) · [คำอ่านที่ประกอบจริง](ASSEMBLED.md) · [ต้นทางและขอบเขต](TEMPLATES.md) · [เว็บทดลอง](https://knowme-trial-694e1.web.app/beta/thai)

- Application `1063925` ผ่าน required CI ก่อนเผยแพร่เวลา 18:22:29 น. กรุงเทพฯ เฉพาะ Hosting site `knowme-trial-694e1` ที่ version `07921333569fd11e` [CI application](https://github.com/notekmitl/knowme/actions/runs/43415039658) · [สิทธิ์ Hosting](hosting-permissions.json)
- ชุดตรวจที่เกี่ยวข้องผ่าน 62 รายการ ทวน suite ของตัวประกอบและ widget อีก 20 รายการหลังเพิ่มการทดสอบการ์ดของ fixture Mercury/Moon ที่ 390×844 ค่าเกิดที่ใช้เปิดหน้าเป็นข้อมูลสังเคราะห์ชุดเดิม คำอ่านในการ์ดมาจากค่าที่เลือกให้ผ่านสองแขนงที่รายงาน [ตัวอย่างจริงของ fixture](ASSEMBLED.md) · [ผลเทียบข้อมูลและหลักฐาน](evidence-parity.json)
- ตรวจ Chrome แบบ headless ผ่าน Playwright บน Windows ทั้งสี่แท็บที่ 390×844, 1280×800 และ 1920×911 พร้อมการ์ดทั้งสี่ตอนยุบ ขยาย และยุบกลับ ผลนี้ครอบคลุมขนาดหน้าจอที่ระบุ การแสดงใน Messenger บน iPhone ยังไม่ได้ตรวจ [ผลปลายทาง](release-summary.json) · [ดูแลตัวเองตอนยุบ](topic-4-collapsed-hosted-a-390-chrome.png) · [ตอนขยาย](topic-4-expanded-end-hosted-a-390-chrome.png) · [ความสัมพันธ์ตอนยุบ](topic-3-collapsed-hosted-a-390-chrome.png) · [ตอนขยาย](topic-3-expanded-end-hosted-a-390-chrome.png)
- ทราบเวลาใช้ 2 POST ไม่ทราบเวลาใช้ 0 เปิดรายละเอียดและสลับแท็บไม่เพิ่มคำขอ ทั้งหกรอบไม่พบ Auth, Firestore, Production API หรือการเขียนข้อมูลเพิ่ม [ผลปลายทาง](release-summary.json)
- ฉบับพิมพ์ไทยตรงกับรายงานบนเว็บ พบครบ 64 ย่อหน้าใน PDF 4 หน้าต่อชุด ตรวจข้อความทุกหน้าและภาพส่วนสุขภาพที่เปลี่ยน [PDF มือถือ](hosted-a-390-chrome-pages.png) · [PDF เดสก์ท็อป](hosted-b-1280-cpu-pages.png)
- Browser โหลด pin `trial_plain_th_20261113_r6_3` และ hash ตรง build เว็บหลักและ calculator revision ตรงกับที่อ่านก่อนเผยแพร่ [hash](hosted-hashes.json) · [ผลปลายทาง](release-summary.json)

## ย้อนกลับ r6.2

คืนเฉพาะ version `506e2dad2253eb21` ของ trial แล้วเทียบ [hash r6.2](../pr149-r6-2/hosted-hashes.json)

```powershell
firebase hosting:clone knowme-trial-694e1@506e2dad2253eb21 knowme-trial-694e1:live --project knowme-app-694e1 --non-interactive
```
