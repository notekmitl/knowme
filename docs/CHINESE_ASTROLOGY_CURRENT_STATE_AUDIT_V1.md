# Chinese Astrology Current-State Audit V1

**Status:** HISTORICAL AUDIT SNAPSHOT — superseded by
`docs/CHINESE_ASTROLOGY_CURRENT_STATE.md`; implementation remains blocked on one
Owner calculation-policy decision
**Date:** 2026-09-12
**Working branch:** `codex/chinese-astrology-report-v1`
**Stack base:** PR #120 head
`4ce29747fee66d08637dbe0b16b982b17071526d`
**Runtime changes in this audit:** none

> Post-audit verification note: a later strict scan found one literal
> `localhost` hostname comparison in the existing pinned Production bundle, but
> no development URL. See `docs/CHINESE_ASTROLOGY_CURRENT_STATE.md` for the
> current classification; this snapshot otherwise remains unchanged.

## Executive finding

KnowMe's existing “Chinese astrology” is **BaZi / Four Pillars
(八字 / 四柱)**. It is not merely a Chinese-year-zodiac calculator. The year
animal is an additive secondary interpretation inside the BaZi result and fusion
layers.

The repository already calculates four pillars, Day Master, year animal and a
simple five-element surface count. It also has a signed-in Flutter result page,
Firestore persistence, deterministic Thai/English interpretation copy and fusion
adapters. It does **not** yet have a governed Chinese Report contract, a public
Chinese beta route, Chinese PDF/export, unknown-time output, interpretation
provenance, authenticated API writes, or reliable regeneration after birth data
changes.

Implementation must stop at this audit because the repository contains two
incompatible levels of birth-time policy:

- the repository backend directly calculates from local civil clock fields with
  `lunar_python@1.4.8`, `sect=2`, Li Chun/Jie boundaries and no solar-time
  correction; but
- the shared Birth Normalization contract explicitly marks BaZi as a placeholder
  and says true-solar-time and solar-term normalization are not implemented.

The day boundary implied by `sect=2`, the use of timezone, and the treatment of
coordinates/true solar time are not documented as an Owner-approved product
contract. This is the exact hard-stop condition for Chinese Astrology Report V1.

## 1. Baseline and repository state

| Check | Verified evidence | Result |
|---|---|---|
| Thai Production route | `https://knowme-app-694e1.web.app/beta/thai` returned HTTP 200 | Matches the supplied baseline |
| Live cache pin | Live `index.html` and bootstrap reference `flutter_bootstrap.js?v=e6aaa98` and `main.dart.js?v=e6aaa98` | Matches `e6aaa98` |
| Live payload hashes | `index.html` `7585e92b...`, bootstrap `4af0e8f2...`, main JS `389fe890...` | Match the release record in PR #120 docs |
| Hosting release | PR #120 head records Firebase Hosting release `04c592` | Matches the supplied baseline; no deploy was performed |
| Production application source | `e6aaa987ebf02da4ac3c05909c385f8378514b35` is an ancestor of PR #120 head | Matches; the six later changed files are documentation only |
| PR #120 | GitHub reports Open + Draft, unmerged, head `4ce29747fee66d08637dbe0b16b982b17071526d` | Matches the supplied baseline |
| Existing Chinese work | GitHub PR and remote-branch searches found no active BaZi/Chinese/Zodiac branch or PR | No duplicate active work found |
| Working base | Local branch created exactly from PR #120 head | Suitable stacked base; no Thai source delta introduced |

The exact diff from Production source `e6aaa98` to the stack base `4ce2974` is
limited to `task.md`, `TASK_RESULT.md`, `docs/CURRENT_STATUS.md`,
`docs/HANDOFF.md`, `docs/ROADMAP.md`, and
`docs/THAI_REPORT_READER_EXPERIENCE_V2.md`. Application code and the tested Thai
report runtime are identical across that range.

## 2. What exists today

### Calculation engine

The backend under `backend/app/services/bazi/` is the primary engine. The dormant
`lib/astrology/services/chinese_zodiac_calculator.dart` is not the production
BaZi source of truth.

| Area | Actual behavior |
|---|---|
| Input calendar | Gregorian birth date plus local civil birth time |
| Engine | `lunar_python@1.4.8` via `Solar.fromYmdHms` |
| Year pillar | Exact Li Chun (`立春`) boundary |
| Month pillar | Exact Jie (`节`) solar-term boundary |
| Day boundary | `EightChar.setSect(2)`; runtime probes show the civil date changes at 00:00, while 23:00–23:59 remains on the same day pillar |
| Timezone | IANA identifier is validated, then only the unchanged local wall-clock fields are passed to the engine; UTC offset is not used in the chart calculation |
| Coordinates | Accepted and stored but not used by the calculator |
| True solar time | Explicitly `none` in engine metadata |
| Birth time | Required; there is no three-pillar/unknown-time mode |

The output contains Year/Month/Day/Hour pillars, Day Master, year animal, engine
metadata, and element counts. “Dominant Element” is the highest count among the
eight visible stem/branch element slots. Backend comments correctly state that
this is an approximation only: it does not include hidden stems, rooting,
seasonal weighting, Day Master strength, or Useful God (`用神`) analysis. Ties
use the fixed order Wood → Fire → Earth → Metal → Water.

### Interpretation and fusion

- `BaziThemeEngine` and `BaziSummaryEngine` generate deterministic Thai/English
  copy from Day Master and the surface element count.
- `lib/features/astrology/chinese_zodiac/` adds a deterministic 12-animal
  personality library and resolver.
- Fusion weights BaZi core signals above the year-animal signal. The year animal
  is therefore a secondary lens, not the definition of the system.
- No LLM, network prompt, or generative-AI prediction is used in these paths.
- The interpretation catalogs have no source/citation/provenance record. Their
  personality, work and relationship claims therefore cannot be promoted into a
  source-verifiable V1 report as-is.

### Product path

| Surface | Current state |
|---|---|
| Web/UI | `BaziResultPage` is a signed-in, internal navigation destination from Home; there is no direct `/beta/chinese` route |
| Report | Day Master hero, surface-element emphasis, core/strength/growth copy, year-animal personality, summary, Four Pillars and technical metadata |
| Unknown time | Global birth readiness and the API both require birth time; no distinct safe result exists |
| PDF/export | No Chinese report PDF, print/export document, or capture route was found |
| Primary storage | `users/{uid}/astrology/chinese_bazi` |
| Secondary mirror | `users/{uid}/results/chinese_bazi` |
| Fusion | BaZi and year-animal signals can feed the astrology mirror/fusion runtime |
| Browser cache | No separate Chinese offline cache; the deployed web shell uses the global pinned/no-cache release assets |

## 3. Blocking and material gaps

### P0 — calculation contract is not approved

The backend has implementation choices, but the product documentation does not
establish them as the canonical Chinese policy. In particular:

1. `sect=2` means a 00:00 day change in the pinned library, but this meaning is
   neither named nor explained in the UI/docs.
2. Timezone validation currently does not affect calculation beyond accepting a
   valid zone name; two zones with identical wall-clock fields produce the same
   pillars even though the stored `input_hash` differs.
3. Latitude and longitude do not affect the chart and are omitted from
   `input_hash`.
4. Shared Birth Normalization says the real BaZi adapter—including true solar
   time—is future work and always reports `implemented == false`.

Changing any of these choices can change pillars near boundaries. V1 cannot
silently select a school or pretend the current implementation is an approved
canon.

### P0 — Known time and Unknown time are not separate contracts

Unknown time currently blocks all astrology generation rather than producing a
safe Chinese result. A V1 unknown-time report must never invent an hour pillar.
It must also avoid silently choosing noon: Li Chun and Jie transitions occur at
an exact time, so Year/Month pillars can be ambiguous for an unknown-time birth
on a transition date. Any V1 must expose only values invariant across the
possible time interval or mark/suppress the ambiguous value.

### P0 — API write authorization

The Flutter client sends JSON without a Firebase ID token. The backend accepts a
body `uid`, performs no token verification and then writes with Admin SDK
privileges. This endpoint must not be exposed through a wider Chinese beta route
until the caller identity is authenticated and bound to the requested UID.

### P0 — stale chart after profile edits

Profile editing calls `ensureGenerated` after birth data changes, but the
coordinator generates only a missing/not-ready lens. An existing BaZi document
therefore remains “ready” and is not rebuilt for the changed birth input. The
canonical profile save path does not invalidate the chart. Input-hash comparison
or explicit regeneration is required before V1 owner testing.

### P1 — evidence, labels, routes and parity

- Existing interpretive claims lack citable source records. Until reviewed
  sources exist, a V1 should show computed facts and narrowly worded explanatory
  text, not personality prediction presented as calculation output.
- “Dominant Element” overstates the current eight-slot surface count. The UI
  should identify the method and its exclusions.
- There is no stable owner-test route or Chinese PDF/export parity.
- The live API could not be read through its OpenAPI endpoint during this audit;
  runtime conclusions above are based on the exact deployed source lineage and
  repository implementation, not a Production mutation or API write.

## 4. Test evidence and missing coverage

Executed on the audit branch:

- `PYTHONPATH=backend pytest -q backend/tests/test_bazi_builder.py` — **8/8
  passed** with the pinned `lunar_python==1.4.8`.
- Runtime boundary probes with the pinned library:
  - `1990-05-12 22:59` → day `丁丑`, hour `辛亥`
  - `1990-05-12 23:00` and `23:59` → day `丁丑`, hour `壬子`
  - `1990-05-13 00:00` → day `戊寅`, hour `壬子`
- The repository contains **83 direct test/testWidget declarations across 14
  BaZi/Chinese/coordinator test files**. Flutter is unavailable in the audit
  environment, so these were inspected but not re-executed.
- PR #120's checked-in release record reports the current source baseline's full
  Flutter gate as **3,029/3,029 passed**. GitHub exposes no check run for either
  the Production source SHA or current PR head, so this remains recorded release
  evidence rather than a newly reproduced result.

Current backend tests cover a standard chart, Day Master, before/after Li Chun by
date, year animal, surface count, metadata and required birth time. They do not
cover the exact Li Chun instant, Jie transition instants, 23:00/00:00 policy,
timezone semantics, coordinate/solar-time semantics, unknown-time suppression,
API authentication, or stale-cache regeneration.

## 5. Safe V1 boundary after the Owner decision

The smallest maintainable report is a **non-predictive BaZi facts-and-context
report**, not a luck forecast:

- publish one explicit calculation contract and return it in report metadata;
- Known time: show only governed Four Pillars facts and carefully sourced or
  plainly methodological explanations;
- Unknown time: no hour pillar or hour-derived text, and suppress/mark any
  Year/Month result that is not invariant across its possible day;
- rename the current element result to “surface element count” and disclose that
  it is not strength/Useful-God analysis;
- add authenticated UID-bound generation plus input-hash freshness;
- add a stable owner-test web route and equivalent export/PDF behavior only after
  the same projection contract passes leakage tests;
- retain deterministic output and add no AI-authored predictions.

Out of V1: Ten Gods, hidden-stem/seasonal strength, Useful God, combinations and
clashes, Da Yun/luck pillars, annual timing, compatibility and event prediction.

## 6. Required Owner decision

The recommended compatibility policy is: Gregorian civil input; use the recorded
IANA zone as the local wall-clock context; Li Chun for Year; Jie for Month;
`sect=2`/00:00 for Day; no true-solar correction; coordinates disclosed as unused;
and an interval-safe unknown-time projection with all hour-dependent or
transition-ambiguous fields omitted. This preserves current Known-time outputs
while making their limitations explicit.

The alternative is to pause implementation until an astrologer-reviewed canon
defines true-solar correction, location/timezone transformation, day boundary and
approved interpretation sources. That path is more authoritative but can change
existing charts and is not a small compatibility V1.

## Scope protection

This audit changes documentation only. It does not modify `product-acceptance/`,
Production data, Firebase services, any deployed asset, the Thai astrology
runtime, PR #120 readiness, merge state, or deployment state.
