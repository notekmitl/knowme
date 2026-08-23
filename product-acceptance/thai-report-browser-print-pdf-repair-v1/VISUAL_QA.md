# Browser-print repair visual QA

## Accepted local result

| Fixture | Browser-print | Dedicated PDF | Semantic coverage | Visual result |
| --- | ---: | ---: | ---: | --- |
| known | 7 pages | 8 pages | 100% | PASS |
| unknown | 7 pages | 8 pages | 100% | PASS |
| owner-known-0035 | 7 pages | 8 pages | 100% | PASS |
| owner-unknown | 7 pages | 8 pages | 100% | PASS |
| regression-known-0003 | 7 pages | 8 pages | 100% | PASS |
| comparison-known-bangkok | 7 pages | 8 pages | 100% | PASS |
| comparison-known-khon-kaen | 7 pages | 8 pages | 100% | PASS |

All 14 PDFs and all 105 uniquely named page renders were inspected. Blank
pages, clipping, overlap, duplicated sections and missing sections are 0.
Reader-visible text matches Owner-approved Revision 4 exactly after disregarding
only whitespace introduced by PDF line wrapping.

The render identity gate found 91 byte-identical pages. The 14 non-byte-identical
pages are exactly infographic page 2 in browser-print and dedicated output for
the seven fixtures. The source-labelled contact sheets under
`pdf-contact-sheets/local-final/` were reviewed at readable scale. Differences
are rasterizer/runtime antialiasing only: title `ดวงชะตาปี 2569`, all copy,
geometry, colors, category rows, opportunity/caution cards and Unknown
disclosure are visually unchanged. Manual result: 105/105 PASS.

The 15-fixture 1080×1920 infographic title/identity gate also passes 15/15.
No Monthly Timeline, month name, inferred monthly highlight or fake monthly
visualization is present.
