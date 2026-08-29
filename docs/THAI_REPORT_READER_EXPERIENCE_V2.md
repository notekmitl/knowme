# Thai Report Reader Experience V2

## Inline Astrology Basis Dedup V1 — 2026-08-27

Owner feedback ระบุว่าประโยค “อ่านจาก/ดูจากเรือน” ในคำทำนายส่วน 1–3 ซ้ำกับส่วน 4. Implementation `5d42d146c1955fe1498bedc49934a471db6d177e` ถอดเฉพาะ basis ตาม semantic role โดยคง prediction/advice, “รายงานนี้ดูจากอะไร”, วิธีนับวันไทย, โครงสร้างดวง, ลัคนา/เจ้าเรือน/เรือน, disclaimers, Canon และ provenance/traceability. Unknown ยัง fail-closed และ canonical 00:35 เชียงใหม่ยังเป็นกุมภ์ 19°19′. Technical/visual QA complete; `PENDING OWNER REVIEW — NOT MERGED — NOT DEPLOYED`.

## PR107 Rolling Production Horizon Contract Correction

Status: **MERGED AND DEPLOYED — PUBLIC PRODUCTION QA PASS — ROLLING HORIZON CONFIRMED — OWNER LANGUAGE ACCEPTED — DOCS CLOSED**. Owner ยืนยันว่า Production ใช้ rolling `asOf` ณ เวลา submit ส่วน Owner Review/golden/deterministic fixture pin `asOf` ได้. Public `/beta/thai` ไม่ต้อง Login; input จับ submit time หนึ่งครั้ง, analysis แปลงเป็น Bangkok civil และ shared export document เดียวป้อน Web, infographic, Dedicated PDF และ Chrome browser print. Period helper ใช้วันก่อนครบรอบหนึ่งปีและ clamp วันที่ที่ไม่มีในปีเป้าหมายสำหรับ leap-year boundary. OR3 pinned `7 ส.ค. 2569 – 6 ส.ค. 2570` จึงยังเป็น accepted deterministic evidence; live Production `27 ส.ค. 2569 – 26 ส.ค. 2570` ถูกต้องตาม rolling contract. ความต่างเป็น expected environment/input difference ไม่ใช่ reader-copy, semantic หรือ Production defect. Auth blocker และ horizon mismatch เดิมเป็นการจำแนกผิด; รายการเดิมด้านล่างคงไว้เป็น correction trail. Evidence เดิมผ่าน Known canonical, Unknown fail-closed, Web desktop/mobile 390, infographic 1080×1920, Dedicated 9/8, Chrome print 7/7, raster 31/31, stale 0 และ blank/clipping/overlap/overflow 0: `C:\Users\USER\Documents\Knowme\PR107_PROD_PUBLIC_THAI_REPORT_QA_20260827T051048Z.zip`, SHA-256 `57BD75E65612DBC4DCF1AC3312204846D1C4A28509485C4E8C0836BAE5E6DBDC`. ไม่มี source/code/test/product artifact หรือ `product-acceptance/` delta; ไม่มี hotfix/redeploy/Firebase configuration/Production-data change และไม่ต้องสร้าง Owner package ใหม่.

## PR107 Final Merge and Production Release

Status: **MERGED AND DEPLOYED — PUBLIC PRODUCTION QA NOT COMPLETE: HORIZON CONTRACT MISMATCH**. `/beta/thai` เป็น public route และไม่ต้อง login; ข้อความ auth blocker เดิมไม่ถูกต้อง. Live Known/Unknown ผ่านการเปิด Web desktop/mobile 390, infographic 1080×1920, Dedicated 9/8, Chrome print 7/7 และ raster 31 หน้า. Known คง 00:35/เชียงใหม่/วันเสาร์ก่อนพระอาทิตย์ขึ้น/ลัคนากุมภ์ 19°19′; Unknown ไม่สร้างลัคนา เรือน หรือ timing ที่ต้องใช้เวลาเกิด. สี่ส่วน, `แนวโน้ม 12 เดือนข้างหน้า`, no monthly forecast และ stale phrase audit ผ่าน; ไม่พบ blank/clipping/overlap/overflow. แต่ live range คือ `27 ส.ค. 2569 – 26 ส.ค. 2570` เพราะ analysis ใช้ submit wall clock เป็น `asOf`, ไม่ตรง Owner-accepted `7 ส.ค. 2569 – 6 ส.ค. 2570`. จึงไม่อ้าง Production QA PASS และไม่ได้แก้ source/redeploy. Evidence ZIP อยู่ที่ `C:\Users\USER\Documents\Knowme\PR107_PROD_PUBLIC_THAI_REPORT_QA_20260827T051048Z.zip`; ไม่มี account, feedback, Production-data/Firebase/config หรือ `product-acceptance/` change.

## PR107-OR3.1 — Evidence-only Owner Language Acceptance Closeout

Status: **OWNER LANGUAGE ACCEPTED — READY FOR FINAL MERGE DECISION — NOT MERGED — NOT DEPLOYED**. Owner รับ OR3 Language/Visual ที่ implementation `5e05d1c0c725064a8a833489a5904cff53871e02`, docs `be7df0d798142aec6bdc598052be5d7a6a13456b` และ ZIP SHA-256 `104A39A6A55E11F4A14211A464BB426B93C9955AB95EB1BE0A1B7C1CEA862A0A`. OR3.1 ไม่เปลี่ยน reader-facing copy, UI, infographic, PDF generator, source หรือ tests; เพิ่มเฉพาะ full Before/After และ validator ที่ตรวจ normalized full blocks แบบ exact พร้อม source/surface/section/page/line/boundary. Provenance 8 entries ครบ Known/Unknown × ส่วน 1–4; missing/mismatch/truncated/boundary/coverage = 0; negative checks 48. Product artifacts 55 ไฟล์ตรง accepted OR3 ทุก SHA-256. ZIP ใหม่ SHA-256 `74447E727B7B86AA262E94655B2DDF58BCCD0FE62E32072FA07ADB387B09531A`; CRC/extraction/manifest/secret scan errors 0. OR3 results 96 focused, audit 300/12,651/impacts 0, full 1,623, Analyzer/PreCommit/PostCommit ยังคงใช้ได้; ไม่ rerun Full suite เพราะ source/test delta 0. `product-acceptance/`, Firebase และ Production ไม่เปลี่ยน.

## PR107-OR3 — Final Human-Sounding Thai Copy Closure

Status: **TECHNICAL CLOSURE COMPLETE — PENDING OWNER FINAL LANGUAGE RE-ACCEPTANCE**. OR2 Visual/Structure/Infographic ผ่าน แต่ Owner Reject ภาษา Web/PDF ที่ยังเป็นภาษารายงาน/ระบบและมีข้อความซ้ำ. OR3 implementation `5e05d1c0c725064a8a833489a5904cff53871e02` แก้เฉพาะ reader-visible narrative และ regression tests: Known วางความหมายก่อน canonical evidence; Unknown รวม opening/ข้อจำกัดที่ซ้ำและทำ Section 4/omission rows ให้เป็นภาษาคน. คง four-section order, infographic placement/copy/design (**Unchanged OR2 → OR3**), `แนวโน้ม 12 เดือนข้างหน้า`, `7 ส.ค. 2569 – 6 ส.ค. 2570`, `monthlyTimelineAvailable=false`, Unknown fail-closed, semantics, traceability, Engine, Canon, R1–R7.1 และ `product-acceptance/`. ผลจริง: 96 focused, 38 narrative, 3 artifact, audit 300 / 12,651 / impacts 0, full 1,623, Analyzer baseline 298 / exit 0 และ PreCommit PASS. Fresh evidence มี Web 12 captures, infographic 4×1080×1920, Dedicated 8/7, Chrome print 7/7, PDF rasters 29/29, provenance 10 entries missing/mismatch 0; ZIP SHA-256 `104A39A6A55E11F4A14211A464BB426B93C9955AB95EB1BE0A1B7C1CEA862A0A`. PR #107 ยัง Open + Draft; ไม่ Merge/Ready/Deploy/Firebase/Production change.

## Production QA closeout — PR106-PQ2

Status: **PR106 DEPLOYED TO PRODUCTION — OWNER ACCEPTED — FULL AUTHENTICATED PRODUCTION QA PASSED — FIXTURE REMOVED**. Run `pr106_pq2_prod_qa_20260825T101222177Z` confirmed the accepted four-part flow, infographic placement, natural Known/Unknown reading, Unknown fail-closed omission, and no-monthly contract on Production. Coverage includes desktop 1440/mobile 390 Web, Known/Unknown infographic surfaces 360/390 at 1080×1920, Dedicated PDFs 9/8, Chrome browser-print PDFs 8/7, and all 32 rastered pages. No blank page, clipping, overlap, overflow, duplicated/missing section, or KnowMe-origin runtime error was found. Cleanup and unchanged Hosting release/version are machine-recorded in the PQ2 evidence package, SHA-256 `271C75CF207A91A218D97F6817A45CDBA9E649E2C438D59D1528897775B59789`.

Status: **PR106 PAGINATION AUDIT — FALSE NEGATIVE CONFIRMED — FULL AUTHENTICATED RE-QA STILL REQUIRED**. PQ1 assigns **Classification A: content-dependent pagination**. OR3 and Production share byte-equivalent app/PDF/print source and materially equivalent rendering settings, but not profile inputs or as-of dates. Different narrative and atomic-block distribution explains Production 9/8/8/7 versus OR3 8/7/7/7; added pages contain substantive Section 4/evidence/omission text and have no observed blank, clipping, overlap or overflow defect. The corrected contract treats OR3 counts as fixture-specific and uses semantic/layout invariants across profiles. Production acceptance remains incomplete because Known/Unknown infographic 360/390 coverage was incomplete. Full authenticated re-QA remains required. No code, tests, artifacts, deploy, Firebase, Production data or `product-acceptance/` changed.

Status: **PR106 AUTHENTICATED PRODUCTION QA FAILED — FIXTURE REMOVED — NO CODE OR DEPLOY CHANGE**. Live Known-time and Unknown-time reports were opened with two synthetic Firebase Auth accounts on `2026-08-25`. Unknown preserved fail-closed omission, but fresh PDFs measured Dedicated 9/8 and Chrome browser-print 8/7 pages, which does not match Owner-accepted OR3 evidence 8/7/7/7. Both exact UIDs now return user-not-found; exact Firestore roots/subcollections and the run-tag Storage prefix are all 0. No real account, external email, source, test, deployment, Firebase configuration, rules, schema, index, or `product-acceptance/` mutation occurred. Production remains release `1787640954233000`, version `0aea9c854b86b99f`.

Console clarification: KnowMe runtime errors were 0; three extension message-channel errors were logged against the page URL and are disclosed browser-extension noise.

Status: **PR106 DEPLOYED — PUBLIC/ASSET VERIFIED — AUTHENTICATED PRODUCTION QA BLOCKED**. Exact source `d63a6079372db1c23f6458f5a5dc10e4973c2c05` was deployed only to Firebase Hosting project/site `knowme-app-694e1` at `2026-08-25T13:55:54.233+07:00`, release `1787640954233000`, version `0aea9c854b86b99f`, URL `https://knowme-app-694e1.web.app`. The clean production bundle passes API/localhost/secret/debug guards; Production index, bootstrap and main bundle hashes exactly match local. Desktop 1440 and mobile 390 Chrome smoke passes public rendering/routing with application-origin console errors 0. Owner Acceptance for sections 1–4, infographic placement, `แนวโน้ม 12 เดือนข้างหน้า`, `7 ส.ค. 2569 – 6 ส.ค. 2570`, Known/Unknown language, fail-closed behavior and `monthlyTimelineAvailable=false` remains bound to the accepted source/evidence. Live authenticated verification of those report surfaces and PDF/Print is not claimed because no completed safe QA fixture existed in the available session. Rollback baseline `1787482140137000` / `e563b9b6df94ef81` was not used. Only Hosting changed; no other Firebase resource or Production data changed.

Status: **PR106 MERGED TO MAIN — OWNER ACCEPTED — NOT DEPLOYED — READY FOR RELEASE DECISION**. PR #106 merged by regular merge commit `4be5eddca88b13ea1303480c0370e46d91f3c425` at `2026-08-25T13:10:39+07:00` from PR HEAD `c422c4748c30d7c9ca7d722fe0624857614edb7a`. The merge tree exactly matches the PR head; unexpected paths and `product-acceptance/` delta are 0. Owner Final Language Acceptance PASS applies to implementation `d516477a808f7ff2fe791e561451c68043796301`, OR3 source/evidence `f5780d4881b8dbf91138bb6bdb3e773a4ba77c5f`, and ZIP SHA-256 `42F729EF2E14AAB8200B0911E96DF565DBDCB2BFA7D18DEC8D0D7528BEE5DC11`. Accepted scope includes sections 1–4, infographic placement, `แนวโน้ม 12 เดือนข้างหน้า`, exact date `7 ส.ค. 2569 – 6 ส.ค. 2570`, Known/Unknown language, Unknown fail-closed behavior and the no-monthly contract. Reference validation remains 95/95, 300 / 8,956 / impacts 0, 1,622/1,622 and Analyzer/PreCommit/PostCommit pass; PDFs are 8/7/7/7. GitHub reports no check runs. Production has not been deployed and Firebase/Production are unchanged. Next step: Release/Deployment Decision.

Historical final merge-readiness status follows.

Status: **PR106 OWNER ACCEPTANCE PASSED — READY FOR FINAL MERGE DECISION**. Owner decision `PR106-OR3 OWNER FINAL LANGUAGE ACCEPTANCE: PASS` applies to implementation commit `d516477a808f7ff2fe791e561451c68043796301`, pre-closeout HEAD `f5780d4881b8dbf91138bb6bdb3e773a4ba77c5f`, and ZIP SHA-256 `42F729EF2E14AAB8200B0911E96DF565DBDCB2BFA7D18DEC8D0D7528BEE5DC11`. OR1 passed Visual/Structure but failed language; OR2 repaired the main language issues but failed Final Editorial Quality; OR3 passed Visual, Structure, Infographic and Final Thai Language for Known/Unknown. Owner accepted sections 1–4, infographic placement, `แนวโน้ม 12 เดือนข้างหน้า` and `7 ส.ค. 2569 – 6 ส.ค. 2570`. Unknown remains fail-closed and omits time-dependent topics. `monthlyTimelineAvailable=false`; there are no good months, caution months or monthly predictions. Reference validation is Focused 95/95, audit 300 profiles / 8,956 fields / impacts 0, full 1,622/1,622 and Analyzer/PreCommit/PostCommit pass; PDFs are 8/7/7/7 pages. Closeout is docs/status-only. Not merged, not deployed; Firebase/Production unchanged.

Historical pre-acceptance OR3 status follows.

Status: **PR106-OR3 TECHNICAL VALIDATION COMPLETE — PENDING OWNER FINAL LANGUAGE RE-ACCEPTANCE**. OR2 passed Visual/Structure/PDF/Technical Validation but was Owner-rejected for Final Thai Editorial Quality. OR3 performs a candidate-only copy sweep at final source commit `d516477a808f7ff2fe791e561451c68043796301`, preserving semantics, traceability, four-part structure, infographic position/design, exact rolling date, Unknown fail-closed behavior and accepted R1–R7.1. Fresh validation passes focused 95/95, audit 300 profiles / 8,956 fields with all impacts 0, full 1,622/1,622, analyzer, PreCommit and PostCommit. Dedicated pages are 8/7; Chrome print is 7/7. Owner package: `C:\Users\USER\Documents\Knowme\OWNER_REVIEW_PR106_OR3_d516477.zip` (SHA-256 `42F729EF2E14AAB8200B0911E96DF565DBDCB2BFA7D18DEC8D0D7528BEE5DC11`). No Acceptance, merge, Ready-for-Review, deploy or Firebase/Production change.

Historical OR2 status follows.

Status: **PR106-OR2 COMPLETE — PENDING OWNER LANGUAGE RE-ACCEPTANCE**. OR1
passed visual/structure review and was Owner-rejected for language. OR2 is a
limited copy/consistency repair at implementation commit
`7a03a0ca4a692b0caa7dcdf6c51ae7fbf1ae4892`; Draft PR #106 remains Open and
Draft.

Unknown now uses the same explicit fail-closed omission statement on Web,
Dedicated PDF, browser print and infographic. The six omitted-topic reasons,
all past-reflection age bands and the Unknown conclusion were repaired without
new predictions or semantic/traceability impact. Fresh actual QA measures
Dedicated Known/Unknown 8/7 pages and Chrome browser-print 7/7 and verifies all
Web captures, four 1080x1920 infographics and every PDF page. No Owner/Product
Acceptance is claimed.

Owner-rejected mechanical phrases were repaired through candidate-only copy
rules with 300-profile semantic impact 0. Dedicated pagination now follows
measured semantic flow instead of fixed paragraph/NewPage assumptions; the
actual Owner fixtures measure 8/7 pages, versus Chrome browser-print 7/7. Fresh
Web desktop/mobile, four 1080×1920 infographic and every-page PDF renders are
in the external Owner package. No Owner/Product Acceptance is claimed.

Base: `58b1d742f7a00ef9c882c1fad2357dbcf08f3ad0`

Date: 2026-08-24

## Owner feedback addressed

The Production report mixed lifelong reading, past reflection, current stage,
future guidance, methodology and the infographic without a visible hierarchy.
The infographic also used the calendar-year title `ดวงชะตาปี 2569` while the
underlying consumer evidence described a rolling next-12-month window. Several
reader sentences retained system-like phrasing and duplicated labels.

## Shared reading order

Web, dedicated PDF and browser print now consume the same ordered export model:

1. `ส่วนที่ 1 · พื้นดวงของคุณ`
2. `ส่วนที่ 2 · จังหวะชีวิตที่ผ่านมาและปัจจุบัน`
3. `ส่วนที่ 3 · แนวโน้มข้างหน้า`
4. `ส่วนที่ 4 · ที่มาและข้อจำกัด`

Each chapter has a short orientation line. Domain labels such as `การงาน`,
`การเงิน`, `ความรัก` and `สุขภาพ` are rendered as headings rather than body
paragraphs. The old unlabeled divider before the timeline is removed.

Within the future chapter, the order is current decision, rolling 12-month
narrative, infographic, long-term life-period context, next-period preparation
and closing guidance. The image therefore appears immediately after the text
it summarizes.

## Rolling 12-month contract

- Reader title: `แนวโน้ม 12 เดือนข้างหน้า`
- Period label: exact start and inclusive end dates derived from `analysis.asOf`
  (for example `7 ส.ค. 2569 – 6 ส.ค. 2570`)
- No calendar-year claim in the reader title
- `monthlyTimelineAvailable=false`
- No invented good/bad months or monthly score
- The Buddhist start year remains internal metadata for deterministic file
  naming and provenance only

## Infographic redesign

The 360x640 logical canvas (exported at 1080x1920) now uses a compact premium
navy/indigo system with a gold frame, a clearly separated period pill, a theme
card, a 2x2 domain grid, paired opportunity/caution cards, one action card and
a small evidence-boundary footer. A low-opacity Thai lotus ornament is used as
background detail instead of occupying a large empty block.

The same PNG is embedded by the dedicated PDF and browser-print paths. Layout
keys and raster tests cover title, period, theme, all four domains,
opportunity, caution, action, disclaimer and decorative ornament.

## Language repair

Reader copy was revised at the presentation/composer boundary only:

- lifelong core-reading sentences now state the relationship between the
  chart evidence and the reader meaning directly;
- past reflection uses age-appropriate natural questions, including home,
  caregiver, play and learning for childhood;
- current-stage duplicate labels are removed;
- current, 12-month and next-period summaries use direct decisions,
  observable review signals and clearer conjunctions;
- the dormant reader-copy rule that could restore `ราว 12 เดือนข้างหน้า` was
  removed so the exact date range remains authoritative.

## Preserved contracts

This draft does not change the Thai astrology engine, Canon, calculations,
ascendant, houses, Thai astrological-day basis, life-period boundaries, evidence
trace IDs, Known/Unknown fail-closed rules, Auth, Firebase, feedback or audience
policy. Accepted R1-R7.1 and PR #100 product-acceptance artifacts are untouched.

## Validation status

Flutter 3.41.1 / Dart 3.11.0 validation is complete through the local
pre-commit test boundary:

- all four focused commands pass: 91, 1, 38 and 3 tests;
- the 300-profile audit passes with 4,884 changed fields and zero omission,
  addition, semantic, prediction/advice or traceability impact;
- the required full suite passes 1,618/1,618;
- analyzer exits 0 with 298 non-fatal baseline warnings/infos;
- Known/Unknown 360px and 390px surfaces export deterministic 1080x1920 PNGs
  and all four files pass direct visual inspection;
- dedicated PDFs pass direct every-page review at Known 9 / Unknown 8 pages;
- real Chrome browser-print PDFs pass at Known 7 / Unknown 7 pages;
- Web/shared-model, dedicated-PDF and browser-print chapter order and forbidden
  title checks pass; no monthly predictions are present.

Repository PreCommit and PostCommit pass, implementation commit
`2f59602867c6ce5c53bd76d00efe2645121e7d68` is pushed and Draft PR #106 is
open. GitHub reports a clean merge state but exposes no check runs or Actions
runs for this branch, so there is no remote check result to call green. No
merge, deployment or Firebase mutation is authorized.
# Conversational Plain Language V1 closeout — 2026-08-26

ปรับเฉพาะ candidate reader-copy ให้เป็นภาษาไทยสนทนาที่ตรงและใช้ได้จริง โดยคงลำดับส่วน 1–4, “แนวโน้ม 12 เดือนข้างหน้า”, วันที่ 7 ส.ค. 2569 – 6 ส.ค. 2570, `monthlyTimelineAvailable=false`, Unknown fail-closed, Canon/engine/semantics/traceability เดิม ผล audit 300 profiles / 10,189 fields มี impacts ทุกมิติ = 0 และหลักฐาน visual/PDF พร้อมรอ Owner Language Acceptance

# Conversational Plain Language V1 Owner Review OR1 — 2026-08-26

หลัง Owner Reject ภาษา V1 รอบแรก OR1 เรียบเรียง candidate copy ใหม่ตามบริบทให้ความหมายมาก่อนศัพท์โหราศาสตร์ ลดคำนามนามธรรมและบอกการกระทำให้ชัด โดยไม่เปลี่ยนโครงสร้าง 4 ส่วน, canonical Known, Unknown fail-closed, วันที่จริง, `monthlyTimelineAvailable=false`, engine, Canon หรือ traceability. Implementation `40967efa42662e75fd0901d68f3f407891b85057`; audit 300 profiles / 11,339 fields มี impacts = 0 และ visual/PDF QA ผ่าน. สถานะ `PENDING OWNER LANGUAGE RE-ACCEPTANCE`

# Conversational Plain Language V1 Owner Review OR2 — 2026-08-26

OR2 เก็บ final language/consistency หลัง OR1 ถูก Owner Reject โดยตัดคำถามและข้อสรุปซ้ำ แก้ส่วนขยายห้อย และทำ Unknown ให้เป็น fail-closed ภาษาคนบน Web/PDF/infographic เดียวกัน. คงส่วน 1–4, “แนวโน้ม 12 เดือนข้างหน้า”, `7 ส.ค. 2569 – 6 ส.ค. 2570`, `monthlyTimelineAvailable=false`, ไม่มีรายเดือน และไม่เปลี่ยน engine/Canon/R1–R7.1/traceability. Implementation `0f5b7e86e16a8f7f99af6856daa35f8a2a4e5b8b`; 300-profile audit 11,414 fields impacts = 0, full suite 1,622/1,622, analyzer/PreCommit/PostCommit และ visual QA ผ่าน. ZIP SHA-256 `24D74EA3CDE2311CF3335A07EFC7C5E80B62AA3C31B4367F3BC53C45E8A7F8EB`; สถานะ `PENDING OWNER FINAL LANGUAGE RE-ACCEPTANCE`

# Inline Astrology Basis Dedup V1 — PR108 OR1 — 2026-08-28

OR1 ขยายการถอด inline basis ตาม semantic role และซ่อม stale OR3 phrases โดยคง Section 4, Unknown fail-closed, `monthlyTimelineAvailable=false`, ช่วงวันที่จริง, semantics และ traceability. Implementation `647e1f0`; audit 300 profiles / 30,000 fields / inline 0 / stale 0 / impacts 0; PDF จริง 8/7/7/7, visual blank 0. ZIP SHA-256 `5C13B2B644945C9309E5B691C67A3978D3052BCC7DAB56F6D62604D9D00838B7`; `PENDING OWNER RE-REVIEW`
# PR108 OR2 evidence addendum (2026-08-29)

OR1 was rejected for scope-accounting and evidence defects, not accepted by inference. OR2 freezes the reader-visible copy and closes those evidence gaps: all 13,174 changed fields are mutually exclusively reconciled (A 1,125; B 462; C 0; D 11,587; E 0; F 0), actual extracted Web/Dedicated PDF/Browser-print parity is 262/262, infographic has a separate semantic contract, and all 18 top/middle/bottom captures record controller identity plus requested and actual geometry. Known and Unknown contact sheets are variant-filtered and have different hashes.

Two full-copy reads confirm Section 4 still explains methodology and Unknown remains fail-closed. Dedicated PDF pages are Known 8 / Unknown 7; Browser-print pages are Known 7 / Unknown 7, with no blank page, clipping, overlap or overflow. Implementation/test commit: `d78c5f641563ca5810c8952191e217cd31502d57`. Owner Review ZIP SHA-256: `D47AE77CAC12E4D924E5FF4A200786251F34B4646AE5DEAAA373D8C483F41EB1`. Status remains **PENDING OWNER RE-REVIEW — NOT MERGED — NOT DEPLOYED**.
