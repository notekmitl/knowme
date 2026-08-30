# Thai Report Predictive Event Ontology V1

สถานะ: **OR2 PROPOSED — OWNER REVIEW REQUIRED — NO RUNTIME AUTHORIZATION**

Owner เลือก Option B ให้ขยาย evidence contract Ontology นี้แก้ข้อผิดพลาด OR1 ที่จัด `family duty` และ `education/social transition` เป็น career event เพียงเพราะมี career score

## Registry

| Event family | Domain | ความหมายที่อนุญาต | Allowed outcomes | Prohibited outcomes | Required inputs | Required evidence groups | Known / Unknown | Safety boundary | Semantic owner / dedupe |
|---|---|---|---|---|---|---|---|---|---|
| `family_duty_or_constraint` | family | ภาระ กฎ หรือข้อจำกัดในบริบทครอบครัวช่วงอายุที่คำนวณได้ | duty increases, constraint becomes active | ผู้กระทำเฉพาะ ความรุนแรง trauma บุคลิก | age band, known Thai-day basis | life period, annual Taksa, natal relationship | Known only in V1 | ไม่สรุป psychology หรือ abuse | `past.family.<ageBand>`; หนึ่ง atom ต่อ band |
| `education_or_social_transition` | education/social | การเปลี่ยนกรอบการเรียนหรือกลุ่มสังคมที่ boundary รองรับ | setting changes, network changes, education path changes | ชื่อสถาบัน เมือง บุคคล จำนวนครั้ง | age boundary, known Thai-day basis | life-period transition, annual Taksa, planet bond | Known only | ห้ามย้ายเป็น career โดยไม่มี career resolver | `past.educationSocial.<ageBand>` |
| `career_role_change` | career | หน้าที่ ขอบเขต หรืออำนาจตัดสินใจเปลี่ยน | role expands, role contracts, authority changes | ชื่อตำแหน่ง นายจ้าง เงินเดือน actor | known birth time, horizon | period/timing, annual Taksa, natal/lagna, career evidence | Known only V1 | ไม่รับรองการจ้างงาน | `<horizon>.career.roleChange` |
| `career_opportunity` | career | โอกาสทำงานหรือรับบทบาทที่ calculation รองรับ | opportunity opens, work visibility increases | ผู้ชวน ลูกค้าเก่า referral บริษัท | known birth time, horizon | period/timing, annual Taksa, natal/lagna, opportunity evidence | Known only V1 | ไม่รับรองผลสำเร็จ | `<horizon>.career.opportunity` |
| `career_ending_or_transfer` | career | งานหรือหน้าที่ลด จบ หรือถูกส่งต่อ | work closes, work contracts, duty transfers | ไล่ออก เลิกจ้าง ชื่อโครงการ วันสิ้นสุด | known birth time, horizon | period/timing, annual Taksa, challenging natal bond, career risk | Known only V1 | ห้ามกล่าวเหตุแรงกว่าค่า movement | `<horizon>.career.endingTransfer` |
| `income_change` | finance | ทิศทางรายรับเปลี่ยนโดยไม่ระบุแหล่งที่ระบบไม่คำนวณ | income increases, income decreases, income stabilizes | จำนวนเงิน แหล่งรายรับ โชคลาภ วันรับเงิน | known birth time, horizon | period/timing, annual Taksa, natal/lagna, finance opportunity | Known only V1 | ไม่ใช่คำรับรองรายได้/ผลตอบแทน | `<horizon>.finance.income` |
| `expense_or_obligation` | finance | ภาระจ่ายหรือข้อผูกพันทางการเงินเพิ่ม ลด หรือสิ้นสุด | obligation increases, expense pressure rises, obligation closes | จำนวนเงิน ประเภทรายจ่าย หนี้เฉพาะ | known birth time, horizon | period/timing, annual Taksa, challenging natal bond, finance risk | Known only V1 | ไม่สั่งลงทุน/กู้/ซื้อ | `<horizon>.finance.obligation` |
| `relationship_entry` | relationship | ความสัมพันธ์ใหม่เข้าสู่ขอบเขตที่ report กล่าวได้ | connection enters, new relationship begins | คู่แท้ เพศ อาชีพ ช่องทางพบ exact date | `relationshipStatus=single`, known time | clarity rule signals plus explicit status | Known only V1 | ห้ามเดาสถานะหรือบุคคล | `<horizon>.relationship.entry` |
| `relationship_clarity` | relationship | เรื่องหรือข้อตกลงความสัมพันธ์ชัดขึ้น โดยไม่บอกว่ามีคู่ | agreement clarifies, ambiguity resolves | มีคนใหม่ แต่งงาน เลิกกัน เมื่อไม่มี branch | horizon; status optional | period/timing, annual Taksa, natal/lagna, love opportunity | Known only V1 | `not_disclosed` ใช้ได้แต่ห้ามกล่าว actor/status | `<horizon>.relationship.clarity` |
| `relationship_ending` | relationship | ความสัมพันธ์ที่มี input รองรับลดหรือจบ | connection withdraws, relationship closes | นอกใจ หย่า บุคคล เหตุผล exact date | partnered/married/complicated, known time | period/timing, annual Taksa, challenging natal bond, relationship risk | Known only V1 | ใช้ภาษาปลอดภัย ไม่กล่าวโทษ | `<horizon>.relationship.ending` |
| `health_load` | health | ภาระต่อพลังงาน/การพักเพิ่มขึ้น ไม่ใช่โรค | activity load rises, rest pressure rises | โรค อวัยวะ อาการ วินิจฉัย การรักษา | known birth time, horizon | period/timing, annual Taksa, challenging natal bond, health risk | Known only V1 | ต้องมี medical disclaimer; ไม่แทนแพทย์ | `<horizon>.health.load` |
| `recovery_pressure` | health | ระยะฟื้นตัวมีแรงกดมากขึ้นหรือลดลง | recovery pressure rises, recovery pressure eases | อาการหาย ระยะรักษา exact medical outcome | known birth time, horizon | period/timing, annual Taksa, natal challenge, health strength/risk | Known only V1 | ไม่วินิจฉัย ไม่รับรองการฟื้น | `<horizon>.health.recovery` |
| `life_period_transition` | cross-domain time structure | เปลี่ยนจาก life period หนึ่งสู่อีก period ตาม boundary | period begins, period ends | เหตุการณ์สังคม/งาน/เงินที่ไม่ได้คำนวณ | normalized Thai-day basis, age/asOf | life-period engine boundary | Known only V1 | เป็น fact ไม่ใช่เหตุการณ์ภายนอก | `timeline.period.<startAge>` |

## Relationship-status input contract

```text
relationshipStatus = single | partnered | married | complicated | not_disclosed
```

- `relationship_entry` ใช้ได้เฉพาะ `single` และเมื่อ rule อื่นครบทุก signal
- `relationship_ending` ใช้ได้เฉพาะ `partnered`, `married` หรือ `complicated`
- `relationship_clarity` ใช้กับ `not_disclosed` ได้เฉพาะข้อความไม่ผูก actor/สถานะ
- `not_disclosed` ไม่ถูกแปลงเป็น single และไม่ถือเป็น missing error
- Birth-time Unknown ไม่ได้กลายเป็น Known จาก relationship status; V1 omit event rules ทั้งหมดที่ `knownTimeRequired=true`
- รอบนี้เป็น design contract ไม่มี UI, storage หรือ runtime field เพิ่ม

## Dedupe and domain rules

1. Family และ education/social ไม่ใช้ career score เป็น domain owner
2. Past domain transition เลือก domain จาก rule output เพียงหนึ่ง domain ห้ามพูด career/relationship/finance พร้อมกัน
3. หนึ่ง `semanticOwner` มีได้หนึ่ง atom ต่อ horizon; atom ที่ strength ต่ำกว่าถูกเก็บใน trace แต่ไม่สร้างข้อความซ้ำ
4. Summary อ้าง owner เดิมและไม่สร้าง event family ใหม่
5. Event count ไม่ใช่ output field V1 แม้ rule จะนับ signal ภายใน threshold
6. G05/G10 เป็น `PROHIBITED_PSYCHOLOGY` และไม่อยู่ใน ontology นี้
