# Task: Thai Beta Exemplar Narrative V1 — Engine-integrated acceptance

Validate the recovered `thai-beta-exemplar-narrative-v1` product intent on top
of the Product-Accepted Thai Ascendant Correctness V1 dependency. The immutable
base is PR #84 HEAD `57971d9d1cd2f1b634f1e1a9da7b779f40a6dd74`; Engine
source-tested commit `7e313442241e72734bd6eedd0df97a74e386f48e` remains
authoritative. PR #83 is the primary task and must show only Narrative scope
relative to that accepted Engine base.

The reader-facing Thai Beta flow on Web and PDF must be: direct summary; Thai
astrological day-count explanation; concise computed chart facts; supported
identity/core; work, money, relationships, and wellbeing; one grounded closing
synthesis; the existing V3 current/past/future/Timeline surfaces unchanged; and
a final omissions disclosure with verifiable fail-closed reasons.

All prose and fact rows remain deterministic and traceable to existing
`ThaiBetaAnalysis`, Timeline, Prediction, or corrected Ascendant results.
Unsupported content is omitted rather than replaced with generic horoscope
copy. Web and PDF share the same Core Reading instance and omission records.

Preserve the accepted province resolver, UTC typing, horizon equation, Lahiri
epoch correction, 108 Known-time A–G QA baselines, Profile H unknown-time
baseline, and every out-of-scope golden from PR #84. Do not change Canon,
Timeline/Prediction calculations, evidence policy, Auth, Feedback, Firebase,
standalone Thai Mirror defaults, feature flags, or Production data. This task
ends at Draft PR #83 based on `codex/thai-ascendant-correctness-v1`; do not merge
or deploy.

## Recovery provenance

Checkpoint archive SHA-256:
`23e6eea98845863fb8b1dcafed10faca042009235677333182195656d48bad36`.
Patch SHA-256:
`738aaae86668baf0f1f3300f01a5cabf46e4757522d3fd9390b196c35fc453f3`.
The original manifest contains exactly 13 intended paths. The stack integration
uses a non-force merge commit and semantic conflict resolution; it does not
cherry-pick or replace either accepted scope wholesale.
