# Standard Cursor Agent Prompt — KnowMe

คุณคือ Agent ตัวเดียวที่รับผิดชอบ task นี้แบบ end-to-end ทำงานเฉพาะใน worktree/branch ที่เปิดอยู่ ห้ามสร้าง worktree หรือ branch ใหม่ และห้ามเรียก AI reviewer, OpenAI API, KnowMe AI Worker หรือส่งงานวนระหว่าง agent

ให้ทำตามลำดับนี้โดยไม่รอให้ผู้ใช้คัดลอกผลระหว่างทาง:

1. อ่าน `task.md`, `task_scope.json`, `docs/KNOWME_SINGLE_AGENT_WORKFLOW.md` และเอกสารโปรเจกต์ที่เกี่ยวข้อง
2. ตรวจว่า current repo root, worktree, branch และ `base_ref` ตรงกับ scope ก่อนแก้ไฟล์ หากไม่ตรงให้หยุดและเขียน `TASK_RESULT.md` เป็น `BLOCKED`
3. ตรวจว่า task ชัดเจนและทำได้ภายใน allow-list ห้ามแก้ `task_scope.json`, ลด test policy, ขยาย allow-list, เปลี่ยน base_ref หรือแก้ Gate เพื่อให้ผ่าน
4. ลงมือแก้เฉพาะงานใน `task.md` ด้วยการเปลี่ยนแปลงแคบที่สุด รักษา frozen contracts และ behavior ที่ไม่เกี่ยวข้อง
5. เพิ่ม/แก้ focused tests ที่จำเป็นภายใน allow-list
6. รัน:

   `powershell -ExecutionPolicy Bypass -File scripts/knowme_task_gate.ps1 -ScopeFile task_scope.json -Phase PreCommit`

7. ถ้า FAIL ให้อ่าน output, แก้ต้นเหตุใน scope และรัน PreCommit ซ้ำเองจน PASS ห้ามถามผู้ใช้ให้ส่ง output กลับ
8. เมื่อ PreCommit PASS ให้ commit หนึ่ง commit ด้วยข้อความที่ตรง `commit_message_regex` ห้าม push, merge หรือ deploy
9. รัน:

   `powershell -ExecutionPolicy Bypass -File scripts/knowme_task_gate.ps1 -ScopeFile task_scope.json -Phase PostCommit`

10. ถ้า PostCommit FAIL ให้แก้หรือ amend เฉพาะสิ่งที่ถูกต้องตาม scope แล้วรันใหม่จน PASS
11. เขียน `TASK_RESULT.md` เป็นผลสุดท้ายเพียงไฟล์เดียว โดยระบุ task ID, PASS/BLOCKED, branch, worktree, final commit SHA, changed files, gate/test evidence และ blocker ถ้ามี
12. คำตอบสุดท้ายต่อผู้ใช้ให้สั้น: แจ้งสถานะและชี้ให้อ่าน `TASK_RESULT.md` เท่านั้น

กฎตัดสิน:

- Exit code 0 เท่านั้นคือ PASS
- ถ้าทำไม่ได้ภายใน scope ให้หยุดโดยไม่ commit และรายงาน BLOCKED
- ห้ามแตะงานอื่น ห้าม cleanup ของเดิม ห้ามรวม unrelated changes
- ห้ามอ้างว่าผ่านจากข้อความสรุปของตัวเอง ต้องมี Gate exit code จริง
