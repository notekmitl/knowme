# Thai Consumer Narrative Voice V1

## Status

Draft PR #86 Round 4 re-acceptance candidate at source-tested commit
`81f37502ccd2f1b9f65e8d4f7d870dcaea1770a8`. The first, second, and third Product
Acceptance rounds did not pass; this revision addresses the recorded language,
semantic separation, age suitability, disclaimer ownership, meta leakage and
PDF semantic pagination defects.
This work changes deterministic Thai Beta
narrative composition only. It is not merged or deployed and makes no claim of
scientific accuracy.

The Required scope passes 1,514/1,514 with Local Gates.
checks/workflow runs. The reworked known/no-time Web/PDF packet is awaiting
owner voice review; this status is not a Product Acceptance PASS. Approval,
Merge and Deploy are explicitly outside this task.

## Re-acceptance additions

- Window summaries are structurally outside domain blocks.
- Cross-horizon primary claim/risk/action exact and normalized similarity
  gates omit duplicates instead of decorating them with prefixes or suffixes.
- Age ranges through 21 have distinct work, money, relationship, and health
  meaning; adult workload/burnout templates are prohibited.
- Generic pressure requires source, affected domain, and decision impact;
  label-only input fails closed.
- Omission heading, lead and first reason paginate as one atomic unit.

- Position wording uses one deterministic progress contract at start, early,
  middle, late, final year and transition boundaries.
- Eight period narratives use age-aware facts; current, 12-month and next-life
  windows have separate state, action and long-range purposes.
- Repeated medical guidance appears with current context rather than every age
  period; the final disclaimer remains.
- PDF headings stay with their first paragraph and sparse forced final pages
  are removed without reducing typography.
- Acceptance export/Desktop/Mobile commands exit normally, and Windows capture
  loads a Thai font so the delivered images are readable.
- Medical guidance is rendered only as its own disclaimer; it is never reused
  as a risk signal or as input to an action template.
- Current, 12-month and next-period windows carry state, checkpoint/action and
  long-range preparation roles; duplicated summary/opportunity pairs and
  unsupported generic pressure are omitted.
- Ages 69–108 omit domain paragraphs when computed evidence cannot distinguish
  an age/domain-specific claim. Theme-word substitution is not accepted.
- PDF pagination keeps period context, domain heading and first paragraph in
  one unit, repeats `(ต่อ)` context after page breaks, and renders ISO dates as
  atomic no-wrap tokens.

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
## Round 5 evidence-sensitive future contract (2026-08-08)

Round 4 failed Product Acceptance because its consumer composer replaced the evidence-derived 12-month and next-period claims with profile-independent advice. Every future domain/horizon now renders four explicit fields: `แนวโน้ม`, `ความเสี่ยง`, `ผลต่อการตัดสินใจ`, and `แนวทางเตรียมตัว`. Generic advice is labelled only as preparation and is never presented as a prediction.

Known-time and unknown-time fixtures with different evidence fingerprints must not produce an entirely identical predictive matrix. Unknown-time output fails closed on the astrological weekday and never exposes sunrise. Generic taxonomy labels such as `โอกาส` are not consumer domains; the preview shows only meaningful allowlisted domains or omits the line.
