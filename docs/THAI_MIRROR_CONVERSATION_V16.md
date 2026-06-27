# KnowMe V16 — Mirror Conversation Experience Foundation

**Status:** CURRENT (implementation record · experience foundation)
**Audience:** Developers, validation, AI agents.
**Last updated:** June 2026
**Builds on:** V13 Unified Reasoning Runtime
([`THAI_REASONING_RUNTIME_V13.md`](THAI_REASONING_RUNTIME_V13.md),
[`DECISION_LOG.md`](DECISION_LOG.md) D-024) and V12 Question Reasoning
([`THAI_QUESTION_REASONING_FOUNDATION_V12.md`](THAI_QUESTION_REASONING_FOUNDATION_V12.md))

---

## 1. Goal

V16 is the **first conversational experience** on top of the completed Thai
Reasoning Platform (V9–V15). It is a **deterministic, guided conversation** —
the user always picks from a fixed catalog of predefined questions; the runtime
answers; the conversation suggests the next questions.

It is, explicitly:

- **NOT AI. NOT an LLM. NOT a chat model.** No generation, no typing, no parser.
- **No free text** — every step is a selection from a predefined catalog.
- **Deterministic** — output is a pure function of the session, the chosen
  question id and the runtime response.

The four engines, the V13 runtime, V14 simulation and V15 transit are
**untouched** (freeze registry in [`PROJECT_FREEZE.md`](PROJECT_FREEZE.md)).

```
User picks a question  (from catalog)
        ↓
 ThaiReasoningRuntime   (evaluate / predict / decide / question)
        ↓
   ConversationAnswer    (structured runtime output)
        ↓
ConversationSuggestion(s)  (curated follow-ups → next selection)
```

---

## 2. Architecture — a guided graph over the runtime

The conversation lives in `lib/features/astrology/thai/conversation/` (an
**experience layer**, deliberately *not* under `core/`). It consumes the
**`ThaiReasoningRuntime` only** — it never calls the decision, question,
prediction, timeline, simulation or transit engines directly.

| Type | Role |
| --- | --- |
| `ConversationTopic` | The eight topics: Current Life, Career, Money, Relationship, Family, Health, Growth, Future. Six map to a V12 `QuestionTopic`; Current Life & Future are overview topics. |
| `ConversationQuestion` | One **predefined, selectable** prompt: stable `id`, `topic`, structural `label`, the runtime `api` to call, optional `intent`/`scenarioFocus`, and `followUpIds`. |
| `ConversationCatalog` | The fixed registry of questions and their follow-up graph. The whole conversation surface, in one deterministic place. |
| `ConversationAnswer` | A structured wrapper over the runtime `ReasoningResponse` (plus the V12 `QuestionResult` for `question` calls). Evidence only — no rendered prose. |
| `ConversationSuggestion` | A suggested next question (id, topic, label, reason: `followUp` or `deepen`). |
| `ConversationMemory` | The deterministic record of asked ids and answers (in-memory; no Firestore). |
| `ConversationState` | The current screen state: open topic, available questions, last question/answer, suggestions. |
| `ConversationSession` | The chart anchors (birth date, lagna lord, asOf) + current state + memory. Immutable. |
| `ConversationFlow` | The engine: `openTopic` and `ask`. The only thing that touches the runtime. |

### Runtime mapping

Each question declares which runtime API it drives:

- `question` → `runtime.question(...)` with a V12 `QuestionIntent` (most topic
  questions: "Should I…", "When should I…", "What should I prepare…", "Biggest
  opportunity/risk…").
- `decide` → `runtime.decide(...)` (Current Life "What should I focus on now?").
- `evaluate` → `runtime.evaluate(...)` (Current Life overview).
- `predict` → `runtime.predict(...)` (Future outlook).

---

## 3. The flow

`ConversationFlow.openTopic(session, topic)` lists that topic's questions
(no runtime call). `ConversationFlow.ask(session, questionId)`:

1. looks up the question in the catalog,
2. builds one `ReasoningRequest` from the session + question, calls the runtime,
3. wraps the response in a `ConversationAnswer`,
4. records it in `ConversationMemory`,
5. computes `ConversationSuggestion`s — curated `followUpIds` first (excluding
   already-asked), then unasked siblings of the same topic, capped at three,
6. returns a new `ConversationSession` (new state + memory).

### Example (reproduced verbatim in tests)

```
Current Life                         openTopic(currentLife)
   ↓ "Should I change jobs?"         ask('cl_career')   → runtime.question(shouldI, career)
   ↓ Answer                          stance / action / confidence
   ↓ suggested follow-up
     "What opportunity should I       suggestion id 'future_opportunity'
      prepare for?"
   ↓                                  ask('future_opportunity') → runtime.question(biggestOpportunity, career)
   ↓ Answer
```

---

## 4. Copy boundary

The foundation carries **no Thai consumer copy**. Question and suggestion
`label`s are English **structural** strings used for selection and debugging; a
later presentation layer maps question ids → localized prose (the same boundary
used by V10.5 for predictions). Answers expose structured runtime output
(stance, action, confidence, evidence), never rendered text.

---

## 5. Tests

`test/validation/thai_mirror_v16_conversation/conversation_flow_test.dart`:

- **Catalog integrity** — unique ids, every follow-up resolves, every topic has
  questions, every `question` API entry carries an intent.
- **Guided flow / example reproduction** — `openTopic` does not call the runtime;
  the Current Life → "Should I change jobs?" → "What opportunity should I prepare
  for?" thread reproduces across charts.
- **Runtime-only consistency** — a conversation answer equals the runtime called
  directly with the same request; overview questions use the expected depth.
- **Suggestion logic** — suggestions exclude already-asked questions and are
  capped at three.
- **Determinism** — identical session + question → identical answer & suggestions.

---

## 6. Scope

- **No deploy** — foundation only. No UI, no routes, no pipeline, no Firestore.
- **Reusable later by** the consumer presenter / Mirror UI, and future
  Compatibility / AI Conversation surfaces — all through this foundation and the
  runtime, never the engines.

---

## Related documents

- [`THAI_REASONING_RUNTIME_V13.md`](THAI_REASONING_RUNTIME_V13.md) — the only
  reasoning entry point the conversation consumes.
- [`THAI_QUESTION_REASONING_FOUNDATION_V12.md`](THAI_QUESTION_REASONING_FOUNDATION_V12.md)
  — the `QuestionIntent`/`QuestionResult` shapes the catalog uses.
- [`DECISION_LOG.md`](DECISION_LOG.md) D-027 — the decision record.
- [`PROJECT_FREEZE.md`](PROJECT_FREEZE.md) — freeze registry.
- [`DOMAIN_MODEL.md`](DOMAIN_MODEL.md), [`EXECUTIVE_SUMMARY.md`](EXECUTIVE_SUMMARY.md),
  [`ROADMAP.md`](ROADMAP.md), [`CURRENT_STATUS.md`](CURRENT_STATUS.md),
  [`PROJECT_INDEX.md`](PROJECT_INDEX.md).
