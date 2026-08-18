# Test, analyzer and build summary

| Gate | Result |
|---|---|
| vNext model/copy/artifact | 11/11 PASS |
| Screenshot regression | 24/24 PASS |
| Life Map regression scope | 32/32 PASS |
| Matrix payload | 864/864 PASS |
| R7 original runner | 286/286 PASS |
| Full suite branch | 2,938 passed / 37 failed |
| Exact main full suite | 2,925 passed / 39 failed |
| Full-suite delta | branch-only 0; main-only 2; common 37 |
| Scoped analyzer | 0 issues |
| Full analyzer branch/main | 297 / 299; branch-only 0 |
| Web release build | PASS, not deployed |
| Preview Web build | PASS, local only |
| VM/Chrome parity | byte-for-byte PASS, 134,732 bytes |
| R7.1 immutable | PASS, 63/63 and modified paths 0 |

Full-suite failures 37 รายการเป็น failure IDs ชุดเดียวกับ exact `main`; branch ลด baseline failure ลง 2 รายการใน `thai_mirror_timeline_ui_test.dart` และไม่เพิ่ม failure ใหม่ รายละเอียดทั้งหมดอยู่ใน `logs/full-test-delta-result.txt`.

Full analyzer เทียบด้วย severity/message/path/code แบบ deterministic; branch-only diagnostics = 0. รายละเอียดอยู่ใน `logs/full-analyzer-delta-final-result.txt`.

ไม่มีการอ้างผลเก่าแทน rerun: raw logs แยก branch/main, focused regression, analyzer, build, Chrome/VM และ immutable verification ไว้ใน `logs/`.
