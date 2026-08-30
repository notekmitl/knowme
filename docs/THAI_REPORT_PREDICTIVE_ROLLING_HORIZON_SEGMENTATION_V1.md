# Thai Report Predictive Rolling Horizon Segmentation V1

สถานะ: **OR3 DESIGN VERIFIED — NO RUNTIME AUTHORIZATION**

## Defect in Rulebook V1

V1 ใช้ `currentAge + 1` เป็น Annual Taksa age ของ `next12Months` ทั้งช่วง จึงนำผลหลังวันเกิดไปกล่าวเหมือนครอบคลุมช่วงก่อนวันเกิดด้วย การคำนวณนี้ไม่ถูกต้องสำหรับ rolling horizon ที่คร่อมวันเกิด

## Correct segmentation

ให้ `H0` เป็นวัน `asOf` แบบ civil date ใน Asia/Bangkok และ `H1` เป็นวันก่อนวันเดียวกันของปีถัดไป

```text
nextBirthday = first normalized birth-month/day strictly after H0
Segment A.start = H0
Segment A.end = min(H1, nextBirthday - 1 day)
Segment A.age = ageAt(Segment A.start)
Segment A.annualTaksa = AnnualTaksa[Segment A.age]

if nextBirthday <= H1:
  Segment B.start = nextBirthday
  Segment B.end = H1
  Segment B.age = Segment A.age + 1
  Segment B.annualTaksa = AnnualTaksa[Segment B.age]
```

วันที่ 29 กุมภาพันธ์ใช้ anniversary ที่ `DateTime(year, 2, 29)` normalize ตาม engine เดิม จึงเปลี่ยนอายุวันที่ 1 มีนาคมในปีที่ไม่มีวันที่ 29 กุมภาพันธ์ ห้ามสร้าง convention ใหม่เฉพาะ narrative

## Required segment trace

แต่ละ segment ต้องเก็บข้อมูลต่อไปนี้ใน design trace หากมี implementation ภายหลัง

| Field | Contract |
|---|---|
| exact start/end | วันแรกและวันสุดท้ายแบบ inclusive |
| age | อายุที่ `LifePeriodEngine.ageFrom` คืน ณ segment start |
| annual Taksa | `AnnualTaksaYear` ของอายุนั้น รวม house, boriwan planet, `roleByPlanet` |
| overlap duration | จำนวนวัน inclusive |
| source trace | birth date, asOf, anniversary rule, annual age, source engine paths |
| eligible atoms | เฉพาะ atom ที่ rule ระบุ segment และใช้ Annual Taksa ของ segment นั้น |
| conflict/merge | แก้ conflict ภายใน segment ก่อน แล้วจึงรวม semantic owner ข้าม segment |

Atom ของ Segment B ห้ามอ้างว่าครอบคลุม Segment A หาก movement เหมือนกันทั้งสอง segment จึงรวมเป็น rolling-horizon paragraph เดียวได้ แต่ trace ต้องเก็บ A และ B แยก หาก atom มีเฉพาะ segment เดียวแต่ rule ไม่มี vocabulary/timing authority สำหรับช่วงย่อย ให้ omit atom นั้นจาก reader copy แทนการใช้คำว่า ต้น/กลาง/ปลาย ครึ่งแรก/ครึ่งหลัง หรือเดือน

`monthlyTimelineAvailable=false` ยังคงเป็นข้อบังคับ

## Owner fixture 00:03

`asOf=2026-08-29`, วันเกิด 6 มิถุนายน 1982:

| Segment | Boundary | Days | Age | Annual role of current Venus period |
|---|---|---:|---:|---|
| A | 2026-08-29 – 2027-06-05 | 281 | 44 | อุตสาหะ |
| B | 2027-06-06 – 2027-08-28 | 84 | 45 | มูละ |

ดังนั้น atom ที่ต้องการ role อุตสาหะมีสิทธิ์เฉพาะ Segment A และ atom ที่ต้องการ role มูละมีสิทธิ์เฉพาะ Segment B การใช้ age 45/Mula กับทั้ง 365 วันเป็น defect

## Population verification

ใช้ `ThaiBetaSyntheticMatrix.build()` seed `20260803`, `asOf=2026-08-03`: 300/300 profiles มี coverage ต่อเนื่อง ไม่มี gap/overlap, segment count 1–2, age transition ถูกต้อง และ Annual Taksa trace มีครบ Known 225/Unknown 75 การผ่านนี้ยืนยัน algorithmic boundary เท่านั้น ไม่ยืนยันความหมายหรือความแม่นของ event prediction
