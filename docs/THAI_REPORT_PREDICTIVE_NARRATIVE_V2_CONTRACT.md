# Thai Report Predictive Narrative V2 — Narrative Contract

สถานะ: **PROPOSED CONTRACT FOR NEXT IMPLEMENTATION PHASE**

OR1 amendment: Candidate 0003 ถูก Owner ปฏิเสธและห้ามใช้เป็น implementation/expected-output target Prediction ที่เป็น event ต้องมี `PredictiveEvidenceAtom` ตาม Evidence Contract V1 ไม่ใช่อาศัย theme, score band, narrative motif หรือชื่อช่วง Golden เป็น style target เท่านั้น

OR2 amendment: Owner selected Option B Candidate 0004 is content direction only Candidate 0005 maps every prediction to Product Rulebook V1 Rules labeled `OWNER_APPROVED_PRODUCT_INFERENCE` remain prohibited from runtime until explicit Owner rule approval

## 1. Chronological order

Reader-facing report ต้องเรียง: birth input → overview → past periods → current period → rolling 12 months → next life period → summary → source and one disclaimer ไม่ย้อนกลับไปเปิด current claim ใหม่หลัง next-life section

## 2. Section ownership

- Birth facts เป็นเจ้าของวัน เวลา สถานที่ Thai-day basis และ ascendant
- Past section เป็นเจ้าของเฉพาะ past evidence
- Current section เป็นเจ้าของ current forecast และ advice ของ current เท่านั้น
- Rolling 12-month section เป็นเจ้าของ `next12Months` material เท่านั้น
- Next-life section เป็นเจ้าของ future life-period facts และ `nextLifePeriod` material
- Summary ย่อ claim ที่มีอยู่แล้ว ห้ามเพิ่ม claim ใหม่
- Methodology and limitations อยู่ท้ายรายงาน

## 3. Prediction-first ordering

ทุก domain block ต้องเรียง `Prediction` ก่อน `Advice` Prediction บอกทิศทางหรือผลตาม evidence atom Advice บอกการกระทำที่ตอบสนองต่อ risk หรือ decision plan ห้ามใช้ advice แทน prediction

## 4. Advice boundary

Advice ต้องผูกกับ `ForecastDecisionPlan` หรือ evidence boundary ที่ระบุได้ ไม่เพิ่มเหตุการณ์ ความหมาย ระดับความแน่นอน หรือผลลัพธ์ใหม่ Advice ทางสุขภาพต้องไม่เป็นคำวินิจฉัย และ advice ทางการเงินต้องไม่เป็นคำรับรองผลตอบแทน

## 5. Direct-language rules

Prediction body ใช้ประโยคบอกเล่าที่สั้น ชัด และระบุ horizon หลีกเลี่ยงภาษาระบบ คำนามซ้อน และการโยนภาระให้ผู้อ่านวิเคราะห์แทนระบบ

คำต่อไปนี้ห้ามใช้เป็นค่าเริ่มต้นใน Prediction body:

- `อาจ`
- `ลอง`
- `ลองย้อนดู`
- `ลองนึก`
- `จำได้ไหม`
- `ให้ดูว่า`
- `ให้สังเกต`
- `ทบทวน`
- `เช็กว่าหรือไม่`
- `ไม่ใช่ข้อสรุปว่าเหตุการณ์ใดเคยเกิดขึ้น`

คำเงื่อนไขใช้ได้เมื่อเป็นเงื่อนไขข้อมูลจริง เช่น Known time, Unknown time, คนมีคู่ หรือคนโสดที่ระบบได้รับสถานะนั้นจริง ห้ามใช้เงื่อนไขเพื่อหลบการทำนาย

Prediction body ของ Candidate target ใหม่ห้ามใช้ `หาก`, `ตราบใด`, โครงสร้าง `จะ + ผลลัพธ์ + ได้เมื่อ`, `เช็ก`, `ทบทวน` และ `สังเกต` ด้วย ยกเว้นคำอธิบาย input branch นอก prediction body

## 6. Past prediction rules

- ชื่อดาว ชื่อช่วง และ age range เขียนเป็น fact ได้
- เหตุการณ์อดีตต้องมี past-event evidence atom และ provenance ที่ตรวจได้
- ห้ามถามให้เจ้าชะตายืนยันความทรงจำเพื่อทำให้ข้อความดูแม่น
- ห้ามอนุมาน event count, family context, relationship ending หรือ financial disruption จาก archetype label
- หากมีเพียง life-period fact ให้เขียนเฉพาะ theme ของช่วงโดยไม่แต่งเหตุการณ์

## 7. Psychology boundary

รายงานโหราศาสตร์ไม่ใช้บุคลิกเป็นเนื้อหาหลัก ลัคนาและ house facts แสดงได้ใน birth basis หรือ source section การสรุปนิสัย แผลใจ survival pattern หรือ self-concept ต้องอยู่ในผลิตภัณฑ์ psychological report หรือมี contract แยกที่ Owner อนุมัติ

## 8. Semantic deduplication

หนึ่ง semantic claim มี owner horizon เดียว Detail อธิบาย claim ได้หนึ่งครั้ง Advice อ้าง consequence ได้แต่ห้าม paraphrase prediction เดิมใน section อื่น Dedupe ต้องใช้ semantic key หรือ material projection ไม่ใช่ string similarity อย่างเดียว

## 9. Summary/detail relationship

Summary ต้องย่อ primary movement, boundary และ next transition จาก detail ที่แสดงแล้ว ทุกประโยคใน summary ต้อง map กลับไปยัง detail claim อย่างน้อยหนึ่งรายการ ห้ามเพิ่มเหตุการณ์หรือ certainty ใหม่

## 10. Infographic relationship

Infographic เป็น concise projection ของ rolling 12-month section ใช้ material และ date range เดียวกับ Web, Dedicated PDF และ browser print ห้ามสร้าง month cards, good months, caution months หรือ three-part timing เมื่อ `monthlyTimelineAvailable=false`

## 11. Known/Unknown evidence boundary

- Known ใช้ time-dependent material ได้เมื่อ fingerprint และ source ownership ยืนยัน
- Unknown ใช้เฉพาะ material ที่ `e=noLagna`, `td=false` และ source ownership ไม่พึ่งลัคนาหรือเรือน
- Unknown ต้องเว้น Thai-day assertion, ascendant, houses และตำแหน่งที่ต้องใช้เวลาเกิด
- Known copy ห้ามรั่วเข้า Unknown ผ่าน fallback หรือ shared template

## 12. One-disclaimer rule

รายงานมี disclaimer รวมหนึ่งตำแหน่งท้ายรายงาน Health block อาจมี safety sentence เฉพาะทางการแพทย์ได้หนึ่งครั้ง แต่ห้ามทำซ้ำ general uncertainty ในทุก section

## 13. Reader-visible birth-input traceability

หัวรายงานต้องแสดงวัน เวลา สถานที่ เพศเมื่อมีข้อมูล Thai-day basis และ ascendant เฉพาะ Known Unknown ต้องแสดงว่าไม่ทราบเวลาเกิดและสิ่งที่ระบบเว้น ค่าแสดงผลต้องมาจาก normalized input และ calculated profile เดียวกับ export

## 14. No hardcoded fixture copy

ห้าม branch ด้วยชื่อ fixture, วันเกิด, เวลา 00:03, พิกัด หรือ expected degree ข้อความต้องประกอบจาก typed evidence และผ่าน variant tests อย่างน้อย Known 00:03, Known 00:35, Unknown และ population audit

## 15. Acceptance invariants

- Same narrative order and semantic content across Web, infographic projection, Dedicated PDF and browser print
- Prediction and advice roles remain distinguishable in structured data
- Every prediction has a source path and evidence key or is explicitly a life-period fact
- Event prediction has a typed atom, approved calculation method, boundary, event family, outcome and provenance; a band or prose source is insufficient
- Unsupported Golden paragraphs remain blocked until a separate evidence contract is accepted
- `monthlyTimelineAvailable=false` remains authoritative until a new calculation contract passes Owner review
