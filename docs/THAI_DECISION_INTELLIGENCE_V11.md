# Thai Astrology V11 — Decision Intelligence Foundation

**Status:** CURRENT (implementation record · engine layer)
**Audience:** Developers, validation, AI agents.
**Last updated:** June 2026
**Builds on:** V10 Prediction Intelligence Foundation
([`THAI_PREDICTION_INTELLIGENCE_FOUNDATION_V10.md`](THAI_PREDICTION_INTELLIGENCE_FOUNDATION_V10.md),
[`DECISION_LOG.md`](DECISION_LOG.md) D-020/D-021)

---

## 1. Goal

V10 taught the Thai engine to *predict*: structured strength/confidence,
opportunities, risks and reasons for the seven life areas across three time
horizons — all as deterministic **evidence**.

V11 adds the **Decision Intelligence Foundation**: a deterministic reasoning
layer that **converts Prediction Intelligence into actionable decision
guidance** for ten real-life scenarios. For each scenario it answers *should I
act now, prepare, wait, or avoid* — with confidence, reasons, supporting and
conflicting evidence, best/worst timing and tradeoffs.

It is, explicitly:

- **NOT AI** — no LLM, no generation, fully deterministic.
- **NOT Transit** — no ephemeris/transit math; it reasons only over the V9/V10
  life-period model.
- **NOT Compatibility** — single-person reasoning only.
- **Evidence only** — no Thai copy, no user-facing text, no presenter, no UI,
  no Firestore, no routing.

V11 adds **no new runtime path and modifies no frozen engine**. It is additive
on the reusable core, consistent with D-007/D-009/D-019/D-020 and the freeze
registry in [`PROJECT_FREEZE.md`](PROJECT_FREEZE.md).

---

## 2. Architecture (engine-first, reusable)

All logic lives in a new reusable core package
`lib/features/astrology/thai/core/decision/`. It depends **only** on the V10
prediction core (`core/prediction/`) and the V9 core (`core/life_period/`) and
is free of Flutter, `BuildContext`, copy and persistence — so it can be reused
unchanged by **Transit, Compatibility, AI Conversation and Future Chat**.

```
DecisionIntelligenceEngine.fromBirthDate(birthDate, lagnaLord?, asOf?)
  → PredictionIntelligenceEngine.fromBirthDate(...)   (V10 — reused, untouched)
  → DecisionContext.fromPrediction(prediction)
  → for each scenario (10):
        assess each window  → strength · risk · confidence · net favourability
        decide verdict      → shouldAct / shouldPrepare / shouldWait / shouldAvoid
        reasons (4 axes) · evidence (6 families, split supporting/conflicting)
        best/worst timing · tradeoffs · outcome
  = DecisionIntelligence {
        context, recommendations[ one per scenario ]
    }
```

The engine never re-derives anything V9/V10 already computed (category strength,
opportunities, risks, confidence, period strength, natal harmony, transition
quality). It *composes* that evidence into per-scenario recommendations.

---

## 3. Types

| Type | Role |
|------|------|
| `DecisionScenario` | The ten Supported Scenarios (V1). Each maps onto a weighted blend of V10 `PredictionCategory`s via `DecisionScenarioConfig` — the engine never re-scores categories. |
| `DecisionScenarioConfig` | Per-scenario config: category weights + `stakes` (1–3) → derived `riskWeightPct`, `actThreshold`, `avoidRisk`. Pure config. |
| `DecisionAction` | The verdict: `shouldAct`, `shouldPrepare`, `shouldWait`, `shouldAvoid` (+ a coarse `direction`). |
| `DecisionContext` | Read-only adapter over the V10 `PredictionIntelligence` result (forwarding only; adds no derived state). |
| `DecisionConfidence` | How well-supported the verdict is (0–100) + `band` (low/moderate/high). |
| `DecisionReason` (+ `DecisionReasonKind`, `DecisionReasonCode`) | A *why* code on one of four axes — favourability, timing, risk, natal — with the signed magnitude it contributed. **Codes, never prose.** |
| `DecisionEvidence` (+ `DecisionEvidenceSource`) | A typed, signed signal atom traceable to one of the six required input families. Positive supports acting; negative argues against. |
| `DecisionWindow` | A scenario's timing assessment for one horizon: age bounds + net `favourability`/`risk`/`confidence` + `available`. |
| `DecisionTradeoff` | A `gain` life-domain weighed against a `cost` life-domain, each with a 0–100 magnitude (+ `net`). |
| `DecisionOutcome` (+ `DecisionOutlookBand`) | Projected outlook at the decisive window: band + net favourability + leading opportunity/risk domains. |
| `DecisionRecommendation` | One scenario's full result: action, confidence, reasons[], supporting/conflicting evidence, best/worst timing, tradeoffs[], outcome. |
| `DecisionIntelligence` | The full result: `context`, `recommendations[]`, plus `forScenario` / `ranked` accessors. |

### 3.1 Scenario → category mapping (V1)

| Scenario | Categories (weight) | Stakes |
|----------|---------------------|:------:|
| Career Change | career 0.6 · finance 0.25 · personal growth 0.15 | 3 |
| Business Start | career 0.45 · finance 0.4 · learning 0.15 | 3 |
| Investment | finance 0.7 · career 0.3 | 3 |
| Marriage | relationship 0.6 · family 0.25 · finance 0.15 | 3 |
| Relationship | relationship 0.7 · personal growth 0.3 | 2 |
| Education | learning 0.6 · personal growth 0.25 · career 0.15 | 2 |
| Relocation | career 0.35 · family 0.3 · personal growth 0.2 · health 0.15 | 3 |
| Health Improvement | health 0.7 · personal growth 0.3 | 1 |
| Financial Planning | finance 0.7 · career 0.2 · family 0.1 | 2 |
| Family Planning | family 0.5 · relationship 0.3 · finance 0.2 | 3 |

---

## 4. Reasoning (deterministic)

### 4.1 Per-window assessment

For each scenario × window the engine reads the V10 predictions for the
scenario's categories and computes a weighted blend:

- **strength** — weighted prediction strength (0–100).
- **risk** — weighted top-risk magnitude (0–100).
- **confidence** — weighted prediction confidence (0–100).
- **favourability (net)** = clamp(`strength` − `risk` × `riskWeightPct`/100).

`riskWeightPct`, `actThreshold` and `avoidRisk` are derived from the scenario's
**stakes** so irreversible decisions weigh risk more and demand a stronger
favourable signal before "act":

| Stakes | riskWeightPct | actThreshold | avoidRisk |
|:------:|:------:|:------:|:------:|
| 1 (reversible) | 40 | 50 | 80 |
| 2 | 55 | 56 | 74 |
| 3 (irreversible) | 70 | 62 | 68 |

### 4.2 Verdict

With `current` = the current-window assessment and `best` = the most favourable
available window (ties → nearer window), and `_gap` = 8:

1. **shouldAvoid** — `current.risk ≥ avoidRisk` and `current.net < actThreshold`.
2. **shouldAct** — `current.net ≥ actThreshold` and not beaten by a future
   window (`current.net + gap ≥ best.net`).
3. **shouldWait / shouldPrepare** — a materially better window ahead
   (`best.net − current.net ≥ gap`): `shouldWait` if that window is the next
   life period, else `shouldPrepare`.
4. **shouldPrepare** — default when nothing is decisive now and nothing is
   clearly better soon.

The **decisive window** (used for outcome/confidence/tradeoffs) is the current
window for act/avoid, the next-12-months window for prepare, and the next-life-
period window for wait (falling back to current when unavailable).

### 4.3 Reasons, evidence, confidence

- **Reasons (4):** one per axis — favourability (from the decisive net), timing
  (from the verdict/best window), risk (from the decisive risk vs `avoidRisk`)
  and natal (from the governing period's `natalHarmonyScore`). Each carries a
  signed magnitude so the verdict is reconstructable from its reasons.
- **Evidence (6 input families → 8 sources):** Prediction Intelligence
  (strength/risk/confidence), Timeline Intelligence (period strength tier),
  Current Age (stage), Future Window (best future vs now), Planet Relationship
  (natal-ruler bond) and Natal Context (natal alignment). Each atom is a signed
  contribution; atoms are split into **supporting** (`> 0`) and **conflicting**
  (`< 0`) lists. Neutral (`0`) signals are omitted.
- **Confidence** = clamp(decisive-window confidence + margin/3 −
  conflicts×2), where `margin` is how decisively the act threshold was cleared
  or missed. Because it is anchored on the V10 confidence (which is monotonic by
  horizon and rises with known lagna), nearer/better-supported reads stay more
  confident.

### 4.4 Tradeoffs & outcome

Tradeoffs pair the decisive window's leading opportunity domains against its
leading risk domains (gain ≠ cost; `pressure` is never an opportunity, so a
distinct cost always exists), capped at two. The outcome bands the decisive net
(favourable ≥ 60 · mixed ≥ 45 · unfavourable otherwise) and names the leading
opportunity/risk.

---

## 5. Tests

`test/validation/thai_mirror_v11_decision/decision_intelligence_test.dart`
(18 tests) covers the five required areas:

- **Determinism** — identical inputs → identical recommendations;
  `fromBirthDate` ≡ `fromIntelligence`.
- **Consistency** — one recommendation per scenario (no dupes); four reasons
  (one per kind); `shouldAct`/`shouldAvoid` only when the decisive favourability
  clears/misses the scenario threshold; `shouldWait` always points at the next
  life period.
- **Evidence traceability** — evidence non-empty, valid sources, correctly
  signed; current-stage always present; the union over a diverse spread wires
  all six input families (eight sources).
- **Scenario stability** — known lagna never lowers confidence (verdict held);
  `ranked` ordering; graceful final-period degradation.
- **Timing stability** — best timing ≥ worst timing; windows available and age
  bounds ordered; scores within 0..100; tradeoffs bounded with distinct gain/cost.

---

## 6. Boundaries & reuse

- **Frozen / untouched:** Thai Foundation Engine, Theme Engine, Timeline
  Intelligence Engine (V9), Prediction Intelligence Engine (V10), Consumer
  Presenter, Prediction UI (V10.5).
- **No presentation layer** ships in V11 — nothing consumes the engine yet. A
  later feature will map `DecisionReasonCode`s → copy on the presentation side,
  preserving the copy boundary.
- **Reusable by:** Transit, Compatibility, AI Conversation, Future Chat — all
  can feed a `DecisionContext` (or a `PredictionIntelligence`) and read
  structured decision evidence.

---

## 7. File map

```
lib/features/astrology/thai/core/decision/
  decision_action.dart                  # verdict enum
  decision_scenario.dart                # scenarios + category weighting + stakes config
  decision_confidence.dart              # confidence value + band
  decision_reason.dart                  # reason kinds/codes (evidence only)
  decision_evidence.dart                # evidence atoms + six source families
  decision_window.dart                  # per-horizon timing assessment
  decision_tradeoff.dart                # gain vs cost domain pair
  decision_outcome.dart                 # outlook band + leading opportunity/risk
  decision_context.dart                 # read-only adapter over V10 prediction
  decision_recommendation.dart          # per-scenario aggregate
  decision_intelligence_engine.dart     # engine + DecisionIntelligence result

test/validation/thai_mirror_v11_decision/
  decision_intelligence_test.dart       # determinism / consistency / traceability / stability / timing
```

---

## Related documents

- [`THAI_PREDICTION_INTELLIGENCE_FOUNDATION_V10.md`](THAI_PREDICTION_INTELLIGENCE_FOUNDATION_V10.md) — the V10 layer this builds on.
- [`THAI_LIFE_TIMELINE_INTELLIGENCE_V9.md`](THAI_LIFE_TIMELINE_INTELLIGENCE_V9.md) — the V9 substrate.
- [`DECISION_LOG.md`](DECISION_LOG.md) — D-022 (this layer), D-020 (V10), D-019 (V9).
- [`DOMAIN_MODEL.md`](DOMAIN_MODEL.md) — conceptual model.
- [`PROJECT_FREEZE.md`](PROJECT_FREEZE.md) — freeze registry (Decision Foundation entry).
- [`EXECUTIVE_SUMMARY.md`](EXECUTIVE_SUMMARY.md) — project context.
