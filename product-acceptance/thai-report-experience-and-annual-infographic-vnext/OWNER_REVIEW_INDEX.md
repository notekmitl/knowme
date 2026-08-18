# Owner Review Index — PR #100 Revision 2

สถานะ: **Pending Owner Review** — เอกสารนี้จัดเส้นทางตรวจเท่านั้น ไม่ได้อนุมัติแทน Owner

## 1. ตรวจภาพหลัก

- [Known infographic 1080×1920](generated-artifacts/revision-2/annual-infographic-known.png)
- [Unknown infographic 1080×1920](generated-artifacts/revision-2/annual-infographic-unknown.png)
- [Canonical-five contact sheet](visual-qa/revision-2-repaired/infographic-canonical-five-contact-sheet.png)
- [Stress contact sheet](visual-qa/revision-2-repaired/infographic-stress-contact-sheet.png)
- [Known dedicated PDF contact sheet](visual-qa/revision-2-repaired/pdf-contact-sheets/dedicated-report-known-contact-sheet.png)
- [Unknown dedicated PDF contact sheet](visual-qa/revision-2-repaired/pdf-contact-sheets/dedicated-report-unknown-contact-sheet.png)
- [Known browser-print contact sheet](visual-qa/revision-2-repaired/pdf-contact-sheets/browser-print-known-contact-sheet.png)
- [Unknown browser-print contact sheet](visual-qa/revision-2-repaired/pdf-contact-sheets/browser-print-unknown-contact-sheet.png)

## 2. ตรวจ Web mobile

- Known: [360 top](web-screenshots-repaired/web-known-360x800-top.png), [360 infographic top](web-screenshots-repaired/web-known-360x800-infographic.png), [360 infographic bottom](web-screenshots-repaired/web-known-360x800-infographic-bottom.png), [390 top](web-screenshots-repaired/web-known-390x844-top.png)
- Unknown: [360 top](web-screenshots-repaired/web-unknown-360x800-top.png), [360 infographic top](web-screenshots-repaired/web-unknown-360x800-infographic.png), [360 infographic bottom](web-screenshots-repaired/web-unknown-360x800-infographic-bottom.png), [390 top](web-screenshots-repaired/web-unknown-390x844-top.png)

## 3. ตรวจ copy

- [Copy summary](copy-review-summary.md)
- [Grouped table — 45 active rules](owner-copy-curated-review-revision-2.md)
- Full ledger — `copy-before-after-ledger-revision-2.json` (4,003 fields / 300 profiles)
- Preserved prior ledger — `copy-before-after-ledger.json` (2,105 fields)

ทุกกลุ่มและทุก field มี decision = Pending; Owner ต้องระบุ approve/reject เอง

## 4. ตรวจ parity และ gate

- [Web/PDF shared section inventory](web-pdf-section-inventory.md)
- [Visual QA](visual-qa.md)
- [Test/analyzer/build summary](test-summary.md)
- [Monthly engine capability gap](monthly-engine-capability-gap.md)
- `SHA256SUMS.txt` สำหรับตรวจ identity ของ packet

## Stop point

PR #100 ต้องคงเป็น Open, Draft และ unmerged. Monthly timeline ยัง BLOCKED. Production ยังคง V1.5 `5f98dfffef913e38`. ห้าม Merge, Deploy หรือเปลี่ยน Firebase ในงานนี้
