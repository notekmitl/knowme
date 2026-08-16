# Production PDF visual QA before rollback

Fixture: `owner-known-0035`  
Production PDF: `owner-known-0035-production.pdf`  
Expected and actual pages: 7 / 7  
Render: Poppler at 150 DPI, 1241 × 1754 pixels per A4 page

The PDF was visually usable, but the release still failed because its extracted narrative did not exactly match the accepted R7.1 reference. The mandatory text failure was discovered on the first fixture, so the remaining four Production fixtures were not generated.

| Page | Page-specific observation |
| --- | --- |
| 1 | Cover identity, report title, hook, core reading, five domain headings, and medical disclaimer are all visible. Thai glyphs render cleanly; the final disclaimer remains above the footer with no clipping. |
| 2 | The core-reading close and Life Map orientation lead into the first three past-period cards. Rounded borders remain inside the printable area; the 30–41 card begins fully and the page footer is unobstructed. |
| 3 | The past reflection continues before the current-period card. Current work, finance, and health cards are complete, with consistent padding and no overlap or truncated bottom line. |
| 4 | The luck card, forward-looking orientation, current decision section, four domain paragraphs, and 12-month heading fit without border escape. The continuation is semantically oriented and the page is not footer-only. |
| 5 | The 12-month work/finance/relationship/health content and next-life-period domains remain readable in one column. Section spacing is consistent and the final health paragraph is complete above the footer. |
| 6 | Closing advice, long-term orientation, next-period card, and methodology section are visible. The `โครงสร้างดวงหลัก — ต่อ` continuation is explicit, and the Aquarius `19°19′` fact is fully rendered. |
| 7 | Remaining house evidence, interpretation source, and limitations card are present. This is a valid content page—not blank or footer-only—and the card border and Thai wrapping remain intact. |

Across all seven pages: no blank page, footer-only page, clipping, overlap, truncation, broken Thai wrapping, missing font, or border escape was observed. Visual layout result: `PASS`. Canonical text result: `BLOCKED`; rollback required.
