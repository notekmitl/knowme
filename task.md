# Task: Thai Consumer Narrative Voice Product Acceptance — Round 9

Round 8 failed Product Acceptance. Rework the same branch and Draft PR #86 only. Do not merge, deploy, change Production, routes, flags, Thai Mirror defaults, Engine, Canon, evidence meaning, normalization, province resolution, calculations, timelines, or accepted 00:03/00:35 results.

## Active Round 9 scope

- Decision Impact and Action must be generated from one typed `ForecastDecisionPlan`; never infer intent by parsing Thai prose.
- The plan owns horizon, forecast domain, band posture, risk domain/response, decision intent/consequence, availability, and transition.
- Controlled production mutations must recompose all fields through the real production path. Report production generation sensitivity separately from negative gate detection.
- Actual cross-mode identity is `profileCaseId/horizon/domain`, using deterministic non-PII fixture IDs. Duplicate, missing, and unexpected identities fail; ordering must not matter.
- Keep uncertainty disclosure outside predictive fields and shared-output calculation.
- Preserve current/12-month/next-period ownership, Web/PDF parity, unknown-time omissions, taxonomy, age language, pagination, and accepted regressions.
- Create and inspect a new immutable Round 9 packet. Product Acceptance remains pending owner review.

## Delivery boundary

Commit and non-force push only to `codex/thai-consumer-narrative-voice-v1`; update existing Draft PR #86. No merge or deploy. Deliver actual Round 9 PDFs and ZIP through supported attachments. If delivery is unavailable, report `DELIVERY_BLOCKED` and do not claim readiness.

## Historical Acceptance

Rounds 3–8 failed Product Acceptance and are historical only.
