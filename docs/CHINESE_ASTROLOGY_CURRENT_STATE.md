# Chinese Astrology V1 — Current State and Owner Decision Gate

**Status:** CURRENT — stacked Draft PR #122; audit complete; implementation
blocked on one Owner calculation-policy decision

**Date:** 2026-09-12

**Branch:** `codex/chinese-astrology-report-v1`

**Stack dependency:** Draft PR #120 at
`4ce29747fee66d08637dbe0b16b982b17071526d`

**Runtime delta:** none

## Decision summary

KnowMe currently implements **BaZi / Four Pillars (八字 / 四柱)**. The Chinese
year animal is a secondary lens, not the calculation system itself. The code is
deterministic and does not use AI text as a substitute for calculation, but the
repository has never approved the calculation school as a product contract.

That ambiguity can change pillars at real boundaries. The Discovery gate is
therefore closed: Draft PR #122 records the audit and does not implement a
report, route, PDF, API change, cache change, Thai change, or Production change.

The recommended compatibility policy is:

- Gregorian local civil date and time in the recorded IANA timezone;
- Li Chun (`立春`) changes the Year pillar;
- Jie (`节`) solar terms change the Month pillar;
- `sect=2` changes the Day pillar at local civil 00:00;
- no true-solar correction; coordinates are disclosed as unused;
- Known time may expose four pillars; Unknown time omits the Hour pillar and
  every hour-dependent field, and suppresses any Year/Month result that is not
  invariant across a solar-term transition day.

This preserves current Known-time charts while naming their limits. The
alternative is to keep implementation paused until an astrologer-reviewed canon
defines location correction, day boundary, solar-term policy and interpretation
sources.

## System and source of truth

| Concern | Source actually used |
|---|---|
| BaZi calculation | `backend/app/services/bazi/` |
| Calendar engine | pinned Python package `lunar_python==1.4.8` |
| API endpoint | `backend/app/api/routes/bazi.py` |
| Flutter model/API/state | `lib/models/bazi_chart_model.dart`, `lib/services/bazi_api_service.dart`, `lib/providers/bazi_provider.dart` |
| Signed-in result UI | `lib/features/bazi/presentation/bazi_result_page.dart` |
| Deterministic interpretation | `BaziThemeEngine`, `BaziSummaryEngine`, and `lib/features/astrology/chinese_zodiac/` |
| Persistence | `users/{uid}/astrology/chinese_bazi`, mirrored to `users/{uid}/results/chinese_bazi` |
| Shared normalization contract | `docs/BIRTH_NORMALIZATION.md` and its Dart adapter |

`lib/astrology/services/chinese_zodiac_calculator.dart` is a dormant year-animal
calculator and is not the BaZi source of truth. Shared Birth Normalization still
marks the real BaZi adapter and true-solar normalization as unimplemented, which
is the central contract conflict behind this gate.

## Inputs, calculation, and outputs

### Inputs

The current API accepts Gregorian `birth_date`, required local `birth_time`, an
IANA `timezone`, `latitude`, `longitude`, and a body-supplied `uid`.

- The timezone identifier is validated. Its UTC offset is not applied: the same
  wall-clock fields are passed unchanged to the calendar engine.
- Latitude and longitude are stored but not used in calculation and are omitted
  from the input hash.
- Birth time is mandatory. Empty time raises `MissingBirthTime`; the current
  system has no three-pillar mode.

### Rules implemented today

The builder calls `Solar.fromYmdHms` with local civil fields and reads
`EightChar` from `lunar_python@1.4.8`.

| Boundary or rule | Current behavior | Approval state |
|---|---|---|
| Year | exact Li Chun boundary | implemented, not Owner-approved as canon |
| Month | exact Jie solar-term boundary | implemented, not Owner-approved as canon |
| Day | `EightChar.setSect(2)`; civil 00:00 change | implemented, not Owner-approved as canon |
| Hour | two-hour branch from supplied civil time | implemented for Known time only |
| Timezone | validates IANA name; calculation uses unchanged wall time | limitation not yet approved |
| Location | coordinates accepted/stored, calculation unchanged | limitation not yet approved |
| True solar time | `none` in metadata | not implemented |

### Outputs

The engine returns Year, Month, Day and Hour pillars; Day Master; year animal;
engine/version metadata; generated timestamp; input hash; and a five-element
count over the eight visible stem/branch slots. The UI currently calls the
largest count “Dominant Element.” The accurate V1 label would be **surface
element count**: it excludes hidden stems, rooting, seasonal weighting, Day
Master strength and Useful God (`用神`). Count ties resolve in the fixed order
Wood → Fire → Earth → Metal → Water.

Generated timestamps vary by run, but chart facts are deterministic for the same
accepted civil input, engine version and rule settings. Calculation and report
metadata must expose those inputs and rule identifiers so a result can be traced
and reproduced.

## Known and Unknown time contract

### Known time

Current code genuinely supports a supplied local civil time and uses it for the
Hour pillar. It does not support a claim that timezone offsets, longitude or true
solar time affect the result. Any V1 must say that plainly.

### Unknown time — required fail-closed behavior

Current code blocks generation entirely. A safe V1 may add a three-pillar
projection only after the calculation policy is approved. It must:

1. never insert noon, midnight, a guessed time, or a placeholder Hour pillar;
2. omit the Hour pillar, hour-derived element slots and all hour-dependent copy;
3. evaluate the full possible local-day interval at Li Chun/Jie transition dates
   and expose a Year or Month pillar only when invariant; otherwise suppress it
   or mark it unavailable;
4. keep the same projection rules across Web, shared view, storage and export.

## Surface parity and current gaps

| Surface | Current state |
|---|---|
| Web | signed-in `BaziResultPage`; no stable `/beta/chinese` owner route |
| Shared report | no Chinese shared-report projection |
| PDF/export | no Chinese PDF, export document or capture route |
| Unknown time | generation blocked; no safe projection |
| Interpretation evidence | deterministic copy exists but has no source/citation records |
| API authorization | client sends no Firebase ID token; backend trusts body `uid` and writes via Admin SDK |
| Freshness | an already-ready chart is not regenerated when birth data changes |

The authentication and stale-chart findings are release blockers for any wider
Chinese route. Existing personality, work and relationship prose must not be
presented as a calculated fact until its interpretation sources and wording are
reviewed.

## Tested evidence on this branch

The audit uses equivalence classes and targeted probes; it does **not** claim
coverage of every date, time, timezone or location.

- Backend: the eight existing builder assertions passed against
  `lunar_python==1.4.8`. Because this Windows Python installation lacks IANA
  `tzdata`, the fresh reproduction used a UTC `ZoneInfo` stub after separately
  inspecting the timezone-validation code. This verifies the pinned calendar
  outputs but is not evidence that Windows timezone lookup works.
- Focused Flutter: **83/83 passed** across 14 BaZi, Chinese Zodiac,
  coordinator, provider, page, mirror and fusion files.
- Analyzer: exit 0 under repository policy, with **297 existing warning/info
  diagnostics** and no analyzer error.
- Full Flutter invocation: **2,989 passed / 40 failed**. All failures are pixel
  comparisons in existing Thai screenshot-golden tests. They reproduce when the
  four golden-bearing files are isolated on Flutter 3.41.3; PR #120's recorded
  3,029/3,029 baseline used Flutter 3.41.1. The goldens were not updated because
  this branch has no Thai/UI delta.
- Fresh read-only Production bundle guard: the Thai route returns 200 and the
  index carries cache pin `e6aaa98`, but the pinned 8,565,520-byte
  `main.dart.js` contains one literal `localhost`. Its surrounding minified code
  compares `window.location.hostname` with that value; URL extraction finds no
  localhost/loopback URL, and the other loopback strings are absent. The strict
  no-`localhost` string gate therefore fails even though no development endpoint
  was found. This is an existing Production/shared-bundle issue, not a Chinese
  branch delta, and it was not changed or deployed under this task.
- Existing backend probes record `1990-05-12` 22:59 as Day `丁丑` / Hour `辛亥`,
  23:00 and 23:59 as Day `丁丑` / Hour `壬子`, and `1990-05-13` 00:00 as Day
  `戊寅` / Hour `壬子`.

Still missing before implementation acceptance: exact Li Chun instants across
zones, exact Jie/month transitions, leap-year representatives, timezone
normalization, coordinate/solar-time semantics, interval-safe Unknown time,
authenticated UID binding, stale-input regeneration, and cross-surface
projection/PDF tests. There is no Chinese PDF or export to inspect visually in
this audit-only PR.

## Safe V1 after approval

The smallest acceptable scope is a non-predictive facts-and-context report:

- publish a versioned calculation contract and its source/version metadata;
- bind API identity to an authenticated user and reject mismatched body UIDs;
- regenerate when the normalized birth-input hash changes;
- implement Known and interval-safe Unknown projections;
- label the visible eight-slot result as surface element count;
- use sourced, plain-language explanations and no AI-generated calculation;
- project one canonical report to Web, shared view and PDF/export;
- place health/financial limitations at the end;
- add boundary, completeness, leakage, deterministic and cross-surface tests.

Out of V1: Ten Gods, hidden-stem or seasonal strength, Useful God, combinations
and clashes, Da Yun/luck pillars, annual timing, compatibility and event
prediction.

## Owner review artifact

Draft PR #122 and this document are the Owner artifact. There is intentionally no
Chinese test route or PDF yet: creating either would require selecting the
unapproved rules this gate is designed to protect. Owner testing for this
checkpoint is to review the actual/current behavior, the gaps, and the single
policy choice in the Decision summary.

## Scope protection

This branch changes documentation and the narrow task-scope manifest only. The
strict Production-bundle string guard remains a separately classified blocker.
This branch
does not change Dart/Python runtime, calculations, Chinese or Thai reader copy,
routes, tests, golden files, Firebase, Production data, deployed assets, PR #120
readiness, merge state, or Hosting release `04c592`.
