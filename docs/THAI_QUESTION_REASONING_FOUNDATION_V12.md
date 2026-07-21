# Thai Astrology V12 — Question Reasoning Foundation

**Status:** CURRENT (implementation record · engine layer)
**Audience:** Developers, validation, AI agents.
**Last updated:** June 2026
**Builds on:** V11 Decision Intelligence Foundation
([`THAI_DECISION_INTELLIGENCE_V11.md`](THAI_DECISION_INTELLIGENCE_V11.md),
[`DECISION_LOG.md`](DECISION_LOG.md) D-022)

---

## 1. Goal

V11 turned predictions into per-scenario decision guidance (verdict, confidence,
reasons, evidence, timing, tradeoffs, outcome). V12 adds the **Question
Reasoning Foundation**: a deterministic layer that converts a **structured
question intent** into a **structured Decision query** and returns a structured
answer.

It is, explicitly:

- **NOT AI** — no LLM, no generation, fully deterministic.
- **No parser** — it consumes **intent objects, never natural-language text**.
  A UI control, a voice assistant or a future AI front-end constructs the
  `QuestionIntent`; this layer routes it.
- **Evidence only** — no Thai copy, no user-facing text, no presenter, no UI,
  no Firestore, no routing.

V12 **recomputes nothing**: it routes a topic onto a V11 `DecisionScenario`,
reads that recommendation, and re-projects the *existing* decision evidence
through the lens of the asked intent. It adds **no runtime path and modifies no
frozen engine**, consistent with D-020/D-022 and the freeze registry in
[`PROJECT_FREEZE.md`](PROJECT_FREEZE.md).

---

## 2. Architecture (engine-first, reusable)

All logic lives in a new reusable core package
`lib/features/astrology/thai/core/question/`. It depends **only** on the V11
decision core (`core/decision/`) (and the V10/V9 types it re-exposes) and is
free of Flutter, `BuildContext`, copy and persistence — so it can be reused
unchanged by **Transit, Compatibility, Future AI and a Voice Assistant**.

```
QuestionReasoningEngine.fromBirthDate(birthDate, intent, lagnaLord?, asOf?)
  → DecisionIntelligenceEngine.fromBirthDate(...)   (V11 — reused, untouched)
  → QuestionContext.fromDecision(decision)
  → resolve(context, intent):
        topic → DecisionScenario      (route, no recomputation)
        recommendation = decision.forScenario(scenario)
        structured answer  (stance from verdict / informational)
        relevant windows   (focus / best / worst)
        relevant evidence  (re-ranked decision atoms — provenance preserved)
        priority reasons   (decision reasons re-ordered by intent emphasis)
        confidence         (= decision confidence)
  = QuestionResult
```

---

## 3. Types

| Type | Role |
|------|------|
| `QuestionTopic` | The ten Supported Topics (V1). Each routes 1:1 onto a V11 `DecisionScenario`. |
| `QuestionIntentKind` | The six Supported Intents (V1): should-I, when-should-I, should-I-wait, what-to-prepare, biggest-opportunity, biggest-risk. |
| `QuestionConstraint` | Optional structured filter: `horizon` (focus a window) and `minConfidence` (reported, never silently applied). |
| `QuestionIntent` | A fully structured question: `kind` + `topic` + `constraint`. **Object, not text.** |
| `QuestionContext` | Read-only adapter over the V11 `DecisionIntelligence` (forwarding only; exposes prediction/timeline beneath). |
| `QuestionScenario` | The topic → `DecisionScenario` resolution + the routed `DecisionRecommendation`. |
| `QuestionWindow` (+ `QuestionWindowRole`) | A relevant window projected from a V11 `DecisionWindow`, tagged `focus` / `best` / `worst`. |
| `QuestionReason` | A V11 `DecisionReason` (kind + code + magnitude) re-ranked with a `priority` for the asked intent. Codes only. |
| `QuestionEvidence` | A V11 `DecisionEvidence` atom (untouched, provenance preserved) plus a `relevance` score. |
| `QuestionAnswer` (+ `QuestionStance`) | The structured answer: stance + underlying `DecisionAction` + focus window / focus domain / focus tradeoff. |
| `QuestionResult` | The full result: intent, resolved scenario, answer, relevant windows, relevant evidence, priority reasons, confidence (+ `meetsConfidence`). |

### 3.1 Topic → scenario routing (V1)

| Topic | Decision scenario (V11) |
|-------|--------------------------|
| Career | Career Change |
| Finance | Financial Planning |
| Investment | Investment |
| Relationship | Relationship |
| Marriage | Marriage |
| Health | Health Improvement |
| Education | Education |
| Business | Business Start |
| Relocation | Relocation |
| Family | Family Planning |

---

## 4. Reasoning (deterministic, recompute-free)

### 4.1 Answer stance

Directional intents (should-I, should-I-wait) map the V11 verdict to a stance:
`shouldAct → yes`, `shouldPrepare → prepareFirst`, `shouldWait →
waitForBetterWindow`, `shouldAvoid → avoid`. The informational intents
(when-should-I, what-to-prepare, biggest-opportunity, biggest-risk) are
`informational`. Every answer still carries the underlying `DecisionAction`, a
focus window, and — depending on intent — a focus domain (leading
opportunity/risk from the outcome) and the headline tradeoff.

### 4.2 Window selection

The **focus** window defaults to the recommendation's best timing; a
`QuestionConstraint.horizon` re-points it to the matching best/worst window when
available. Comparison intents (when-should-I, should-I-wait) additionally
surface the **worst** window for contrast. Windows are projected from the V11
`DecisionWindow` (age bounds + net favourability), deduped by horizon.

### 4.3 Priority reasons & relevant evidence

The four V11 reasons are re-ordered so the intent's **emphasis axis** leads
(should-I/biggest-opportunity → favourability; when-should-I/should-I-wait →
timing; what-to-prepare/biggest-risk → risk), then by |magnitude|; each gets a
0-based `priority`. Evidence atoms are scored by `|magnitude|` plus a bonus when
the source matches the intent's emphasis (and a bonus for the matching sign on
opportunity/risk/prepare intents), then ranked and capped at five. **Atoms are
the original decision atoms** (identity preserved), so every piece of question
evidence is traceable back to V11.

### 4.4 Confidence

Confidence is the underlying **decision confidence** unchanged — so all intents
on the same topic share one honest confidence, and a `minConfidence` constraint
is *reported* via `meetsConfidence` rather than silently rewriting the verdict.

---

## 5. Tests

`test/validation/thai_mirror_v12_question/question_reasoning_test.dart`
(12 tests) covers the five required areas:

- **Determinism** — identical inputs → identical results (stance, action,
  confidence, windows, reason codes, evidence sources/relevance).
- **Intent mapping** — directional verdict → stance; informational intents are
  `informational`; opportunity/risk intents focus the right outcome domain;
  priority reasons lead with the emphasis axis with a stable 0..n priority.
- **Scenario resolution** — every topic routes to the documented scenario and to
  the exact V11 recommendation (identity).
- **Evidence traceability** — every question-evidence atom is the original V11
  atom; sources valid; bounded to five.
- **Confidence stability** — equals the decision confidence; identical across
  all intents for a topic; `minConfidence` is reported, never applied.

(Plus coverage for all topic × intent combinations and the horizon constraint.)

---

## 6. Boundaries & reuse

- **Frozen / untouched:** Timeline Intelligence (V9), Prediction Intelligence
  (V10), Decision Intelligence (V11), Consumer Presenter, Prediction
  Presentation (V10.5).
- **No presentation layer** ships in V12 — nothing consumes the engine yet. A
  later feature maps stances/codes → copy on the presentation side.
- **Reusable by:** Transit, Compatibility, Future AI, Voice Assistant — all can
  build a `QuestionIntent` and read a structured `QuestionResult`.

---

## 7. File map

```
lib/features/astrology/thai/core/question/
  question_topic.dart                   # topics + scenario routing
  question_intent.dart                  # intent kinds + QuestionIntent
  question_constraint.dart              # optional structured constraint
  question_window.dart                  # relevant window projection + role
  question_reason.dart                  # priority-ranked reason
  question_evidence.dart                # relevance-scored evidence (provenance kept)
  question_answer.dart                  # stance + focus payload
  question_scenario.dart                # topic → scenario resolution
  question_context.dart                 # read-only adapter over V11 decision
  question_result.dart                  # QuestionResult aggregate
  question_reasoning_engine.dart        # engine

test/validation/thai_mirror_v12_question/
  question_reasoning_test.dart          # determinism / intent / resolution / traceability / confidence
```

---

## Related documents

- [`THAI_DECISION_INTELLIGENCE_V11.md`](THAI_DECISION_INTELLIGENCE_V11.md) — the V11 layer this builds on.
- [`THAI_PREDICTION_INTELLIGENCE_FOUNDATION_V10.md`](THAI_PREDICTION_INTELLIGENCE_FOUNDATION_V10.md) — the V10 substrate.
- [`DECISION_LOG.md`](DECISION_LOG.md) — D-023 (this layer), D-022 (V11), D-020 (V10).
- [`DOMAIN_MODEL.md`](DOMAIN_MODEL.md) — conceptual model.
- [`PROJECT_FREEZE.md`](PROJECT_FREEZE.md) — freeze registry (Question Reasoning Foundation entry).
- [`EXECUTIVE_SUMMARY.md`](EXECUTIVE_SUMMARY.md) — project context.
