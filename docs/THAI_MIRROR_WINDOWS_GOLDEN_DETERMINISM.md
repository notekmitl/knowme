# Thai Mirror Windows Golden Determinism

Status: **PRECOMMIT PASS — BASELINE CANDIDATE — NO PRODUCT DELTA**

Base: `efc63c61b672dd79ec3fc8f9f5e1eb8c16d205d3` (`origin/main`)
Toolchain: Flutter 3.41.1 / Dart 3.11.0 on native Windows and native Linux

## What failed on unchanged main

The previously reported Windows full-suite result was 3,036 passed and 40
failed tests. The 40 failures split into two independent platform causes:

- 38 test cases used 174 exact PNG comparisons: 24 QA-harness cases (144
  images), 13 consumer-UX cases (29 images), and one legacy consumer-page
  case (one image). The accepted images had been produced on Linux. Windows
  used the same Flutter framework and engine revisions but rasterized the test
  glyphs differently.
- Two tests hashed the raw worktree bytes of
  `test/evidence/fixtures/or5r_known_baseline.json`. Git checked the canonical
  LF blob out as CRLF on Windows, changing only the worktree byte hash.

No calculation, reader copy, Thai UI, production font, route, PDF, or runtime
behavior caused these failures.

## Narrow repair

`thaiMirrorGoldenPath` keeps the accepted path unchanged on Linux and inserts
the sibling `windows/` directory only on Windows. Flutter's built-in exact
golden comparator remains in force. There is no skip, threshold, tolerance,
custom comparator, or Gate change.

The original 174 Linux PNGs remain byte-for-byte unchanged. The Windows set
contains the same 174 filenames and dimensions:

| Group | Windows files | Missing Linux counterparts | Dimension mismatches |
| --- | ---: | ---: | ---: |
| Legacy consumer page | 1 | 0 | 0 |
| Consumer UX | 29 | 0 | 0 |
| QA harness | 144 | 0 | 0 |
| **Total** | **174** | **0** | **0** |

The completeness test enumerates every file rather than sampling names. A
read-only comparison manifest over path, both SHA-256 values, dimensions,
changed-pixel count, and changed-pixel percentage hashes to
`b458020ca47729adf68f5cf36fd4dcdb7ef17498593e09f286fe6bc3433fc387`.
The QA-harness differences cover 144/144 images (0.987294%–5.266388%, average
2.961039%). Consumer UX differs in 27/29 images (0%–4.501264%, average
1.860201%). The legacy pair is byte-identical.

The OR5R fixture now has a file-specific `text eol=lf` rule. Its repository
blob remains unchanged, and the Windows worktree SHA-256 is the accepted
`91b71e6689193ee8c5cbd2604f24f139d380b9994a94437f4135fd42019cd998`.

## Validation

- Windows strict focused suite: **46/46**.
- Native Linux strict focused suite against the original paths: **46/46**.
- Windows OR5R/PDF focused regression with pinned Python and Poppler: **9/9**.
- Local Gate PreCommit and Windows full Flutter suite: **3,080/3,080**.
- Analyzer: 282 inherited non-fatal diagnostics, matching repository policy;
  no product source is changed.
- Representative legacy, full-page consumer, and mobile harness PNGs were
  opened at original resolution. Layout blocks are complete with no clipping,
  overlap, overflow, or blank image.

The golden fixtures deliberately use the existing test font, whose Thai glyphs
appear as boxes. These baselines test layout and cross-platform regression;
they are not Production typography acceptance. Production Web/PDF Thai glyph
QA remains a separate release gate.

## Scope proof

Changed runtime, Thai golden originals, Thai calculation, reader copy,
`product-acceptance/`, Firebase, Backend, and deployment files: **0**. The
repair only adds the platform path helper and tests, a targeted LF rule, the
174 Windows PNG siblings, and documentation.
