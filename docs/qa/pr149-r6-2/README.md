# PR #149 · r6.2 ปิดสี่กลุ่มที่ค้างจาก r6.1

[สถานะรายแขนง](TEMPLATES.md) · [ก่อน–หลังจากคำอ่านจริง](READINGS.md) · [ผลประกอบ](ASSEMBLED.md) · [เว็บทดลอง](https://knowme-trial-694e1.web.app/beta/thai)

- Application `b256db9` ผ่าน required CI ก่อนเผยแพร่เวลา 10:46:06 น. กรุงเทพฯ เฉพาะ Hosting site `knowme-trial-694e1` ที่ version `506e2dad2253eb21` [CI application](https://github.com/notekmitl/knowme/actions/runs/43359992743) · [สิทธิ์ Hosting](hosting-permissions.json)
- ชุดตรวจที่เกี่ยวข้องผ่าน 62 รายการ และรันซ้ำเฉพาะส่วนที่แก้ล่าสุด 28 รายการ รวมชุดประกอบออฟไลน์ ไทย 30 เคส จีน 240 ชุดเคสและปี และตะวันตก 120 ชุด ผลดิบ A/B และ owner-wording ข้อมูลดวง หลักฐาน รหัสคำอ่านไทย จำนวนแถวและป้ายปีจีน ตรงกับฐานที่เทียบ [ผลเทียบ](evidence-parity.json)
- ตรวจ Chromium ปลายทางครบสี่แท็บและรายละเอียดที่ 390×844, 1280×800 และ 1920×911 เทียบข้อความบนจอจากผลประกอบ แถวช่วงเวลาจีนตรวจจากภาพที่เลื่อนต่อเนื่อง [ผลปลายทาง](release-summary.json) · [สรุปตะวันตกบนมือถือ](western-overview-hosted-a-390-chrome.png) · [ช่วงสิบปีและรายปีจีน](chinese-timeline-sweep-04-hosted-b-1280-cpu.png)
- ทราบเวลาใช้ 2 POST ไม่ทราบเวลาใช้ 0 การเปิดรายละเอียดและสลับแท็บใช้ผลเดิม ทั้งหกรอบไม่พบ Auth, Firestore, Production API หรือการเขียนข้อมูลเพิ่ม [ผลปลายทาง](release-summary.json)
- ฉบับพิมพ์ไทยตรงกับรายงานบนเว็บ พบครบ 64 ย่อหน้าใน PDF 4 หน้าต่อชุด ตรวจข้อความและภาพทุกหน้า ภาพสรุป 12 เดือนแสดงแยกบนเว็บตามช่องทางเดิม [PDF 390](hosted-a-390-chrome-pages.png) · [PDF 1280](hosted-b-1280-cpu-pages.png) · [PDF 1920](hosted-b-1920-chrome-pages.png)
- Browser โหลด pin `trial_plain_th_20261113_r6_2` และ hash ตรง build เว็บหลักและ calculator revision ตรงกับที่อ่านก่อนเผยแพร่ [hash](hosted-hashes.json) · [ผลปลายทาง](release-summary.json)

## ย้อนกลับ r6.1

คืนเฉพาะ version `32a0b1e0fbbed6bd` ของ trial แล้วตรวจเทียบ [hash r6.1](../pr149-r6-1/hosted-hashes.json)

```powershell
firebase hosting:clone knowme-trial-694e1@32a0b1e0fbbed6bd knowme-trial-694e1:live --project knowme-app-694e1 --non-interactive
```

**สถานะภาษา** ตรวจคำอ่านที่ประกอบจริงและปิดรายการตามขอบเขต r6.2 แล้ว ต้นทางไทยเรื่องกำลังระบุความเกี่ยวข้องโดยไม่ได้บอกทิศทาง จึงแสดงข้อจำกัดในคำอ่าน เจ้าของยังไม่ได้รับภาษา r6.1 หรือ r6.2
