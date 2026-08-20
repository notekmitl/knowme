# Rule Inventory

This inventory records every plausible repository rule inspected for the V1
Authority Gate. It does not authorize new astrology behavior.

| Candidate | Source | Rule/Canon identity | Input → calculation → output | Domain | Boundary | Precision/parity risk | Classification |
|---|---|---|---|---|---|---|---|
| Target year | Thai Beta analysis clock | runtime civil-time contract | Bangkok `asOf` → year/month → target/display year | framing | Known + Unknown | integers; low | authoritative and usable, not a score |
| Life periods | `core/life_period/life_period_engine.dart` | frozen life-period engine | birth date + `asOf` → whole-year age → inclusive period | life timeline | Both | integers; low | authoritative, not month level |
| V9 intelligence | `core/life_period/life_timeline_intelligence.dart` | V9 evidence | period+natal anchors → bonds/stage → structured evidence | life domains | Both; Lagna Known only | integer/ranked values; existing stable | authoritative, not month level |
| Rolling prediction | `core/prediction/prediction_window.dart` | `PredictionWindowKind.next12Months` | current whole-year age → `now..now+1` → one window | prediction domains | Both | integers; existing stable | annual/rolling only |
| Annual Taksa | `core/life_period/annual_taksa_engine.dart` | `taksaRole.*` | birth-day ruler+age → ring/house rotation → annual roles | annual structure | Base path Both | integer ordering; low | annual only |
| Daily transit | `core/transit/transit_intelligence_engine.dart` | `transitDayVsNatal`, `transitDayVsPeriod` | exact day → weekday ruler relationships → same-day impact | leading life domain | Both | integer score/magnitude; low | daily only; aggregation unauthorized |
| Life-period Canon | `knowledge/canon/production/foundation_v1.knowme.json` | 299 `life_period` contexts | source example context → atomic unit | internal evidence | partial exact mapping | string/id matching | no month applicability |
| Taksa Canon | same corpus/integration | 8 `taksa_chart` contexts, `taksaRole.*` | source rotation → internal role assignment | internal evidence | partial source coverage | integer/stable ids | annual/structural only |
| Period status | Canon integration/status docs | `periodStatus.*` | exact context markers/runtime metadata → internal status | period evidence | incomplete and internal | exact strings | not a monthly rule |
| Lunar cases | `foundation/lunar/validation/thai_golden_cases.dart` | fixture/source references | lunar month input → calculation validation | calendar calculation | fixture-specific | integer/table | no forecast meaning |
| Annual infographic traces | `thai_beta_report_export_document.dart` | serialized prediction material/evidence keys | rolling window domain → accepted summary | reader projection | Known/Unknown fail closed | existing S008 boundary | cannot become month claims |

No inspected candidate satisfies all required fields for even one authoritative
monthly record, and no candidate set satisfies 12/12 completeness.

The V15 daily-source follow-up further classifies `transitDayVsNatal` and
`transitDayVsPeriod` as deterministic signed source codes but not complete
monthly-source rules: they lack claim/trace IDs, typed applicability and full
career/finance/relationship/health mapping.

KnowMe Monthly Derived Evidence V1 was not Owner-approved and is not operative
or approved Canon. There is no implementation;
`monthlyTimelineAvailable=false`; Production is unchanged; PR #102 closes
unmerged.

Governance: `DEFERRED — NO AUTHORITATIVE MONTH-LEVEL SOURCE`; no implementation
or generated monthly records/artifacts. A future new work item requires an
authoritative source with complete month-level provenance.
