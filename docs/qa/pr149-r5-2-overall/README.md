# PR #149 · r5.2 ปรับคำอ่านตามความเห็นเจ้าของ

เจ้าของอ่าน r5.1 แล้วบอกว่า “เริ่มดีขึ้นเยอะ แต่ยังต้องปรับบางข้อความ” รอบ r5.2 แก้ถ้อยคำที่ระบุบนดวงรวม ใช้การจัดหน้าเดิม และยังรอเจ้าของทดลองอ่าน [ก่อน–หลังและต้นทาง](READINGS.md) · [PR #149](https://github.com/notekmitl/knowme/pull/149)

## ผลตรวจ

- Flutter regression ที่เกี่ยวข้องผ่าน 65 รายการ ครอบคลุม A/B, owner-wording, การเงินสองแขนง, ความสัมพันธ์ true/false/null และข้อความที่ใช้ร่วมกันจากดาวเจ้าเรือนและราศีต่าง ๆ [ผลประกอบแขนงอื่น](branch-readings.json)
- ผลดวงที่เลือก หลักฐาน หมวด ข้อความ raw/non-trial ข้อความรายศาสตร์ กรณีข้อมูลไม่ครบ และผลขัดแย้งตรงกับ r5.1 ที่วันอ้างอิงเดียวกัน [ผลเทียบข้อมูล](evidence-parity.json)
- Application `43a7698` ผ่าน isolated trial build, Flutter validation และ backend validation ก่อนเผยแพร่เวลา 17:17:42 น. กรุงเทพฯ ไปยัง Hosting site `knowme-trial-694e1` version `8e1873a271b61a58` [CI](https://github.com/notekmitl/knowme/actions/runs/43197157492) · [สิทธิ์ Hosting](hosting-permissions.json)
- ตรวจ Chromium ปลายทางจริงที่ 390×844, 1280×800 และ 1920×911 เปิด–ยุบตรงหัวข้อ ข้อความครบและคอลัมน์กว้างเท่าเดิม เอกสารพิมพ์ไทยจาก DOM ตรงกับ r5.1 ทั้ง 46 ย่อหน้า [ผลปลายทาง](release-summary.json)
- ทราบเวลาเกิดใช้ 2 POST ต่อรอบ ไม่ทราบเวลาใช้ 0 การเปิด–ยุบ สลับแท็บ และเปิดรายละเอียดใช้ผลเดิม ทั้งหกรอบไม่พบ Auth, Firestore, Production API หรือการเขียนข้อมูลอื่น [ผลปลายทาง](release-summary.json)
- Browser โหลด pin `trial_plain_th_20261112_r5_2` และ hash ตรงกับ build ที่เผยแพร่ เว็บหลัก version `d32e72678324e634` และเครื่องคำนวณ trial revision `knowme-overall-pr149-preview-00004-kt9` ตรงกับก่อนเผยแพร่ [hash จากปลายทาง](hosted-hashes.json)

Chromium แบบ CPU ที่ 390×844 จับภาพหน้าแรกโดยภาพประกอบยังไม่ขึ้นในรอบแรก ตรวจซ้ำด้วยโหมดและขนาดเดิมผ่าน ภาพประกอบใน build ตรงกับ r5.1 [ผลตรวจซ้ำ](release-summary.json)

## ย้อนกลับไป r5.1

ใช้คำสั่งนี้เพื่อคืน version `8934e10662a0a374` เฉพาะ trial แล้วเทียบ hash กับ [หลักฐาน r5.1](../pr149-r5-1-overall/hosted-hashes.json)

```powershell
firebase hosting:clone knowme-trial-694e1@8934e10662a0a374 knowme-trial-694e1:live --project knowme-app-694e1 --non-interactive
```
