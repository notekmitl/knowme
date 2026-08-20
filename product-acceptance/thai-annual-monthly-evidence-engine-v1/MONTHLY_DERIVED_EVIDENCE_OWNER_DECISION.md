# Monthly Derived Evidence — Owner Decision

**Contract name:** KnowMe Monthly Derived Evidence V1

**Decision:** `DEFERRED — NO AUTHORITATIVE MONTH-LEVEL SOURCE`

**Decision recorded:** 2026-08-20

The Owner did not approve Monthly Derived Evidence Contract V1 because no
authoritative source exists for month-level astrology rules. The Monthly
Timeline is deferred. No substitute data or prediction may be generated from
guesswork.

## Binding effect

- The conditional contract is not Owner-approved and is not operative.
- Weekday-ruler aggregation must not be used as a substitute for a monthly
  horoscope.
- Adding claim IDs, reasoning-trace IDs or serialization alone does not make an
  insufficient source authoritative.
- No monthly records, opportunity/caution highlights, or monthly Web/PDF/PNG
  artifacts were created.
- `monthlyTimelineAvailable=false` remains unchanged.
- The accepted annual infographic continues to operate without a Monthly
  Timeline.
- Production is unaffected at Hosting release `1787038542564000`, version
  `5f98dfffef913e38`.
- PR #102 is to be closed unmerged after this decision record is pushed. Its
  source branch must be retained.

## Why the proposal was not approved

The repository has deterministic age-period, rolling annual, annual Taksa and
same-day transit evidence. None is an authoritative calendar-month rule set.
The daily transit layer can evaluate explicit dates, but it does not establish
the month applicability, transit-to-domain semantics, aggregation, scoring,
ranking and source-trace authority required for reader-visible monthly claims.
The previously documented counting/ranking approach is therefore only a
historical conditional proposal and cannot drive product output.

## Conditions for reopening as a new work item

Future work requires an authoritative source with reviewable provenance that
defines, at minimum:

1. calendar-month applicability;
2. transit-to-domain mapping;
3. aggregation, scoring and ranking;
4. claim and reasoning-trace contracts;
5. Known/Unknown applicability and fail-closed behavior;
6. Bangkok civil-time provenance; and
7. deterministic identity and serialization.

This decision does not authorize implementation, tests, fixtures, expected
outputs, goldens, Canon, PDF/PNG/ZIP generation, Build, Merge, Deploy or any
Firebase mutation.
