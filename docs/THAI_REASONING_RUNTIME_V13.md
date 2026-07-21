# Thai Astrology V13 — Unified Reasoning Runtime Foundation

**Status:** CURRENT (implementation record · orchestration layer)
**Audience:** Developers, validation, AI agents.
**Last updated:** June 2026
**Builds on:** V12 Question Reasoning Foundation
([`THAI_QUESTION_REASONING_FOUNDATION_V12.md`](THAI_QUESTION_REASONING_FOUNDATION_V12.md),
[`DECISION_LOG.md`](DECISION_LOG.md) D-023)

---

## 1. Goal

V9–V12 produced four reasoning layers — Timeline (V9), Prediction (V10),
Decision (V11) and Question (V12) — each chained onto the one beneath it. V13
adds the **Unified Reasoning Runtime**: a single orchestration layer that
coordinates all four behind one public surface, so callers never wire the layers
together and never depend on the internal pipeline.

It is, explicitly:

- **NOT AI** — no LLM, no generation, fully deterministic.
- **NOT Transit, NOT Compatibility** — those are future *consumers* of this
  runtime, not part of it.
- **Orchestration only** — no Thai copy, no presenter, no UI, no Firestore, no
  parser, no LLM.

V13 **recomputes nothing** of the underlying logic: it calls the existing
engines unchanged, in order, and assembles their products into one response. It
adds **no new behaviour to any frozen engine**, consistent with D-020/D-022/D-023
and the freeze registry in [`PROJECT_FREEZE.md`](PROJECT_FREEZE.md).

`ThaiReasoningRuntime` is intended to become **the only public reasoning entry
point**: future features (Transit, Compatibility, AI Conversation) must consume
the runtime, not the individual engines.

---

## 2. Architecture (one entry point, hidden wiring)

All logic lives in a new reusable core package
`lib/features/astrology/thai/core/runtime/`. It depends only on the existing
core engines and is free of Flutter, `BuildContext`, copy and persistence.

```
ThaiReasoningRuntime
  evaluate / predict / decide / question / answer
    ReasoningRequest (birthDate + lagnaLord? + asOf? + question? + scenarioFocus?)
      → LifeTimelineIntelligenceEngine.fromBirthDate(...)   (V9 — reused, untouched)
      → PredictionIntelligenceEngine.fromIntelligence(...)  (V10 — reused, untouched)
      → DecisionIntelligenceEngine.fromPrediction(...)      (V11 — reused, when depth ≥ decision)
      → QuestionReasoningEngine.fromDecision(..., intent)   (V12 — reused, when a question is asked)
    = ReasoningResponse
        depth, timeline/prediction/decision/question snapshots,
        flattened evidence, trace, confidence
```

Each deeper engine is built from the *result object* of the layer above (not a
re-run from the birth date), so the runtime's chaining matches the engines'
own `from…` contracts exactly and stays deterministic.

---

## 3. Types

| Type | Role |
|------|------|
| `ThaiReasoningRuntime` | The single public entry point. Stateless, `const`-constructible. Exposes `evaluate` / `predict` / `decide` / `question` / `answer`. |
| `ReasoningRequest` | The one structured input: `birthDate`, optional `lagnaLord`, optional `asOf`, optional `question` (a V12 `QuestionIntent`), optional `scenarioFocus` (a V11 `DecisionScenario`). |
| `ReasoningDepth` | How far the pipeline ran: `prediction` < `decision` < `question`. |
| `ReasoningContext` | Internal orchestration state — the layer results computed so far (timeline + prediction always; decision/question when reached). Not the public surface. |
| `ReasoningResponse` | The unified public output: depth, the four snapshots, flattened evidence, trace, confidence. |
| `TimelineSnapshot` | Summarized V9 view (current age/planet/strength tier/stage/natal harmony/has-next) + full `source`. |
| `PredictionSnapshot` | Summarized V10 view (top predictions, prediction count, available-window count) + full `source`. |
| `DecisionSnapshot` | Summarized V11 view (`focus` recommendation + all recommendations) + full `source`. |
| `QuestionSnapshot` | The V12 `QuestionResult` (present only when a question was asked). |
| `ReasoningEvidence` (+ `ReasoningLayer`) | A unified, layer-tagged evidence atom (`layer` + `sourceName` code + signed `magnitude` + optional domain/planet) flattened across every layer that ran. |
| `ReasoningTrace` / `ReasoningStep` (+ `ReasoningStepStatus`) | An ordered audit of all four layers: ran/skipped, output count, contributed confidence. |

---

## 4. APIs

| API | Depth | Decision snapshot | Question snapshot | Notes |
|-----|-------|-------------------|-------------------|-------|
| `predict(request)` | prediction | — | — | Timeline + Prediction only. |
| `decide(request)` | decision | ✓ | — | Adds Decision; `scenarioFocus` centres the focus. |
| `question(request)` | question | ✓ | ✓ | Requires `request.question`. Full pipeline. |
| `answer(request)` | question | ✓ | ✓ | Ergonomic alias of `question`. |
| `evaluate(request)` | decision, or question if a question is present | ✓ | conditional | The "do the appropriate thing" call. |

All five return the same `ReasoningResponse` shape; they differ only in how deep
the pipeline ran (deeper snapshots are `null` when not reached).

### 4.1 Confidence

The overall response confidence is taken from the **deepest layer that ran**:
question confidence when a question was asked, else the focus recommendation's
confidence, else the top prediction's confidence. The trace additionally records
each layer's own contributed confidence.

### 4.2 Focus selection

When a `scenarioFocus` is supplied, the decision snapshot centres on that
scenario's recommendation; otherwise it centres on the most actionable
recommendation (`decision.ranked.first`). The top prediction is
`prediction.ranked.first`.

### 4.3 Evidence flattening

`ReasoningResponse.evidence` concatenates, in pipeline order: a Timeline atom
(natal harmony), the top prediction's evidence, the focus recommendation's
evidence, and (when a question ran) the question's relevant evidence. Each atom
keeps its **original signed magnitude** and is tagged with its `ReasoningLayer`,
so provenance is preserved and only layers that ran contribute.

---

## 5. Tests

`test/validation/thai_mirror_v13_runtime/reasoning_runtime_test.dart`
(14 tests) covers the four required areas:

- **Determinism** — identical request → byte-identical response (depth,
  confidence, snapshots, full trace and evidence signatures).
- **Runtime consistency** — snapshots equal the engines called directly
  (prediction/decision/question), focus = most-actionable when unfocused,
  `scenarioFocus` centres correctly, confidence mirrors the deepest layer.
- **Trace integrity** — all four layers listed in pipeline order; ran/skipped
  status matches the depth; ran steps have positive output, skipped steps are
  zeroed.
- **Evidence integrity** — evidence non-empty, only from layers that ran,
  timeline atom equals the natal-harmony score, decision atoms match the focus
  recommendation, and a full-pipeline response covers all four layers.

(Plus coverage of the API → depth mapping across eight birth dates.)

---

## 6. Boundaries & reuse

- **Frozen / untouched:** Timeline Intelligence (V9), Prediction Intelligence
  (V10), Decision Intelligence (V11), Question Engine (V12), Consumer Presenter,
  Prediction Presentation (V10.5).
- **No presentation layer** ships in V13 — nothing consumes the runtime yet. A
  later feature maps snapshots/codes → copy on the presentation side.
- **Reusable by:** Transit, Compatibility, AI Conversation — all must consume
  `ThaiReasoningRuntime` only, never the individual engines.

---

## 7. File map

```
lib/features/astrology/thai/core/runtime/
  reasoning_request.dart                # ReasoningRequest + ReasoningDepth
  reasoning_evidence.dart               # ReasoningLayer + ReasoningEvidence
  reasoning_trace.dart                  # ReasoningStep(+Status) + ReasoningTrace
  reasoning_snapshot.dart               # Timeline/Prediction/Decision/Question snapshots
  reasoning_context.dart                # internal orchestration state
  reasoning_response.dart               # ReasoningResponse aggregate
  thai_reasoning_runtime.dart           # the runtime (entry point)

test/validation/thai_mirror_v13_runtime/
  reasoning_runtime_test.dart           # determinism / consistency / trace / evidence
```

---

## Related documents

- [`THAI_QUESTION_REASONING_FOUNDATION_V12.md`](THAI_QUESTION_REASONING_FOUNDATION_V12.md) — the V12 layer this orchestrates.
- [`THAI_DECISION_INTELLIGENCE_V11.md`](THAI_DECISION_INTELLIGENCE_V11.md) — the V11 layer.
- [`THAI_PREDICTION_INTELLIGENCE_FOUNDATION_V10.md`](THAI_PREDICTION_INTELLIGENCE_FOUNDATION_V10.md) — the V10 substrate.
- [`DECISION_LOG.md`](DECISION_LOG.md) — D-024 (this layer), D-023 (V12), D-022 (V11).
- [`DOMAIN_MODEL.md`](DOMAIN_MODEL.md) — conceptual model.
- [`PROJECT_FREEZE.md`](PROJECT_FREEZE.md) — freeze registry (Unified Reasoning Runtime entry).
- [`EXECUTIVE_SUMMARY.md`](EXECUTIVE_SUMMARY.md) — project context.
