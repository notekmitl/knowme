# Thai Narrative V1.5 R7.1 Evidence-Only Repair

สถานะ: `R7 NARRATIVE ACCEPTED` และ `R7 ACCEPTANCE PACKAGE REJECTED`

R7.1 แก้เฉพาะ encoding, evidence accuracy, manifest, checksum และ packaging ไม่แก้ product code, reader-visible report, canonical text, PDF หรือ renders ผล R7 focused tests 286/286 เป็นหลักฐานเดิมและไม่ได้รันซ้ำใน R7.1 ส่วน full suite ไม่ได้รัน

Product Acceptance รวมยัง pending จนกว่า Owner จะรับ evidence package นี้

R7.1 evidence gate ผ่านใน staging และหลัง clean extraction: UTF-8/BOM/U+FFFD/C0/C1/tab/mojibake/identity mismatch เป็น 0, negative fixture ถูก reject, immutable mismatch 0 และ checksums ผ่านทั้งหมด

`DO NOT MERGE` · `DO NOT DEPLOY` · Production คง V1.4

<!-- R7_1_ARTIFACT_IDENTITIES:START -->
ค่าชุดนี้สร้างอัตโนมัติจาก final PDF files โดย tool/thai_narrative_r7_1_finalize.ps1; source-of-truth คือ evidence/artifact-identities.json

| Artifact | Pages | Bytes | SHA-256 |
|---|---:|---:|---|
| comparison-known-bangkok-report.pdf | 7 | 38336 | AA66312F30D7ED47E223CF4E94EB74FBF00573F3B438B11EBBCC125BDE217963 |
| comparison-known-khon-kaen-report.pdf | 7 | 38823 | E07F071E275AFB8291D27D32C520D69B3370088C5A2C400D9B345E2C2380AAFE |
| owner-known-0035-report.pdf | 7 | 39080 | 23D7AEBC40F27C29BDA55F521688BCC7D156FDE928173BE435BB7033EB8535B6 |
| owner-unknown-report.pdf | 6 | 37021 | CD1704B2F84EE6C3AAA89EC0A011969CFAFA02C4B1318BC209D57EF972865CFF |
| regression-known-0003-report.pdf | 7 | 39072 | D9A43853DBC8F9A173A2342EC0B2180E6F3DD33CA59D7CB819660E4B72CFE377 |
<!-- R7_1_ARTIFACT_IDENTITIES:END -->

อ่านผลใน `validation-summary.md`, `reader-quality-review.md`, `repetition-distinctness.md`, `visual-qa.md` และ `evidence/r7-to-r7.1-identity-comparison.json`
