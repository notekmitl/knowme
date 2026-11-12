# PR #149 · r6.1 เก็บข้อความที่ตกหล่นจาก r6

ผู้ตรวจพบข้อความตกหล่นจาก r6 เจ้าของยังไม่ได้ตัดสินภาษา r6 **รอเจ้าของทดลองอ่าน r6.1** [ก่อน–หลังและต้นทาง](READINGS.md) · [คำอ่านเต็ม](FULL_READINGS.md) · [สถานะระดับ template](TEMPLATES.md)

## ผลตรวจ

- Application `761463f` ผ่าน required CI ทุก job ก่อนอัปเดตเฉพาะเว็บทดลองเวลา 20:07:43 น. กรุงเทพฯ ที่ Hosting version `32a0b1e0fbbed6bd` [CI application](https://github.com/notekmitl/knowme/actions/runs/43222852465) · [สิทธิ์ Hosting](hosting-permissions.json)
- ชุดตรวจในเครื่องผ่าน 86 รายการ เปรียบเทียบ raw รายงาน ดวงที่เลือก หลักฐาน หมวด กฎข้อมูลไม่ครบและข้อขัดแย้งกับ r6 ที่วันอ้างอิงเดียวกัน รวมดวงรวม A/B และ owner-wording การเงินทั้งสองแขนงและความสัมพันธ์ true/false/null [ผลเทียบข้อมูล](evidence-parity.json)
- ตรวจข้อความที่ประกอบจริงและการเปิดรายละเอียดบน Chromium ทั้งสี่แท็บที่ 390×844, 1280×800 และ 1920×911 ตรวจคำอ่าน BaZi V1/V2 ที่ใช้เมื่อข้อมูลไม่ครบเพิ่มเติมแบบออฟไลน์ และตรวจแถวช่วงเวลาบนเว็บจากภาพต่อเนื่อง [ผลปลายทาง](release-summary.json) · [ภาพย่อหน้าตะวันตก](western-reading-hosted-b-1280-cpu.png) · [คำอ่านสำรอง](FULL_READINGS.md#จีน--ข้อมูลไม่ครบ)
- ทราบเวลาใช้ 2 POST ไม่ทราบเวลาใช้ 0 การสลับแท็บและเปิดรายละเอียดไม่เพิ่มคำขอ ทั้งหกรอบไม่พบคำขอ Auth, Firestore, Production API หรือการเขียนข้อมูลอื่น [ผลปลายทาง](release-summary.json)
- ฉบับพิมพ์ไทยใช้ข้อความเดียวกับรายงานบนเว็บ ตรวจภาพและข้อความครบทั้ง 4 หน้าต่อชุด พบครบ 60 ย่อหน้าต่อชุด ภาพสรุป 12 เดือนแสดงแยกบนเว็บตามเดิม [PDF มือถือ](hosted-a-390-chrome-pages.png) · [PDF เดสก์ท็อป 1280](hosted-b-1280-cpu-pages.png) · [PDF เดสก์ท็อป 1920](hosted-b-1920-chrome-pages.png)
- Browser โหลด pin `trial_plain_th_20261112_r6_1` และ hash ตรงกับ build เว็บหลักและ calculator revision ตรงกับค่าที่อ่านก่อนเผยแพร่ [hash ปลายทาง](hosted-hashes.json) · [ผลปลายทาง](release-summary.json)

## ย้อนกลับไป r6

คำสั่งนี้ใช้คืน version `5d7769e42db14297` เฉพาะ trial แล้วเทียบกับ [hash ของ r6](../pr149-r6/hosted-hashes.json)

```powershell
firebase hosting:clone knowme-trial-694e1@5d7769e42db14297 knowme-trial-694e1:live --project knowme-app-694e1 --non-interactive
```
