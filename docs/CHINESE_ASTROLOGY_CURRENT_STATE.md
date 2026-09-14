# Chinese Astrology V1 — Current State

**Status:** IMPLEMENTED FOR OWNER TESTING — stacked Draft PR #122 — not Ready,
not merged, not deployed

**Date:** 2026-09-14

**Product contract:** `KnowMe BaZi Compatibility V1`

**Interpretation contract:** `knowme_bazi_symbolic_reading_v1`

**Validated application:** the runtime commit containing the 2026-09-14
three-system handoff and natal-reading expansion; its exact commit/tree are
recorded in the final docs-only closeout.

## What the system actually uses

KnowMe uses **BaZi / Four Pillars (八字 / 四柱)**. The year animal is a
secondary value derived from the Year pillar; it is not the calculation system
by itself. V1 is explicitly a KnowMe compatibility contract. It does not claim
to be the universal standard of every BaZi school.

The deterministic source of calculation is the Python code under
`backend/app/services/bazi/`, backed by the pinned dependency
`lunar_python==1.4.8`. No AI text is used to calculate a chart or compose the
reading. The report projects calculated facts, input/rule metadata, a
source-ledgered symbolic interpretation and limitations. The dormant legacy
personality/work/relationship/prediction copy is still excluded because it has
no approved mapping to this calculation contract.

## Sourced symbolic reading

`knowme_bazi_symbolic_reading_v1` adds the smallest useful interpretation that
can be audited against the governed facts:

- all ten Heavenly Stem Day Masters have a Thai and English natural-image
  metaphor, symbolic tendency, constructive expression, balance point and
  practical reflection;
- visible elements are grouped into five broad relationships relative to the
  Day Master: Resource, Companion, Output, Wealth and Authority; and
- complete Known or ordinary Unknown charts receive five reader-facing natal
  areas—usable strengths, work/roles, money/resources, relationships/shared
  space and cautions/development—derived from the Day Master plus every
  joint-highest visible relationship family; and
- the report separates calculation sources from interpretation sources and
  identifies both versioned contracts.

The source ledger cites Hong Kong Observatory for stem/branch and solar-term
structure, the pinned 6tail implementation for reproducible calculation, and
Joey Yap's Ten Day Masters and 10 Gods books for the named interpretation
framework. KnowMe owns the concise paraphrases. They are presented as symbolic
self-reflection, not scientific evidence, diagnosis or event prediction.

The five relationship counts reuse only the visible surface elements already
allowed by the calculation contract. A largest count is described as most
visible, never strong/favourable or good/bad. Zero is not treated as absence
because V1 does not include hidden stems, roots, seasonality or strength
weighting. Exact wording and mappings are in
`CHINESE_ASTROLOGY_INTERPRETATION_V1.md`.

Each natal-area paragraph carries an evidence line naming the Day Master and
family/count used. Ties are retained instead of resolved arbitrarily. The
money area also discloses the visible Wealth-family count and explicitly
refuses a good/bad conclusion when that count is zero. These are natal
reflection prompts, not timed events or outcome guarantees.

## Approved compatibility policy

| Concern | KnowMe BaZi Compatibility V1 rule |
|---|---|
| Calendar input | Gregorian local civil date and optional local civil time |
| Timezone | a supplied IANA zone is required and validated as the civil-time context; the wall clock is not converted to UTC |
| Year boundary | exact Li Chun (`立春`) boundary from the pinned engine |
| Month boundary | exact Jie (`節`) solar-term boundary from the pinned engine |
| Day boundary | local civil 00:00 using `sect=2`; 23:00 changes the Hour branch but not the Day pillar |
| True-solar correction | none |
| Location/coordinates | recorded as context; not used in the V1 calculation or input fingerprint |
| Known time | exposes Year, Month, Day and Hour pillars |
| Unknown time | omits Hour and time-dependent fields; evaluates 00:00:00 and 23:59:59 and omits a Year/Month value if it is not invariant across the civil date |

Chinese/Lunar New Year is deliberately **not** the V1 Year-pillar boundary.
Li Chun is. A regression test fixes this distinction.

## Inputs and normalization

The authenticated API accepts:

- `uid`, which must exactly match the verified Firebase ID-token UID;
- `birth_date` as a Gregorian local-civil date;
- optional `birth_time`; null/blank means Unknown time;
- required IANA `timezone`;
- optional latitude and longitude, retained only as disclosed context.

The input fingerprint is SHA-256 over a canonical JSON payload containing
trimmed birth date, normalized birth time (`null` for Unknown), trimmed IANA
zone and the contract id. Coordinates are intentionally excluded because they
do not affect this compatibility calculation. The Dart client and Python
backend have fixed cross-language hash fixtures.

Authentication is enforced twice: the client requires a current Firebase user
and ID token, and the backend verifies the bearer token with revocation checking,
rejects UID mismatch, and writes only to the authenticated UID paths. Tests use
stubs; they do not write Production data.

The `/beta/thai` form now supplies a product handoff into this profile model.
After form validation, one screen offers Thai, Chinese BaZi and Western natal.
Thai stays on its accepted anonymous calculation path. Chinese and Western
require sign-in before saving the profile. Unknown time is stored as an empty
string rather than the Thai normalization layer's internal noon sentinel.
Chinese can proceed under this contract; Western is disabled unless a real
time and province are available.

## Outputs

The stored chart and its results mirror carry the same governed projection:

- contract id/name, engine/version, generated timestamp and input fingerprint;
- disclosed calculation policy and normalized input context;
- available pillars and Day Master stem;
- Year-pillar animal only when Year is available;
- visible stem/branch element counts over available pillars only;
- completeness, `time_known`, ambiguity flags and an explicit suppressed-field
  list.

The element result is a **visible surface count**, not full BaZi strength. It
does not include hidden stems, rooting, seasonal weighting, Day Master strength
or Useful God (`用神`). The report may identify the most visible broad
relationship family as a structural reflection, but it does not turn that count
into a strength score, personality verdict or prediction.

## Known and Unknown time behavior

Known time uses only the supplied local civil clock fields supported by V1.
Timezone offsets and longitude do not shift the clock, and no true-solar
correction is implied.

Unknown time is fail-closed:

1. no noon, midnight-as-birth-time, guessed clock, placeholder Hour pillar or
   hour-derived element slots are exposed;
2. the Day pillar remains available because `sect=2` holds it constant across
   one civil date;
3. if Li Chun occurs within the date, Year, Month and Year animal are omitted;
4. if another Jie occurs within the date, Month is omitted;
5. suppression metadata is persisted and the same canonical report builder is
   used by signed-in Web, the Owner route and PDF/export.

For interpretation, ordinary Unknown time uses the six visible slots from
Year/Month/Day and explicitly excludes Hour. A Li Chun/Jie boundary fixture may
have too few complete pillars for a chart-wide relationship summary, so it
shows only the invariant Day Master reflection and does not fill the gap.
The five natal-area readings follow the same boundary: shown for complete
four-/three-pillar context and omitted for boundary-partial Unknown.

The generation coordinator fingerprints the current profile before accepting a
stored chart. A missing, legacy-version or changed fingerprint triggers a new
BaZi calculation. If regeneration fails, the result page does not expose the
stale chart. Unknown-time profiles generate BaZi only; Thai, Western and Fusion
generation remain closed because their existing readiness contract requires
the missing inputs.

Fusion freshness uses the governed BaZi input fingerprint rather than only the
Day Master. A Known -> Unknown edit therefore changes the BaZi lens version, and
the version comparison treats a lens that disappears as outdated. The old
hour-bearing Fusion result cannot survive the fail-closed transition even when
the Day Master itself is unchanged.

## Product surfaces

- Signed-in BaZi result page: authenticated chart freshness check, then the
  canonical sourced natal reading and PDF export.
- Post-form selection: `/beta/thai` validates the existing form, then presents
  Thai, Chinese BaZi and Western natal without rerunning or changing the Thai
  calculation. The selected non-Thai system is prepared before its result page
  opens.
- Owner fixture route: `/beta/chinese?case=known`, `unknown`,
  `lichun-unknown`, or `jie-unknown`. It is visibly marked as a fixture, calls no
  API and performs no user-data write.
- Owner PDFs: `output/pdf/knowme-bazi-natal-reading-v1/`
  contains `known`, `unknown`, `lichun-unknown` and `jie-unknown`. Each is
  reproducible from the same canonical report object and ignored by Git.
  Chinese glyphs use the checked-in static `NotoSansSC-Regular` font; the Thin
  variable font is not used.

There is no separately published public Chinese shared-report URL in V1. Any
surface implemented here uses the same report model. Wider Fusion/narrative,
strength, luck-cycle and event interpretation remains outside this sourced V1.

## Owner manual QA boundary

Owner fixture testing is deliberately limited to:

1. Known completeness;
2. ordinary Unknown omission of Hour and all time-dependent values;
3. Li Chun Unknown omission of boundary-ambiguous values;
4. Jie Unknown omission of boundary-ambiguous values; and
5. Web/PDF parity for the Day Master reading, relationship families, facts,
   omissions, source ledger, policy labels and final limitations.

The fixture route calls no API and writes no data. Token presence, verified UID,
revoked-token handling, regeneration and Fusion freshness are automated
engineering gates, not Owner fixture steps.

## Evidence and coverage limits

The validation uses targeted boundary and equivalence classes. It does **not**
claim every date, second, IANA zone or coordinate pair was executed. The exact
matrix and counts are maintained in
`docs/CHINESE_ASTROLOGY_VALIDATION_V1.md`.

Covered representatives include Known and Unknown time, ordinary dates,
Li Chun, Jie, Chinese New Year as a deliberate non-boundary, leap day,
22:59/23:00/23:59/00:00, two valid zones plus one invalid zone, two coordinate
pairs, UID mismatch, missing/invalid tokens, stale-profile regeneration,
Fusion Known -> Unknown invalidation, cross-surface report leakage and four PDF
fixture variants. The interpretation suite additionally covers all ten Day
Masters, all five Day Master element cycles, Known/ordinary Unknown/boundary
projection and forbidden outcome promises. The current suite also covers the
three-system chooser, anonymous Thai preservation, authenticated profile
handoff, versioned BaZi/Western APIs, Western input gating, and forced-Western
Fusion invalidation. Authoritative Flutter 3.41.1 / Dart 3.11.0 results with
`TZ=Asia/Bangkok` are backend 22/22, focused Flutter 79/79, full Flutter
3,070/3,070, analyzer exit 0 with 282 inherited non-fatal diagnostics and
scoped analyzer 0.

## Known limitations and separate blockers

- `lunar_python@1.4.8` is a pinned implementation dependency, not evidence that
  V1 represents all schools.
- No true-solar correction, arbitrary school selection, hidden-stem/seasonal
  strength, polarity-specific Ten Gods, Useful God, combinations/clashes, luck
  pillars or event prediction is present. V1 only uses the five broad elemental
  relationship families documented by the interpretation contract.
- Actual localhost/loopback endpoint findings are 0. The bundle has one literal
  `localhost` in a hostname comparison, which is not an endpoint. Distinguishing
  the two is a future shared guard-quality task; policy still requires it to
  close before Production. This PR does not change shared or Production code.
- Full-suite pixel results are toolchain-sensitive. Final results and the exact
  Flutter version are recorded in the validation document; Thai goldens are not
  changed.

## Release sequencing (not authorized by this PR)

The prior client-first then immediate backend-enforcement proposal remains
withdrawn because it does not cover cached or already-open clients. PR #122 now
implements the compatibility code but does not deploy it:

1. authenticated `/v1/generate-bazi` and `/v1/generate-chart` routes exist in
   parallel with explicit compatibility routes;
2. the new clients send Firebase bearer tokens to the v1 routes;
3. Production must deploy the backend v1 routes before releasing this client;
4. adoption must then be observed and verified; and
5. the legacy Western route may be retired only after that gate passes.

The existing BaZi compatibility route remains authenticated. The pre-existing
Western compatibility route remains unauthenticated only for already-released
clients and is not used by the new code. This is implementation evidence, not
release authorization. Draft PR #122 performs no backend, Hosting or
Production deployment.

## Scope protection

PR #122 remains stacked on Open + Draft PR #120 at
`4ce29747fee66d08637dbe0b16b982b17071526d`. This work modifies only the Thai
route's post-submit navigation seam; it does not modify Thai calculation/report
logic or Thai goldens. It also leaves `product-acceptance/`, Firebase Hosting,
Production data, Production services, merge state and readiness state
unchanged.
