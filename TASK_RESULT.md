# Thai Consumer Narrative Voice V1 — Round 6

## Status

READY FOR PRODUCT RE-ACCEPTANCE. PR #86 remains Draft. No merge, deployment, Production change, feature-flag change, public-route change, or astrology-engine/calculation change was made.

## Round 6 result

- Fixed horizon ownership: current actions begin with `ตอนนี้` and cannot use long-term wording; the 12-month action explicitly owns review within 12 months; next-period actions begin before the life-period transition and own long-term preparation.
- Forecast cards now carry separate structured Claim, Risk, Decision Impact, and Action fields from the shared narrative model through Web and PDF export.
- Decision Impact and Action are selected from the upstream material fingerprint (`horizon/domain/band/risk/evidence/transition`) rather than static domain-only templates.
- Replaced the weak cross-mode check with a horizon × domain × field matrix. It compares known-time and unknown-time output using exact match, bidirectional containment, and normalized trigram similarity, while allowing shared output only when the projected material fingerprint is equal.
- Added a negative self-test in which only one field changes; the unchanged fields with unequal fingerprints are rejected, proving that one differing block cannot let the matrix pass.
- Preserved accepted 00:03 (Aquarius 9°24′, Saturday), 00:35 (Aquarius 19°19′, Saturday), unknown-time fail-closed behavior, consumer taxonomy, age language, parity, and pagination contracts.

## Verification

- Focused narrative/export regression: 237 tests PASS after the export-contract update; the directly targeted Round 6 test file is 12/12 PASS.
- Synthetic/V3/parity suite: 15 tests PASS, including 300/300 deterministic synthetic profiles.
- Full required regression: 1,518 tests PASS.
- Static analysis: exit 0 under the accepted non-fatal warning/info policy (299 existing repository findings).
- Product artifact generator, exact PDF audits, visual page review, gates, source/remote SHAs, and packet hashes are recorded in the Round 6 acceptance packet.

## Scope and safety

Changed only the Thai consumer forecast narrative model/composer, Web presentation, PDF export projection, scoped tests, task scope, and status/contract documentation. The Thai Astrology Engine, ascendant/houses/planets, province resolver, birth normalization, known-time astrological-day rule, Canon/Mahabhut, evidence meanings, timeline ranges, auth/feedback/Firebase/Production, and feature flags were not changed.

## Acceptance history

- Round 5: failed Product Acceptance because the current-window action inherited long-term wording, Decision/Action remained domain-template driven, and the cross-mode gate could pass when only one block differed.
- Round 4 and earlier: retained as historical context in git history and prior immutable acceptance packets; none supersedes this Round 6 status.

READY FOR THAI CONSUMER NARRATIVE VOICE RE-ACCEPTANCE — ROUND 6
