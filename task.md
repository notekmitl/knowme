# Task: Thai Report Reader Experience V2

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
