# Task: Thai Report Reader Experience V2

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
