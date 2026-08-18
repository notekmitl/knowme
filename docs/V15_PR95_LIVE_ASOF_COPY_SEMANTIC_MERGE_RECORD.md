# V1.5 PR #95 live-as-of and copy-semantic merge record

## Owner authorization and merge identity

- PR: `notekmitl/knowme#95`
- Accepted PR HEAD: `3934de20852c6a3b733299c93ba029edb8334ea4`
- Accepted pinned main: `075ddfc6eeb8fbe4e3a0aaade9c4c2d5711340b9`
- Merge method: regular merge commit; no squash, rebase, force-push or source-branch deletion
- Merge commit: `e2f27be6cce02e821750110771eb461418d8af91`
- Merge time: `2026-08-18T04:42:45Z`
- Parent 1 (main): `075ddfc6eeb8fbe4e3a0aaade9c4c2d5711340b9`
- Parent 2 (PR): `3934de20852c6a3b733299c93ba029edb8334ea4`
- PR #95 final state: MERGED

## Tree-identity verification

The accepted PR tree and merge tree are both `d65d91f79a9c3f55eaff48ef7e087eb7d4189437`. The byte-for-byte tree comparison has 0 differing paths. Unexpected application code, test, golden, canonical-text, ZIP, PDF or acceptance-artifact difference between the accepted PR tree and merge tree is 0.

The full suite was not rerun after merge because the merged tree is byte-identical to the accepted PR tree. The post-merge gate therefore uses tree-identity verification, not a fresh test claim.

## Accepted technical and product gates

- S008 raw diagnostic: VM `102.39560244592322`; Chrome `102.39560244592323`.
- S008 canonical degree: exact integer `102395602446` on both runtimes; canonical/report/narrative mismatch 0.
- Reader-visible delta, omission, addition and prediction-to-advice transformation: 0.
- Canonical five: 5/5; Web/PDF exact; Unknown fail-closed.
- Accepted full suite: branch 2,914 passed / 39 failed; pinned main 2,889 passed / 39 failed.
- Failure reconciliation: common baseline 39; branch-only 0; main-only 0.
- Full analyzer: branch 299 / pinned main 299 / normalized delta 0.
- Web release build: successful before merge; it was not deployed.

## Acceptance evidence identity

- Evidence manifest entries/files: 332/332.
- Evidence bytes: 480,630,900.
- Missing: 0; mismatch: 0.
- `SHA256SUMS.txt` SHA-256: `2E04DDC4D219203074AACD972D7FEDB2102B134E6DBFA8B2B6C0E493E5EE6DE5`.
- R7.1 ZIP: 10,709,328 bytes / 80 entries.
- R7.1 ZIP SHA-256: `9E541F21C68FDAD93BC595C55BD0BE23600F88454CFBA7FAB6C713FE53F79E58`.
- R7.1 checksums: 79/79; immutable comparison: 63/63; R1–R7.1 modified paths: 0.

The pre-merge evidence packet was not modified or regenerated after merge.

## Release state

Post-merge verification found no GitHub deployment record and no workflow run for the merged revision. The accepted source branch `codex/v15-live-asof-contract-repair` remains on the remote at the accepted HEAD.

Firebase Hosting live remains release `1786872330369000`, type `ROLLBACK`, with V1.4 version `10af10c6d960d590` and update time `2026-08-16T09:25:30.369Z`. No deploy command, Hosting release command or Firebase mutation was run during this merge task.

V1.5 deployment is not authorized by this record. A separate explicit Owner Production Release authorization is required.
