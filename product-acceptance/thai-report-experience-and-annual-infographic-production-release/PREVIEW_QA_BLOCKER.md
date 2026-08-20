# Preview QA Blocker — Browser-Print Pagination

## Decision

`BLOCKED — DO NOT DEPLOY PRODUCTION`

The real Firebase Preview browser-print PDF is incomplete for every canonical
fixture. This is a mandatory release gate, not a documentation-only discrepancy.

| Fixture | Dedicated pages / chars | Browser-print pages / chars | Coverage | Result |
| --- | ---: | ---: | ---: | --- |
| owner-known-0035 | 8 / 9,367 | 1 / 732 | 7.81% | BLOCKED |
| owner-unknown | 8 / 8,394 | 1 / 630 | 7.51% | BLOCKED |
| regression-known-0003 | 8 / 9,366 | 1 / 732 | 7.82% | BLOCKED |
| comparison-known-bangkok | 8 / 9,039 | 1 / 734 | 8.12% | BLOCKED |
| comparison-known-khon-kaen | 8 / 9,209 | 1 / 732 | 7.95% | BLOCKED |

All five single-page print PDFs stop in the annual infographic and omit later
sections. The dedicated PDFs contain the complete eight-page report.

## Root-cause proof

The Owner Known real Preview print page was measured after print media was
activated:

- `#knowme-print-root` exists;
- root text length: 9,366 characters;
- root HTML length: 300,474 characters;
- root height: 4,979.703125 px;
- root display/position: `block` / `static`;
- computed body position: `fixed`;
- body height/overflow: 8,000 px / `visible`;
- computed html height: 0 px;
- Chrome output: one A4 page / 732 extracted characters.

Thus the shared model and semantic print markup are present, but the Flutter Web
host constraints clip Chrome pagination. This is consistent across 5/5 real
Preview fixtures and is visible in every browser-print contact sheet.

## Repair boundary

This deploy task forbids application/source changes. A separate Owner-authorized
repair must update and test the live print-media host contract, then repeat the
entire release from a fresh main commit and a new one-time build. The repair must
not change canonical text, dedicated PDF content, Owner-approved infographic
content, tests/goldens merely to hide the failure, or R1–R7.1 artifacts.

No Production deployment occurred, so rollback was neither required nor run.
Final live Hosting remains release `1787038542564000`, version
`5f98dfffef913e38`.

