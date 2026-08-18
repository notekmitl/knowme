# Preview and Production PDF visual QA

All five PDFs in each environment were rasterized at 110 DPI. Every rendered page and each five-report contact-sheet set was inspected. The checks covered Thai glyphs, heading hierarchy, paragraph wrapping, card boundaries, margins, page numbering, blank/footer-only pages, clipping, overlap, truncation, and continuation orientation.

| Fixture | Preview pages | Production pages | Preview | Production |
| --- | ---: | ---: | --- | --- |
| owner-known-0035 | 7 | 7 | PASS 7/7 | PASS 7/7 |
| owner-unknown | 6 | 6 | PASS 6/6 | PASS 6/6 |
| regression-known-0003 | 7 | 7 | PASS 7/7 | PASS 7/7 |
| bangkok-known-1420 | 7 | 7 | PASS 7/7 | PASS 7/7 |
| khon-kaen-known-0645 | 7 | 7 | PASS 7/7 | PASS 7/7 |

Result: Preview 34/34 and Production 34/34 pages pass. There are no blank, footer-only, clipped, overlapping, truncated, missing-glyph, border-escape, or unusable pages.

