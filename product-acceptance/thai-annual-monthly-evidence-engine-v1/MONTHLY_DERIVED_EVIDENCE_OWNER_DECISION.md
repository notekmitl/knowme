# Monthly Derived Evidence — Owner Decision

**Contract name:** KnowMe Monthly Derived Evidence V1

**Decision:** Pending Owner Review

**Current gate:** BLOCKED — daily source contract insufficient

This is a proposed KnowMe product methodology, not an ancient astrology rule,
not approved Canon and not an implementation. `monthlyTimelineAvailable=false`.
PR #102 remains Open Draft. Production remains release `1787038542564000`,
version `5f98dfffef913e38`. No Merge, Deploy or Firebase mutation is authorized.

## What the system would use

The proposal would evaluate only existing, authoritative daily transit signals
for every Bangkok calendar day in the selected year. It would not read
narrative text or invent astrology rules.

Today the source can evaluate explicit dates deterministically and returns two
signed signals per day. It does not yet provide claim IDs, transit trace IDs,
typed Known/Unknown eligibility or full career/finance/relationship/health
coverage. Therefore no monthly result has been created.

## How daily counting would work

After the source gaps are fixed, a domain would count a day once when at least
one eligible supportive signal exists, and once when at least one eligible
caution signal exists. The same day could count on both sides when separate
signals disagree. Repeated same-side signals would not multiply the day.

## Why divide by days in the month

February and 30/31-day months are different lengths. Dividing the counted days
by the number of days in that month and storing integer basis points makes the
comparison length-normalized without floating-point ordering.

## How highlighted months would be chosen

At most three opportunity months would be ranked by supportive basis points,
then consecutive supportive run, then earlier month. Caution months would use
the same order on caution evidence. A tied month would remain mixed instead of
being forced good or bad. Missing days or missing claim/trace evidence would
make the month unavailable.

## What the system would not do

- no best/worst or certainty claims;
- no random, hash, AI or narrative-derived scoring;
- no new planet weights;
- no copying annual summaries into months;
- no fallback birth time or Known result for Unknown;
- no Production output before source, implementation and Owner gates pass.

## Known and Unknown

Known may use only rules explicitly authorized for time/Lagna/house inputs.
Unknown may use only rules explicitly independent of them. Current transit
signals do not consume a fallback birth time, but they also do not label their
applicability, so neither path is monthly-ready.

## Limitations and user impact

The proposal measures how often eligible daily signals occur, not their
strength. Noon sampling may miss intraday transitions. Mixed evidence remains
mixed. If eventually approved and implemented, readers would receive
evidence-limited “opportunity”, “more caution” or mixed labels—not predictions
of guaranteed events. Current users see no change.

## Feasibility evidence and computation cost

The existing focused V15 suite passes 6/6 for fixed-date stability,
determinism, integer polarity and evidence merge. The requested five-fixture,
365-day worked results were intentionally not generated after the Stop Rule
failed. Theoretical source volume is two transit atoms per day: 730 in a normal
year per fixture, or 3,650 for five fixtures, before base-runtime evidence and
aggregation. Actual latency, caching and Production cost remain unmeasured.

## What the Owner would be approving

Approval would accept the product methodology—daily boolean counting, month
length normalization, deterministic ranking, limited labels and fail-closed
boundaries—only after the missing daily source contract is supplied and
reviewed. It would not approve Canon facts, implementation, UI, Merge or Deploy.

## Decision options

- Approve KnowMe Monthly Derived Evidence V1 methodology
- Reject and keep monthly timeline unavailable

Decision remains `Pending Owner Review`. Because the source gate is currently
blocked, approval is not yet actionable and no readiness claim is made.
