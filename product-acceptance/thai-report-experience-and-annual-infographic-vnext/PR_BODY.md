# Thai Report Experience Repair and Annual Horoscope Infographic

Draft-only candidate for Owner review. Do not merge or deploy.

## What changed

- Web, dedicated PDF and browser print now consume the same shared report presentation document for content, order and Known/Unknown visibility.
- Browser print uses a semantic multi-page A4 document instead of printing the clipped Flutter viewport.
- Reader-facing Thai copy repairs are isolated behind a candidate-only projection. The accepted V1.5 default remains unchanged.
- A 1080 x 1920 annual infographic is integrated into Web, dedicated PDF and browser print from the same presentation data.
- Month-by-month content is intentionally absent because the current engine exposes no validated calendar-month evidence.

## Evidence and gates

- Copy corpus: 300 profiles, 2,105 changed fields; omission, addition, semantic, prediction/advice and traceability impact all 0. Owner decision remains Pending.
- Dedicated PDF: Known 8 pages, Unknown 8 pages; infographic is page 2.
- Browser print: Known 7 pages, Unknown 7 pages; infographic is page 2.
- Full suite: branch 2,938 passed / 37 failed; exact main 2,925 / 39; branch-only failures 0.
- Analyzer: scoped 0 issues; branch/main 297/299; branch-only diagnostics 0.
- Web release and local preview builds passed; neither build was deployed.
- VM/real-Chrome manifest is byte-identical: 134,732 bytes, SHA-256 `E961E1DEE62B3A16FE6DD0245D1EFE8376E93F294F65590A65D900EDDF8C2780`.
- R7.1 remains 10,709,328 bytes / 80 entries / SHA-256 `9E541F21C68FDAD93BC595C55BD0BE23600F88454CFBA7FAB6C713FE53F79E58`; checksums 79/79, immutable comparison 63/63, modified paths 0.

Owner review packet: `product-acceptance/thai-report-experience-and-annual-infographic-vnext/README.md`

Owner review is required for Web/PDF parity, the complete copy ledger, Known/Unknown infographic visuals, mobile PNGs and the monthly evidence gap. The PR must remain Draft.

Production remains V1.5 Hosting version `5f98dfffef913e38`; V1.4 rollback remains `10af10c6d960d590`. No Firebase service was changed.

`ANNUAL INFOGRAPHIC MONTHLY TIMELINE BLOCKED — VALIDATED MONTH DATA REQUIRED — PRODUCTION UNCHANGED`
