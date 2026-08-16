# Immediate Production verification result

## Hosting integrity — passed before product rollback trigger

- V1.5 release/version: `1786871603892000` / `a5721c17f758aa6d`.
- Release time: `2026-08-16T09:13:23.892Z`.
- Release message: `KnowMe Thai Narrative V1.5 — source 7a2bdea4, product a574fcb6`.
- Frozen build manifest: 78 files, of which 77 were deployable because Firebase ignores `.last_build_id`.
- Production assets: 77/77 HTTP-successful and byte/SHA-256 identical to the frozen build; mismatch 0.
- `/` and `/beta/thai`: HTTP 200 and exact `index.html` bytes.
- `index.html`, `flutter_bootstrap.js`, `flutter_service_worker.js`, and `main.dart.js` returned the configured no-cache/must-revalidate policy; immutable assets retained the long-lived immutable policy.
- Existing V1.4 tab reloaded to a complete, non-white UI; fresh desktop and mobile sessions loaded without missing chunks or mixed asset hashes.
- Browser warning/error logs: 0.

## Product verification — blocked

The first accepted canonical profile was entered through the real signed-out Production UI using the accepted fixture values:

- Fixture: `owner-known-0035`
- Name: `Acceptance Fixture`
- Birth: `1982-06-06 00:35`, Chiang Mai
- Summary input confirmation: correct
- Known fact visible in the downloaded report: Aquarius `19°19′`
- Download action: real `/beta/thai/capture` → `ดาวน์โหลดรายงานเต็ม`
- Downloaded PDF: 39,370 bytes / SHA-256 `5F706E04462DEA15716F09C3B8230C03DA34D2CF02B9C0C3E11BBBFCDC47C49B` / 7 pages
- Accepted R7.1 PDF: 39,080 bytes / SHA-256 `23D7AEBC40F27C29BDA55F521688BCC7D156FDE928173BE435BB7033EB8535B6` / 7 pages
- Production extracted text versus accepted canonical: not exact
- Production extraction versus accepted PDF extraction: not exact; four substantive replacement spans

This violates the mandatory accepted-canonical identity gate. Verification stopped immediately. `owner-unknown`, `regression-known-0003`, `comparison-known-bangkok`, and `comparison-known-khon-kaen` were not executed after the mandatory rollback trigger. Therefore no claim of Production parity 5/5 or Production traceability 170/170 is made.

Result: `BLOCKED — ROLLBACK REQUIRED`.

## Rollback result

- Exact retained V1.4 version selected in Firebase Hosting Release history: `10af10c6d960d590` (`60d590`).
- New rollback release: `1786872330369000`, type `ROLLBACK`, time `2026-08-16T09:25:30.369Z`.
- Six baseline assets after rollback: 6/6 exact byte/SHA-256 matches, mismatch 0.
- `/` and `/beta/thai`: HTTP 200.
- Fresh and existing browser tabs: complete signed-out landing, warning/error logs 0.
- Final Production: V1.4.

Final release-task result: `V1.5 DEPLOYMENT ROLLED BACK — PRODUCTION RESTORED TO V1.4`.
