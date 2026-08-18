# Thai Report Experience and Annual Infographic vNext — Owner Review Revision 2

สถานะ: artifact repair candidate สำหรับ Owner review บน Draft PR #100 เท่านั้น ยังไม่อนุมัติ copy หรือ visual, ห้าม Merge และห้าม Deploy

## สิ่งที่แก้ใน Revision 2

- ปรับสำนวน candidate เฉพาะ reader-facing projection โดยไม่แก้ accepted V1.5/R1–R7.1 canonical text
- ปรับ annual infographic ให้ข้อความไม่ล้น ไม่ตัดคำ และคงลำดับชั้นเดียวกันบน 360/390 px; PNG จริงมีขนาด 1080×1920
- ใช้ลายเส้นโค้งและดอกสี่กลีบเป็นองค์ประกอบตกแต่งเท่านั้น ไม่สื่อว่าเป็นข้อมูลรายเดือน
- Web, dedicated PDF และ browser print ใช้ `ThaiBetaReportExportDocument` ชุดเดียวกัน ทั้ง section order, heading, paragraph และ Known/Unknown omission rules
- dedicated PDF 7 fixtures × 8 หน้า และ browser print 7 fixtures × 7 หน้า; render ตรวจครบ 105/105 หน้า
- monthly timeline ยัง BLOCKED เพราะ engine ไม่มี validated calendar-month evidence; ไม่มีการสร้างข้อมูลเดือนดี/เดือนระวังขึ้นเอง

## Copy review

- audit ใหม่ครบ 300 profiles: Known 225 / Unknown 75
- full Revision 2 ledger: 4,003 changed fields; omission/addition/semantic/prediction↔advice/traceability impact = 0
- grouped Owner table: 45 active transformation rules โดยอ้างอิง full ledger ไม่ใช่ sampling
- ledger เดิม 2,105 fields (`copy-before-after-ledger.json`) เก็บไว้แบบ immutable สำหรับ provenance
- Owner decision: **Pending**

## Technical gates

- focused Revision 2: 105/105 PASS; layout/export/screenshot regression: 98/98 PASS
- Life Map regression: 32/32; matrix payload: 864/864; original R7 runner: 286/286
- full suite branch/main: 2,940 passed / 37 failed เทียบ 2,925 / 39; branch-only failures 0, main-only failures 2
- scoped analyzer: 0 issues; full analyzer branch/main: 297/299; branch-only diagnostics 0
- Web release build และ local preview build: PASS; ไม่มี Deploy
- VM/real Chrome manifest: 133,841 bytes, byte-for-byte equal, SHA-256 `2726315A625CF8AF0999EE27B673EBBDF1DA22EC24BB34A0B52AF79C74D5E093`
- R7.1 archive: 10,709,328 bytes, 80 entries, SHA-256 `9E541F21C68FDAD93BC595C55BD0BE23600F88454CFBA7FAB6C713FE53F79E58`; checksums 79/79, immutable 63/63, modified paths 0

## Review map

- เริ่มตรวจ: [OWNER_REVIEW_INDEX.md](OWNER_REVIEW_INDEX.md)
- Copy summary: [copy-review-summary.md](copy-review-summary.md)
- Grouped copy table: [owner-copy-curated-review-revision-2.md](owner-copy-curated-review-revision-2.md)
- Full Revision 2 ledger: `copy-before-after-ledger-revision-2.json`
- Shared section inventory: [web-pdf-section-inventory.md](web-pdf-section-inventory.md)
- Monthly gap: [monthly-engine-capability-gap.md](monthly-engine-capability-gap.md)
- Visual QA: [visual-qa.md](visual-qa.md)
- Gate summary: [test-summary.md](test-summary.md)

Production ยังคง V1.5 Hosting version `5f98dfffef913e38`; rollback V1.4 คือ `10af10c6d960d590`. ไม่มี Firebase mutation.
