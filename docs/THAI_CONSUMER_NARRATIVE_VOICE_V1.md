# Thai Consumer Narrative Voice V1

## Status — Round 8 Draft re-acceptance

Product Acceptance is pending. Existing Draft PR #86 remains unmerged and undeployed.

## Forecast contract

Each horizon/domain block owns separate Claim, Risk, Decision Impact, Action, and non-predictive uncertainty disclosure fields. Web and PDF consume the same presentation model.

`ForecastMaterialFingerprint` is the typed authority for horizon, domain, evidence band, structured risk domain, real evidence availability, and transition. Serialization is audit-only; composition and tests do not parse it.

Claim projection uses horizon/domain/band; Risk uses horizon/domain/risk; Decision Impact uses horizon/domain/band/risk; Action uses all material components. Availability belongs to Action only because it changes recommended behavior. It does not belong to Claim, Risk, or Decision projections. Uncertainty disclosure belongs to no predictive projection.

Action is a short executable recommendation. It uses the actual Claim posture, typed risk response, supported decision consequence, evidence availability, and horizon ownership without quoting whole Claim, Risk, or Decision sentences. With `noLagna`, Action requires an observed-result checkpoint before added commitment; the separate disclosure explains why without being counted as predictive meaning.

## Cross-mode acceptance gate

Pairs are same-civil-profile and matched symmetrically by horizon/domain identity. Claim, Risk, Decision Impact, and Action are compared after excluding disclosure, using exact equality, bidirectional containment, and normalized trigram similarity.

The report separates:

- observed value coverage: strong/active/quiet, multiple risk domains, full/noLagna, transition true/false;
- actual cross-mode difference coverage: band/risk/availability, plus transition only if it truly differs;
- controlled real-derived mutation coverage: band/risk/availability/transition independently;
- field-level comparison coverage: all four predictive fields.

Acceptance fails on missing required coverage, asymmetric identity, zero differences, shared predictive meaning under different material without an evidence-backed record, disclaimer-only differences, or one-cell/vacuous escapes. Shared output is counted only when output is actually equal/contained/similar. If none is justified, the count is zero.

## Horizon ownership and safety

- Current begins `ตอนนี้` and owns immediate action only.
- Next 12 months owns a checkpoint explicitly within 12 months.
- Next life period begins before transition and owns long-term preparation.

Unknown time never substitutes noon or exposes unsupported astrological day, sunrise, Lagna, or houses. Accepted 00:03 Aquarius 9°24′ Saturday and 00:35 Aquarius 19°19′ Saturday remain unchanged. Engine, Canon, evidence meaning, calculations, timeline ranges, routes, flags, Production, and Thai Mirror defaults are outside scope.

## Historical Acceptance

Rounds 3–7 failed Product Acceptance. Their records do not represent current readiness.
