# Test, analyzer and build summary — Revision 4

| Gate | Result |
|---|---|
| Title integrity + negative cases | 2/2 PASS; final raster 15/15 |
| Focused copy/layout/title | 13/13 PASS |
| Copy audit | 300 profiles / 4,407 fields; all impact counts 0 |
| Manual infographic QA | 15/15 original-resolution + 5 identity sheets PASS |
| PDF validation/render | 14 PDFs; 105/105 uniquely named pages; failures 0 |
| PDF visual evidence | 32 identity-labelled sheets; infographic title visible in both PDF paths |
| Web mobile | 12 fresh screenshots: 360/390 Known/Unknown PASS |
| Known/Unknown fail-closed | 62/62 PASS |
| Screenshot regression | 24/24 PASS |
| Life Map / matrix | 32/32; 864/864; each weekday 108/108 PASS |
| R7 original directory runner | 286/286 PASS |
| Full suite branch/main | 2,941/37 vs 2,925/39; common 37; branch-only 0; main-only 2 |
| Scoped analyzer | 0 issues |
| Full analyzer branch/main | 297 / 299; branch-only 0; main-only 2 |
| Web release build | PASS, not deployed |
| VM×2 / Chrome×2 | 133,592 bytes; mismatch 0; SHA-256 `AE15130780DA9B5CAF847909D60B5A29459BB5298F4715EF2CC82F58E41E537E` |
| R7.1 immutable | ZIP/checksums PASS; 63/63; canonical 5/5; claims 170/170; R1–R7.1 modified paths 0 |

No test, expected output, golden or canonical text was weakened. Production-equivalent builds were local only; no Deploy or Firebase mutation command was run.
