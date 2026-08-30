# Thai Report Predictive Signal Convergence Map V1

สถานะ: **OR2 DESIGN EVALUATED — OWNER APPROVAL REQUIRED**

## Independent groups

| Group | Fields / source paths | Independent from | Not independent from |
|---|---|---|---|
| `G_BIRTH_BASIS` | normalized civil/astrological date, time availability, place/timezone from adapter | life-period ring, annual Taksa, natal/lagna relationship | formatted birth copy is not a signal |
| `G_PERIOD_TIMING` | `LifeTimeline.current`, `PeriodState.startAge/endAge/progress`, `PredictionEvidenceSource.timing/transition`, reason codes | natal structure, annual Taksa, domain affinity | timing reason and timing evidence are one group |
| `G_ANNUAL_TAKSA` | `AnnualTaksaYear.house`, `boriwanPlanet`, `roleByPlanet` from `annual_taksa_engine.dart` | life-period position, natal bond, forecast score | role label and its Canon reference are one group |
| `G_NATAL_STRUCTURE` | birth ruler bond, lagna-lord bond, `natalHarmonyScore`, whole-sign house/lord relationship | period stage, annual Taksa | harmony score and component natal/lagna bonds are one group |
| `G_DOMAIN_AFFINITY` | `PredictionEvidenceSource.categoryAffinity`, `LifePlanetData.affinity`, Canon domain relation | timing, Taksa, natal bond | opportunity/risk derived from the same planet affinity is not a second group |
| `G_DOMAIN_OUTCOME` | typed `PredictionOpportunity` or `PredictionRisk` used to choose opportunity/risk vocabulary | timing, Taksa, natal bond | category affinity and derived opportunity/risk cannot satisfy two-group minimum together |
| `G_CANON_CONTEXT` | Canon unit id, relation, domain, context, page provenance | none as calculation | provenance alone never counts as a calculation signal |
| `G_SCORE_ELIGIBILITY` | strength, confidence, weighted, band | no independent group credit | strength, weighted and band are the same calculation family |

## Convergence invariant

An event atom may fire only when:

```text
periodTimingPresent = true
independentCalculationGroups >= 2 excluding G_SCORE_ELIGIBILITY and G_CANON_CONTEXT
requiredDomainSignalPresent = true
all positiveConditions = true
all negativeConditions = false
all exclusionConditions = false
```

Every OR2 product event inference uses `G_PERIOD_TIMING + G_ANNUAL_TAKSA + G_NATAL_STRUCTURE` and then uses one domain group to resolve vocabulary The classical life-period boundary fact uses `G_BIRTH_BASIS + G_PERIOD_TIMING` Score fields are eligibility thresholds only Narrative strings, motif, advice, Candidate paragraphs and Canon provenance do not contribute to group count

## Deterministic field helpers

```text
prediction(category, horizon) = PredictionIntelligence.predictionFor(category, horizon)
affinity(prediction) = max magnitude where evidence.source == categoryAffinity
opportunity(prediction, domain) = max magnitude for opportunities matching domain; empty = 0
risk(prediction) = max risk magnitude; empty = 0
timingPresent(prediction) = evidence contains timing or transition
harmony = current PeriodIntelligence.natalHarmonyScore
annualAge(current) = clamp(currentAge, 1, 108)
annualAge(next12Months) = clamp(currentAge + 1, 1, 108)
annualRole(horizon) = roleByPlanet[currentPeriod.planet] at annualAge(horizon)
distinctGroups = set of calculation group IDs that passed
atomStrength = min(prediction.strength, selectedDomainMagnitude)
atomConfidence = min(prediction.confidence, 60 + 5 * distinctGroups.length)
```

`selectedDomainMagnitude` is affinity for role-change, opportunity magnitude for opportunity/income/clarity, and risk magnitude for ending/expense/health rules No formula adds band and weighted as extra evidence

## Role sets used by proposed product inferences

| Purpose | Allowed annual roles | Status |
|---|---|---|
| expansion / authority | เดช, อุตสาหะ, มนตรี | Owner product inference, not claimed classical |
| opportunity / income / clarity | ศรี, มนตรี, เดช; clarity also บริวาร and อุตสาหะ; income also มูละ | Owner product inference |
| contraction / obligation / load | เดช, อายุ with negative harmony and risk threshold | Owner product inference |
| past family signal | บริวาร or กาฬกิณี repeated in the age band | Owner product inference; count is internal only |
| past education/social boundary | เดช, อุตสาหะ or มนตรี at period boundary | Owner product inference |
| past domain ending boundary | กาฬกิณี, มูละ or อุตสาหะ with negative previous-period bond | Owner product inference |

These sets are proposals created for product behavior They are not represented as traditional Thai astrology rules and require Owner approval before tests or runtime
