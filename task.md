# KnowMe Task

## Task ID

`thai-beta-narrative-v1.1.1-block-integrity-confidence`

## เป้าหมาย

Hardening Thai Beta Narrative V1.1 curated blocks สำหรับ:
1. **Block Integrity** — catalog invariants (unique ids, required fields ต่อ section, fallback coverage, birth-time flag consistency)
2. **Confidence Consistency** — ค่า confidence ที่ส่งเข้า selector สอดคล้องกับ birth-time policy ทุก call site และ effective minimumConfidence กันไม่ให้ block ที่ไม่ปลอดภัยถูกเลือกเมื่อไม่มีเวลาเกิด

## สิ่งที่ต้องทำ

- รวม confidence derivation เป็นจุดเดียว
- แก้ call site ที่ขาด `confidence` หรือ hardcode `hasBirthTime: true` โดยไม่สอดคล้องกับ profile จริง
- เพิ่ม integrity validator + focused regression tests
- อัปเดตเอกสาร review เฉพาะส่วน V1.1.1

## สิ่งที่ห้ามทำ

- ห้ามเปลี่ยน public evidence badge rollout, feature flag, invite allow-list
- ห้ามแตะ Canon / Mahabhut Canon
- ห้ามเปลี่ยน engine / prediction / life-period selection
- ห้ามสร้าง worktree หรือ branch ใหม่
- ห้าม merge, push หรือ deploy
- ห้ามใช้ KnowMe AI Worker / OpenAI reviewer

## Definition of Done

- Focused tests ของ integrity + confidence ผ่าน
- PreCommit Gate PASS
- commit หนึ่งครั้งด้วยข้อความตรง policy
- PostCommit Gate PASS
- `TASK_RESULT.md` มีผลสุดท้าย

## หมายเหตุเฉพาะงาน

ฐาน: cherry-pick V1 + V1.1 บน `integrate/thai-beta-narrative-base` แล้ว (HEAD ก่อนงานนี้เป็น base_ref)
