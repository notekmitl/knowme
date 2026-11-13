# PR #149 · r6.4 เก็บภาษาสามจุด

ผู้ตรวจพบสามจุดที่ยังอ่านสะดุดใน r6.3 เจ้าของยังไม่ได้ตัดสินภาษา r6.3 หรือ r6.4 [ก่อน–หลังและต้นทาง](READINGS.md) · [คำอ่านที่ประกอบจริง](ASSEMBLED.md) · [เว็บทดลอง](https://knowme-trial-694e1.web.app/beta/thai)

- Application `1c0a9ee` ผ่าน required CI ก่อนเผยแพร่เวลา 19:43:04 น. กรุงเทพฯ เฉพาะ Hosting `knowme-trial-694e1` ที่ version `e74d116527a4cf2c` [CI application](https://github.com/notekmitl/knowme/actions/runs/43426164474) · [สิทธิ์ Hosting](hosting-permissions.json)
- Regression เดิมและเครื่องมือเก็บคำอ่านผ่าน 68 รายการ ตรวจ Mercury/Moon ใน widget เดิมและ Saturn ในชุดแขนงเดิม เทียบไฟล์ copy ของ r6.3 ที่ตรวจ Git hash แล้วกับผลประกอบใหม่ ข้อมูลดวง คะแนน หลักฐาน หมวด เงื่อนไข และผลดิบตรงกัน [ผลเทียบ](evidence-parity.json)
- Chrome แบบ headless ผ่าน Playwright บน Windows ที่ 390×844, 1280×800 และ 1920×911 ตรวจการ์ดตอนยุบ ขยาย และยุบกลับ รวมทั้งสี่แท็บ ตรวจ Saturn เพิ่มที่ 1280×800 การแสดงใน Messenger บน iPhone ยังไม่ได้ตรวจ [ผลปลายทาง](release-summary.json) · [ดูแลตัวเองตอนยุบ](topic-4-collapsed.png) · [ตอนขยาย](topic-4-expanded-end.png) · [Saturn ตอนยุบ](saturn-collapsed.png) · [ตอนขยาย](saturn-expanded.png)
- ทราบเวลาใช้ 2 POST ไม่ทราบเวลาใช้ 0 เปิดรายละเอียดและสลับแท็บไม่เพิ่มคำขอ ไม่พบคำขอ Auth, Firestore, Production API หรือการเขียนข้อมูลเพิ่ม [ผลปลายทาง](release-summary.json)
- ตรวจข้อความและภาพ PDF ไทย 4 หน้าต่อชุด เคส A มีครบ 64 ย่อหน้า เคส Saturn มีครบ 66 ย่อหน้า [PDF Mercury มือถือ](a-390-pdf-pages.png) · [PDF Mercury คอมพิวเตอร์](a-1920-pdf-pages.png) · [PDF Saturn](saturn-pdf-pages.png)
- Browser โหลด pin `trial_plain_th_20261113_r6_4` และ hash ตรง build เว็บหลักและ calculator อยู่ revision เดิม [hash](hosted-hashes.json) · [ผลปลายทาง](release-summary.json)

## ย้อนกลับ r6.3

คืนเฉพาะ version `07921333569fd11e` ของ trial แล้วเทียบ [hash r6.3](../pr149-r6-3/hosted-hashes.json)

```powershell
firebase hosting:clone knowme-trial-694e1@07921333569fd11e knowme-trial-694e1:live --project knowme-app-694e1 --non-interactive
```
