# Repair validation summary

| Gate | Fresh result |
|---|---|
| Helper contract | 11 passed / 0 failed |
| Mandatory `live_asof` focused suite | 36 passed / 0 failed |
| Frozen canonical Web/PDF | 5/5 exact |
| Live Web/PDF and deterministic repeat | 5/5 exact |
| Copy semantic audit | 300/300; semantic/reader-visible/omission/addition/prediction-to-advice mismatch 0 |
| Unknown fail-closed | mismatch 0 |
| S008 VM×2 / real Chrome×2 | 300/300 each; canonical mismatch 0; disclosed raw one-ULP only |
| Scoped analyzer | no issues |
| Full analyzer | branch 299 / main 299 / normalized delta 0 |
| Full suite | branch 2925/39; pinned-main LF 2914/39; shared 39; branch-only 0; main-only 0 |
| R7.1 | 10,709,328 bytes; 80 entries; checksums 79/79; SHA-256 `9E541F21C68FDAD93BC595C55BD0BE23600F88454CFBA7FAB6C713FE53F79E58` |
| R7→R7.1 immutable | 63/63; mismatch 0; historical modified paths 0 |

S008 raw VM/Chrome values remain `102.39560244592322` and `102.39560244592323`; both canonicalize to `102395602446` and display `12°24′`. Owner Known remains Aquarius 19°19′ and regression 00:03 remains Aquarius 9°24′. Claim traceability remains 170/170.
