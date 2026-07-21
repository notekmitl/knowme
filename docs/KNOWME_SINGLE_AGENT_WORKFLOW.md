# KnowMe Single-Agent + Local Gate

**Status:** CURRENT — authoritative automation workflow for Cursor Agent tasks.  
**Last updated:** July 2026

## 1. การตัดสินใจหลัก

KnowMe ใช้ Cursor Agent ตัวเดียวทำงาน end-to-end ใน branch/worktree ที่ผู้ใช้กำหนดไว้ล่วงหน้า ระบบนี้ยุติ KnowMe AI Worker, OpenAI API reviewer, reviewer loop, การส่ง JSON หลายไฟล์ และการสร้าง worktree ระหว่าง task อย่างถาวร

Local Gate เป็น PowerShell script ธรรมดา ตัดสิน PASS/FAIL จาก command exit code จริง ไม่ให้ AI เป็นผู้ตัดสินว่าผ่านหรือไม่

**Supersedes:** [`AI_WORKER_OPERATION.md`](AI_WORKER_OPERATION.md) (retired — kept as historical record).

## 2. โครงสร้างต่อหนึ่ง task

- `task.md`: เป้าหมายและ acceptance criteria ที่คนอ่าน
- `task_scope.json`: ขอบเขตที่ Gate อ่านได้
- `scripts/knowme_task_gate.ps1`: ตัวตรวจกลางของ repo
- `scripts/knowme_task_gate_selftest.ps1`: deterministic self-tests สำหรับ Gate
- `TASK_RESULT.md`: ผลสุดท้ายที่ผู้ใช้อ่านเพียงไฟล์เดียว (local-only — ดู §5)
- `docs/STANDARD_CURSOR_AGENT_PROMPT.md`: prompt มาตรฐานสำหรับทุก task

## 3. เหตุผลที่ Gate มีสองระยะ

### PreCommit

รันก่อน commit และต้องผ่านทั้งหมด:

1. อยู่ใน worktree และ branch ที่กำหนด
2. `base_ref` มีอยู่จริงและเป็น ancestor ของ HEAD
3. changed files เทียบจาก `base_ref` รวม staged, unstaged และ untracked อยู่ใน allow-list
4. ไม่มี forbidden files หรือ generated outputs ใน changed files
5. changed textual content ไม่มี forbidden patterns
6. `analyze_command` ผ่าน (หรือ `SKIP` สำหรับ documentation-only tasks)
7. focused tests ทุกคำสั่งผ่าน
8. full tests รันตาม policy และผ่าน

### PostCommit

รันหลัง commit:

1. ตรวจ worktree/branch/base อีกครั้ง
2. commit message ตรง regex
3. ไม่มี source change ค้างหลัง commit ตาม policy (`TASK_RESULT.md` ยกเว้น)

หาก PreCommit ไม่ผ่าน ห้าม commit หาก PostCommit ไม่ผ่าน Cursor ต้องแก้เอง โดยแก้หรือ amend commit แล้วรัน PostCommit ใหม่ ห้าม push/merge/deploy ทุกกรณีใน workflow นี้

## 4. กฎของ scope

- ใช้ path แบบ relative ต่อ repo และใช้ `/`
- `allowed_files` เหมาะกับงาน production-safe เพราะระบุไฟล์ตรงตัว
- `allowed_globs` ใช้เท่าที่จำเป็น ห้ามใช้ `**/*`
- `base_ref` ต้องเป็น full immutable commit SHA ห้ามใช้ `main`, `HEAD~1` หรือชื่อ branch
- focused test ต้องเป็นคำสั่งเต็มที่รันจาก repo root
- `full_test_policy` มีค่า `required`, `skip` หรือ `auto`
- `analyze_command` ใช้ `SKIP` เมื่อ task เป็น documentation/tooling-only
- `auto` ให้รัน full tests เมื่อ changed files มี source/test files; documentation-only ข้ามได้

## 5. TASK_RESULT.md

ไฟล์นี้เป็นรายงานสุดท้าย ไม่ใช่หลักฐานตัดสิน PASS หลักฐานจริงคือ exit code ของ Gate Cursor ต้องเขียนผลตามที่เกิดขึ้นจริงเท่านั้น และต้องระบุ commit SHA หลัง PostCommit ผ่าน

แนะนำให้ `TASK_RESULT.md` เป็นไฟล์ operational ที่ไม่ commit และเพิ่มไว้ใน `.git/info/exclude` ของ worktree เพื่อให้รายงานมี commit SHA สุดท้ายได้โดยไม่ทำให้ tree สกปรก ห้ามเพิ่มลง project `.gitignore` หากไม่จำเป็น

```powershell
# One-time per worktree (local only):
if (-not (Select-String -Path .git/info/exclude -Pattern '^TASK_RESULT\.md$' -Quiet)) {
  Add-Content -Path .git/info/exclude -Value 'TASK_RESULT.md'
}
```

## 6. Failure behavior

- Gate หยุดทันทีเมื่อ invariant สำคัญผิด เช่น branch/worktree/base/scope
- Test failure แสดง command และ exit code
- Cursor อ่าน output แก้เฉพาะต้นเหตุ แล้วรัน phase เดิมซ้ำ
- ห้ามลด test policy, ขยาย allow-list, เปลี่ยน base_ref หรือแก้ Gate เพื่อทำให้ task ผ่าน หาก task ไม่สามารถเสร็จใน scope ให้เขียน `TASK_RESULT.md` เป็น `BLOCKED` และหยุดโดยไม่ commit

## 7. ขั้นตอนใช้งานที่สั้นที่สุด

1. ผู้ใช้เตรียม branch/worktree หนึ่งชุด แล้วแก้ `task.md` กับ `task_scope.json`
2. เปิด Cursor ที่ worktree นั้น วาง `docs/STANDARD_CURSOR_AGENT_PROMPT.md` เพียงครั้งเดียว
3. Cursor ตรวจ scope, ลงมือ, รัน PreCommit, แก้จนผ่าน, commit, รัน PostCommit และเขียน `TASK_RESULT.md`
4. ผู้ใช้อ่านเฉพาะ `TASK_RESULT.md`

## 8. สิ่งที่ workflow นี้ไม่ทำ

- ไม่สร้าง branch/worktree
- ไม่เรียก AI/API reviewer
- ไม่สร้าง review rounds หรือ JSON ส่งต่อ
- ไม่ merge, push, deploy
- ไม่แก้ scope อัตโนมัติ

## 9. Gate commands

```powershell
# PreCommit (before commit)
powershell -ExecutionPolicy Bypass -File scripts/knowme_task_gate.ps1 -ScopeFile task_scope.json -Phase PreCommit

# PostCommit (after commit)
powershell -ExecutionPolicy Bypass -File scripts/knowme_task_gate.ps1 -ScopeFile task_scope.json -Phase PostCommit

# Self-test (validates Gate behavior)
powershell -ExecutionPolicy Bypass -File scripts/knowme_task_gate_selftest.ps1
```

## 10. ขอบเขตเฟสนี้

เฟสนี้ติดตั้งระบบ workflow เท่านั้น ห้ามแก้ไฟล์หรือพฤติกรรมของ Thai Beta Narrative V1.1.1
