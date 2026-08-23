# Preview and Production Visual QA

## Decision

`PASS — 105/105 PAGES IN PREVIEW AND 105/105 PAGES IN PRODUCTION`

The following seven fixtures were generated through the real user-visible flow
in real Chrome in both environments:

| Fixture | Browser print | Dedicated PDF | Semantic coverage | Visual decision |
| --- | ---: | ---: | ---: | --- |
| `known` | 7 pages | 8 pages | 100% | PASS |
| `unknown` | 7 pages | 8 pages | 100% | PASS |
| `owner-known-0035` | 7 pages | 8 pages | 100% | PASS |
| `owner-unknown` | 7 pages | 8 pages | 100% | PASS |
| `regression-known-0003` | 7 pages | 8 pages | 100% | PASS |
| `comparison-known-bangkok` | 7 pages | 8 pages | 100% | PASS |
| `comparison-known-khon-kaen` | 7 pages | 8 pages | 100% | PASS |

For each environment, all 14 PDFs contain 105 pages. Automated inspection found
no blank page, clipping, overlap, duplicated section, missing heading,
introduction/footer loss or semantic omission/addition. Reader-visible text is
exactly the approved Revision 4 output.

Ninety-one renders per environment are byte-identical to the approved renders.
The remaining 14 are page 2 (the infographic page) for both PDF runtimes across
all seven fixtures. Their dimensions and layout match. Each labelled contact
sheet was inspected at original resolution; the only raster delta is font/image
antialiasing and there is no visible content or geometry change.

Known and Unknown were also inspected at a real 390x844 browser viewport at
top, middle and bottom. Text remains readable, controls remain reachable,
horizontal overflow is 0 and console/page/request errors are 0.

The accepted 15-fixture infographic gate remains 15/15 at 1080x1920. Its
identity is carried through the byte-identical repair merge tree, the single
build and exact remote asset manifests; seven live report fixtures additionally
exercise the embedded panel in both PDF runtimes in Preview and Production.

