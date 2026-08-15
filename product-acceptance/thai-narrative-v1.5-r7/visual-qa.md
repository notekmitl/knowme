# Visual QA

PDF final ทั้งห้าถูก render ที่ 180 dpi และเปิดตรวจ full-resolution ครบ 34/34 หน้า: Owner Known 7, Owner Unknown 6, regression 7, Bangkok comparison 7 และ Khon Kaen comparison 7 หน้า

ไม่พบ clipping, overlap, truncation, broken Thai wrapping, border escape, blank page หรือ footer-only page ผล geometry audit คือ blank 0, footer-only 0 และ touches-edge 0 หน้า Known หน้าที่ 7 มีพื้นที่ว่างมากแต่มี limitation card และเลขหน้าครบ จึงไม่ใช่หน้าว่าง

<!-- R7_ARTIFACT_IDENTITIES:START -->
เธเนเธฒเธเธธเธ”เธเธตเนเธชเธฃเนเธฒเธเธญเธฑเธ•เนเธเธกเธฑเธ•เธดเธเธฒเธ final PDF files เนเธ”เธข 	ool/thai_narrative_r7_finalize.ps1; source-of-truth เธเธทเธญ evidence/artifact-identities.json

| Artifact | Pages | Bytes | SHA-256 |
|---|---:|---:|---|
| comparison-known-bangkok-report.pdf | 7 | 38336 | `AA66312F30D7ED47E223CF4E94EB74FBF00573F3B438B11EBBCC125BDE217963` |
| comparison-known-khon-kaen-report.pdf | 7 | 38823 | `E07F071E275AFB8291D27D32C520D69B3370088C5A2C400D9B345E2C2380AAFE` |
| owner-known-0035-report.pdf | 7 | 39080 | `23D7AEBC40F27C29BDA55F521688BCC7D156FDE928173BE435BB7033EB8535B6` |
| owner-unknown-report.pdf | 6 | 37021 | `CD1704B2F84EE6C3AAA89EC0A011969CFAFA02C4B1318BC209D57EF972865CFF` |
| regression-known-0003-report.pdf | 7 | 39072 | `D9A43853DBC8F9A173A2342EC0B2180E6F3DD33CA59D7CB819660E4B72CFE377` |
<!-- R7_ARTIFACT_IDENTITIES:END -->
