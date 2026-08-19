# Test, analyzer and build summary — Revision 3

| Gate | Result |
|---|---|
| Focused PDF page-one regression | 10/10 PASS |
| Focused copy/layout | 11/11 PASS |
| Copy audit | 300 profiles / 4,407 fields; semantic/omission/addition/prediction-advice/traceability impact 0 |
| Artifact generation | 15/15 fixtures PASS |
| PDF validation and render | 14 PDFs; 105/105 uniquely named pages; failures 0 |
| Manual PDF visual QA | 105/105 pages across 32 sheets PASS |
| Known/Unknown fail-closed | 62/62 PASS |
| Screenshot regression | 24/24 PASS |
| Life Map regression | 32/32 PASS |
| Matrix payload | 864/864; each weekday 108/108 PASS |
| R7 original directory runner | 286/286 PASS |
| Full suite branch/main | 2,940/37 vs 2,925/39; common 37; branch-only 0; main-only 2 |
| Scoped analyzer | 0 issues |
| Full analyzer branch/main | 297 / 299; branch-only 0; main-only 2 |
| Web release build | PASS, not deployed |
| VM×2 / Chrome×2 | 133,592 bytes; mismatch 0; SHA-256 `AE15130780DA9B5CAF847909D60B5A29459BB5298F4715EF2CC82F58E41E537E` |
| R7.1 immutable | ZIP/checksums PASS; 63/63; R1–R7.1 modified paths 0 |

The 226/226 R7 diagnostic used a narrower reconstructed file list and is not the final gate. The exact original directory-scope command was rerun and passed 286/286. Raw failures and diagnostics are retained. No Deploy or Firebase mutation command was run.
