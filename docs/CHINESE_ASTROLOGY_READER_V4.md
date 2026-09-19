# KnowMe BaZi Reader V4

Status: Production-released interpretation contract
`knowme_bazi_reader_th_v4` over the unchanged calculation contract
`knowme_bazi_reader_v3`.

## Purpose

Reader V4 turns the complete deterministic Da Yun and Liu Nian data already
returned by Reader V3 into a readable past-present-future life timeline. It
does not change the Four Pillars, apparent-solar-time policy, input
fingerprint, luck-cycle direction, chart persistence, or API contract.

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
12. the next two ten-year cycles; and
13. concise calculation input.

The four technical sections hidden in the accepted concise Reader V3 release
remain hidden from both Web and PDF: chart facts, reproducibility rules,
sources, and limitations.

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
