# Monthly Authority Audit

**Result:** `FAIL — AUTHORITATIVE MONTH-LEVEL RULES REQUIRED`

**Baseline:** `46d7883bca87570950eb84a7ca3dffbb3e6653b3`

**Audit date:** 2026-08-19

**Application edits before/after audit:** 0 / 0

## Mandatory gate checks

| Requirement | Evidence found | Result |
|---|---|---|
| Calendar-year framing from Bangkok civil `asOf` | Existing stable clock and `analysis.asOf` | PASS as framing only |
| 12 month-applicable rule records | No month model or month applicability in engine/Canon | FAIL |
| Start/end dates per month signal | Transit has one same-day window; other engines use age/year windows | FAIL |
| Per-domain monthly scores from authoritative rules | No monthly aggregation/scoring rule | FAIL |
| Opportunity/caution thresholds and ranking | No monthly threshold or stable rule-order contract | FAIL |
| Claim ids and trace ids per highlighted month | Existing ids are horizon/domain or daily evidence, not month claims | FAIL |
| Known/Unknown eligibility | Existing fail-closed boundaries exist, but no monthly eligibility contract | FAIL |
| Stable numeric/cross-runtime contract | Existing S008 boundary applies to existing outputs only | FAIL for monthly output |
| Complete Jan–Dec identity | No monthly typed record/identity | FAIL |

Any failed row blocks implementation. No partial rule was promoted into a
monthly score.

## Fresh repository inventory

- Canon production corpus: 854 atomic units.
- Unit fields: `condition`, `confidence`, `context`, `domain`, `evidence`, `id`,
  `object`, `objectKind`, `relation`, `strength`, `subject`, `subjectKind`
  (plus comments).
- Contexts: 299 `life_period`, 43 `archetype_chart`, 142 `other`, 8
  `taksa_chart`.
- Calendar-month fields: 0.
- Annual/year contexts: 0.
- Thai month-name values in production Canon units: 0.
- Month-name search hits in Thai engine code are limited to lunar golden-case
  fixture/source notes; they are not forecast rules.

## Rule disposition

| Rule candidate | Authority/use class | Known/Unknown | Claim/trace state | Disposition |
|---|---|---|---|---|
| Bangkok civil year/month | Authoritative temporal framing | Both | No astrology outcome ids | Use only to define target year/current month |
| V9 life-period intelligence | Authoritative age-period evidence | Both; Lagna additions Known only | Period/domain evidence | Cannot assign calendar months |
| V10 `next12Months` | Rolling annual evidence only | Both with fail-closed omissions | Horizon/domain material ids | Cannot split into Jan–Dec |
| Annual Taksa rotation | Authoritative annual evidence | Base path Both | Internal `taksaRole.*` trace | No monthly applicability |
| V15 weekday transit | Authoritative current-day evidence | Both | Daily evidence source ids | No authorized monthly aggregation |
| Canon life-period context | Source-backed, partial mapping | Internal only | Canon evidence refs | Example age ranges; no month scope |
| Period rise/fall status | Partial/internal with documented gaps | Not public | Internal status trace | Cannot drive month claims |
| Lunar month fixture notes | Validation data, not interpretive rule | N/A | Test source note | Excluded |
| Existing annual infographic copy | Owner-approved reader projection | Both | Rolling window trace ids | Copy cannot become evidence |

## Prohibited substitutions explicitly rejected

- copying the annual/rolling score to all 12 months;
- sampling the daily transit once per month without an authorized sampling rule;
- summing daily transit evidence without authorized weights/thresholds;
- deriving month bands from copy, hash, random, profile seed or ordering side
  effects;
- inventing Canon ids or claim/trace ids;
- using Known-time house/Lagna evidence for Unknown-time profiles;
- labelling a rolling current-month + 11-month horizon as a calendar year.

## Gate decision

`monthlyTimelineAvailable` must remain `false`. Phase B and all implementation,
artifact, parity and final regression work are not reached. The next action is
Owner/Canon authorization of a complete month-level rule set, followed by a new
implementation candidate and fresh gates.
