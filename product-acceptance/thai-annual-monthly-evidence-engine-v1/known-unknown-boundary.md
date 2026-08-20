# Known / Unknown Boundary

## Decision

Monthly availability is `false` for both Known and Unknown profiles because
month-level applicability and scoring rules are absent. Known time does not
make the Authority Gate pass by itself.

| Evidence family | Known time | Unknown time | Monthly consequence |
|---|---|---|---|
| Bangkok civil target year | available | available | framing only |
| Birth-day/life-period evidence | available | available | age/period resolution only |
| Lagna/house evidence | available when calculated | unavailable; must be omitted | cannot be used as Unknown fallback |
| Rolling 12-month prediction | available | available with omissions | still not Jan–Dec monthly evidence |
| Annual Taksa base rotation | available | available without invented time | annual only |
| Current-day transit | available | available | daily only |
| Month-level Canon/scoring rule | absent | absent | fail closed |

No fallback birth time, inferred Lagna, house assignment, annual-copy cloning or
synthetic neutral record is permitted. Unknown output must continue to explain
that the system does not have supported month-level data.

The daily transit source itself does not consume a fallback birth time, but it
also does not emit typed Known/Unknown applicability. That absence blocks both
paths from claiming 365/366-day completeness. KnowMe Monthly Derived Evidence V1
is not Owner-approved or operative; there is no implementation;
`monthlyTimelineAvailable=false`; Production is unchanged; PR #102 closes
unmerged. Future Known/Unknown work requires an authoritative source with
explicit applicability and provenance.
