# PDF visual QA

PDF ห้าไฟล์ถูก render ใหม่จาก final code ที่ 120 DPI รวม 34 หน้า และเปิดตรวจผ่าน contact sheet ทุก fixture พร้อมเปิดหน้า Past สำคัญของ Owner Known/Unknown ที่ความละเอียดเต็ม

| PDF | Pages | SHA-256 |
|---|---:|---|
| owner-known-0035-report.pdf | 7 | `9E556B724D0A290859186A6C5A2992BB6498B5288A2257846D12C2C55A2F7553` |
| owner-unknown-report.pdf | 6 | `67C49A366D9903B80EFECCBE391F7CFF4CFD2C2733ACAC6FC6459615E9DAB608` |
| regression-known-0003-report.pdf | 7 | `99087A761D991AF5CF9763DB7B4D54330C8437C83E418EA053341D59C40FD467` |
| comparison-known-bangkok-report.pdf | 7 | `A32A292163B61FA8DB4689AD954EBDBC0D223F079AEE2944A37B7FE841A5087B` |
| comparison-known-khon-kaen-report.pdf | 7 | `BBE8985BA1455057EA16878809913ED3F136CB2908ADDC1D126673943BF7DD14` |

Geometry audit: blank 0, footer-only 0, touches-edge 0; ทุกหน้า 993×1404 pixels. Visual inspection ไม่พบ clipping, overlap, truncation, broken Thai wrapping, card-border escape หรือเลขหน้าผิด

Owner Known 00:35 ยังคง Aquarius 19°19′; regression 00:03 ยังคง Aquarius 9°24′.
