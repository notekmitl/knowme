# Test, analyzer and build summary — Revision 2

| Gate | Result |
|---|---|
| Focused Revision 2 suite | 105/105 PASS |
| Layout/export/screenshot regression | 98/98 PASS |
| 300-profile copy audit | PASS; 4,003 fields; semantic/omission/addition 0 |
| Artifact generation | 15/15 fixtures PASS |
| PDF render | 14 PDFs; 105/105 pages PASS |
| Life Map regression scope | 32/32 PASS |
| Matrix payload | 864/864 PASS |
| R7 original runner | 286/286 PASS |
| Full suite branch | 2,940 passed / 37 failed |
| Exact main full suite | 2,925 passed / 39 failed |
| Full-suite delta | branch-only 0; main-only 2; common 37 |
| Scoped analyzer | 0 issues |
| Full analyzer branch/main | 297 / 299; branch-only 0 |
| Web release build | PASS, not deployed |
| Preview Web build | PASS, local only |
| VM/Chrome parity | byte-for-byte PASS, 133,841 bytes, mismatch 0 |
| R7.1 immutable | PASS, 63/63 and modified paths 0 |

Full-suite failures 37 รายการเป็น failure IDs ร่วมกับ exact `main`; branch-only failures = 0 และ main-only = 2. Full analyzer เปรียบเทียบด้วย severity/message/path/code แบบ deterministic และ branch-only diagnostics = 0

Raw logs ของ rerun ชุดนี้ใช้ suffix `-repaired` หรือ `revision-2`; ไม่มีการอ้างผลรอบก่อนแทนผล rerun และไม่มีคำสั่ง Deploy/Firebase mutation
