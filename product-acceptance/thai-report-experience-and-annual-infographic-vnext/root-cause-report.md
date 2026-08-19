# Root-cause report

## Reproduction

Owner artifacts ถูกเก็บแบบ read-only ใน `attached-pdf-comparison/`:

- `owner-full-report.pdf`: 7 หน้า A4, 39,390 bytes, SHA-256 `53676D4CEEB626213EDFB6D7E79D36B5C5AE6299B8C3B949C3A5AC27836ABB11`
- `owner-browser-print.pdf`: 1 หน้า A4, 156,053 bytes, SHA-256 `51F800C8A2E67B4D4601DF740273A3A3BA32A81E65367F0161BD1ECBD0D16A20`

Text comparison ยืนยันว่าช่วงต้นมาจาก analysis เดียวกัน แต่ export path ไม่ได้ใช้ presentation document เดียวกัน

## สาเหตุจาก code path

1. หน้า `/beta/thai/capture` แสดง long report ใน Flutter scroll viewport แบบคงที่
2. browser Save as PDF เดิมพิมพ์ canvas/viewport ของ Flutter โดยตรง จึงเห็นเฉพาะพื้นที่ที่ paint อยู่ใน viewport; horizontal canvas และ scroll owner ไม่ได้ถูก reflow เป็น A4 หลายหน้า
3. ปุ่ม dedicated PDF ไปอีกเส้นทางหนึ่งซึ่งประกอบข้อความและ pagination ด้วย package `pdf`
4. ทั้งสองเส้นทางจึงมี typography, card layout และ pagination คนละชุด แม้ข้อมูลต้นทางบางส่วนตรงกัน ผู้ใช้จึงเข้าใจว่าเป็น “รายงานเดียวกัน” แต่ได้ไฟล์ไม่เท่ากัน

ผลคือ browser print เดิมถูกตัดด้านขวา เหลือ 1 หน้า และหยุดกลางรายงาน ไม่ใช่เพราะ Chrome ละข้อความ แต่เพราะ Chrome ได้ fixed Flutter viewport แทน semantic document ที่พิมพ์ซ้ำหน้าได้

## การแก้

- `ThaiBetaReportExportDocument` เป็น shared presentation model สำหรับ Web, dedicated PDF, browser print และ infographic
- `ThaiBetaSharedReportView` แสดง section inventory เดียวกันบน Web
- `browserPrintDocumentHtml` สร้าง semantic HTML จาก model เดียวกัน พร้อม A4 `@page`, print-only hiding, break-inside และ overflow rules
- `ThaiBetaReportPdfExporter` อ่าน model เดียวกันและแทรก PNG เดียวกับ Web หลัง summary boundary
- ปุ่มใช้ชื่อแยกชัดเจน: “ดาวน์โหลดรายงาน PDF” และ “พิมพ์ / บันทึกหน้าเว็บเป็น PDF”
- tests เปรียบเทียบ exact normalized text, order, Known/Unknown rules, year และ infographic fields ระหว่าง renderers

ความแตกต่างที่ยังอนุญาตมีเฉพาะ responsive/A4 layout, page breaks, header/footer และ page number; ไม่มี renderer ใดประกอบ canonical paragraph ชุดใหม่
