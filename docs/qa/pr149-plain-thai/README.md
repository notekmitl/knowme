# PR149 — ภาษาไทยอ่านครั้งเดียวเข้าใจ · 10 พ.ย. 2026

สถานะก่อนเผยแพร่: local focused checks และ guarded trial build ผ่าน;
รอ CI ของ revision ใหม่และ Hosted QA รุ่นใหม่ **รอผลทดลองอ่าน** จากคนทดลอง
ยังไม่รับรองว่าผู้อ่านเข้าใจแล้วจากการผ่าน tests

## จุดเริ่มและ feedback

ตรวจ GitHub PR #149 และ remote ใหม่แล้ว: OPEN + DRAFT, branch
`codex/three-tradition-overall-v1`, HEAD เริ่มต้น
`1d3b9445e7cf7c34ac19c6e430a1697a0a22a6c2` ไม่มีงานค้างใน checkout `pr149`.
โฟลเดอร์รวมงานเริ่มต้นไม่ใช่ checkout ของแอป จึงใช้ checkout เดิมและ fast-forward
จากรุ่นเดือนกันยายน ไม่มี reset หรือใช้ SHA เก่าทับงานใหม่ อ่าน CURRENT_STATUS,
HANDOFF และ THREE_TRADITION_OVERALL_V1 ก่อนแก้

ผู้ทดลองส่วนใหญ่บอกว่าอ่านยาก เจ้าของต้องการคำง่ายระดับเด็กประถมที่ใช้คุยกับผู้ใหญ่
จุดรับงานคือรู้ว่าข้อความพูดถึงอะไร เกี่ยวกับตนอย่างไร และมีเงื่อนไขใด ไม่ใช่เพียงลดจำนวนคำ

## กติกาภาษาและต้นทาง

- ใช้ “คุณ” และคำพูดทั่วไป หนึ่งประโยคหนึ่งเรื่อง ระบุคนและสิ่งที่ทำ
- บอกความหมายก่อนเหตุผล ตัดคำเปรียบเทียบและประโยคซ้ำที่ไม่เพิ่มความหมาย
- เก็บศัพท์จำเป็นในรายละเอียด พร้อมคำอธิบายสั้น ๆ เช่น ธาตุประจำวัน สี่เสา และเรือน
- คง “อาจ” เงื่อนไข ช่วงปี ช่วงอายุ และคำแนะนำเดิม ไม่สร้างเหตุการณ์ ตัวอย่างเฉพาะตัว หรือคำทำนายทดแทนข้อมูลขาด
- แก้เฉพาะข้อความของ trial หลังผลเดิมเลือกหลักฐานแล้ว ไม่เปลี่ยนวิธีคำนวณ เกณฑ์ 0.6 คะแนน ข้อมูลดวง เงื่อนไขขัดแย้ง หรือ missing-data gate

| ส่วนที่แสดงจริง | แหล่งเดิม | ตำแหน่งแก้เฉพาะ trial |
| --- | --- | --- |
| ฟอร์ม/ข้อมูลไม่ครบ | ThaiBetaInputPage และ selector | ระบุเฉพาะเวลาเกิด/จังหวัดที่ยังขาด ใช้เงื่อนไขเดิม; ข้อความของ build ปกติคงเดิม |
| ดวงรวม/รายละเอียด | ThreeTraditionLifeReadingComposer, BaziReaderV2, WesternNatalLifeSemantics | TrialReadingCopy.overall ที่จุดแสดงผล; source claims และ evidence เดิมไม่ถูกเขียนทับ |
| ไทย hero/สรุป 4 ด้าน | ThaiMirrorEvidenceComposer / consumerViewState | อ่าน template หัวเรื่องครบ 12 แบบแล้วเรียบเรียงโครงประโยคเดิมโดยเก็บ trait ที่เลือกไว้; แก้ย่อหน้า/วลีที่ตรวจบริบทแล้ว |
| ไทยฉบับเต็ม/พิมพ์ | ThaiBetaReportExportDocument.candidate, CoreReading, PredictiveRuntimeV2 | TrialReportDocuments.thai ส่ง document ชุดเดียวให้ SharedReportView และ browser-print sync; IDs/trace/visibility/runtime plan เดิม |
| จีน/เส้นทางชีวิต | BaziCompatibilityReportBuilder, BaziReaderV2/V4, symbolic profile | TrialReportDocuments.chinese เก็บ section/row/ช่วงปีเดิม แก้ข้อความใน paragraph/intro/row/notes; คง Day Master ที่คำนวณได้และอธิบายแทนภาพเปรียบเทียบ |
| ตะวันตก/รายละเอียด | backend astrology/reader.py → chart.reader | TrialReadingCopy.western เฉพาะ WesternReaderBody(trialVisual); ไม่แก้ backend, reader revision, basis, chart หรือ API contract |

ชุดคำ `TrialReadingCopy` เป็นการแก้ clause/template ที่อ่านบริบทและตรวจความหมายแล้ว
ไม่ใช่การแทนคำศัพท์เหมา เช่น แทน “พลัง” ทุกแห่ง ไม่ตีความจากข้อความเพื่อเลือกผลดวงใหม่
แก้แบบ single pass เพื่อไม่ให้ข้อความที่เพิ่งแก้ไปกระตุ้นกฎอื่น และปล่อยข้อความที่ไม่รู้จักไว้ตามเดิม
ไม่เรียก AI หรือบริการใดเพื่อเขียนใหม่ขณะเปิดอ่าน

## หลักฐานย่อหน้าจริงและข้อมูลเดิม

[ตารางก่อน–หลัง 14 ตัวอย่างครบสี่มุมมอง](before-after.md) อ้างจาก
[คำอ่านที่ประกอบจริงทั้งย่อหน้า](assembled-reading-review.json).
ข้อมูลเกิดสังเคราะห์ A/B อยู่ใน `test/fixtures/trial_readability/` พร้อม provenance;
ใช้ `asOf=2026-11-10T03:00:00Z` เดียวกันทั้งก่อน–หลัง

`test/trial_readability_snapshot_test.dart` ตรวจการไม่แก้ source models,
IDs/trace IDs/visibility/known-unknown rules/runtime plan, ตัวเลขและจำนวนคำว่า
“อาจ”, ทุก topic พร้อมฐานดาวและหลักฐานไทย/จีน, รวมถึงคำนวณ comparison ซ้ำแล้วเท่ากัน
ข้อมูล raw calculator ทั้งก้อนเท่าเดิมหลังเรียบเรียง มีกรณีไทยไม่ทราบเวลาและจีนข้อมูลไม่ครบ
การทดสอบ conflict และ threshold ต่ำยังใช้ regression เดิมของ consensus/life-reading/meaning-alignment

ไม่มีการแก้ calculator/adapters/consensus/composers/model/คะแนน/หลักฐาน.
ไฟล์ backend ทุกไฟล์คงเดิม จึงไม่จำเป็นต้อง deploy calculator ใหม่

## Cache และ PDF/Export ในเส้นทางนี้

trial ใช้ผลสอง POST ที่อยู่ในหน่วยความจำ ไม่โหลด saved chart หรือ Firestore cache;
การสลับศาสตร์และเปิดรายละเอียดใช้ผลเดิม ไม่มีการล้างข้อมูลหรือบังคับคำนวณใหม่ทั้งหมด
revision ข้อความคือ `trial_plain_th_20261110_r1`; bundle pin
`trial-plain-th-20261110-r1` เปลี่ยนเฉพาะ entrypoint ของ trial. แท็บที่เปิดอยู่ต้องโหลดหน้าใหม่
เพื่ออ่าน bundle รุ่นใหม่ โดยไม่ไปเปลี่ยน revision/cache ของแอปหลัก

trial ไม่มีปุ่มส่งออก PDF ของจีน/ตะวันตก หรือปุ่ม PDF/capture ของไทย และไม่เพิ่มปุ่มใหม่
แต่ไทยติดตั้ง browser-print document อยู่แล้ว จึงปรับ document ก่อนส่งทั้งให้เว็บและพิมพ์
ตรวจ PDF จริงจาก Chrome และ render ด้วย Poppler; ไม่อ้างว่าได้ทดสอบปุ่มที่ไม่มีใน trial

## ผลตรวจ local และข้อจำกัด

- focused tests แรก 71/71 ผ่าน; รอบสุดท้ายของไฟล์ที่ปรับ 46/46 ผ่าน
- analyzer ตาม policy ของ workflow ผ่าน (0 errors; warnings/infos เดิม 280 รายการ; ไม่มีรายการในไฟล์ใหม่)
- plugin-free isolated release build ผ่าน registrant/bundle/privacy guards ใช้ calculator แยกเดิมเท่านั้น
- Chrome 390×844 (A), 1280×800 (B): ไปฟอร์ม → รวม → ไทย → จีน → ตะวันตก → รวม เปิดรายละเอียดและกลับได้; 2 POST (200) ต่อ journey ไม่มี POST เพิ่ม
- unknown-time 390×844: บอกว่าขาดเวลาเกิดและหยุดก่อนคำนวณ; 0 POST
- ทั้งสาม journey ไม่มี Auth/Firestore SDK/API, Production API, write อื่น, failed request, app error หรือ horizontal overflow
- landing 390×844 ของ build ใหม่เทียบ hosted รุ่นก่อนตรงทุกพิกเซล; ไม่แก้ landing source/ภาพหรือ layout ที่ยอมรับแล้ว
- PDF ไทยจาก Chrome มือถือเป็น 4 หน้า ตรวจภาพ render และข้อความ โดยใช้ print document ชุดเดียวกับเว็บ
- Windows full suite รอบแรกใช้ `TZ=Asia/Bangkok` แบบ Linux แล้วพบ 5 failures เกี่ยวกับเวลา (ค่าเพี้ยน 7 ชั่วโมง/asOf hash); รันซ้ำโดยไม่ตั้ง TZ ของ Linux ใช้ `SE Asia Standard Time` (+07:00) ของ Windows เดิม ผ่าน **3,162 tests, 3 skipped** ใน 2:06 นาที ไม่แก้สูตรหรือ test เพื่อให้ผ่าน

**ข้อที่ยังต้องแยกตรวจโดยไม่เปลี่ยนหลักฐานในงานนี้:** การ์ด “อ่านเร็ว 4 ด้าน” ของไทยบาง input
มีข้อความเดิมที่ไม่ชัดว่าเกี่ยวกับชื่อด้านอย่างไร เช่น fixture B ของ snapshot
การงานแสดง “คุณเปรียบเทียบตัวเลือกก่อนใช้เงินก้อนใหญ่ (ผ่านคิดละเอียด)” และการเงินแสดงข้อความเรื่องงาน
browser fixture B ก็มีข้อความการใช้จ่ายอยู่ใต้การงาน การแก้ให้ใช้หลักฐานของด้านอื่น
จะเปลี่ยนเกณฑ์เลือกคำอ่านที่ Owner สั่งให้รักษา จึงคง selection เดิมและบันทึกเป็นงานตรวจหมวด/หลักฐานแยก
ไม่เพิ่มความหมายเรื่องงานหรือเงินเพื่อทำให้ดูเข้ากัน ไม่มีการอ้างว่า correctness ของเนื้อหาส่วนนี้ผ่านแล้ว

## เผยแพร่และ rollback

ได้รับอนุญาตให้อัปเดต trial เดิมตาม Owner authorization ที่ยังมีผล ไม่ Merge PR #149.
ตรวจล่าสุดว่ามีเพียง site หลัก `knowme-app-694e1` กับ USER_SITE
`knowme-trial-694e1`; trial ก่อนแก้ยังเป็น release `1793599203756000` /
version `c0ad58f8d39f8731`. calculator ยังคง revision
`knowme-overall-pr149-preview-00004-kt9`. คำสั่งและสิทธิ์อ่าน Hosting ใช้งานได้

จะ deploy หลัง CI revision ใหม่ผ่าน โดย config มีเพียง Hosting และ site เป็น
`knowme-trial-694e1` เท่านั้น เก็บ hash เว็บหลักก่อน–หลังและตรวจ hosted hashes/reload/journey ใหม่
rollback ที่เตรียมไว้: clone version `c0ad58f8d39f8731` กลับ **เฉพาะ trial site**;
ทางหยุด trial ใช้ holding page/config เดิมใน `../pr149-trial-site-release/rollback`.
ไม่เปลี่ยน CORS/backend/IAM/Auth/Firestore/billing หรือ Hosting หลัก

ยังไม่เผยแพร่ revision นี้ ณ ตอนเขียนส่วนนี้ จะเพิ่มผล release และ CI ตามจริงเมื่อเสร็จ
