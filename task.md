# Task: Thai Report Reader Experience V2

## Predictive Narrative V2 Phase 1 — Golden Copy and Evidence Blueprint (2026-08-30)

Status: **COMPLETE — DRAFT PR — PENDING OWNER CONTENT REVIEW — NOT MERGED — NOT DEPLOYED**. Owner accepts the Golden Reference as a style target only; Candidate copy, contract and implementation are not Owner-accepted by implication. Phase 1 changes Markdown content/evidence only at content commit `61ea2457a894bd7cd514037b866119f99473e270`.

Owner feedback recorded as six defects in the current report: (1) chronology jumps, (2) Thai is not conversational enough, (3) prediction hedges instead of speaking directly, (4) personality content is mixed into the astrology report, (5) past sections ask readers to remember events instead of predicting, and (6) the same meaning repeats across sections. The proposed contract requires past → current → rolling 12 months → next life period, Prediction before Advice, direct language, one semantic owner per claim, psychology separation and cross-surface parity.

Fixture separation is verified by the real pipeline: Known `00:03 → Aquarius 9°24′`, Known `00:35 → Aquarius 19°19′`, and both resolve the Saturday Thai-day boundary. Unknown remains fail-closed: empty birth time, null ascendant, no noon substitution, no asserted Thai day, no houses or time-dependent positions. Focused fixture regression passes 4/4. The Known 00:03 probe exposes 12 real forecast materials across 3 horizons × 4 domains. `monthlyTimelineAvailable=false`; no evidence supports Golden early/middle/late buckets.

Evidence Matrix result for 39 Golden paragraphs: `SUPPORTED 1`, `SUPPORTED_WITH_REWRITE 18`, `REQUIRES_NEW_EVIDENCE 18`, `MUST_NOT_IMPLEMENT 2`. Current evidence supports birth identity, life-period sequence, current/12-month/next-period domain bands and decision boundaries. Specific past events, age 44–46 timing, status-specific relationship events, named income/expense/opportunity sources, and within-year event buckets require a separately accepted calculation/evidence contract. Psychology conclusions G05 and G10 must not be implemented in this astrology report.

Candidate: `docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0003.md`. Owner package: `C:\Users\USER\Documents\Knowme\OWNER_REVIEW_THAI_REPORT_PREDICTIVE_NARRATIVE_V2_PHASE1_61ea245.zip`, SHA-256 `54E0261FD6260C4768D161BA25A90EDDB526269C6BBC448206FB5014710088D2`. Package validation: 10 entries, CRC 0, missing/extra 0/0, hash/size/SHA256SUMS mismatch 0, secret hits 0, absolute Windows paths 0, placeholder/ellipsis 0.

No Dart, application code, engine, Canon, composer, ReaderCopyRepair, UI, infographic, PDF/export generator, runtime test behavior, artifact or `product-acceptance/` changed. Full Flutter suite was not rerun because non-Markdown runtime delta is 0. Firebase/Production remain unchanged at Hosting release `1787994532335000`, version `869582a05e8db108`.

## PR110 merge, Hosting deploy and Production QA — complete (2026-08-29)

**PR110 MERGED AND DEPLOYED — UNKNOWN-TIME INPUT COPY PRODUCTION QA PASS — DOCS UPDATED — NO ROLLBACK.** Acceptance docs `10770703d6e660cf41cd910f62ec2dfafa464dea`; regular merge `4031049efc675d35c44660c0453bb432c50c8f06`, tree `b89ac1331f21b2fba6cce1c5979b43702ce73374`, merged `2026-08-29T15:51:39+07:00`. The exact merge was built and deployed only to Firebase Hosting `knowme-app-694e1` as release `1787994532335000`, version `869582a05e8db108`, at `2026-08-29T16:08:52.335+07:00`; rollback `1787985139294000` / `abd3efe5bbcb18db` was not used.

Gates: focused 191/191, full 1,625/1,625, analyzer baseline 298, audit 300/30,000 with impact counters 0, Known 19°19′, Unknown omissions, screenshot/input regression, diff-check and PostCommit pass. Production HTTP and local/remote asset hashes match; Desktop 1248×900 and mobile 390×844 Known↔Unknown QA has copy count 1/0 as expected, visual defects 0 and application console errors/warnings 0. Live Dedicated PDFs are 9/8 pages and Chrome browser-print PDFs 7/7; 31/31 pages were rasterized and opened with blank/clipping/overlap/overflow 0. Evidence is `C:\Users\USER\Documents\Knowme\PR110_PRODUCTION_QA_20260829T160852`. No Functions, Firestore, Storage, Rules, Indexes, Firebase config, Production data or `product-acceptance/` changed.

## PR110 Owner Acceptance — 2026-08-29

**OWNER REVIEW ACCEPTED — PR110 COPY AND VISUAL QA PASS — PENDING MERGE AND HOSTING DEPLOYMENT.** Accepted PR HEAD `158ed2d6b325c2464e097a92c6d68367b1d4191e`, implementation `4ff56e73fe8044b72940f4923de0ab95ea451edc`, ZIP SHA-256 `B13374B09CFC1A2A074ADEB67C1A190D82CE18F13FBD43A7A834407445FEB27C`. Owner accepted the exact old/new input copy, the one-line application delta and widget test, and desktop 1248×900/mobile 390×844 visual QA with no clipping, overlap or overflow. Known/report/export/Engine/Canon/asOf/infographic/PDF remain unchanged. Reference validation: focused 191/191, full 1,625/1,625, analyzer baseline 298, audit 300/30,000 impacts 0, PreCommit/PostCommit pass. This record is Markdown-only; PR #110 is not yet merged or deployed and Production/`product-acceptance/` remain unchanged.

## Thai Unknown-Time Input Copy Accuracy V1 — 2026-08-29

**THAI UNKNOWN-TIME INPUT COPY ACCURACY V1 COMPLETE — DRAFT PR — PENDING OWNER REVIEW — NOT MERGED — NOT DEPLOYED.** Draft PR #110, base `e094c789ec4e0dcd24d9b79a01c3bbd569f1c70c`, implementation/test `4ff56e73fe8044b72940f4923de0ab95ea451edc`. แก้เฉพาะ reader-visible input/help ใต้ `ฉันไม่ทราบเวลาเกิด`: old `ผลวิเคราะห์บางส่วนอาจคลาดเคลื่อน แต่ยังสามารถวิเคราะห์พื้นฐานได้` จาก legacy `112f4f5a`; new `หากไม่ทราบเวลาเกิด รายงานจะเว้นหัวข้อที่ต้องใช้เวลาเกิด เช่น ลัคนาและเรือน เพื่อไม่สรุปเกินข้อมูลที่มี`. Runtime fail-closed, Known flow, form behavior, report/export, Engine/Canon/asOf, infographic และ PDF ไม่เปลี่ยน.

Focused `191/191`, full `1,625/1,625`, analyzer exit 0 / baseline 298, audit 300 / 30,000 / impacts 0 และ PreCommit/PostCommit ผ่าน. Desktop 1248×900 กับ mobile 390×844 ผ่าน Known/Unknown และทั้งสองทิศทางการสลับ; visual/duplicate/console defects 0. ZIP `C:\Users\USER\Documents\Knowme\OWNER_REVIEW_THAI_UNKNOWN_TIME_INPUT_COPY_ACCURACY_V1_4ff56e7.zip`, SHA-256 `B13374B09CFC1A2A074ADEB67C1A190D82CE18F13FBD43A7A834407445FEB27C`, ตรวจ CRC/extraction/manifest/hash/secret ผ่าน. ไม่มี generated artifact, `product-acceptance/`, Firebase หรือ Production delta; release/version ปัจจุบันยังเป็น `1787985139294000` / `abd3efe5bbcb18db`.

## PR108 Production deployment closeout — 2026-08-29

**PR108 DEPLOYED — PRODUCTION KNOWN/UNKNOWN QA PASS — DOCS UPDATED — NO ROLLBACK.** Exact merge `8e2fec36f7b8a98bcb7dff3c5183951de8c9e507` / tree `3c887d85bcc715ab1981c41d246256647205302b` was built and deployed only to Firebase Hosting project/site `knowme-app-694e1`. Production release `1787985139294000`, version `abd3efe5bbcb18db`, completed at `2026-08-29T13:32:19.294+07:00`; `https://knowme-app-694e1.web.app/` and `/beta/thai` return HTTP 200 and exact build asset hashes. Rollback release `1787803668337000` was not used.

Pre-deploy: Focused 96/96, Narrative 38/38, Artifact 3/3, Canonical 11/11, R7 1/1, screenshot/geometry 10/10, regressions and PostCommit pass; audit 300 profiles / 30,000 fields / all impact counters 0. Production QA passed Known/Unknown Web desktop/mobile 390, two 1080×1920 infographics, Dedicated 9/8 and Chrome print 7/7, with 31/31 rasters inspected and blank/clipping/overlap/overflow 0. Known remains Aquarius 19°19′; Unknown fabricated time-dependent fields 0 and remains fail-closed. Inline-basis/stale hits 0; parity 262/262 with mismatch/missing/truncated/duplicate and semantic/omission/addition/traceability 0. Production correctly used rolling `29 ส.ค. 2569 – 28 ส.ค. 2570`; pinned `7 ส.ค. 2569 – 6 ส.ค. 2570` remains deterministic evidence. No QA account/persistent fixture was created. No non-Hosting Firebase resource, Production data, source/code/test/artifact or `product-acceptance/` changed. Evidence: `C:\Users\USER\Documents\Knowme\PR108_PRODUCTION_QA_20260829`.

## Inline Astrology Basis Dedup V1 — 2026-08-27

Implementation `5d42d146c1955fe1498bedc49934a471db6d177e` ถอด inline basis ซ้ำจากส่วน 1–3 โดยคงส่วน 4 และ traceability. Canonical 00:35 เชียงใหม่ = กุมภ์ 19°19′; technical/visual evidence complete. ZIP SHA-256 `4EEE4EA1B5175B6DB6F88D0A20DF98FA924B72050152825A23739CF91D4093A5`. `PENDING OWNER REVIEW`; ไม่ Merge/Deploy/Firebase/Production change.

**PR107 MERGED — OR3 DEPLOYED — PUBLIC PRODUCTION QA PASS — ROLLING HORIZON CONFIRMED — OWNER LANGUAGE ACCEPTED — DOCS CLOSED.** Correction (2026-08-27): `/beta/thai` เป็น public flow ไม่ต้อง Login และ Production contract ใช้ rolling `asOf` ณ เวลา submit หนึ่งครั้งต่อรายงาน ส่งผ่าน analysis/shared document เดียวไปยัง Web, infographic, Dedicated PDF และ Chrome browser print; วันสิ้นสุดคือวันก่อนครบรอบหนึ่งปีพร้อม leap-year clamp. OR3/golden fixture pin `7 ส.ค. 2569 – 6 ส.ค. 2570` เพื่อ deterministic evidence ขณะที่ live Production วันที่ 27 แสดง `27 ส.ค. 2569 – 26 ส.ค. 2570` อย่างถูกต้อง. ความต่างนี้เป็น expected environment/input difference ไม่ใช่ reader-copy, semantic หรือ Production defect; auth blocker และ horizon mismatch เดิมเป็นการจำแนกผิดและคงข้อความเดิมด้านล่างไว้เป็น audit trail. Public QA เดิมผ่าน Known/Unknown ทุก surface, infographic 1080×1920, Dedicated 9/8, Chrome print 7/7, rasters 31/31, stale 0, Unknown fail-closed และ layout defects 0. Evidence ZIP `C:\Users\USER\Documents\Knowme\PR107_PROD_PUBLIC_THAI_REPORT_QA_20260827T051048Z.zip`, SHA-256 `57BD75E65612DBC4DCF1AC3312204846D1C4A28509485C4E8C0836BAE5E6DBDC`. ไม่มี source/code/test/product artifact หรือ `product-acceptance/` delta; ไม่มี hotfix/redeploy/Firebase config/Production-data change และไม่ต้องสร้าง Owner package ใหม่.

**PR107 MERGED — OR3 DEPLOYED — PUBLIC PRODUCTION QA NOT COMPLETE: HORIZON CONTRACT MISMATCH.** `/beta/thai` เป็น public flow; ข้อสรุปเดิมว่าไม่มี authenticated session เป็น blocker ถูกแก้แล้ว. Anonymous Known/Unknown QA บน release `1787803668337000` / version `7ee3fac5ba6c97cc` ครบ Web desktop/mobile 390, infographic, Dedicated 9/8, Chrome print 7/7 และ raster 31 หน้า โดย layout/stale-copy ผ่านและ Unknown fail-closed. Blocker จริงคือ live infographic ใช้ wall-clock as-of จึงแสดง `27 ส.ค. 2569 – 26 ส.ค. 2570` ไม่ตรง Owner-accepted `7 ส.ค. 2569 – 6 ส.ค. 2570`. ไม่มี source fix, deploy, account, feedback, Production-data/Firebase/config หรือ `product-acceptance/` change; ต้องมี release decision/hotfix แยกก่อน rerun Production QA. Evidence ZIP: `C:\Users\USER\Documents\Knowme\PR107_PROD_PUBLIC_THAI_REPORT_QA_20260827T051048Z.zip`.

**PR107 OWNER LANGUAGE ACCEPTED — OR3.1 EVIDENCE CLOSEOUT COMPLETE — READY FOR FINAL MERGE DECISION — NOT MERGED — NOT DEPLOYED.** Acceptance ผูกกับ implementation `5e05d1c0c725064a8a833489a5904cff53871e02`, OR3 docs `be7df0d798142aec6bdc598052be5d7a6a13456b` และ OR3 ZIP SHA-256 `104A39A6A55E11F4A14211A464BB426B93C9955AB95EB1BE0A1B7C1CEA862A0A`. OR3.1 แก้เฉพาะ evidence/docs: provenance 8 entries ครบ 2 surfaces × 4 sections, errors 0 ทุกประเภท, negative boundaries 48 และ product artifacts 55 ไฟล์ตรง OR3 เดิมทุก hash. ZIP ใหม่ SHA-256 `74447E727B7B86AA262E94655B2DDF58BCCD0FE62E32072FA07ADB387B09531A`. Source/code/test/artifact และ `product-acceptance/` delta = 0; ไม่รัน Full suite ซ้ำเพราะไม่มี source/test delta. OR3 evidence ยังคง 96 focused, audit 300/12,651/impacts 0, full 1,623, Analyzer/PreCommit/PostCommit PASS. ไม่ Merge/Deploy/Firebase/Production change.

**PR107-OR3 COMPLETE — PENDING OWNER FINAL LANGUAGE RE-ACCEPTANCE.** OR2 ถูก Owner Reject ด้าน final human-sounding Thai copy ขณะที่ Visual/Structure/Infographic ผ่านและถูกล็อก. OR3 implementation `5e05d1c0c725064a8a833489a5904cff53871e02` แก้เฉพาะ reader-copy/test: Known เรียงความหมายก่อนหลักฐานและตัดภาษารายงาน; Unknown รวม opening/ข้อจำกัดซ้ำและทำ omission copy ให้เป็นธรรมชาติ โดย semantics/traceability/Engine/Canon/R1–R7.1/infographic/`product-acceptance/` ไม่เปลี่ยน. Focused 96/96, Narrative 38/38, Artifact 3/3, audit 300 / 12,651 / impact counters 0, Full 1,623/1,623, Analyzer exit 0 baseline 298 และ PreCommit PASS. QA ใหม่: Web 12, infographic 4×1080×1920, PDF 8/7/7/7, rasters 29/29; provenance 10 entries missing/mismatch 0. Owner ZIP SHA-256 `104A39A6A55E11F4A14211A464BB426B93C9955AB95EB1BE0A1B7C1CEA862A0A`. PR #107 คง Open + Draft; ไม่ Merge/Ready/Deploy/Firebase/Production change.

**PR106 DEPLOYED TO PRODUCTION — OWNER ACCEPTED — FULL AUTHENTICATED PRODUCTION QA PASSED — FIXTURE REMOVED.** PQ2 run `pr106_pq2_prod_qa_20260825T101222177Z` passed authenticated Known/Unknown Production QA on unchanged release `1787640954233000` / version `0aea9c854b86b99f`: Web desktop 1440/mobile 390, four 1080×1920 infographics, Dedicated PDF 9/8, Chrome browser-print 8/7, and all 32 PDF rasters. PQ1 Classification A explains fixture-dependent counts without weakening semantic/layout checks. Exact Auth, Firestore, tag, Storage-prefix and pending-job cleanup is 0/user-not-found. Evidence ZIP SHA-256 is `271C75CF207A91A218D97F6817A45CDBA9E649E2C438D59D1528897775B59789`; no source, test, artifact, deploy, Firebase configuration or `product-acceptance/` change occurred.

**PR106 PAGINATION AUDIT — FALSE NEGATIVE CONFIRMED — FULL AUTHENTICATED RE-QA STILL REQUIRED.** PQ1 classification: **A — content-dependent pagination**. OR3 and Production are source/rendering-equivalent but input/content-different; 8/7/7/7 is an OR3 fixture-specific measurement rather than a global golden. Production's extra pages contain real Section 4/evidence/omission content and show no blank, clipping, overlap or overflow defect. Full authenticated re-QA remains mandatory because the previous run did not complete Known/Unknown infographic surfaces at both 360 and 390. Evidence: `C:\Users\USER\Documents\Knowme\PR106_PROD_QA_20260825T083555850Z\PAGINATION_FORENSICS.md`. PQ1 is docs-only and made no source, test, artifact, deploy, Firebase, Production-data or `product-acceptance/` change.

**PR106 AUTHENTICATED PRODUCTION QA FAILED — FIXTURE REMOVED — NO CODE OR DEPLOY CHANGE.** Two synthetic Firebase Auth accounts exercised Production Known-time and Unknown-time on `2026-08-25`. Unknown remained fail-closed, but actual PDF counts were Dedicated 9/8 and Chrome browser-print 8/7 rather than accepted OR3 8/7/7/7. Exact cleanup passed: both UIDs are user-not-found, exact Firestore roots/subcollections are 0, and the run-tag Storage prefix is 0. No email, real-user access, source/test change, deploy, Firebase configuration/rules/schema/index change, or `product-acceptance/` delta occurred.

Console clarification: KnowMe runtime errors were 0; three extension message-channel errors were logged against the page URL and are disclosed browser-extension noise.

## Owner Review checkpoint — Draft PR #106

**PR106 DEPLOYED — PUBLIC/ASSET VERIFIED — AUTHENTICATED PRODUCTION QA BLOCKED.** Owner-accepted source `d63a6079372db1c23f6458f5a5dc10e4973c2c05` was deployed only to Firebase Hosting project/site `knowme-app-694e1` as release `1787640954233000`, version `0aea9c854b86b99f`, at `2026-08-25T13:55:54.233+07:00`; URL `https://knowme-app-694e1.web.app`. Public HTTP, exact release asset hashes, desktop 1440/mobile 390 rendering, routing and application console smoke pass. Focused 95/95, audit 300/8,956/impacts 0, narrative 38/38, artifact 3/3 and bundle guards passed; exact source identity permits reference to OR3 full 1,622/1,622 and Analyzer/PreCommit/PostCommit. The available authenticated session had no completed safe QA report fixture, so Known/Unknown copy, infographic and PDF/Print are not claimed as live-verified; no real user data was changed. Rollback baseline `1787482140137000` / `e563b9b6df94ef81` was not used. Only Hosting changed; all other Firebase resources and Production data remain unchanged.

**PR106 MERGED TO MAIN — OWNER ACCEPTED — NOT DEPLOYED — READY FOR RELEASE DECISION.** PR #106 merged via regular merge commit `4be5eddca88b13ea1303480c0370e46d91f3c425` at `2026-08-25T13:10:39+07:00`, from base `58b1d742f7a00ef9c882c1fad2357dbcf08f3ad0` and PR HEAD `c422c4748c30d7c9ca7d722fe0624857614edb7a`. GitHub reports MERGED and no checks. Post-merge tree matches PR HEAD exactly, with unexpected paths 0 and `product-acceptance/` delta 0. Owner Final Language Acceptance PASS remains bound to implementation `d516477a808f7ff2fe791e561451c68043796301`, OR3 source/evidence `f5780d4881b8dbf91138bb6bdb3e773a4ba77c5f`, and ZIP SHA-256 `42F729EF2E14AAB8200B0911E96DF565DBDCB2BFA7D18DEC8D0D7528BEE5DC11`. Reference results remain Focused 95/95, copy audit 300 / 8,956 / impacts 0, full 1,622/1,622, Analyzer/PreCommit/PostCommit pass and PDFs 8/7/7/7. This closeout is docs-only. No deploy or Firebase/Production change; next step is a separately authorized Release/Deployment Decision.

Historical final merge-readiness checkpoint follows.

**PR106 OWNER ACCEPTANCE PASSED — READY FOR FINAL MERGE DECISION.** Owner decision: `PR106-OR3 OWNER FINAL LANGUAGE ACCEPTANCE: PASS`, scoped to implementation `d516477a808f7ff2fe791e561451c68043796301`, pre-closeout HEAD `f5780d4881b8dbf91138bb6bdb3e773a4ba77c5f`, and `OWNER_REVIEW_PR106_OR3_d516477.zip` SHA-256 `42F729EF2E14AAB8200B0911E96DF565DBDCB2BFA7D18DEC8D0D7528BEE5DC11`. OR1 passed Visual/Structure but failed language; OR2 fixed the main issues but failed Final Editorial Quality; OR3 passed Visual, Structure, Infographic and Known/Unknown Final Thai Language. Sections 1–4, infographic after `แนวโน้ม 12 เดือนข้างหน้า`, and exact `7 ส.ค. 2569 – 6 ส.ค. 2570` range passed. Unknown stays fail-closed; `monthlyTimelineAvailable=false`; no good/caution months or monthly predictions. Reference results: Focused 95/95, 300 profiles / 8,956 fields / impacts 0, full 1,622/1,622, Analyzer/PreCommit/PostCommit pass, PDF pages 8/7/7/7. This closeout is docs/status-only. PR #106 has not been merged or deployed; Firebase/Production are unchanged.

Historical pre-acceptance OR3 checkpoint follows.

**PR106-OR3 TECHNICAL VALIDATION COMPLETE — PENDING OWNER FINAL LANGUAGE RE-ACCEPTANCE.** OR2 passed Visual/Structure/PDF/Technical Validation but was rejected for Final Thai Editorial Quality. OR3 is a copy-only final sweep at final source commit `d516477a808f7ff2fe791e561451c68043796301`. Focused 95/95, 300-profile / 8,956-field audit with every impact counter 0, full 1,622/1,622, analyzer, PreCommit and PostCommit pass. Fresh Web desktop/mobile, four 1080×1920 infographics, Dedicated 8/7 and Chrome print 7/7 pages plus all rasters/contact sheets are verified in `C:\Users\USER\Documents\Knowme\OWNER_REVIEW_PR106_OR3_d516477.zip` (SHA-256 `42F729EF2E14AAB8200B0911E96DF565DBDCB2BFA7D18DEC8D0D7528BEE5DC11`). PR #106 must remain Open + Draft; no Owner/Product Acceptance, merge, Ready-for-Review, deploy or Firebase/Production change.

Historical OR2 checkpoint follows.

**PR106-OR2 COMPLETE — PENDING OWNER LANGUAGE RE-ACCEPTANCE.** OR1 passed
visual/structure review and was rejected for language. The limited OR2 copy and
consistency repair is implemented at
`7a03a0ca4a692b0caa7dcdf6c51ae7fbf1ae4892`; technical validation and fresh
artifact QA are complete. Review package:
`C:\Users\USER\Documents\Knowme\OWNER_REVIEW_PR106_OR2_7a03a0c.zip`.
Dedicated Known/Unknown is 8/7 pages and Chrome browser-print is 7/7. PR #106
must remain Open, Draft, unmerged and undeployed. This checkpoint does not
grant Owner/Product Acceptance.

Historical OR1 checkpoint follows.

**PR106-OR1 COMPLETE — PENDING OWNER VISUAL AND LANGUAGE RE-ACCEPTANCE.**
Source repair is complete at implementation commit
`b5526dd33441e96e47308c038f9fc15de119f6e9`. Final actual evidence measures
Dedicated Known/Unknown 8/7 pages and Chrome browser-print 7/7 pages, includes
four 1080×1920 infographics plus desktop/mobile Web captures, and is packaged
at `C:\Users\USER\Documents\Knowme\OWNER_REVIEW_PR106_OR1_b5526dd.zip`.
All technical gates pass; this does not grant Owner/Product Acceptance. Keep
PR #106 Open, Draft, unmerged and undeployed.

The previous rejected review checkpoint was validated at source HEAD
`f0931fd581c7ea24567cbee165146c7d725f14e0`. A verified Owner Review package
contains Known/Unknown dedicated PDFs (9/8 pages), Chrome browser-print PDFs
(7/7 pages), four 1080×1920 surface-360/390 infographics, contact sheets and
all page renders. Status is **PENDING OWNER VISUAL AND LANGUAGE ACCEPTANCE**;
this checkpoint does not grant Product/Owner Acceptance. No source code was
changed and the full suite was not rerun. PR #106 remains Open and Draft; no
merge, deployment or Firebase/Production change occurred.

## Owner feedback

The current Production Thai report has five connected reader-facing defects:

1. The reading order feels arbitrary.
2. The report does not identify its major parts clearly.
3. The 1080x1920 infographic is visually weak and wastes space.
4. The infographic says `ดวงชะตาปี 2569` while its evidence is a rolling
   next-12-month window.
5. Several Thai sentences remain mechanical or difficult to understand.

## Outcome

Create one shared Web / dedicated-PDF / browser-print reading flow:

1. `ส่วนที่ 1 · พื้นดวงของคุณ`
2. `ส่วนที่ 2 · จังหวะชีวิตที่ผ่านมาและปัจจุบัน`
3. `ส่วนที่ 3 · แนวโน้มข้างหน้า`
4. `ส่วนที่ 4 · ที่มาและข้อจำกัด`

The infographic belongs after the next-12-month narrative, uses the truthful
title `แนวโน้ม 12 เดือนข้างหน้า`, and shows the exact rolling date range. It
must not imply calendar-year or month-level evidence.

## Boundaries

- Presentation and deterministic reader copy only.
- Preserve Thai Engine, Canon, calculations, ascendant/houses, Thai day basis,
  life-period boundaries, evidence trace IDs, Known/Unknown fail-closed rules,
  Auth, Firebase data/rules, feedback, and audience policy.
- `monthlyTimelineAvailable` remains `false`; do not invent good/bad months.
- Do not edit accepted R1-R7.1 or PR #100 product-acceptance artifacts.
- No merge, deployment, or Firebase mutation in this task.

## Acceptance

- Web, dedicated PDF, and browser print share the same chapter order.
- Every major part has a visible chapter label and short orientation line.
- Domain labels inside mixed sections are visually distinct from body copy.
- The infographic is inserted after `แนวโน้ม 12 เดือนข้างหน้า`.
- The infographic title and date range agree with rolling 12-month evidence.
- The redesigned 1080x1920 image has no clipping, overlap, overflow, or large
  accidental empty region at 360px and 390px surfaces.
- Owner fixture language is natural, direct Thai without changing factual
  anchors or adding predictions.
- Focused tests, full policy, analyzer, Web/PDF parity, infographic raster,
  browser-print, documentation, PreCommit and PostCommit gates are recorded
  truthfully. If the required Flutter toolchain is unavailable, do not waive or
  claim those gates.
# Thai Report Conversational Plain Language V1

สถานะ 2026-08-26: implementation และ technical/visual evidence complete; Draft PR pending Owner Language Acceptance. Implementation `01d27911b2ce0b647016dde0074fa35c4aa3827b`; Owner ZIP SHA-256 `C86808698126A30617C0035EFDCAF99CE368983916061D1175BBE98DED9A42A8`. ไม่ Merge, Deploy หรือเปลี่ยน Firebase/Production

## Owner Review OR1

Owner ไม่รับภาษา V1 รอบแรกและกำหนด OR1. แก้ copy แบบจำกัดขอบเขตที่ implementation `40967efa42662e75fd0901d68f3f407891b85057`; technical/visual gates ผ่านและสร้าง Owner ZIP SHA-256 `CD3FF9C1FA5AAA2BB021E0B97576A5E7C1A379EAD19ADCAC567BBCF915B773EE`. สถานะ `PENDING OWNER LANGUAGE RE-ACCEPTANCE`; PR #107 ยังคง Draft และยังไม่ Merge/Deploy/Firebase/Production change

## Owner Review OR2

OR1 ถูก Owner Reject ด้านภาษา จึงทำ OR2 final conversational polish แบบ copy/test-only. Implementation `0f5b7e86e16a8f7f99af6856daa35f8a2a4e5b8b`; focused 95/95, copy audit 300 profiles / 11,414 fields impacts = 0, full suite 1,622/1,622, analyzer/PreCommit/PostCommit ผ่าน. PDF จริง 8/7/7/7 หน้าและ visual QA ผ่าน. Owner ZIP SHA-256 `24D74EA3CDE2311CF3335A07EFC7C5E80B62AA3C31B4367F3BC53C45E8A7F8EB`. สถานะ `PENDING OWNER FINAL LANGUAGE RE-ACCEPTANCE`; PR #107 คง Draft ไม่ Merge/Deploy/Firebase/Production change

## PR108 OR1 closeout — 2026-08-28

Owner Reject ชุดแรกด้าน cross-variant copy/evidence. OR1 `647e1f0` ผ่าน focused 96/96, audit 300 profiles / 30,000 examined / impacts 0, full 1,623/1,623, analyzer/PreCommit และ visual QA PDF 8/7/7/7; visual blank 0. ZIP SHA-256 `5C13B2B644945C9309E5B691C67A3978D3052BCC7DAB56F6D62604D9D00838B7`. `PENDING OWNER RE-REVIEW`; Draft, ไม่ Merge/Deploy/Firebase/Production
# PR108 OR2 status (2026-08-29)

At evidence delivery the status was `PENDING OWNER RE-REVIEW`. OR1 evidence was rejected for incomplete 12,049-field “other” accounting, assertion-only parity, duplicate Known/Unknown Web contact sheets and absent actual scroll geometry. OR2 reader copy is frozen. The 13,174 figure is the historical/raw audit population classified during reconciliation, not the PR108 delta. Actual PR108 baseline-to-candidate changes are 1,587 fields: A=1,125 and B=462; C=0, E=0, F=0. D=11,587 has `baselineValue == candidateValue`, was present at the PR108 base and is unchanged by PR108. Implementation/test commit is `d78c5f641563ca5810c8952191e217cd31502d57`; evidence/docs HEAD was `ec2ecbaa1f9f21fe69df6476f9d0fed0a39f5120`.

Evidence passes: parity 262/262; captures 18/18; copy audit 300 profiles / 30,000 fields with all semantic impacts 0; focused 96/96; narrative 38/38; artifact 3/3; full 1,623/1,623; analyzer and PreCommit pass. Final ZIP SHA-256 is `D47AE77CAC12E4D924E5FF4A200786251F34B4646AE5DEAAA373D8C483F41EB1`. At evidence delivery PR was Open + Draft; it was not merged or deployed, and Firebase/Production and `product-acceptance/` were unchanged.

## PR108 Owner Acceptance — 2026-08-29

Owner independently verified ZIP CRC/SHA256SUMS and accepted OR2 scope, copy and evidence. Inline/stale hits 0; parity 262/262 with all error counters 0; geometry 18/18; PDFs Dedicated 8/7 and Browser-print 7/7; page 5 is an image-only infographic; visual defects 0. This acceptance update is one docs-only commit (exact commit SHA is the final PR HEAD). Required final PR state: Open + Ready for Review. Do not merge, deploy, regenerate artifacts, change Firebase/Production or modify `product-acceptance/`.
