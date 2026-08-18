# Live-oracle PDF visual QA

All five live-date oracle PDFs were rasterized at 90 DPI and every page was inspected through the fixture contact sheets. Page counts are 7, 7, 7, 6 and 7 (34 pages total).

Result: 34/34 pass.

- Every page has the expected white report canvas and correct page numbering.
- No page is blank or footer-only.
- No heading, paragraph or card is clipped, overlapped or truncated.
- Thai wrapping remains inside printable bounds and card borders.
- Continuations remain readable and final disclosure/action cards are present.
- Owner Unknown remains visually fail-closed and contains no lagna assertion.

The source pages are in `live-oracle-renders/<fixture>/`; the five inspected sheets are `live-oracle-renders/*-contact-sheet.png`. The separate actual compiled-Web Owner PDF has 7 pages and was also rendered and inspected under `rendered-live-oracle-owner-known-0035/`.
