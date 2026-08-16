# R5 identity discrepancy record

R5 SHA-256 values were correct, but file sizes previously reported in the acceptance handoff did not consistently match the actual immutable files. R6 does not modify R5. This record recomputes the actual R5 identities read-only:

| R5 artifact | Actual bytes | Verified SHA-256 |
|---|---:|---|
| comparison-known-bangkok-report.pdf | 38,270 | `A32A292163B61FA8DB4689AD954EBDBC0D223F079AEE2944A37B7FE841A5087B` |
| comparison-known-khon-kaen-report.pdf | 38,461 | `BBE8985BA1455057EA16878809913ED3F136CB2908ADDC1D126673943BF7DD14` |
| owner-known-0035-report.pdf | 38,636 | `9E556B724D0A290859186A6C5A2992BB6498B5288A2257846D12C2C55A2F7553` |
| owner-unknown-report.pdf | 36,695 | `67C49A366D9903B80EFECCBE391F7CFF4CFD2C2733ACAC6FC6459615E9DAB608` |
| regression-known-0003-report.pdf | 38,629 | `99087A761D991AF5CF9763DB7B4D54330C8437C83E418EA053341D59C40FD467` |
| thai-narrative-v1.5-r5.zip | 7,897,835 | `7A41C205F5ABE821AB2FCE2E6232B806EE742DFFBBA748C620D6471D04201438` |

For R6, bytes, pages and SHA-256 are generated directly from final files by `tool/thai_narrative_r6_finalize.ps1` into `artifact-identities.json`; the same generated block is inserted into README, manifest, handoff and visual QA.
