# Thai Astrology V14 — Scenario Simulation Foundation

**Status:** CURRENT (implementation record · simulation layer)
**Audience:** Developers, validation, AI agents.
**Last updated:** June 2026
**Builds on:** V13 Unified Reasoning Runtime
([`THAI_REASONING_RUNTIME_V13.md`](THAI_REASONING_RUNTIME_V13.md),
[`DECISION_LOG.md`](DECISION_LOG.md) D-024)

---

## 1. Goal

V13 unified the reasoning layers behind one entry point. V14 adds the **Scenario
Simulation Foundation**: a deterministic engine that evaluates **hypothetical
decision paths** for a life scenario and compares them.

It is, explicitly:

- **NOT AI** — no LLM, no generation, fully deterministic.
- **NOT Transit, NOT Compatibility** — those are future *consumers* of this
  engine.
- **Evidence only** — no Thai copy, no presenter, no parser, no UI, no Firestore.

V14 consumes the **runtime only**: it calls `ThaiReasoningRuntime.decide(...)`
and never touches the Timeline, Prediction, Decision or Question engines
directly. It adds **no runtime path and modifies no frozen engine**, consistent
with D-020…D-024 and the freeze registry in
[`PROJECT_FREEZE.md`](PROJECT_FREEZE.md).

---

## 2. Approach — options are *timing paths*

A simulation evaluates four paths for a scenario:

| Option | Meaning | How it is evaluated |
|--------|---------|---------------------|
| **A — Act now** | Take the decision at the current evaluation date | `runtime.decide(asOf = now)` |
| **B — Act at the best window** | Take it at the recommendation's best timing | `runtime.decide(asOf = birth + bestWindow.startAge)` |
| **C — Act at an alternative window** | Take it at the worst timing, for contrast | `runtime.decide(asOf = birth + worstWindow.startAge)` |
| **Do Nothing** | Status quo — the decision is not taken | Neutral baseline; risk = opportunity cost vs the best path |

Re-querying the runtime at a hypothetical `asOf` re-derives the whole pipeline at
that age, so each acting path is a genuine "what if I act at age X" evaluation —
deterministic and fully grounded in the runtime. A window path that points to the
present or past (or an unavailable window) collapses onto the act-now evaluation;
it is still reported, just at the current point.

```
ScenarioSimulationEngine.simulate(birthDate, scenario, lagnaLord?, asOf?, runtime?)
  scenario → DecisionScenario              (route, no recomputation)
  base = runtime.decide(asOf)              (Option A)
  optB = runtime.decide(best window age)   (Option B)
  optC = runtime.decide(worst window age)  (Option C)
  doNothing = neutral baseline             (status quo)
  → per option: expected / opportunity / risk / tradeoffs / timing /
                confidence / supporting evidence
  → comparison: ranked best→worst, value-of-acting vs Do Nothing
  = SimulationResult
```

---

## 3. Types

| Type | Role |
|------|------|
| `SimulationScenario` | The seven Supported V1 areas (career, investment, business, marriage, relationship, relocation, education). Each routes 1:1 onto a V11 `DecisionScenario`. |
| `SimulationOption` (+ `SimulationOptionKind`) | One path: kind (act-now / best-window / alternative-window / do-nothing), the simulated `targetAge`, and the `evaluatedAsOf` the runtime was queried with. |
| `SimulationImpact` (+ `SimulationImpactBand`) | A 0–100 magnitude + valence band + optional `LifeDomain`. `favourable(...)` (higher = better) for expected/opportunity; `risk(...)` (higher = worse) for risk. |
| `SimulationWindow` | The option's timing, projected from a V11 `DecisionWindow` (age bounds + favourability). |
| `SimulationTradeoff` | A gain-domain vs cost-domain pairing, projected from a V11 `DecisionTradeoff`. |
| `SimulationConfidence` (+ `SimulationConfidenceBand`) | The option's confidence, carried straight from the runtime response for that evaluation. |
| `SimulationEvidence` | A runtime `ReasoningEvidence` atom **unchanged** (provenance preserved) tagged with its option + a relevance score. |
| `SimulationOutcome` | The full per-option result: expected / opportunity / risk / tradeoffs / timing / confidence / evidence + underlying `DecisionAction` (null for Do Nothing). |
| `SimulationComparison` | `ranked` best→worst, `best` / `worst`, the `doNothing` baseline, and `valueOfActing` (best − doNothing). |
| `SimulationResult` | The aggregate: scenario, four outcomes (fixed order), comparison, overall confidence (= best path). |

### 3.1 Scenario → decision routing (V1)

| Simulation scenario | Decision scenario (V11) |
|---------------------|--------------------------|
| Career | Career Change |
| Investment | Investment |
| Business | Business Start |
| Marriage | Marriage |
| Relationship | Relationship |
| Relocation | Relocation |
| Education | Education |

---

## 4. Reasoning (deterministic, runtime-only)

### 4.1 Expected / opportunity / risk

Each acting path reads the runtime recommendation's `DecisionOutcome` at its
evaluation date: **expected** = net favourability; **opportunity** = the same
favourability tagged with the leading-opportunity domain (when one stands out);
**risk** = `100 − favourability` tagged with the leading-risk domain. Bands read
on a "how good is this" axis for both favourable and risk magnitudes.

### 4.2 Do Nothing

The status quo is a neutral baseline (`expected = 50`, aligned with the V11
mixed/favourable thresholds). Its **risk** is the opportunity cost of inaction:
`bestActingPath.expected − 50`, tagged with that path's opportunity domain (or
none when no acting path beats neutral). Its evidence is the current situation's
runtime evidence; it carries no `DecisionAction`.

### 4.3 Comparison

Options are ranked by expected score (then confidence, then a stable option
order). `best`/`worst` are the ends; `valueOfActing` is `best.expected −
doNothing.expected` — positive when acting beats sitting still, negative or zero
when the timing is poor enough that doing nothing is at least as good.

### 4.4 Evidence

Each option surfaces the runtime's flattened `ReasoningEvidence` for its
evaluation, ranked by `|magnitude|` (then layer, then source) and capped at six.
**Atoms are the original runtime atoms** (identity and magnitude preserved), so
every simulation evidence atom is traceable back through the runtime to its
originating layer.

---

## 5. Tests

`test/validation/thai_mirror_v14_simulation/scenario_simulation_test.dart`
(6 tests) covers the four required areas:

- **Determinism** — identical inputs → identical result (options, scores, bands,
  windows, confidence, evidence, ranking).
- **Scenario consistency** — every scenario yields the four options in fixed
  order; acting paths carry an action and timing; Do Nothing is action-less,
  timing-less and neutral.
- **Comparison stability** — `ranked` is a non-increasing permutation of the
  four outcomes; `best`/`worst` are its ends; `valueOfActing` is consistent.
- **Evidence traceability** — every option outcome equals the runtime `decide`
  at its `evaluatedAsOf` (proving runtime-only consumption), and every evidence
  atom traces to a runtime atom, capped and relevance-scored.

---

## 6. Boundaries & reuse

- **Frozen / untouched:** Timeline Intelligence (V9), Prediction Intelligence
  (V10), Decision Intelligence (V11), Question Engine (V12), Reasoning Runtime
  (V13), Consumer Presenter.
- **Runtime-only input:** the engine calls `ThaiReasoningRuntime` and reads its
  response types; it never invokes a lower engine.
- **No presentation layer** ships in V14 — nothing consumes the engine yet.
- **Reusable by:** Transit, Compatibility, AI Conversation — all consume the
  Simulation engine (which in turn consumes the runtime).

---

## 7. File map

```
lib/features/astrology/thai/core/simulation/
  simulation_scenario.dart              # scenarios + decision routing
  simulation_option.dart                # option kinds + SimulationOption
  simulation_impact.dart                # magnitude + valence band
  simulation_window.dart                # timing projection
  simulation_tradeoff.dart              # gain/cost projection
  simulation_confidence.dart            # confidence + band
  simulation_evidence.dart              # runtime-atom-backed evidence
  simulation_outcome.dart               # per-option outcome
  simulation_comparison.dart            # ranked comparison
  simulation_result.dart                # SimulationResult aggregate
  scenario_simulation_engine.dart       # engine (runtime-only)

test/validation/thai_mirror_v14_simulation/
  scenario_simulation_test.dart         # determinism / consistency / comparison / traceability
```

---

## Related documents

- [`THAI_REASONING_RUNTIME_V13.md`](THAI_REASONING_RUNTIME_V13.md) — the runtime this consumes.
- [`THAI_DECISION_INTELLIGENCE_V11.md`](THAI_DECISION_INTELLIGENCE_V11.md) — the decision substrate the runtime exposes.
- [`DECISION_LOG.md`](DECISION_LOG.md) — D-025 (this layer), D-024 (V13).
- [`DOMAIN_MODEL.md`](DOMAIN_MODEL.md) — conceptual model.
- [`PROJECT_FREEZE.md`](PROJECT_FREEZE.md) — freeze registry (Scenario Simulation entry).
- [`EXECUTIVE_SUMMARY.md`](EXECUTIVE_SUMMARY.md) — project context.
