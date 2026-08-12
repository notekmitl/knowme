# PR #89 V1.4 Root-Cause Record

## r15 acceptance-evidence rejection and correction (2026-08-12)

Owner inspection passes the r15 product output but rejects its visual-review evidence. `page_row()` trusted `PdfReader.extract_text()` ordering and selected line zero, which was the footer page number. It also hard-coded generic `cards_present`, `split_state`, and `continuation_heading` strings, allowing non-page-specific boilerplate to be reported as a manual pass.

The corrected workflow separates manual observation from packet generation. A reviewed manifest covers all 6 Known and 5 Unknown renders; generation fails on page identity/count mismatch, missing observable fields, footer-as-heading, generic placeholders, unnamed cards, ambiguous continuation results, or a non-pass review. Four regressions cover the genuine Known page 1 heading, both actual continuation headings, explicit `none`, named sections, placeholder rejection, and page identities. Approved PDFs, canonical texts, renders, facts, and audit remain byte-identical. Status is **PENDING OWNER RE-ACCEPTANCE**; no merge, deploy, or Production change.

## Owner rejection of final r6 (2026-08-12)

The r6 audit compared Known lines only with Unknown lines, so it missed repeated instructions inside one Unknown passage: expense simulation, a shared-schedule trial, and a work/rest trial. The replacement audit separately reports cross-fixture, Known-internal, Unknown-internal, and same-paragraph clause/advice-stem results with inspectable locations and enumerated exceptions. Candidate-r2 fails, r6 fails with 4 substantive violations, and candidate-r14 passes with 0.

The narrative correction uses supported tendency → manifestation → opportunity/pressure → response. Deterministic semantic continuation boundaries put `โครงสร้างดวงหลัก — ต่อ` on Known page 6 and `รายงานนี้ดูจากอะไร — ต่อ` on Unknown page 5. Counts remain 6/5; all pages were inspected, and final-page whitespace is reduced without splitting the limitation card. Status remains **PENDING OWNER RE-ACCEPTANCE**.

Recorded before V1.4 implementation on August 11, 2026.

## Owner decision and verified packet

V1.3 was rejected as `REJECTED — ASCENDANT FACT CONFLICT, FALSE-ZERO NARRATIVE AUDIT, AND BROKEN UNKNOWN PDF CONTINUATION`. The inspected owner-uploaded packet is `C:\Users\USER\Downloads\thai-report-natural-narrative-v1-3-23fe2c2.zip`, SHA-256 `6098BC2E32079048FC46A997E5C807220E79D9ED59F699195295A7B9453121E6`. PR #89 remains open and Draft. Product Acceptance remains pending.

## Ascendant conflict

The exact Known fixture is 1982-06-06 00:03, Chiang Mai. The authoritative engine-backed canonical report says Aquarius 9°24′. Repository status documents written before V1.3 also record Aquarius 9°24′ and distinguish it from the separate 00:35 fixture, Aquarius 19°19′. The V1.3 `MANIFEST.md` and assistant final report incorrectly said Scorpio 9°24′ because acceptance metadata was manually authored after artifact generation instead of being derived from a machine-readable engine factual result. The calculation engine did not produce Scorpio and must not be changed.

## False-zero cross-fixture audit

The reported 240 cells are four typed forecast fields across 12 horizon/domain identities for five synthetic civil profiles. `_matrixReport` compares decision-plan projection fingerprints only for matching forecast cells. It is not a complete line-by-line comparison of the final Known and Unknown canonical documents. Equal projections increment `equalFingerprintCells` and are not classified as reader-facing shared content; only different projections whose selected field text remains similar are added to `sharedOutputJustifications`. Structural sections, current dashboard prose, luck, report explanations, timeline text, closing recommendations, and safety copy never enter the 240-cell matrix. The packet then summarized `zero violations` without shipping the 240 rows, exclusions, classifications, or allowed-shared list. Therefore its statement was both uninspectable and materially incomplete. Owner comparison finds 20 exact shared lines of at least 20 characters, containing both permitted boilerplate and substantive narrative reuse.

## Formulaic differentiation

V1.3 `_forecastClaim` repeats evidence provenance inside every domain paragraph. Known paragraphs repeat a Lagna/house/life-period preface; Unknown paragraphs repeat a no-house explanation. Domain bodies then reuse generic observation or preparation structures. This changes prefaces and selected nouns while leaving semantic families shared. Evidence provenance belongs in internal metadata and one section-level availability explanation, not every reader-facing domain sentence.

## Unknown omission-card pagination

The disclaimer renderer splits every section into arbitrary groups of four paragraphs. Only chunk zero renders `section.title`; later chunks are full-width bordered containers without a parent or continuation heading. For the actual V1.3 Unknown omissions, chunk one landed on page 6 with three lines, producing an unlabelled, mostly empty final page. The visual log called this oriented because it checked bounds and text presence, but no visible orientation existed. The paginator must first attempt one atomic card; if content requires splitting, it must split by complete omission topic and repeat `หัวข้อที่ไม่ได้แสดง (ต่อ)` on every continuation.

## Incomplete validation

The V1.3 full-suite command was terminated by a 120-second external timeout and therefore never produced a complete pass/fail/skip count. Analyzer output reported the repository's 299 findings but did not establish a machine-comparable baseline versus new findings. V1.4 delivery requires a sufficiently long full-suite run and an explicit new-versus-baseline analyzer comparison.

## V1.4 recovery preservation checkpoint

Before further timeout investigation or implementation changes, the ten dirty V1.4 source, test, and Markdown files were preserved in the non-destructive checkpoint `C:\Users\USER\Documents\Knowme\pr89-v14-recovery-checkpoint-20260811-1648.zip`. The archive contains only the nine modified source/test files and this root-cause document; it excludes PDFs, acceptance packets, build output, secrets, and all earlier V1–V1.3 artifacts. Its size is 67,018 bytes and its SHA-256 is `26D07ED0DB30119A58825409EB812DA9C2A7118979DD41C235CCBEAA791A3D20`.

The inventory at preservation time was branch `agent/thai-report-reading-flow-v1`, local and remote HEAD `23fe2c2fc8a9c5089e7e39b920acb01526fde308`, with nine tracked modifications and this untracked document. Test-generated output changes from the earlier broad-suite run had already been restored independently and were not included.

## Confirmed `ARTIFACT_GENERATION_TIMEOUT` root cause

The candidate-r3 entry point was `flutter test test/validation/thai_beta/narrative/thai_consumer_narrative_acceptance_artifact_test.dart` with `KNOWME_ACCEPTANCE_OUTPUT` set to the candidate artifacts directory, followed by separate desktop and mobile capture variants. The attempts at 120, 180, and 360 seconds all stopped before the Dart test runner started: durable redirected stdout/stderr remained empty, no candidate-r3 file appeared, and process telemetry showed only the PowerShell host and `cmd.exe /c flutter.bat`, with no Dart test child.

The confirmed blocking stage is Flutter SDK bootstrap lock acquisition, before fixture loading. `C:\src\flutter\bin\internal\shared.bat` opens `C:\src\flutter\bin\cache\flutter.bat.lock` and silently loops back to `:acquire_lock` whenever the redirection fails. The workspace sandbox can read `C:\src\flutter` but cannot open that SDK lock path for exclusive write; a direct bounded open reproduced `Access to the path ... flutter.bat.lock is denied`. Consequently the batch file looped indefinitely without stdout/stderr, and the external timeout left its child process behind. This rules out fixture analysis, narrative comparison, Web/PDF generation, font loading, screenshot rendering, and audit complexity as the cause of these three timeouts because none of those stages was entered.

Recovery must preflight the Flutter SDK lock with an explicit `flutter-sdk-lock` stage, fail immediately with that stage name when it is not writable, and run Flutter under the approved filesystem context when the preflight passes. Each artifact phase must emit durable before/after markers and use a bounded process timeout with child cleanup.

## Recovery validation and stop decision

Running Flutter in the approved filesystem context proved the smallest reproduction and the artifact entry point complete normally. The focused reproduction passed in 7.2 seconds. Base Known/Unknown artifact generation completed in 2.73 seconds; separate desktop and mobile capture stages completed in approximately 2.8–3.2 seconds. Durable `[V14_STAGE]` markers cover fixture load, Known analysis, Unknown analysis, PDF/Web generation, manifest creation, and desktop/mobile capture. No orphan process attributable to these runs remained.

The complete cross-fixture audit treats candidate-r2 as negative evidence: 78 Known lines by 65 Unknown lines produced 5,070 pairs, 20 exact pairs, 12 near pairs, 23 allowed pairs, and 9 substantive violations. The intermediate candidate-r5 audit produced 5,070 pairs, 18 exact pairs, 5 near pairs, 23 allowed structural/safety pairs, and zero substantive exact or near-duplicate violations. Its inspectable output is `C:\Users\USER\Documents\Knowme\thai-report-natural-narrative-v1-4-candidate-r5\artifacts\audit\cross-fixture-audit.json`. Candidate-r5 predates the final small semantic wording repair and is diagnostic only; it must not be packaged or delivered.

Focused narrative/export validation passed 72/72 in 6.3 seconds. After the final finance/fortune wording repair, `flutter test --no-pub test/validation/thai_beta/life_map/v134/thai_life_map_v134_narrative_quality_test.dart --reporter compact` passed 6/6 in 2.8 seconds. The initial dirty broad run was 2,836 passed / 61 failed in 55.2 seconds. A separate clean worktree at exact HEAD `23fe2c2fc8a9c5089e7e39b920acb01526fde308` produced 2,856 passed / 40 failed in 76.54 seconds. Comparison classified 22 current-only failures: one V1.4 semantic regression and 21 intentional profile B–H desktop/tablet/mobile timeline golden changes. The semantic regression was fixed; all 21 actual images were manually inspected for clipping, overflow, overlap, and truncation before updating only those goldens. One clean-baseline no-time omission expectation is obsolete under the intended V1.4 behavior and now passes.

The final command `flutter test --no-pub --reporter expanded` completed in 55.97 seconds with 2,858 passed and 39 failed. Every remaining failure is reproducible at clean HEAD and belongs to the clean-baseline groups: human-pattern coverage/semantics (7), Thai engine/fact/QA consistency (11), UI/export harness (6), and consumer diversity/UX/golden harness (15). There are zero unexplained or V1.4-only failures, but the recovery brief explicitly requires delivery to stop whenever the broad suite still fails. Therefore V1.4 is **NOT COMPLETE — BROAD SUITE STILL FAILS**. No final candidate, acceptance ZIP, commit, push, PR-body update, merge, deploy, or Production change was made. Product Acceptance remains pending; earlier packets and `product-acceptance/` remain untouched.

## Owner-approved baseline-delta completion

The Owner subsequently approved a strict baseline-delta gate because absolute zero is not attainable within this scoped PR without repairing unrelated repository debt. Fresh JSON-reporter evidence records clean HEAD at 2,856 passed / 40 failed in 55.233 seconds and V1.4 at 2,858 passed / 39 failed in 57.533 seconds. The machine-readable comparator reports 39 unchanged baseline failures, one baseline failure now passing, zero new failures, zero worsened failures, zero unmatched failures, and exact category totals 7 + 11 + 6 + 15 = 39. The passing baseline failure is `no-time reading never claims lagna or houses`; the V1.4 test diff supports this improvement by replacing obsolete broad omission labels with accurate Lagna/house-specific labels.

Final V1.4-specific results are focused 109/109, repository-defined scoped suite 1,535/1,535, golden suite 24/24, and analyzer 299 findings identical to clean baseline with zero new findings. Fresh candidate-r6, not candidate-r2 or candidate-r5, reports 5,070 inspected Known/Unknown pairs, exact 18, near 5, allowed 23, and zero substantive violations. Its Known 6-page and Unknown 5-page PDFs were rendered and manually inspected page by page with no clipping, overflow, containment, continuation, footer, or avoidable-whitespace defect. Product Acceptance remains pending; PR #89 remains Draft; earlier packets and `product-acceptance/` remain untouched; no merge, deploy, or Production change occurred.

Implementation commit is `179c5c9a3f6318d799b0be8c2233be7013b89c1c`. Final ZIP is `C:\Users\USER\Downloads\thai-report-natural-narrative-v1-4-final-r6-179c5c9.zip`, 22,399,505 bytes, 45 unique safe entries, SHA-256 `9C63DCB66CCD938AB013B09FA90CCC986FBB63A53EE5AB66EE7B04624CFC5F7A`. Baseline comparison JSON/CSV hashes are `DA9C2F8C32D6860CE4C0E733839DD013E63FCA3E331BC1158A1079F154EF8642` and `388F142E2F08323E22AD42DDAE13345445DA22B7E4C32356808C8B2DB8F723E5`. `SHA256SUMS.txt` hash is `369925CF10173743965F49009B2A433DF1D6866D21638489F10B866BAFCB8A7F`.
