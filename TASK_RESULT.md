# Thai Report Natural Narrative V1.2 + Pagination Repair

## Result

Draft PR #89 is being reworked on `agent/thai-report-reading-flow-v1` after the Owner rejected the actual V1.1 packet. V1.1 is immutable historical evidence. Status is `PENDING OWNER RE-ACCEPTANCE`; this branch is not merged or deployed.

The V1.2 root cause analysis is recorded in `docs/PR89_V12_ROOT_CAUSE.md`. The composer still concatenated timed claim, impact, bridge, risk, action, fallback, and transition fragments after labels were removed. The PDF semantic-block renderer then treated each split block as a continuation and unconditionally prefixed the parent title with `(ต่อ)`. The previous audit split only complete sentences, while the previous visual checklist did not record first/last lines or continuation counts per page; both therefore missed the Owner-visible failures.

V1.2 retains typed Claim/Risk/Decision/Action semantics but selects only the material needed for one finished reader-facing thought. Current domains are limited to two short paragraphs and one practical focus; twelve-month and next-period domains are limited to one short paragraph, with one observable sign or one preparation item. Parent headings render once, and paragraph chunks no longer create separately headed cards.

## Preserved contracts

- No engine, Canon, calculation, astrological-day boundary, ascendant, house, timeline boundary, factual provenance, Auth, flag, audience, or Production change.
- Known-time facts remain exact; Unknown-time remains fail-closed with no assumed time, Lagna, house, or astrological-day conclusion.
- Web/PDF consume the same analysis and shared presentation values.
- Fortune remains separate from health; ISO date tokens remain atomic.
- Round 9 remains completed historical evidence; existing `product-acceptance/` and the rejected first PR #89 packet were not changed.

## Factual verification

- Exact Known fixture: 1982-06-06 00:03, Chiang Mai, standard `ThaiBetaAnalysisRunner`.
- Canonical ascendant: Aquarius 9°24′.
- The separate 00:35 fixture produces Aquarius 19°19′; this is input-driven, not a regression.

## Validation

- Focused narrative/core/export/pipeline tests: 251/251 passed.
- Synthetic/parity tests: 16/16 passed, including 300 synthetic cases and 20 exact Web/PDF parity cases.
- Golden/story tests: 32/32 passed (24 screenshot profiles and 8 story profiles); no golden update was needed.
- Full required Flutter suite: 1,532/1,532 passed.
- Repository PreCommit gate: passed.
- Analyzer: completed with the repository baseline of 299 warning/info findings and no fatal gate failure.
- Deterministic Known/Unknown V1.2 audit: zero duplicate internal clauses, reused normalized sentence skeletons, repeated action/fallback constructions, forbidden transition families, or content-budget breaches. The V1.1-style negative fixture fails as required.
- Known Web/PDF canonical text parity: byte-identical.
- Unknown Web/PDF canonical text parity: byte-identical; fail-closed behavior preserved.
- Acceptance PDFs from source-tested commit `fa2664f`: Known 6 pages / 36,543 bytes / SHA-256 `4DBEAFC51239398C7ED8ACF42584CFE7CE95B0F71DDFB41A2C4A5A427E796601`; Unknown 5 pages / 33,512 bytes / SHA-256 `EFD5BAA9E9E0FBBE6CF2B3C3EF9EAAABE967758F346AE1839D7BBC6676F492FE`.
- Visual QA: all 11 final rendered PDF pages and four final Web desktop/mobile captures inspected without blank/orphan page, repeated continuation heading, clipping, overflow, footer overlap, or missing glyph. The evidence log records every page's first heading, last visible line, and continuation count (all zero).
- New acceptance folder: `C:\Users\USER\Documents\Knowme\thai-report-natural-narrative-v1-2-fa2664f-acceptance`.
- ZIP: `C:\Users\USER\Downloads\thai-report-natural-narrative-v1-2-fa2664f.zip`, 2,436,006 bytes, 28 safe unique entries, SHA-256 `8EA21BB2AEB98BBD36DDE28B8F958E4693A58F0C49A03D72C7D7B49249BEC673`; 26 checksum lines verified with zero mismatch.

The acceptance ZIP and Draft PR metadata are recorded after packaging and push complete. Do not merge or deploy before explicit Owner approval.
