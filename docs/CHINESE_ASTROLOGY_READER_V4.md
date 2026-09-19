# KnowMe BaZi Reader V4

Status: implementation contract for Thai interpretation
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
