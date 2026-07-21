# KnowMe Task

## Task ID

`single-agent-local-gate-install`

## เป้าหมาย

ติดตั้ง KnowMe Single-Agent + Local Gate workflow ใน repo นี้ ยุติการใช้ KnowMe AI Worker และ reviewer loop สำหรับงาน automation ใหม่

## สิ่งที่ต้องทำ

- ติดตั้ง `scripts/knowme_task_gate.ps1` และ self-test
- ติดตั้งเอกสาร workflow authoritative (`docs/KNOWME_SINGLE_AGENT_WORKFLOW.md`, standard prompt)
- อัปเดต status/handoff docs ให้ชี้ระบบใหม่ และ mark AI Worker ว่า retired
- retire `docs/AI_WORKER_OPERATION.md` เป็น historical record (ห้ามลบ)
- ไม่แตะ Thai Beta Narrative V1.1.1 หรือ application behavior

## สิ่งที่ห้ามทำ

- ห้ามขยาย scope นอก `task_scope.json`
- ห้ามใช้ KnowMe AI Worker, OpenAI API หรือ AI reviewer
- ห้ามสร้าง worktree หรือ branch ใหม่ระหว่างงาน
- ห้าม merge, push หรือ deploy
- ห้ามแตะ external AI Worker directory นอก repo นี้

## Definition of Done

- workflow ใหม่มีเอกสาร authoritative และ Gate ทำงาน PreCommit/PostCommit
- self-tests ครอบคลุม failure modes และ happy path
- Local Gate ระยะ PreCommit ผ่าน
- commit ด้วยข้อความที่ตรงตาม `task_scope.json`
- Local Gate ระยะ PostCommit ผ่าน
- `TASK_RESULT.md` มีผลสุดท้ายเพียงไฟล์เดียว

## หมายเหตุเฉพาะงาน

งานนี้เป็น workflow/tooling task ไม่ใช่งาน Thai Beta Narrative V1.1.1
