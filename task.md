# Task: Thai Beta Exemplar Narrative V1

Port the recovered `thai-beta-exemplar-narrative-v1` intent and test contract
onto immutable prerequisite PR #82 HEAD
`a20be549f8a25f529d539bb7f23734af469b8c50` without replacing or weakening
Past-to-Future Narrative V3 or its repaired Required-suite contracts.

The reader-facing Thai Beta flow on Web and PDF must be: direct summary; Thai
astrological day-count explanation; concise computed chart facts; supported
identity/core; work, money, relationships, and wellbeing; one grounded closing
synthesis; the existing V3 current/past/future/Timeline surfaces unchanged; and
a final omissions disclosure with verifiable fail-closed reasons.

All prose and fact rows remain deterministic and traceable to existing
`ThaiBetaAnalysis`, Timeline, or Prediction results. Unsupported content is
omitted rather than replaced with generic horoscope copy. Web and PDF share the
same Core Reading instance and omission records.

Do not change Birth Normalization, Thai Engine, Canon, Timeline/Prediction
calculations, evidence policy, Auth, Feedback, Firebase, standalone Thai Mirror
defaults, feature flags, or Production data. This task ends at a Draft PR based
on `codex/thai-full-suite-baseline-fix`; do not merge or deploy.

## Recovery provenance

Checkpoint archive SHA-256:
`23e6eea98845863fb8b1dcafed10faca042009235677333182195656d48bad36`.
Patch SHA-256:
`738aaae86668baf0f1f3300f01a5cabf46e4757522d3fd9390b196c35fc453f3`.
The manifest contains exactly 13 intended paths. Nine applied cleanly; the four
overlapping task/status paths were semantically merged to preserve PR #82.
