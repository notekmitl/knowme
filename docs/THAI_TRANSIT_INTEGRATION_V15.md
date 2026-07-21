# Thai Astrology V15 — Transit Intelligence Integration

**Status:** CURRENT (implementation record · enhancement layer)
**Audience:** Developers, validation, AI agents.
**Last updated:** June 2026
**Builds on:** V13 Unified Reasoning Runtime
([`THAI_REASONING_RUNTIME_V13.md`](THAI_REASONING_RUNTIME_V13.md),
[`DECISION_LOG.md`](DECISION_LOG.md) D-024) and V14 Scenario Simulation
([`THAI_SCENARIO_SIMULATION_V14.md`](THAI_SCENARIO_SIMULATION_V14.md))

---

## 1. Goal

V15 integrates **Thai transit** into the existing reasoning platform. It is an
**enhancement layer**, not a parallel architecture: reasoning stays inside the
V13 runtime, and transit only *contributes evidence*.

It is, explicitly:

- **NOT a parallel Transit architecture** — no separate reasoning stack.
- **Transit never decides, never predicts, never answers** — it only contributes
  evidence that is merged into the runtime evidence pool.
- **Evidence only** — no Thai copy, no presenter, no UI, no Firestore, no AI.

The base V13 runtime, V14 simulation and the four engines beneath them are
**untouched** (D-024, freeze registry in [`PROJECT_FREEZE.md`](PROJECT_FREEZE.md)).

```
Runtime  +  Transit
        ↓
  Enhanced Runtime
        ↓
    Simulation
        ↓
     Consumer
```

---

## 2. Approach — transit as a calendar signal, merged as evidence

The pipeline (V9–V14) reasons on the **age/life-period** axis. Transit adds the
**calendar** axis the pipeline does not capture: the Thai **day-of-week ruler**
of the evaluation date. That transiting planet is assessed against:

1. the **natal birth ruler** (`dayVersusNatal`), and
2. the **current life-period planet** (`dayVersusPeriod`),

using the shared V9 `PlanetRelationshipEngine` (reused — **no duplicate
scoring**). Each assessment becomes a signed influence and an evidence atom.

Crucially, transit **never bypasses the runtime**: its `TransitContext` is built
from a runtime `ReasoningResponse` (natal ruler + current planet + asOf). The
`EnhancedReasoningRuntime` **wraps** the frozen runtime, runs it unchanged, then
merges transit evidence into a single pool.

```
EnhancedReasoningRuntime.{evaluate|predict|decide|question|answer}(request)
  base = ThaiReasoningRuntime.<same>(request)      (V13 — reused, untouched)
  ctx  = TransitContext.fromResponse(base, asOf)   (derived from runtime, never bypassed)
  transit = TransitIntelligenceEngine.evaluate(ctx)
  = EnhancedReasoningResponse(base, transit)
        mergedEvidence = base.evidence (runtime) ++ transit.evidence (transit)
        confidence     = base.confidence          (transit adds no verdict)
```

---

## 3. Types

| Type | Role |
|------|------|
| `TransitContext` | Read-only adapter built **from a runtime response** (natal ruler, current planet, asOf). Never calls a lower engine. |
| `TransitSignal` | The raw relationship between the transiting planet and a target, via the shared V9 `PlanetRelationshipEngine` (bond + signed score −3..+3). |
| `TransitEvent` (+ `TransitEventKind`) | A discrete current-transit occurrence (`dayVersusNatal` / `dayVersusPeriod`) wrapping a signal + window. |
| `TransitInfluence` | The signed effect of an event on one `LifeDomain` (the transiting planet's leading domain). |
| `TransitWindow` | The window the transit applies to (current day) + its ruling planet. |
| `TransitImpact` (+ `TransitImpactBand`) | The aggregate net nudge (−100..+100) + band. Not a prediction or decision. |
| `TransitEvidence` | A transit evidence atom (code + signed magnitude + domain + planet), shaped to merge with runtime evidence. |
| `TransitAssessment` | The engine product: events + influences + impact + evidence + window. |
| `TransitIntelligenceEngine` | Evaluates the current transit → `TransitAssessment` (evidence only). |
| `EnhancedReasoningRuntime` | **Runtime + Transit** wrapper; mirrors the five runtime APIs, returns an `EnhancedReasoningResponse`. |
| `EnhancedReasoningResponse` (+ `EnhancedEvidence`, `EnhancedEvidenceOrigin`) | The untouched base response + transit assessment + the merged evidence view. |

---

## 4. Reasoning (deterministic, evidence-only)

### 4.1 The transiting planet

`LifePlanets.rulerForWeekday(asOf.weekday)` (reused) gives the day ruler — a
deterministic function of the date. When the request has no `asOf`, the engine
reconstructs a date from the birth date + the runtime's reported current age, so
the result is always deterministic from inputs.

### 4.2 Influence & impact

Each event's signed relationship score (−3..+3) is scaled (×15) into an influence
magnitude on the transiting planet's leading supportive domain. The aggregate
`TransitImpact.net` is the sum of the influences (clamped to ±100), banded from
strongly-favourable to strongly-unfavourable.

### 4.3 Evidence merge

Transit emits one evidence atom per event (`transitDayVsNatal`,
`transitDayVsPeriod`). The `EnhancedReasoningResponse` normalises runtime
`ReasoningEvidence` and `TransitEvidence` into one `EnhancedEvidence` shape:
runtime atoms keep their layer name; transit atoms carry the literal layer
`transit` (the frozen `ReasoningLayer` enum is **not** modified). The merged pool
is `runtime evidence ++ transit evidence` — runtime atoms are preserved
byte-for-byte, so the base reasoning is never altered.

---

## 5. Tests

`test/validation/thai_mirror_v15_transit/transit_integration_test.dart`
(6 tests) covers the four required areas:

- **Determinism** — identical request → identical enhanced response (transit
  events, signals, impact, merged evidence).
- **Transit stability** — the transiting planet is the day-of-week ruler; two
  events with the right kinds; signals reuse the shared relationship engine;
  same weekday → same transit.
- **Evidence merge** — merged = runtime evidence then transit evidence; runtime
  atoms preserved unchanged (runtime origin); transit atoms tagged `transit`.
- **Runtime compatibility** — `enhanced.base` equals the runtime called directly
  across all five APIs; confidence is exactly the base confidence (transit adds
  no verdict).

---

## 6. Boundaries & reuse

- **Frozen / untouched:** Timeline (V9), Prediction (V10), Decision (V11),
  Question (V12), Reasoning Runtime (V13), Simulation (V14), Consumer Presenter.
- **Reuses (read-only):** `LifePlanets.rulerForWeekday`,
  `PlanetRelationshipEngine.assess` — shared core primitives, no duplicate
  scoring.
- **Runtime-grounded:** transit context comes from a runtime response; transit
  never bypasses the runtime and never makes a decision/prediction/answer.
- **Reusable by:** Compatibility and AI Conversation — both consume the
  Enhanced Runtime.

---

## 7. File map

```
lib/features/astrology/thai/core/transit/
  transit_context.dart                  # adapter from a runtime response
  transit_signal.dart                   # raw relationship (reuses V9 engine)
  transit_event.dart                    # event + kind
  transit_influence.dart                # per-domain signed influence
  transit_window.dart                   # current-day window + ruler
  transit_impact.dart                   # net impact + band
  transit_evidence.dart                 # mergeable transit atom
  transit_assessment.dart               # engine product
  transit_intelligence_engine.dart      # transit engine (evidence only)
  enhanced_reasoning_response.dart      # base + transit + merged evidence
  enhanced_reasoning_runtime.dart       # Runtime + Transit wrapper

test/validation/thai_mirror_v15_transit/
  transit_integration_test.dart         # determinism / stability / merge / compatibility
```

---

## Related documents

- [`THAI_REASONING_RUNTIME_V13.md`](THAI_REASONING_RUNTIME_V13.md) — the runtime this enhances.
- [`THAI_SCENARIO_SIMULATION_V14.md`](THAI_SCENARIO_SIMULATION_V14.md) — the simulation layer that consumes the runtime.
- [`DECISION_LOG.md`](DECISION_LOG.md) — D-026 (this layer), D-024 (V13).
- [`DOMAIN_MODEL.md`](DOMAIN_MODEL.md) — conceptual model.
- [`PROJECT_FREEZE.md`](PROJECT_FREEZE.md) — freeze registry (Transit Integration entry).
- [`EXECUTIVE_SUMMARY.md`](EXECUTIVE_SUMMARY.md) — project context.
