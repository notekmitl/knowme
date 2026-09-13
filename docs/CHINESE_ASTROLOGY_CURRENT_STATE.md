# Chinese Astrology V1 — Current State

**Status:** IMPLEMENTED FOR OWNER TESTING — stacked Draft PR #122 — not Ready,
not merged, not deployed

**Date:** 2026-09-13

**Product contract:** `KnowMe BaZi Compatibility V1`

## What the system actually uses

KnowMe uses **BaZi / Four Pillars (八字 / 四柱)**. The year animal is a
secondary value derived from the Year pillar; it is not the calculation system
by itself. V1 is explicitly a KnowMe compatibility contract. It does not claim
to be the universal standard of every BaZi school.

The deterministic source of calculation is the Python code under
`backend/app/services/bazi/`, backed by the pinned dependency
`lunar_python==1.4.8`. No AI text is used to calculate a chart. The report
projects only calculated facts, input/rule metadata, plain-language term
explanations and limitations. The prior personality, strengths, work-style,
relationship and predictive copy is not used by this report because the
repository does not contain approved sources for those claims.

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
or Useful God (`用神`). The report does not turn the largest count into a
personality or prediction.

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
  canonical fact-only report and PDF export.
- Owner fixture route: `/beta/chinese?case=known`, `unknown`,
  `lichun-unknown`, or `jie-unknown`. It is visibly marked as a fixture, calls no
  API and performs no user-data write.
- Owner PDFs: `output/pdf/knowme-bazi-fusion-linux-20260913/` contains `known`,
  `unknown`, `lichun-unknown` and `jie-unknown`. Each is reproducible from the
  same canonical report object and ignored by Git. Chinese glyphs use the
  checked-in static `NotoSansSC-Regular` font; the Thin variable font is not
  used.

There is no separately published public Chinese shared-report URL in V1. Any
surface implemented here uses the same report model; wider Fusion/narrative
interpretation remains outside this fact-only report and is not claimed as
source-approved Chinese interpretation.

## Owner manual QA boundary

Owner fixture testing is deliberately limited to:

1. Known completeness;
2. ordinary Unknown omission of Hour and all time-dependent values;
3. Li Chun Unknown omission of boundary-ambiguous values;
4. Jie Unknown omission of boundary-ambiguous values; and
5. Web/PDF parity for facts, omissions, policy label and final limitations.

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
fixture variants. Authoritative Flutter 3.41.1 Linux results are backend 18/18,
focused Flutter 51/51, full Flutter 3,049/3,049, analyzer exit 0 with 282 existing
non-fatal diagnostics and scoped analyzer 0.

## Known limitations and separate blockers

- `lunar_python@1.4.8` is a pinned implementation dependency, not evidence that
  V1 represents all schools.
- No true-solar correction, arbitrary school selection, hidden-stem strength,
  Ten Gods, combinations/clashes, luck pillars or event prediction is present.
- Actual localhost/loopback endpoint findings are 0. The bundle has one literal
  `localhost` in a hostname comparison, which is not an endpoint. Distinguishing
  the two is a future shared guard-quality task; policy still requires it to
  close before Production. This PR does not change shared or Production code.
- Full-suite pixel results are toolchain-sensitive. Final results and the exact
  Flutter version are recorded in the validation document; Thai goldens are not
  changed.

## Release sequencing (not authorized by this PR)

The prior client-first then immediate backend-enforcement proposal is withdrawn:
it does not safely cover cached or already-open legacy clients that omit the
bearer token. Release remains blocked on a compatibility migration that is not
implemented in PR #122:

1. add an authenticated versioned endpoint in parallel with the legacy
   endpoint;
2. move the new bearer-capable client to that versioned endpoint;
3. observe and verify client adoption; and
4. retire the legacy endpoint only after the adoption gate passes.

This is a recommended future release design, not authorization or completed
work. Draft PR #122 performs no backend, Hosting or Production deployment. The
validated application is commit
`8fe3c68e2c60ec9a1511e75bc22982a1d854c007`, tree
`a478defae8cd8f88435e8f5fda7c908db4a11773`.

## Scope protection

PR #122 remains stacked on Open + Draft PR #120 at
`4ce29747fee66d08637dbe0b16b982b17071526d`. This work does not modify Thai
astrology source, Thai goldens, `product-acceptance/`, Firebase Hosting,
Production data, Production services, merge state or readiness state.
