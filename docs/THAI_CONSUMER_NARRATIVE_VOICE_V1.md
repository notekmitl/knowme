# Thai Consumer Narrative Voice V1

## Status — Round 7 Draft re-acceptance

Product Acceptance is pending. Existing Draft PR #86 remains unmerged and undeployed.

## Forecast contract

Each horizon/domain block owns four separate fields: Claim, Risk, Decision Impact, and Action. Web and PDF consume the same presentation model.

`ForecastMaterialFingerprint` is the single typed authority. It contains horizon, domain, evidence band, top structured risk domain, real evidence availability, and transition. Serialization is audit-only; composition and tests never parse string keys.

Evidence availability uses the existing `PredictionIntelligence.context.hasLagna` contract only where material. Claim projection uses horizon/domain/band; Risk uses horizon/domain/risk; Decision Impact uses horizon/domain/band/risk; Action additionally uses real availability and transition.

Action receives Claim, Risk, Decision Impact, and the typed fingerprint. It checks the claim posture, responds to the structured risk, uses the decision consequence as its criterion, and fails closed as preparation guidance when Lagna evidence is absent. It must not invent an event or differ only by prefix/synonym/seed.

## Cross-mode acceptance gate

Known/unknown pairs use the same civil profile and are paired by horizon/domain identity. Every field is checked independently for exact equality, bidirectional containment, and normalized trigram similarity. Mandatory disclaimers are excluded.

The report records total compared cells, equal-fingerprint cells, different-fingerprint cells, evidence-backed shared-output justifications, violations, and material-component coverage. A matrix fails if it has no differing fingerprint, a material component lacks fixture/mutation coverage, identity is missing, or materially different cells retain shared/contained/highly similar output without justification.

## Horizon ownership

- Current: immediate action beginning `ตอนนี้`; never long-term wording.
- Next 12 months: checkpoint/review explicitly within 12 months.
- Next life period: preparation before transition and long-term ownership.

## Preserved safety

Unknown time never substitutes noon or exposes unsupported astrological day, sunrise, Lagna, or houses. Accepted 00:03 Aquarius 9°24′ Saturday and 00:35 Aquarius 19°19′ Saturday remain unchanged. Engine, Canon, evidence meaning, calculations, timeline ranges, routes, flags, Production, and Thai Mirror default behavior are outside scope.

## Historical Acceptance

Rounds 3–6 failed Product Acceptance. Their records are historical only and do not represent current readiness.
