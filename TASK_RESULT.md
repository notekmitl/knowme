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

- Focused narrative/fixture tests: 24/24 passed.
- Affected regression tests: 62/62 passed.
- Synthetic/parity tests: 16/16 passed, including 300 synthetic cases and 20 exact Web/PDF parity cases.
- Golden/story tests: 32/32 passed.
- Full required Flutter suite: 1,530/1,530 passed.
- Repository PreCommit gate: passed.
- Analyzer: completed with the repository baseline of 299 warning/info findings and no fatal gate failure.
- Deterministic Known/Unknown audit: zero duplicate complete narrative sentences, identical cross-horizon bodies, reused full actions, visible four-field templates, or prefix/suffix-only horizon variants.
- Known Web/PDF canonical text parity: byte-identical.
- Unknown Web/PDF canonical text parity: byte-identical; fail-closed behavior preserved.
- Acceptance PDFs: Known 11 pages, SHA-256 `F08542ABD7BB61F77C890389F074AB16B50D676E5508B80B5C6E882EDE639CB0`; Unknown 10 pages, SHA-256 `9605081518D9FDB318BF3239535FCCEFE04675839C559DAE628EADE351AF8ED7`.
- Visual QA: all 21 rendered PDF pages and four Web desktop/mobile captures inspected without blank page, clipping, overflow, footer overlap, or missing glyph.
- New acceptance folder: `C:\Users\USER\Documents\Knowme\thai-report-natural-narrative-v1-1-f9945a5-acceptance`.

The acceptance ZIP and Draft PR metadata are recorded after packaging and push complete. Do not merge or deploy before explicit Owner approval.
