# PR149 — trial r3: หมวดถูกต้องและความหมายตรงต้นฉบับ

เผยแพร่เฉพาะ [trial เดิม](https://knowme-trial-694e1.web.app/beta/thai) เมื่อ 10 พ.ย. 2026 เวลา 17:45 น. (Bangkok).
Application `1607cdca7d03e4b36d9ecc152bc8dbe324e66ee1`, ภาษา/entry pin `trial_plain_th_20261110_r3`.
Hosting release `1794307511201000`, version `85ab0ab69785f974`.
[CI application](https://github.com/notekmitl/knowme/actions/runs/42800196340) ผ่านทุก job รวม backend, analyzer, Web builds, isolated plugin-free trial build และ Flutter suite เต็มก่อน deploy.
PR149 ยังคง Draft ไม่ Merge. เอกสาร/หลักฐานที่ commit ตามหลังไม่เปลี่ยน application; checks ของ HEAD ล่าสุดดูใน PR.

## สิ่งที่พิสูจน์และซ่อม

[การตรวจความหมาย 23 ตัวอย่างทั้งย่อหน้า](REVIEW.md) ครบผลรวม ไทย จีน ตะวันตก พร้อมต้นทางและเงื่อนไข/คำแนะนำ.
[ผลที่ประกอบจริงทั้งหมด](assembled-reading-review.json) ใช้ input/as-of เดียวกับหลักฐาน r2: A 2001-01-15 12:34 Bangkok, B 1990-05-12 08:15 Chiang Mai, หญิง, as-of `2026-11-10T03:00:00Z` และ unknown-time.

[Regression ก่อนแก้](regression-before.txt) แดงครบสี่การ์ด UI ของ B. ตัวเลือกสำรองอ้าง field คนละหมวด ก่อนถึง UI: work→money, money→work, love→health, health→love, luck→work. ลำดับหัวข้อและการแปล r2 ไม่ใช่ต้นเหตุ.
เพิ่ม metadata ของแหล่งข้อความที่เลือก แล้ว trial ใช้ field ของหมวดที่ร้องขอในธีมเดิม. ไม่เดาหมวดจากคำ ไม่แต่งคำอ่านใหม่ ไม่ย้ายธีม/หลักฐาน และไม่เปลี่ยนสูตรเลือกผล.

Frozen baseline `test/fixtures/trial_readability/dashboard-before-6261951.json` ถูก capture ก่อนแก้ source. Tests เทียบ snapshot/hash/raw cards และทั้ง 57 ธีม × 5 หมวดพร้อมลำดับ/deduplication กับฐานนี้. A ทั้งห้าการ์ดที่ถูกอยู่แล้วตรง r2, B ธีมเดิมทั้งห้า, unknown ไม่มีการ์ดทดแทนข้อมูลที่ขาด. ทดสอบ duplicate fallback ว่า metadata ตรงกับข้อความที่เลือกจริง.
Raw legacy pool/view ยังอยู่เหมือนเดิมเพื่อคงผลเลือกและผู้ใช้ส่วนที่อยู่นอก trial. การซ่อม field binding จำกัดที่ projection ของ trial. รายละเอียด/เอกสารไทยใช้ narrative composer อีกเส้นทาง ซึ่งตรวจแยกโดยไม่เปลี่ยน logic.

แก้เกณฑ์จบงานให้หมายถึงสิ่งที่ต้องทำครบ และคงเพียงความเป็นไปได้ว่างานที่รับเพิ่มอาจกระจัดกระจาย ไม่เพิ่มผลว่าไม่มีงานใดเสร็จ. คืนขอบเขต “แผน” ความรู้ และการพัฒนาความสัมพันธ์ตามต้นฉบับ. ลดคำลอย/คำเชื่อมซ้ำ. ตรวจจริงพบ single-pass clause overlap ขวางวลีถัดไป จึงแก้ขอบเขตและเพิ่ม assertions จาก Western B การงาน / A ความสัมพันธ์ เพื่อคงภาษา r2 ที่ดีอยู่แล้ว.

## ผลตรวจ

- Focused regression/consensus/selection/date gates ผ่าน 53 tests; final assembled/domain regressions ผ่าน 8 tests. Analyzer gate 0 errors. Initial local full suite 3,167 passed / 3 skipped / PDF test หนึ่งตัวขาด pypdf ใน system Python; rerun PDF file ด้วย bundled Python ผ่าน 4 tests. Final application CI ผ่าน suite เต็ม.
- [Source integrity](source-integrity.json): calculator/model/composer/evidence source 14 พื้นที่ไม่เปลี่ยน. ข้อมูลดวง, confidence, selected evidence, gaps และ conflicts เท่ากับหลักฐาน r2 ด้วย input/as-of เดียวกัน. ไม่ได้อ้างความหมายจากจำนวน “อาจ” หรือเลขเพียงอย่างเดียว.
- [Release summary](release-summary.json): live 390×844 Chrome และ 1280×800 CPU fallback ผ่านการอ่านทั้งสี่มุมมองและรายละเอียด. ทุกขั้นกว้างเท่า viewport ไม่มี horizontal overflow. Known time 2 calculator POST (200) รวมต่อ journey; สลับศาสตร์/เปิดรายละเอียดไม่เพิ่ม. Unknown time ทั้งสองขนาด 0 POST. ไม่มี Auth/Firestore/Production API, write อื่น, app error หรือ failed request.
- [PDF parity](pdf-parity.json): ไทยสองไฟล์ ไฟล์ละ 4 หน้า/46 ย่อหน้า; DOM paragraphs ตรงกับ assembled document ทุกย่อหน้าและเรียงเหมือนกัน. Render Poppler ตรวจภาพครบ 8 หน้า ไม่มีข้อความล้น/ซ้อน/หาย. Chrome ToUnicode ของอักขระไทยบางตัวให้ NUL จึงเทียบ presence โดย normalize combining marks ร่วมกับ exact DOM และการตรวจภาพ ไม่อ้างว่า raw extracted Unicode ตรงทุกตัว.
- คำอ่าน Western ที่แสดงจริงทั้ง 8 หัวข้อตรงกับ assembled fixture ทั้ง A/B; Chinese paragraphs ตรง 8/8 ทั้งสองเคส. Canvas ของหน้าผลรวมไม่ได้ส่ง paragraph text เข้า DOM semantics จึงใช้ assembled source และภาพที่เปิดรายละเอียดตรวจร่วมกัน ไม่ใช้ flattened DOM เป็นหลักฐานจับคู่การ์ด.
- [Cache reload](cache-reload.json): context ที่เปิด r2 ค้างอยู่ reload ปกติได้ r3 ไม่ clear storage/cache และ 0 calculator POST. หน้าแรก mobile และ PC เทียบภาพ r2 เหมือนทุกพิกเซล. [Hosted hashes](hosted-hashes.json) ตรง final build ทั้งสาม entry files; headers/rewrites เท่าเดิม.
- เว็บหลัก release `1790074568414000` / version `d32e72678324e634` และ [entry hashes/headers](main-after.json) เท่าเดิม. Calculator ยังคง `knowme-overall-pr149-preview-00004-kt9`.
- [Permission probe](hosting-permissions.json) เป็น read-only testIamPermissions ของ account เดิม ไม่เปลี่ยน IAM policy/Auth. Deploy config มีเพียง Hosting target trial → knowme-trial-694e1 ใน project knowme-app-694e1. ไม่แก้ backend/Auth/Firestore/IAM/billing ไม่เพิ่มบริการหรือ runtime AI.

`journey.py` บันทึก input, requests, expanded details, screenshots และ browser-print document. Default ใช้ calculator trial จริง. `--fixture-calculators --no-pdf` ใช้ replay chart fixtures เดิมได้เพื่อช่วยตรวจ layout; ไม่ใช้ผล replay อ้าง network/privacy ของ real journey. การจับคู่ทั้งสี่การ์ดพิสูจน์ด้วย widget keys ใน regression ก่อน–หลังและภาพ Thai overview; ไม่ใช้ลำดับปุ่มใน DOM หรือชื่อไฟล์ screenshot เป็นตัวแทนหมวด. ข้อความผลรวมครบสี่ด้านตรวจจาก assembled paragraphs; ภาพเปิดรายละเอียดเก็บเคสย่อหน้าการงานที่ยาวที่สุด และตรวจพื้นที่อ่านด้วย scroll ตามปกติ.

## Rollback เฉพาะ trial

กลับ r2 ที่เป็น live ก่อนงานนี้ (ไม่แตะเว็บหลักหรือ backend):

```powershell
firebase hosting:clone knowme-trial-694e1@fbbc0bf77cbda8ff knowme-trial-694e1:live --project knowme-app-694e1 --non-interactive
```

หลัง rollback ตรวจ release/version และ entry hashes เทียบหลักฐาน r2. ไม่ล้างข้อมูลผู้ใช้หรือบังคับคำนวณใหม่ทั้งหมด.

โปรแกรมและความหมายผ่านการตรวจตามหลักฐานข้างต้น. **รอผลทดลองอ่าน** จากผู้ทดลองรุ่นใหม่ ยังไม่อ้างว่าผู้ใช้เข้าใจแล้วจาก tests. ไม่มี blocker ด้านเครื่องมือ/สิทธิ์ในขอบเขต trial นี้.
