# PR #149 · r5.1 แก้กรอบคำแนะนำสองจุด

ผู้ตรวจพบว่าคำแนะนำการเงินใน r5 มีเงื่อนไขเรื่องขยายแผนที่ตัวประกอบเติม และย่อหน้าแรกของการดูแลตัวเองทำให้ข้อสังเกตของไทยดูเป็นคำแนะนำ เจ้าของยังไม่ได้ตัดสินภาษา r5 และ r5.1 ยังรอเจ้าของทดลองอ่าน [ก่อน–หลังและต้นทาง](READINGS.md) · [PR #149](https://github.com/notekmitl/knowme/pull/149)

## ผลตรวจ

- Flutter regression ใหม่จับกรอบทั้งสองบน r5 เดิมได้ และชุดที่เกี่ยวข้องผ่าน 65 รายการหลังแก้ ครอบคลุม A/B, owner-wording, การเงินทั้งสองแขนง และดาวเจ้าเรือนทั้งเจ็ดแบบ [ก่อน–หลังของแขนงอื่น](branch-readings.json)
- เทียบ A/B ที่วันอ้างอิงเดียวกัน ผลดวงที่เลือก หลักฐาน หมวด ข้อมูลไม่ครบ ข้อขัดแย้ง และคำอ่านรายศาสตร์ตรงกับ r5 คำอ่านการงานและความสัมพันธ์ตรงกันทุกย่อหน้า [ผลเทียบข้อมูล](evidence-parity.json)
- Application `52c007b` ผ่าน isolated trial build, Flutter validation และ backend validation ก่อนเผยแพร่เวลา 16:09:57 น. กรุงเทพฯ ไปยัง site `knowme-trial-694e1` ที่ version `8934e10662a0a374` [CI](https://github.com/notekmitl/knowme/actions/runs/43187590598) · [สิทธิ์ Hosting](hosting-permissions.json)
- Chromium ที่ 390×844, 1280×800 และ 1920×911 ตรวจข้อความจริงในสถานะยุบ ขยาย และยุบกลับ ครบทุกหัวข้อ ข้อความอยู่ในความกว้างเดิมและมีย่อหน้าห่างกันตาม r5 ข้อความเอกสารพิมพ์ไทยจาก DOM ตรงกับหลักฐานเดิม 46 ย่อหน้า [ผลปลายทาง](release-summary.json)
- ทราบเวลาเกิดใช้ 2 POST ต่อรอบ ไม่ทราบเวลาเกิดใช้ 0 การเปิด–ยุบและสลับแท็บใช้ผลเดิม ทั้งหกรอบไม่พบ Auth, Firestore, Production API หรือการเขียนข้อมูลอื่น [ผลปลายทาง](release-summary.json)
- Browser โหลด pin `trial_plain_th_20261112_r5_1` และ hash ตรงกับ build ที่เผยแพร่ เว็บหลัก version `d32e72678324e634` และเครื่องคำนวณ trial revision `knowme-overall-pr149-preview-00004-kt9` ตรงกับก่อนเผยแพร่ [hash ปลายทาง](hosted-hashes.json)

## ย้อนกลับไป r5

ใช้คำสั่งนี้เพื่อคืน version `59ab457cfafda774` เฉพาะ trial แล้วเทียบ hash ปลายทางกับ [หลักฐาน r5](../pr149-r5-overall/hosted-hashes.json)

```powershell
firebase hosting:clone knowme-trial-694e1@59ab457cfafda774 knowme-trial-694e1:live --project knowme-app-694e1 --non-interactive
```
