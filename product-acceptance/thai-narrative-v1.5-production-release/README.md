# Thai Narrative V1.5 Production Release and Rollback

Status: `V1.5 DEPLOYED, PRODUCTION VERIFICATION FAILED, ROLLED BACK TO V1.4`

This packet records the Owner-authorized Firebase Hosting-only release from final main `7a2bdea4d88ebd3e87ee7268641a37a70a7a959f`. Product merge `a574fcb65437013e98c64b1fc9af19f50723534b` contains accepted source `e8cc382fa950e581b4da5ec0ff6b93202a1cd4ee`.

## Outcome

- Pre-deploy exact-source, focused, analyzer, artifact identity, build, manifest, local browser, and rollback-readiness gates passed.
- The only deployment command was `firebase deploy --only hosting --project knowme-app-694e1 -m "KnowMe Thai Narrative V1.5 — source 7a2bdea4, product a574fcb6"`.
- V1.5 Hosting release `1786871603892000`, version `a5721c17f758aa6d`, finalized and went live at `2026-08-16T09:13:23.892Z`.
- All 77 deployable assets matched the frozen build byte-for-byte; `/` and `/beta/thai` were HTTP 200. Existing-tab upgrade, fresh desktop, signed-out, and mobile-width-390 smoke passed with zero console warnings/errors.
- The first real Production PDF, `owner-known-0035`, had the expected 7 pages and visually clean pagination, but extracted narrative text did not exactly match either the accepted R7.1 canonical text or accepted R7.1 PDF extraction. Four substantive replacement spans were detected.
- This is a mandatory rollback trigger. The other four canonical fixtures were intentionally not run after the first blocking failure.
- Firebase Hosting Release history rolled back exact V1.4 version `10af10c6d960d590` as release `1786872330369000` at `2026-08-16T09:25:30.369Z`.
- Post-rollback, all six captured V1.4 baseline assets matched their original byte counts and SHA-256 values; fresh and existing browser smoke passed with zero warnings/errors.
- Final Production is V1.4. V1.5 is not live.

## Release artifact and accepted identities

- Build: 78 files / 44,170,486 bytes; 77 deployable after Firebase ignores `.last_build_id`.
- Build manifest SHA-256: `E0C5E976076F7165DD6CA4913A7227585E2579AAA8F123302A6895877A3767F5`.
- R7.1 ZIP: 10,709,328 bytes / 80 entries / SHA-256 `9E541F21C68FDAD93BC595C55BD0BE23600F88454CFBA7FAB6C713FE53F79E58`.
- R7.1 checksums: 79/79; R7→R7.1 direct accepted-archive immutable comparison: 63/63, mismatch 0.
- Canonical parity in the accepted archive: 5/5; claim traceability: 170/170.

The six generated text evidence files in a fresh Windows Git checkout are line-ending-normalized relative to ZIP bytes. Accepted identity was therefore verified directly between the immutable R7 and R7.1 ZIP entries. The accepted ZIP itself, its 79 checksums, the five canonical Web/PDF pairs, and all 63 immutable comparisons pass. No R1–R7.1 path was modified.

## Blocking evidence

- Production PDF: 39,370 bytes, SHA-256 `5F706E04462DEA15716F09C3B8230C03DA34D2CF02B9C0C3E11BBBFCDC47C49B`, 7 pages.
- Accepted PDF: 39,080 bytes, SHA-256 `23D7AEBC40F27C29BDA55F521688BCC7D156FDE928173BE435BB7033EB8535B6`, 7 pages.
- Normalized production extraction versus accepted PDF extraction: not exact; similarity `0.9920086980157652`; four substantive replacement spans.
- Root-cause candidate requiring a separate repair: the accepted fixture fixes `startedAt/asOf` to `2026-08-07`, while the real Production form uses the wall-clock session start as the analysis `asOf`. The exact causal path was not changed or proven inside this release task.

No application source, tests, goldens, Firebase configuration, secrets, Auth, Firestore, Functions, Storage, Remote Config, or mobile build was changed. The 39 common repository baseline failures remain disclosed debt.
