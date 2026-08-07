# Task: Thai Consumer Narrative Voice V1

ปรับภาษารายงาน Thai Beta ให้เป็นภาษาไทยธรรมชาติ ตรง ชัด และเป็นมิตร โดยแก้
เฉพาะ narrative composition บนข้อมูลคำนวณเดิม ไม่เปลี่ยน Engine, Canon,
Birth Normalization, province resolver, evidence semantics, Timeline ranges,
feature flags, routes หรือ Production configuration

งานใช้ base ที่ยอมรับแล้ว
`4f6aa81fdb8be1d254f21dc3816104cef3252f77` และจบที่ Draft PR เท่านั้น
Web/PDF ต้องใช้ shared document เดียวกัน, output ต้อง deterministic,
หนึ่ง public paragraph ต้องคง provenance ตาม contract เดิม และ unknown-time
ต้อง fail closed

## Fixture separation

- ผู้ใช้รอบนี้: `1982-06-06 00:03`, Chiang Mai (`Asia/Bangkok`,
  `18.7883, 98.9853`) ต้องคง input `00:03` และ Engine/Web/PDF แสดง Aquarius
  `9°24′` ตรงกัน
- regression fixture เดิม: วันและจังหวัดเดียวกันแต่ `00:35` ต้องคง Aquarius
  `19°19′`
- ห้ามเปรียบเทียบค่าจากสองเวลาแล้วสรุปว่าเป็น Ascendant regression
- unknown-time ต้องไม่ใช้ `12:00` ทดแทนและต้อง omit ข้อมูลที่ไม่มีหลักฐาน

Product Acceptance ต้องมี known/no-time Web/PDF, before/after, Desktop/Mobile,
PDF renders ทุกหน้า และผล tests/gates จริงจาก source-tested commit ห้าม Merge
หรือ Deploy
