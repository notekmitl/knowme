# KnowMe Monthly Derived Evidence V1

**Status:** Conditional proposed methodology; blocked by the Daily Transit
Source Capability Gate

**Nature:** KnowMe product aggregation rule, not an ancient Thai astrology rule,
not an existing Canon rule, and not approved Canon

**Owner decision:** Pending Owner Review

**Implementation:** None; `monthlyTimelineAvailable=false`

**PR/Production:** PR #102 remains Open Draft. Production remains V1.5 Hosting
release `1787038542564000`, version `5f98dfffef913e38`. Merge, Deploy and
Firebase mutation are not authorized.

## 1. Gate position

This document records the requested methodology so the missing source contract
is explicit. It is not an executable or approval-ready contract. Phase 2 cannot
be activated because current transit evidence has no claim IDs, no transit
trace IDs, no typed Known/Unknown applicability and no complete mapping to the
four required reader domains. No monthly result may be produced from this
document until those gaps are resolved and separately reviewed.

## 2. Conditional calendar-year contract

If a later authoritative daily source closes the blockers, the product
aggregation would use:

- target year = the year of the explicitly supplied Bangkok civil `asOf`;
- source range = January 1 through December 31 of that year;
- one evaluation per calendar day, including February 29 in leap years;
- daily evaluation anchor = 12:00 Asia/Bangkok;
- the noon anchor is a KnowMe sampling rule, not a Canon or traditional rule;
- no rolling current-month + 11-month horizon;
- `past/current/upcoming` is display metadata only and never changes evidence.

The caller would have to supply an explicit Bangkok civil date on every daily
request. The existing fallback when `asOf` is absent is not eligible for this
contract.

## 3. Conditional daily counting

For each eligible authoritative daily signal and each supported domain:

- at least one positive signal makes `supportiveDay = 1`;
- at least one negative signal makes `cautionDay = 1`;
- a day may be both supportive and caution when separate source signals support
  each polarity;
- multiple same-polarity signals never count the day more than once;
- zero eligible positive/negative signals is neutral;
- narrative text is never converted into a score;
- no planet, rule or signal receives a newly invented weight.

This counting remains conditional because the current source does not carry the
required per-signal claim/trace identity or four-domain eligibility.

## 4. Conditional length normalization

Raw day counts cannot rank months of different length. The proposed derived
integer values are:

```text
supportiveBps = floor(supportiveDays * 10000 / daysInMonth)
cautionBps    = floor(cautionDays    * 10000 / daysInMonth)
```

All operands and results are integers. Multiplication occurs before division;
division truncates toward zero, which is identical for these non-negative
values in Dart VM and compiled JavaScript. No floating-point value participates
in ordering.

Each future record would retain day count, days in month, basis points, longest
consecutive run, contributing rule IDs, claim IDs, trace IDs, missing-day count,
Known/Unknown applicability and deterministic identity.

## 5. Conditional ranking

An opportunity candidate would require all of:

- `supportiveBps > 0`;
- `supportiveBps > cautionBps`;
- an authoritative supportive claim and trace;
- missing-day count = 0.

Order: supportive basis points descending, longest supportive run descending,
month number ascending. Select at most three and never fill a quota.

A caution candidate would require all of:

- `cautionBps > 0`;
- `cautionBps > supportiveBps`;
- an authoritative caution claim and trace;
- missing-day count = 0.

Order: caution basis points descending, longest caution run descending, month
number ascending. Select at most three and never fill a quota.

Equal basis points do not become opportunity or caution. Mixed or near-balanced
signals would remain `mixed`/`neutral-highlight` under a separately reviewed
integer closeness threshold. No closeness threshold is authorized in V1 because
the task supplied no exact value; equality is the only currently specified tie.

## 6. Conditional derived identity

Proposed derived namespaces are product trace identifiers, never Canon units:

- `KMDV1-MONTH-YYYY-MM`
- `KMDV1-OPPORTUNITY-YYYY-MM`
- `KMDV1-CAUTION-YYYY-MM`

An identity would have to include the contract version, target year/month,
source day range, applicability class, ordered source rule/claim/trace IDs,
integer counts/basis points/runs and missing-day count. The serialization and
hash algorithm are not selected here; they require an explicit stable
cross-runtime contract before implementation.

## 7. Known/Unknown boundary

Known may consume only daily rules whose inputs and evidence explicitly permit
birth time, ascendant or houses. Unknown may consume only rules explicitly
independent of those values. No fallback time, noon-as-birth-time, Known result
copy or house/Lagna inference is allowed.

The current transit layer accepts a birth date and optional Lagna lord but does
not emit typed Known/Unknown applicability. Therefore neither Known nor Unknown
can claim 365/366-day monthly availability under this contract today.

## 8. Reader-facing language

Allowed labels, after source and Owner approval:

- `สัญญาณโอกาสเด่น`
- `ช่วงที่ควรระวังมากขึ้น`
- `จังหวะผสม`
- `ไม่มีสัญญาณเด่น`

Forbidden: “เดือนดีที่สุด”, “เดือนแย่ที่สุด”, certainty claims, guaranteed luck
and guaranteed danger.

## 9. Activation prerequisites

Before this conditional proposal can become implementable, a later authorized
change must add and validate, without inventing Canon:

1. stable claim IDs for both daily transit rule families;
2. a transit trace layer that binds date, source rule, target, polarity and
   domain;
3. authoritative mapping to career, finance, relationship and health, including
   explicit ineligible/neutral behavior;
4. typed Known/Unknown applicability;
5. Bangkok timezone/anchor validation;
6. stable serialization and deterministic identity;
7. 365/366-day completeness and missing-day rejection.

Until then this proposed methodology is blocked, not approved Canon, has no
implementation, keeps `monthlyTimelineAvailable=false`, leaves Production
unchanged, awaits Owner decision, and keeps PR #102 Draft.
