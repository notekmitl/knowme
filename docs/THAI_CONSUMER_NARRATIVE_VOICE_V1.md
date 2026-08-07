# Thai Consumer Narrative Voice V1

## Status

Draft Product Acceptance candidate. This work changes deterministic Thai Beta
narrative composition only. It is not merged or deployed and makes no claim of
scientific accuracy.

## Reader-facing contract

- Speak directly and naturally to the reader without Engine names, evidence
  keys, QA language, textbook phrasing, or repeated system transitions.
- Explain meaning, likely expression, opportunity or strength, risk, and a
  grounded action only where existing evidence supports them.
- Keep Personal Core, work, money, relationships, wellbeing, current period,
  next 12 months, and longer-range periods semantically distinct.
- Use age-appropriate language. Early childhood must not contain adult income
  or workload claims; late-life periods must not invent job expansion or a new
  role.
- Keep deterministic typed-domain enforcement, paragraph provenance,
  unsupported-content omission, and shared Web/PDF document parity.

## Correctness boundary and fixture separation

The user-reviewed PDF and the historical regression fixture use different
times and therefore must not be compared as if they were one input.

| Fixture | Stored/Engine input | Location authority | Accepted result |
|---|---|---|---|
| User review | `1982-06-06 00:03` | `Asia/Bangkok`, Chiang Mai `18.7883, 98.9853` | Aquarius `9°24′` |
| Historical regression | `1982-06-06 00:35` | `Asia/Bangkok`, Chiang Mai `18.7883, 98.9853` | Aquarius `19°19′` |

Focused tests verify that the exact selected time survives the stored profile
snapshot, normalization, Engine input, Web shared document, and PDF export. The
unknown-time path keeps an empty time, does not substitute `12:00`, omits lagna
and house-dependent sections, and remains fail closed.

## Out of scope

Thai Astrology Engine, Ascendant formulas, Canon, province resolver, Birth
Normalization, evidence eligibility/meaning, Timeline ranges, Thai Mirror
defaults, Auth, Feedback, Firebase, feature flags, public routes, and Production
data are unchanged.
