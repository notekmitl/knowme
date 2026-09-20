# KnowMe BaZi Reader V4

Status: Production-released interpretation contract
`knowme_bazi_reader_th_v4` over the unchanged calculation contract
`knowme_bazi_reader_v3`.

## Purpose

Reader V4 turns the complete deterministic Da Yun and Liu Nian data already
returned by Reader V3 into a readable past-present-future life timeline. It
does not change the Four Pillars, apparent-solar-time policy, input
fingerprint, luck-cycle direction, chart persistence, or API contract.

## Conversational Thai release candidate (2026-09-20)

The shared Reader V2/V4 composer now explains the chart in short, ordinary
Thai addressed naturally to `คุณ`. Each section starts with its useful answer
and follows with what to watch or do. Report-system terms such as
`แบบจำลอง`, `กรอบคำอ่าน`, `สัญญาณรายปี`, `สัญญาณเสียดทาน`, and
`แนวทางที่ควรพิจารณา` are removed from reader copy. No fixture-specific text
or new astrological claim is introduced.

Reader V4 states once in its introduction that the reading is a planning trend,
not a guarantee. Individual cards do not repeat the same caution. Repeated
Ten-God and relation signals remain traceable to their calculated source but
are expressed once per horizon, with deterministic follow-on wording where a
theme repeats.

`ข้อมูลที่ใช้คำนวณ` is no longer projected to Reader V4 Web or PDF. Birth
input, coordinates, timezone, local civil time, apparent-solar time, and rule
provenance remain present in the chart model and automated tests. This is a
presentation-only correction; pillars, Day Master, Da Yun, Liu Nian, and
apparent-solar calculation are unchanged.

Validation uses actual charts for Bangkok, Chiang Mai, Phuket, and Owner case
1982-06-06 00:03 Chiang Mai male. Focused Flutter 12/12, backend 23/23, full
Flutter 3,085/3,085, and analyzer policy pass. Four desktop/mobile Web
projections and four three-page PDFs share the same report content. All 12 PDF
pages pass text, font, blank-page, clipping, overlap, overflow, and Thai/CJK
glyph review; CJK remains Noto Sans SC Regular. The release Web bundle contains
the Production API and `/beta/chinese`, with zero actual loopback endpoint.
Local Gate PreCommit passes scope, forbidden-text, analyzer, focused tests, and
full Flutter 3,085/3,085. Commit/PostCommit, PR, Hosting-only release, and
Production Web/PDF QA remain pending.

## Owner-copy acceptance repair release (2026-09-20)

The follow-up keeps the same interpretation and calculation contract while
repairing the shared Thai copy composer:

- multi-family overview and work themes join as natural sentences;
- model-derived strengths, money and relationship statements are framed as
  tendencies or review prompts, not guaranteed identity or life events;
- past cycles describe their distinct theme and signal, while the reflective
  prompt appears once in the section introduction;
- current-cycle and annual signals complement each other instead of repeating
  the same advice; and
- annual and decade-cycle horizons are explicitly distinguished when their
  calendar years overlap.

The audit also removes the evidenced doubled phrase
`สัญญาณรายปีมีสัญญาณปะทะ`. No fixture-specific prose is introduced, and no
location, coordinate, timezone, or apparent-solar diagnostic is added to the
Web or PDF reader.

Location regression uses Bangkok (1990-12-05 15:30), Chiang Mai (1982-06-06
00:35), and Phuket (2001-03-03 23:45). Tests cover the form handoff, canonical
profile, authenticated API payload, engine input, coordinate use, historical
IANA offset, longitude correction, NOAA Equation of Time, total correction,
and final apparent-solar datetime. Resulting apparent-solar times are 15:21:09,
00:12:46, and 23:06:08; these are engineering evidence and remain hidden from
the consumer report.

Candidate validation passes focused Flutter 21/21, backend 38/38, and full
Flutter 3,084/3,084. Local Gate PreCommit passes the final candidate, including
analyzer policy with 282 inherited non-fatal diagnostics. Three Web projections
and three PDF projections use the same report object. The PDFs contain 12
visually inspected A4 pages with no missing section, blank page, clipping,
overlap, overflow, or Thai/CJK glyph defect; embedded fonts remain Noto Sans
Thai Regular/Bold and Noto Sans SC Regular. Local Gate PreCommit/PostCommit
pass, and PR #138 merged as `949c6d16`, tree `04ca7169`.

Hosting-only release `1789886487340000` / version `b89bf52264152570` serves
cache pin `949c6d1`. The live 8,611,124-byte bundle matches the exact-merge
build at SHA-256
`369AFF2D8B1BF7DED42075C9750A6E8CE667158A7E40FE1464DE910AEDD1D06D`,
contains the Production API and `/beta/chinese`, and has zero actual loopback
endpoint. Production Web QA confirms the repaired copy and complete bounded
timeline with zero application console errors. The browser-downloaded PDF is
four A4 pages / 33,082 bytes / SHA-256
`AD7AE0A7E370CE8398648A1A22F95BB277677D7E6CD652004C6D56759009D69E`;
all pages pass parity, font, glyph, clipping, overlap, overflow, and blank-page
review. No Backend or other Firebase resource was deployed.

## Reader order

1. Four Pillars and Day Master;
2. overall picture;
3. identity and practical use of energy;
4. work;
5. money;
6. love and relationships;
7. cautions and balance;
8. up to three most recent completed ten-year cycles;
9. the active ten-year cycle;
10. the current annual influence;
11. the next five annual influences;
12. the next two ten-year cycles.

The four technical sections hidden in the accepted concise Reader V3 release
remain hidden from both Web and PDF: chart facts, reproducibility rules,
sources, and limitations. Reader V4 also keeps concise calculation input out
of the consumer report while retaining it internally for calculation,
traceability, and automated tests.

## Timing rules

- Past cycles are presented as themes for comparison with lived experience,
  never as claims that a specific event occurred.
- Current and future sections describe tendencies, trade-offs, and practical
  planning priorities. They do not guarantee events or outcomes.
- The five-year view starts after the current year and can cross a ten-year
  cycle boundary because it is selected from the complete annual list.
- The long-term view is limited to the next two decade cycles. Monthly and
  daily forecasts are intentionally excluded because they would add length
  and false precision without a separate product need.
- If the chart has no governed luck cycles, the reader keeps the existing
  fail-closed current-cycle wording and does not create past or future timing.

## PDF contract

The existing embedded Thai/CJK fonts, A4 cards, and page numbering remain.
Timeline rows are independently breakable cards so a five-year section can
flow across pages without clipping or overlap. Production acceptance requires
rendering and inspecting every page, including Thai and Chinese glyphs.

## Calculation provenance

Reader V4 reuses the sources and rules documented in
`CHINESE_ASTROLOGY_READER_V3.md`. No calculation dependency or data source is
added in this release.

## Release-candidate validation (2026-09-19)

- PR #135 is rebased onto Thai Mirror baseline merge `e1426fc`; the baseline
  is isolated in merged PR #136 and has zero product delta.
- Focused chart/report/route/PDF tests pass 17/17. The complete Windows suite
  passes 3,080/3,080. Analyzer passes repository policy with 282 inherited
  non-fatal diagnostics. Local Gate PreCommit passes its scope guard,
  forbidden-text scan, analyzer, focused tests, and full suite.
- The Web release bundle contains the Production Cloud Run API and
  `/beta/chinese`, with zero loopback endpoint strings. Local Firebase Hosting
  SPA QA confirms the `BaZi Reader V4` header, past and current sections, five
  future years, two future cycles, normal Thai/Chinese rendering, and zero
  console errors.
- The generated Owner PDF is 4 A4 pages / 33,262 bytes / SHA-256
  `4E76DB104848DB94FD12014BBC158387BE3EEA93844AB26A483DC669E9D2666E`.
  Poppler rendering and original-resolution review cover all four pages. No
  text is missing; no page is blank; no clipping, overlap, or overflow is
  visible. Embedded fonts are Noto Sans Thai Regular/Bold and Noto Sans SC
  Regular.
- Calculation, Backend, Firestore, Functions, Auth, Storage, IAM, Thai
  astrology, Thai golden originals, and Production data remain unchanged.

## Production closeout (2026-09-19)

- PR #135 merged as `63c790d8ffca03bb5b6d776d6e9f9dad9c703b68`,
  tree `b9fa82a516fa125c04fb819820f8f1fc97ff0201`.
- Firebase Hosting-only release `1789821517363000`, version
  `e08803aacc812816`, serves cache pin `63c790d` on both Production domains.
- The live 8,601,936-byte bundle SHA-256 is
  `62BB3DE78672506E80DFAF4ED61FA098250CEA9F5D18D46617473A5589ECCC8F`;
  it matches the exact-merge build and contains zero loopback endpoints.
- Production `/beta/chinese?case=known` displays Reader V4 with past,
  present, years 2570–2574, and the next two decade cycles. Thai/Chinese text
  is normal and browser console errors are zero.
- The browser-downloaded Production PDF is 4 A4 pages / 33,437 bytes /
  SHA-256
  `CF0B1CB8ACDD7D95BBDC124185945F3E96D92AF1C6623D0F68C827D03D1B7266`.
  Its four rendered PNGs are byte-identical to the accepted candidate pages;
  embedded fonts remain Noto Sans Thai Regular/Bold and Noto Sans SC Regular.
