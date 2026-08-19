# Thai Annual Monthly Evidence Engine V1

**Status:** `BLOCKED — AUTHORITATIVE MONTHLY RULES REQUIRED`

**Authority Gate:** FAILED

**Owner decision:** Pending

**Audit baseline:** `main@46d7883bca87570950eb84a7ca3dffbb3e6653b3`

**Date:** 2026-08-19

## Outcome

The repository cannot currently produce an authoritative January–December
monthly evidence timeline. It has deterministic evidence at four different
resolutions, but none defines the complete month-level rule required by the
product contract:

- life-period evidence uses inclusive age ranges;
- prediction evidence exposes a rolling one-year age window labelled
  `next12Months`;
- annual Taksa evidence resolves one Thai astrological age year;
- transit evidence evaluates one calendar day using its weekday ruler.

No repository rule authorizes aggregation of those signals into twelve
calendar-month records, month bands, opportunity/caution ranking, or concise
month claims. Consequently this candidate makes no application change, creates
no monthly score or timeline, and keeps `monthlyTimelineAvailable=false`.

## Required calendar-year contract

The intended contract remains:

- `targetYear = Bangkok civil asOf.year`;
- January 1 through December 31 of that Gregorian year only;
- displayed Buddhist year = `targetYear + 543`;
- exactly 12 ordered records, January through December;
- temporal status (`past`, `current`, `upcoming`) affects presentation only;
- every band and highlight must have authoritative rule, claim and trace ids;
- missing rule, month, trace or deterministic identity fails closed.

This is not the existing rolling `current age .. current age + 1` prediction
window. The current annual summary may remain a separately labelled rolling
horizon, but it cannot be represented as a Jan–Dec timeline.

## Authoritative capability audit

| Candidate | Classification | Repository proof | Month-level result |
|---|---|---|---|
| Bangkok civil `asOf` | Authoritative; usable for Known and Unknown | `ThaiBetaAnalysis.asOf`; submit-time Bangkok civil clock | Defines target year/current month only; it does not score months. |
| Life Period Engine / V9 intelligence | Authoritative; usable without birth time, with Lagna additions only for Known | `life_period_engine.dart`, `life_timeline_intelligence.dart` | Age-range chapters are not calendar-month intervals. |
| V10 `next12Months` | Annual/rolling-window evidence only | `prediction_window.dart` sets `startAge=now`, `endAge=now+1` | One rolling horizon, not 12 calendar records. |
| Annual Taksa | Authoritative annual evidence; base rotation does not require birth time | `annual_taksa_engine.dart` | One record per Thai age year; no month applicability or monthly scoring rule. |
| V15 transit | Authoritative current-day evidence; usable without birth time | `transit_intelligence_engine.dart` creates one same-day `TransitWindow` | No authoritative day-to-month aggregation, threshold, domain roll-up or ranking rule. |
| Canon life-period/taksa corpus | Authoritative source-backed units, internally traceable | `foundation_v1.knowme.json` | 854 units; 299 `life_period` contexts, 8 `taksa_chart` contexts, zero calendar-month fields/contexts and zero Thai month-name values. |
| Canon period-status mapping | Partially authoritative/internal only | period-context/status mapping docs and code | Runtime/Canon matching is incomplete and age/example-chart scoped; not month scoped. |
| Lunar golden cases mentioning months | Calculation validation only | `thai_golden_cases.dart` | Fixture/source labels are not forecast or month-impact rules. |
| Existing annual infographic traces | Traceable rolling annual presentation | `thai_beta_report_export_document.dart` | Trace ids point to rolling prediction-domain material, not month claims. |
| S008 canonical numeric boundary | Stable cross-runtime boundary for existing calculations | accepted V1.5 parity evidence | Does not define monthly inputs, aggregation or ranking identity. |

## Candidate rule detail

### Bangkok civil target-year resolver

- Source: Thai Beta analysis clock and `analysis.asOf`.
- Rule/Canon id: runtime time contract; no astrology Canon id.
- Input: one submit-time Bangkok civil timestamp.
- Calculation: `targetYear = asOf.year`; Buddhist year `+543`.
- Output: year and current-month identity.
- Domain: temporal framing only.
- Known/Unknown: both.
- Claim/trace ids: none for astrology outcomes.
- Numeric precision: integer year/month.
- VM/JavaScript risk: low after the accepted civil-time/canonical contract.
- Decision: usable as framing, insufficient as a monthly evidence rule.

### Life-period and rolling prediction

- Source: `life_period_engine.dart`, `prediction_window.dart`,
  `prediction_intelligence_engine.dart`.
- Rule/Canon ids: V9/V10 engine evidence codes; Canon structural refs may attach
  internally where exact period context exists.
- Input: birth date, optional Lagna lord, `asOf`.
- Calculation: whole-year age, active life-period and one-year age slice.
- Output: category/window evidence and scores.
- Domain: career, finance, relationship, health and other prediction domains.
- Known/Unknown: core works without time; Lagna-dependent evidence is Known only.
- Claim/trace ids: available for horizon/domain claims, not per calendar month.
- Numeric precision: bounded integer scores; stable for the existing horizon.
- VM/JavaScript risk: existing canonicalization is accepted, but no monthly
  canonical model exists.
- Decision: `annual/rolling-window evidence; unusable at month level`.

### Annual Taksa

- Source: `annual_taksa_engine.dart` and Taksa Canon integration.
- Rule/Canon ids: `taksaRole.*` and source-backed rotation units.
- Input: birth-day ruler and Thai astrological age.
- Calculation: deterministic annual planet/house/role rotation.
- Output: one `AnnualTaksaYear` and role assignments.
- Domain: annual structural evidence; not reader-facing month claims.
- Known/Unknown: base birth-day path can operate without birth time; special
  Wednesday boundary handling remains governed by existing normalization.
- Claim/trace ids: internal Taksa attachments/trace, no month claim ids.
- Numeric precision: integer age/house/ring order.
- VM/JavaScript risk: low for integer rotation.
- Decision: `authoritative annual evidence; unusable at month level`.

### Current-day transit

- Source: `transit_intelligence_engine.dart`, `transit_window.dart`.
- Rule/Canon ids: `transitDayVsNatal`, `transitDayVsPeriod`; no monthly Canon
  aggregation id.
- Input: runtime natal ruler, current-period planet, exact `asOf` day.
- Calculation: weekday ruler relationships and signed integer influences.
- Output: two events, two evidence atoms and one same-day impact.
- Domain: the transiting planet's leading domain.
- Known/Unknown: does not require Lagna/birth time.
- Claim/trace ids: runtime evidence source names only; no month claim ledger.
- Numeric precision: integer relationship scores and magnitudes.
- VM/JavaScript risk: low for the existing daily output.
- Decision: `authoritative daily evidence; month aggregation not authorized`.

## Known/Unknown boundary

Neither path may enable the monthly timeline. Known time has additional Lagna
evidence, but still lacks month-level applicability and aggregation. Unknown
time must not receive a fallback time, house/Lagna inference, or a timeline
that looks calculated. The existing polite gap explanation remains the correct
fail-closed behavior for both paths.

## What authorization is missing

Before implementation can begin, the repository needs reviewed authoritative
rules that define, at minimum:

1. which dated signals apply to each calendar month;
2. how daily/period/annual signals are combined per domain;
3. neutral/opportunity/caution thresholds and deterministic tie ordering;
4. source/Canon ids plus claim/trace ids for every output;
5. Known/Unknown eligibility and omission behavior;
6. canonical integer/fixed-point inputs and cross-runtime identity;
7. complete January–December and missing-evidence rejection rules;
8. how the Jan–Dec timeline aligns with, or is explicitly separated from, the
   existing rolling annual summary.

These rules must enter through the existing Canon/review governance. External
astrology knowledge, remembered rules, hashes, randomness, AI generation and
copy-derived scoring are prohibited.

## Change scope and verification policy

- Application source changes: 0.
- Test/golden/expected/canonical changes: 0.
- Owner-approved PR #100 copy/visual changes: 0.
- R1–R7.1 artifact changes: 0.
- Monthly records/highlights/screenshots/PDFs/PNGs: not generated because the
  Authority Gate failed.
- Cross-runtime monthly gate, full suite, analyzer reconciliation and Web build:
  not run; there is no implementation candidate to validate.
- Production: unchanged at Hosting release `1787038542564000`, version
  `5f98dfffef913e38`.
- Merge/Deploy/Firebase mutation: not authorized and not performed.

Detailed evidence is under
`product-acceptance/thai-annual-monthly-evidence-engine-v1/`.

## Monthly Derived Evidence Contract V1 follow-up

The follow-up audit tested whether V15 current-day transit could serve as the
source for `KnowMe Monthly Derived Evidence V1`, a proposed KnowMe product
aggregation methodology rather than an ancient or existing Canon rule.

Positive capability is real but incomplete: explicit arbitrary dates work,
integer polarity is deterministic, and the focused V15 suite passes 6/6 on
Flutter 3.41.1 / Dart 3.11.0. The Source Capability Gate nevertheless fails:

- `TransitEvidence` and `EnhancedEvidence` have no claim IDs;
- `ReasoningTrace` has no transit step/id, and transit atoms have no trace IDs;
- transit assigns one leading domain only; finance is never a leading domain
  and growth/opportunity fall outside the required four reader domains;
- Known/Unknown applicability is not typed on the source evidence;
- Bangkok civil timezone/noon provenance is not enforced by the source type.

The Stop Rule therefore prevents 365/366-day worked monthly results and blocks
Phase 2 activation. The conditional methodology is documented in
`THAI_MONTHLY_DERIVED_EVIDENCE_CONTRACT_V1.md` only to expose what a future
source contract must support. It is proposed methodology, not approved Canon,
has no implementation, keeps `monthlyTimelineAvailable=false`, leaves
Production unchanged, awaits Owner decision, and keeps PR #102 Draft.
