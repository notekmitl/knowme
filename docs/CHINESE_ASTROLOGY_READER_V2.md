## Production release evidence (2026-09-16)

BaZi Reader V2 is live on `knowme-app-694e1` from application commit `fc7e56c8647fdcbddc08885bf853b74a287c4056` and tree `07235acdbdd7bb71986302c816d879cbf62e3144`. The original V2 merge remains `0c8eec05f6741068ef9bd87a5a651f75941eb86d`; PR #126 corrected the Production no-write known fixture so that browser and PDF QA exercise the V2 contract rather than the legacy V1 fixture.

Production evidence:

- Cloud Run revision `knowme-astrology-api-00005-r87`, image `sha256:a1495d512376e81f424c47e0256645d455cd0db72628c51840eb16d37c93f25a`, Ready and 100% traffic.
- Firebase Hosting release `1789557959784000`, version `02ad04dcd6116530`, cache pin `fc7e56c`.
- Browser semantics on both Hosting domains confirmed the exact reader-first order required by this specification and contracts `knowme_bazi_reader_v2` / `knowme_bazi_reader_th_v2`. The rendered report does not use the V1 count-first slot/group copy.
- The Production-generated PDF is 4 pages. Visual inspection confirmed complete sections, readable Thai and Chinese glyphs, wrapping contained inside report cards, and no clipping or overlap. SHA-256: `1e247ec57753a61ccc8facdb01e81b549f8587e4553557f595849b58443d5ca1`.
- API checks passed with health 200 and unauthenticated generation requests rejected with 401. No Production data was written during the fixture QA.

# KnowMe BaZi Reader V2

**Calculation contract:** `knowme_bazi_reader_v2`

**Thai reading contract:** `knowme_bazi_reader_th_v2`

**Status:** Production live from application commit `fc7e56c8647fdcbddc08885bf853b74a287c4056`; release evidence is recorded
in `CURRENT_STATUS.md` and `HANDOFF.md` when the branch is closed.

## Purpose

Reader V2 replaces the V1 surface-count-first report with a reader-first Thai
horoscope. The calculation remains deterministic, but the first pages now
answer the questions a person expects from a BaZi reading before showing the
technical audit trail.

The visible order is:

1. the four-pillar chart and Day Master;
2. a direct overall reading;
3. identity and constructive use of the Day Master;
4. work;
5. money;
6. love and relationships;
7. cautions and balance;
8. the active ten-year luck cycle;
9. the current annual influence; and
10. calculated facts, input, rules, sources and limitations.

The primary prose does not describe a person as a count of “slots.” Counts and
method identifiers remain available only in the audit sections.

## Calculation policy

Reader V2 preserves the released local-civil calculation policy:

| Concern | Rule |
|---|---|
| Calendar input | Gregorian local civil date and optional time |
| Timezone | supplied IANA zone validates the local-civil context |
| Year boundary | Li Chun (`立春`) |
| Month boundary | Jie (`節`) |
| Day boundary | local civil 00:00, `sect=2` |
| True-solar correction | none |
| Coordinates | recorded as context, not used to change pillars |
| Unknown time | omit Hour and every time-dependent output |

The client now sends normalized gender because the traditional Da Yun direction
depends on gender together with the birth-year stem. Gender is part of the
Reader V2 input fingerprint. If gender or time is unavailable, Reader V2 does
not invent a ten-year direction or annual sequence.

## New governed fact layers

The backend derives these facts from the same pinned
`lunar_python==1.4.8` EightChar instance:

- hidden stems and their polarity-specific Ten Gods for every available
  pillar;
- visible and hidden Ten-God family weights, with disclosed weighting of two
  points for a visible stem and one for a hidden stem;
- a disclosed Day Master support heuristic using month primary qi, grounding
  and visible support;
- stem combinations/clashes and branch combinations, clashes, harms,
  punishments and three-harmony groups;
- Da Yun onset, direction and ten-year cycles when gender and time are known;
  and
- annual pillars and their main relationships with the natal chart.

When one branch pair appears in both traditional combination and break tables,
Reader V2 gives the direct combination precedence. It does not show two
contradictory labels for one pair.

Reader V2 does not declare a Useful God (`用神`), diagnose health, recommend an
investment, or guarantee a career, money or relationship event. Its strength
band is a named, reviewable heuristic rather than a claim that all BaZi schools
must reach the same conclusion.

## Synthetic regression case

The checked-in regression reuses the repository's synthetic 1990 Bangkok case
with male luck-cycle direction. Real user birth data is not added to source
control:

| Layer | Expected result |
|---|---|
| Four pillars | `庚午 · 辛巳 · 丁丑 · 戊申` |
| Day Master | `丁 Ding`, Yin Fire |
| Hidden stems | `丁己 · 丙庚戊 · 己癸辛 · 庚壬戊` |
| Leading family | Wealth |
| Support band | `balanced`, score `4/9` under `three_gains_primary_qi_v2` |
| Natal headline relations | `午–丑` harm, `巳–申` combine |
| Active cycle in 2026 | `甲申`, 2018–2027 |
| Annual influence in 2026 | `丙午` |

The real profile that prompted Reader V2 is checked locally against the same
engine policy, but its date, clock time and place are deliberately absent from
this change set.

## Projection and regression rules

- Backend chart storage and the results mirror carry the same V2 facts.
- Signed-in Web, plain text and dedicated PDF read the same
  `BaziCompatibilityReport` object.
- V1 charts retain the legacy renderer; a new V2 chart selects Reader V2 by
  `contract_id`.
- Birth date, normalized time, normalized gender, timezone and V2 contract id
  form the cross-language SHA-256 input fingerprint. Coordinates remain outside
  the hash because they do not alter this calculation policy.
- Unknown time remains fail-closed and does not expose luck cycles.

Backend tests pin boundaries, authentication, mirror projection and the golden
owner case. Flutter tests pin the natural Thai section order, exact pillars,
current cycle/year, hidden-stem evidence, final cautions and the absence of the
old “slot count” wording from the V2 report.
