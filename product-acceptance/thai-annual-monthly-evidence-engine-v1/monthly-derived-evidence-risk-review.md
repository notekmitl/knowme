# Monthly Derived Evidence Risk Review

**Status:** Risk review for a conditional proposed methodology; the daily source
gate is blocked. This is not approved Canon and not implementation approval.

`monthlyTimelineAvailable=false`. Owner decision is Pending. PR #102 remains
Open Draft. Production remains release `1787038542564000`, version
`5f98dfffef913e38`. No Merge, Deploy or Firebase mutation is authorized.

| Risk | Consequence | Mitigation without new astrology rules |
|---|---|---|
| Noon sampling misses intraday transitions | One sample may not represent a day containing a boundary | Declare noon as product sampling only; require source to expose boundary ambiguity; fail closed on ambiguous days |
| Unequal daily rule coverage | Some domains/profiles appear stronger only because more rules emit | Store coverage per rule/domain; require full declared coverage and reject missing days |
| Month length 28–31 | Raw counts favor longer months | Use non-negative integer basis points with multiply-before-divide truncation |
| Mixed signals | A month may be misleadingly forced positive/negative | Preserve supportive and caution independently; equal values remain mixed |
| Duplicate claims | Repeated atoms inflate apparent support | Deduplicate by stable source rule + claim + trace + day before setting daily booleans |
| One strong day vs many weak days | Day-presence aggregation ignores magnitude | Disclose that V1 measures frequency, not strength; do not add weights without separate methodology approval |
| Cross-runtime precision | Floating ordering or serialization can diverge | Integer counts/basis points/runs only; specify canonical ordered serialization before implementation |
| Year boundary | Rolling data may leak adjacent year | Enumerate Jan 1–Dec 31 from target Bangkok year and reject out-of-range source dates |
| Known/Unknown disparity | Unknown may look complete while silently using Known inputs | Typed applicability on each rule/trace; no fallback birth time; availability may differ and fails closed |
| “Good/bad month” overinterpretation | Reader treats frequency as certainty | Use evidence-limited labels and explicit limitation copy; forbid best/worst/certainty wording |
| 365/366 evaluations per report | Latency and resource cost may rise substantially | Benchmark outside Production; cache only after deterministic identity is specified; retain fail-closed timeout behavior |
| Cache staleness/collision | Wrong year/profile evidence could be reused | Key by contract version, canonical profile inputs, target year, applicability and ordered source identities |
| Web/PDF divergence | Different surfaces could show different months | One shared typed monthly model and canonical ordering; parity gate before any flag can enable |
| Production performance | Synchronous full-runtime daily calls could block UI/export | No Production implementation until profiling; consider precomputation only after privacy/cache review |
| Missing source claim/trace | Monthly claims cannot be audited | Current hard blocker: add reviewed daily claim and transit trace contracts first |
| Incomplete four-domain mapping | Finance and other domains can be absent or misassigned | Current hard blocker: authorize an explicit source mapping; never infer from narrative or copy signals across domains |

The proposed frequency method intentionally does not preserve signal magnitude.
That trade-off must be an explicit Owner methodology choice after the source
contract is complete; it cannot be hidden by adding weights in implementation.
