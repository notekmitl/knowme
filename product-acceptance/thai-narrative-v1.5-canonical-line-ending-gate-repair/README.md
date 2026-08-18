# V1.5 canonical line-ending gate repair

Status: repair validation passed on branch `codex/v15-canonical-line-ending-gate-repair`, based on `bb85b07c643bc35cef076df066cb191f2f0a7d24`. Production remains V1.4 Hosting version `10af10c6d960d590`; this packet records no V1.5 build, Preview, Production deploy, or Firebase mutation.

The defect was in the test fixture comparison boundary: Git blobs and pipeline output are LF, while Windows Git with system `core.autocrlf=true` materialized CRLF worktree fixture bytes. All ten Web/PDF byte comparisons become exact after canonicalizing only line endings. No hidden content difference exists.

The repair is limited to one canonical-text test helper, its vector tests, and migration of four exact-text assertions. Application source, canonical/expected/golden content, R1–R7.1, ZIP/PDF artifacts, and reader-visible output are unchanged.

Fresh gates pass as recorded in `validation-summary.md`: helper 11/11; focused 36/36; frozen/live canonical 5/5; Web/PDF mismatch 0; copy audit 300/300 with every semantic and reader-visible delta 0; S008 canonical mismatch 0; analyzers 299/299/delta 0; full-suite common failures 39 with branch-only/main-only 0; and R7.1 immutable identity 63/63.

Raw logs and machine-readable comparisons are preserved in this directory. `SHA256SUMS.txt` is generated after the packet is final and covers every other file in the packet.
