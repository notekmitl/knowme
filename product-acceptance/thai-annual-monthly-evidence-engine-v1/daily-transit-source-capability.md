# Daily Transit Source Capability

**Gate result:** FAIL — daily source contract insufficient

**Methodology status:** Proposed only; not approved Canon

**Implementation:** None; `monthlyTimelineAvailable=false`

**Owner/PR/Production:** Owner decision Pending. PR #102 remains Open Draft.
Production remains release `1787038542564000`, version
`5f98dfffef913e38`. No Merge, Deploy or Firebase mutation is authorized.

## Capability answers

| # | Question | Finding | Gate |
|---:|---|---|---|
| 1 | Explicit target date | `ReasoningRequest.asOf` accepts `DateTime?`; the enhanced runtime forwards it | PASS when required explicitly |
| 2 | Wall clock/device timezone | Explicit `asOf` avoids wall clock; absent `asOf` uses a reconstructed date. No timezone ID is carried | CONDITIONAL |
| 3 | Bangkok civil date | A caller can supply Bangkok civil Y-M-D; the transit layer does not verify `Asia/Bangkok` | CONDITIONAL |
| 4 | Deterministic | Existing V15 suite passes repeat determinism | PASS |
| 5 | Authoritative polarity | Existing engine score −3..+3 and magnitude `score * 15` provide signed polarity | PASS as engine rule; no Canon link |
| 6 | Support/caution/neutral | Positive/negative/zero is structurally separable from integer magnitude/bond | PASS |
| 7 | Four reader domains | Source assigns only the transiting planet's single leading domain; finance is never leading | **FAIL** |
| 8 | Claim IDs / trace IDs | Transit evidence has stable `sourceName` only; no claim ID and no transit trace step/id | **FAIL** |
| 9 | Known/Unknown applicability | No typed applicability or omission reason on request/evidence/assessment | **FAIL** |
| 10 | Arbitrary date | Any explicit date can be evaluated; tests exercise fixed dates and same weekdays | PASS |
| 11 | Numeric risk | Transit math is bounded integer math; date/time construction and future identity serialization remain risks | LOW for current signal; UNDEFINED for monthly identity |
| 12 | Birth time/Lagna/houses | Transit context uses birth ruler and current period planet; no birth time/house input and no fallback time. Optional Lagna exists on the base request but is not carried into transit evidence | PASS for no fallback; applicability still missing |

The missing claim/trace contract and four-domain mapping independently trigger
the Source Capability Stop Rule.

## Source-rule inventory

| File | Symbol | Canon/rule ID | Input/date dependency | Domain/polarity | Known/Unknown | Claim/trace | Precision/determinism | Eligibility |
|---|---|---|---|---|---|---|---|---|
| `core/runtime/reasoning_request.dart` | `ReasoningRequest.asOf` | runtime input field; no Canon id | explicit `DateTime?` | none | not typed | none | civil date object | Eligible only when non-null |
| `core/transit/enhanced_reasoning_runtime.dart` | `_enhance` | V15 wrapper | forwards request `asOf` | none | not typed | base trace only | deterministic orchestration | Eligible transport |
| `core/transit/transit_context.dart` | `TransitContext.fromResponse` | V15 context rule | explicit `asOf`, else reconstructed fallback | none | no applicability field | none | deterministic, but fallback prohibited | Conditional |
| `core/life_period/life_planet.dart` | `LifePlanets.rulerForWeekday` | weekday-ruler engine rule; no attached Canon unit | date weekday | planet only | birth time not used | none | integer enum mapping | Eligible source primitive |
| `core/life_period/planet_relationship_engine.dart` | `assess` | `natural*2 + element`; no runtime Canon reference | transiting + target planets | signed −3..+3 | time-independent | none | integer and deterministic | Eligible polarity primitive |
| `core/transit/transit_intelligence_engine.dart` | `evaluate` | `transitDayVsNatal`, `transitDayVsPeriod` | exact date, natal ruler, current-period planet | two signed events | no typed boundary | stable source names only | integer, deterministic | Ineligible as monthly source contract |
| same | `_leadingDomain` | leading affinity rule; no Canon id | transiting planet | one of 6 supportive domains | same path for all | none | deterministic sort | **Ineligible: no four-domain coverage** |
| `core/transit/transit_evidence.dart` | `TransitEvidence` | sourceName only | source event | magnitude/domain/planet | absent | **claim/trace absent** | integer | **Ineligible** |
| `core/transit/enhanced_reasoning_response.dart` | `transitEvidence` | layer literal `transit` | transit atoms | preserves source/magnitude/domain | absent | no identity added | deterministic list order | **Ineligible** |
| `core/runtime/reasoning_trace.dart` | `ReasoningTrace` | V13 base layers | runtime steps | timeline/prediction/decision/question | absent | no transit step | deterministic | **Ineligible for transit trace** |

## Domain proof

`_leadingDomain` chooses only `supportRanked.first` from fixed affinity data:

| Planet | Leading domain |
|---|---|
| Saturn | career |
| Jupiter | growth |
| Rahu | opportunity |
| Venus | love |
| Sun | career |
| Moon | health |
| Mars | career |
| Mercury | growth |

Finance is never selected; growth/opportunity are outside the required four
reader domains. Reassigning or copying a signal into finance/other domains would
be a new product/astrology mapping and is prohibited in this task.

## Canon and trace proof

The production Canon corpus contains no `transit` units and no friend/enemy
relationship units linked to the runtime matrix. The transit code emits no
Canon reference. Repository search finds no `claimId`, `claimIds`, `traceId` or
`traceIds` field in the transit/runtime evidence shapes. A stable source name is
not equivalent to a claim ID or a date-bound trace.

## Focused verification

- Toolchain: Flutter 3.41.1 / Dart 3.11.0.
- Command: `flutter test --no-pub --reporter expanded test/validation/thai_mirror_v15_transit/transit_integration_test.dart`.
- Result: 6/6 passed.
- Proven: fixed explicit dates, weekday-ruler stability, relationship reuse,
  evidence merge, runtime compatibility and identical-request determinism.
- Not proven: claim/trace completeness, four-domain coverage, Bangkok timezone
  enforcement, Known/Unknown applicability, 365/366 completeness or monthly
  aggregation.

## Stop decision

No 365-day fixture harness or worked monthly ranking was produced. Doing so
would create results without the identities and domains required by the source
contract. The exact repair prerequisite is a separately authorized source
contract layer; application implementation remains prohibited here.

Governance: proposed methodology; not approved Canon; no implementation;
`monthlyTimelineAvailable=false`; Production unchanged; Owner decision Pending;
PR #102 remains Draft.
