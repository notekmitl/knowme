# Thai Report Experience and Annual Infographic vNext

สถานะ: candidate สำหรับ Owner review บน Draft PR เท่านั้น ไม่มีการ Merge หรือ Deploy

## ผลลัพธ์

- Web, dedicated PDF และ browser print ใช้ `ThaiBetaReportExportDocument` ชุดเดียวกัน ทั้ง section order, heading, paragraph และ Known/Unknown omission rules
- browser print เปลี่ยนจากการพิมพ์ Flutter viewport เป็น semantic print document แบบหลายหน้า A4 จึงไม่ถูกตัดด้านขวาหรือหยุดกลางรายงาน
- dedicated PDF: Known 8 หน้า, Unknown 8 หน้า; infographic อยู่หน้า 2 หลังส่วนสรุป
- browser print: Known 7 หน้า, Unknown 7 หน้า; infographic อยู่หน้า 2 และไม่ถูกตัด
- PNG จริง 1080×1920 สำหรับ Known/Unknown ใช้ปี พ.ศ. จาก Bangkok civil `asOf`, ไม่มีข้อมูลวัน/เวลา/สถานที่เกิดบนภาพ
- copy candidate แยกจาก accepted V1.5: 300 profiles, 2,105 fields changed, omission/addition/semantic/prediction↔advice/traceability impact = 0; Owner decision ยัง Pending
- engine ไม่มี validated calendar-month evidence จึงไม่สร้างเดือนดี/เดือนระวัง และ monthly timeline เป็น BLOCKED

## Technical gates

- vNext model/copy/artifact tests: 11/11
- screenshot regression: 24/24
- Life Map regression scope: 32/32; matrix payload: 864/864
- original R7 runner: 286/286
- full suite branch/main: 2,938 passed / 37 failed เทียบ 2,925 / 39; branch-only failures 0, main-only failures 2
- scoped analyzer: 0 issues; full analyzer branch/main: 297/299; branch-only diagnostics 0
- Web release build: PASS; local preview build: PASS; ไม่มี Deploy
- VM/real Chrome manifest: 134,732 bytes, byte-for-byte equal, SHA-256 `E961E1DEE62B3A16FE6DD0245D1EFE8376E93F294F65590A65D900EDDF8C2780`
- R7.1 archive: 10,709,328 bytes, 80 entries, SHA-256 `9E541F21C68FDAD93BC595C55BD0BE23600F88454CFBA7FAB6C713FE53F79E58`; checksums 79/79, immutable 63/63, modified paths 0

## Review map

- Root cause: [root-cause-report.md](root-cause-report.md)
- Shared inventory: [web-pdf-section-inventory.md](web-pdf-section-inventory.md)
- Copy review: [copy-review-summary.md](copy-review-summary.md) และ `copy-before-after-ledger.json`
- Infographic provenance: [infographic-data-provenance.md](infographic-data-provenance.md)
- Monthly gap: [monthly-engine-capability-gap.md](monthly-engine-capability-gap.md)
- Visual QA: [visual-qa.md](visual-qa.md)
- Gate summary: [test-summary.md](test-summary.md)
- Raw outputs: `logs/`, `generated-artifacts/`, `renders-final/`, `visual-qa-final/`, `web-screenshots-final/`

Production ยังคง V1.5 Hosting version `5f98dfffef913e38`; rollback V1.4 คือ `10af10c6d960d590`.
