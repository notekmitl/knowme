# Thai Report Predictive Narrative V2 — Gap Report

## Conclusion

Golden Reference ผ่านในฐานะมาตรฐานการเล่า แต่ยังนำไปใช้ตรงตัวไม่ได้ Current engine รองรับข้อมูลเกิด ลำดับ life period และ forecast band ระดับโดเมนในสาม horizon ระบบยังไม่รองรับเหตุการณ์เฉพาะในอดีต เหตุการณ์ที่ผูกกับสถานะความสัมพันธ์ แหล่งรายรับหรือรายจ่ายเฉพาะ และช่วงต้น กลาง ท้ายของ 12 เดือน

Evidence Matrix มี 39 ย่อหน้า: `SUPPORTED` 1, `SUPPORTED_WITH_REWRITE` 18, `REQUIRES_NEW_EVIDENCE` 18 และ `MUST_NOT_IMPLEMENT` 2

## Root cause ของรายงานปัจจุบัน

1. `ThaiBetaReportExportDocument` เรียง Core Reading ก่อน timeline แล้วแยก current life-period กับ current forecast เป็นสองชุด จึงเกิดการกระโดดและความหมายซ้ำ
2. `ThaiBetaPastReflection` ถูกออกแบบให้ถามความทรงจำตาม age band โดยตรง จึงไม่ใช่เครื่องมือสร้างคำทำนายอดีต
3. `ForecastMaterialFingerprint` มีเพียง horizon, domain, band, risk, availability และ transition flag ไม่มี event atom หรือ calendar bucket ภายในปี
4. `ThaiBetaReportNarrativePlan` จัด primary และ secondary motif เพื่อช่วยตัดสินใจ แต่ไม่ใช่ event-prediction planner
5. `ThaiBirthProfileCoreReading` วางลัคนา เจ้าเรือน และ house-derived personality framing ไว้ต้นรายงาน จึงทำให้บุคลิกแทรกเป็นเนื้อหาหลักก่อน timeline
6. `ThaiBetaReaderCopyRepair` เป็น replacement layer สำหรับ polish และ parity ไม่สามารถแก้ section ownership, chronology หรือสร้าง evidence ใหม่
7. life-period composers ให้ชื่อช่วง ดาว ธาตุ และความหมายกว้าง แต่ไม่ยืนยันว่าเหตุการณ์เฉพาะเกิดขึ้นจริง
8. Infographic เป็น projection ของ `next12Months` และคง `monthlyTimelineAvailable=false`; ไม่มีข้อมูลรองรับช่วงต้น กลาง และท้าย
9. Unknown boundary ทำงานถูกต้องอยู่แล้ว: ตัดลัคนา เรือน วันทางโหราศาสตร์ และ material ที่ต้องใช้เวลาเกิดออกแทนการเดา

## Golden content ที่ current engine ยังสร้างไม่ได้

### Past events

- G04, G06–G09: กฎในบ้าน ความรับผิดชอบเร็ว การเปลี่ยนแวดวง เหตุการณ์นับครั้ง การจบหรือเปลี่ยนความสัมพันธ์ งาน หรือฐานะ
- ต้องมี evidence contract ที่ระบุ event family, affected domain, period boundary, strength, provenance และข้อจำกัดอย่างชัดเจน
- ห้ามสรุปเหตุการณ์ย้อนหลังจากชื่อดาวหรือชื่อช่วงเพียงอย่างเดียว

### Psychology statements outside the astrology-report boundary

- G05 และ G10 ต้องไม่ implement ในรายงานนี้
- การเอาตัวรอด การพึ่งพาตัวเอง คนที่เหมาะ และภาระที่ควรแบกเป็นข้อสรุปเชิงบุคลิกหรือ self-analysis เมื่อไม่มี evidence atom เฉพาะ

### Current and domain-specific events

- G03, G12, G14, G17, G21 และ G25 ต้องการ age subrange, event source, relationship-status input, expense category หรือ encounter/opportunity evidence
- Forecast band ระดับ strong หรือ active ไม่เพียงพอสำหรับการอ้างว่าจะมีเงินก้อน คนแนะนำ งานเก่ากลับมา หรือคนเข้ามาจากงาน

### Within-year chronology

- G27–G32 และ G38 ต้องการ calculation contract สำหรับช่วงภายในปี
- Contract ขั้นต่ำต้องให้ deterministic bucket boundary, source calculation, supported domains, event or tendency atom, confidence, traceability และ Known/Unknown availability
- ตราบใดที่ contract นี้ไม่มี ระบบต้องแสดงเพียงช่วง `29 ส.ค. 2569 – 28 ส.ค. 2570` รวม และคง `monthlyTimelineAvailable=false`
- ห้ามสุ่มเดือน วัน เหตุการณ์ หรือบังคับ output ให้ตรง Golden fixture

## Golden content ที่นำมาใช้ได้เมื่อ rewrite

- ลำดับ life period: Saturn 1–10, Jupiter 11–29, Rahu 30–41, Venus 42–62, Sun 63–68
- Current age 44 และตำแหน่งต้นรอบ Venus
- Career as primary decision domain
- Current and next-12-month strong material for work, finance, relationship and health
- Next-life material: career strong, finance active, relationship quiet, health active
- Quality-versus-load, available-cash, agreement consistency and recovery-time boundaries
- One rolling 12-month date range without monthly or three-part event timing

## Fixture separation

- 00:03 และ 00:35 ผ่าน regression เดียวกันแต่เป็นคนละ fixture identity
- 00:03 ให้ Aquarius 9°24′ และใช้ทำ Full Candidate
- 00:35 ให้ Aquarius 19°19′ และใช้เป็น canonical regression เท่านั้น
- Unknown ไม่รับมรดกข้อความจาก Known และไม่แทนเวลาเกิดด้วย noon

## Phase 1 disposition

Candidate เลือกเฉพาะ fact และ forecast material ที่มีอยู่จริง รายการที่ขาดถูกบันทึกในเอกสารนี้และ Matrix ไม่มี placeholder ใน Candidate ไม่มี hardcoded runtime copy และไม่มีการแก้ engine, generator, UI, export, test หรือ artifact
