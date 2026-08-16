# PDF geometry and visual QA

Poppler rasterized the five final PDFs at 120 DPI. All 30 actual page PNGs were inspected through five contact sheets, with opening, forecast and appendix pages also checked at original render resolution.

| PDF | Pages | Result |
|---|---:|---|
| owner-known-0035 | 6 | pass |
| owner-unknown | 6 | pass |
| regression-known-0003 | 6 | pass |
| comparison-known-bangkok | 6 | pass |
| comparison-known-khon-kaen | 6 | pass |

No blank/footer-only page, clipping, overlap, out-of-bounds text, broken Thai wrapping, incorrect footer number or section-order defect was observed. Every page footer reads `หน้า n / 6`. The “ลายเซ็นของคำอ่าน” hook appears before the rest of the reading, forecast horizons follow the life-map/current flow, and methodology/limitations remain at the end.
