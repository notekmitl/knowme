# Thai Report Reader Experience V2

Status: PreCommit passed on `codex/thai-report-reader-experience-v2`;
commit and Draft PR pending

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

Repository PreCommit passes with the same analyzer, focused commands and full
suite. Commit, PostCommit, push, Draft PR and GitHub checks are the remaining
workflow gates. No merge, deployment or Firebase mutation is authorized.
