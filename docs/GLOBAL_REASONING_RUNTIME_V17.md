# KnowMe V17 — Global Reasoning Runtime Foundation

**Status:** CURRENT (implementation record · cross-system foundation)
**Audience:** Developers, validation, AI agents.
**Last updated:** June 2026
**Builds on:** V13 Thai Unified Reasoning Runtime — now the **reference
implementation** ([`THAI_REASONING_RUNTIME_V13.md`](THAI_REASONING_RUNTIME_V13.md))
and V16 Mirror Conversation ([`THAI_MIRROR_CONVERSATION_V16.md`](THAI_MIRROR_CONVERSATION_V16.md))

---

## 1. Goal

V17 **generalizes** the Thai Reasoning Runtime into a system-agnostic runtime
architecture so other systems (Western, BaZi, MBTI, Big Five, EQ, Compatibility)
can plug in later behind one entry point.

It is, explicitly:

- **Not a merge / not a rewrite** — Thai stays exactly as it is; it remains the
  first (and, in V17, only) implementation.
- **No system implemented except Thai** — only a `ThaiRuntimeAdapter`.
- **No hard-coded Thai dependency in the runtime** — providers are discovered.
- **Architecture only** — no AI, no UI, no presenter, no routing, no Firestore,
  no deploy.

```
ReasoningRuntime  (discovers providers; system-agnostic)
        ↓ dispatch by ReasoningModule + ReasoningCapability
ReasoningProvider  →  ThaiRuntimeAdapter  →  Thai Reasoning Runtime (V13, frozen)
        ↓
ReasoningResponse  (module-tagged evidence + trace + confidence + raw)
```

---

## 2. Architecture — `lib/features/runtime/`

| Type | Role |
| --- | --- |
| `ReasoningModule` | The catalog of reasoning *systems* (identity only): `thaiAstrology`, `westernAstrology`, `bazi`, `mbti`, `bigFive`, `eq`, `compatibility`. |
| `ReasoningCapability` | The cross-system operations: `evaluate`, `predict`, `decide`, `question`, `answer` (mirrors the Thai reference APIs). |
| `ReasoningRequest` | System-agnostic request: target `module` + `capability`, common temporal inputs (`birthDate`, `asOf`), and a free-form `parameters` map for system-specific inputs. The generic runtime never inspects `parameters`. |
| `ReasoningEvidence` | System-agnostic evidence atom: `module`, `layer` (string), `sourceName`, `magnitude`, optional `domain`/`tag`. |
| `ReasoningTrace` / `ReasoningStep` | System-agnostic audit of one dispatch. |
| `ReasoningResponse` | System-agnostic output: `module`, `capability`, flattened `evidence`, `trace`, `confidence`, and `raw` (the native system response, opaque to the runtime). |
| `ReasoningProvider` | The contract each system implements: owns one `module`, advertises `capabilities`, answers `run(request)`. |
| `ReasoningProviderRegistry` | Discovery registry; providers register at bootstrap so the runtime imports no concrete system. |
| `ReasoningRuntime` | Holds providers, detects capabilities, dispatches by module, aggregates evidence. |

### Discovery & no hard-coded dependency

`ReasoningRuntime` resolves providers either from an explicit constructor list
(`ReasoningRuntime([...])`) or, by default, from
`ReasoningProviderRegistry.instance` (`ReasoningRuntime.discover()`). The runtime
core imports **no** system package. The Thai adapter registers itself via
`ThaiRuntimeAdapter.register()` at bootstrap; nothing in the runtime references
Thai.

---

## 3. The Thai adapter (only implementation)

`lib/features/runtime/adapters/thai_runtime_adapter.dart` wraps the frozen
`ThaiReasoningRuntime`:

1. builds a Thai `ReasoningRequest` from the generic request's `birthDate`/`asOf`
   plus `parameters` (`lagnaLord`, `questionIntent`, `scenarioFocus`),
2. dispatches to the matching Thai API by capability,
3. maps the Thai response into a `ReasoningResponse`: each Thai evidence atom
   becomes a module-tagged `ReasoningEvidence` (`layer = thaiLayer.name`), the
   confidence is carried over, and the **native Thai response is preserved in
   `raw`** for consumers that need the full V12 `QuestionResult` etc.

The Thai runtime, simulation, transit and the four engines are **untouched**.

---

## 4. Mirror Conversation now consumes the global runtime

The V16 `ConversationFlow` previously took a `ThaiReasoningRuntime`. As of V17 it
takes a **`ReasoningRuntime`** (default: a runtime hosting only the
`ThaiRuntimeAdapter`). It builds a generic `ReasoningRequest`
(`module: thaiAstrology`, capability mapped from the question's API, intent in
`parameters`) and reads the rich V12 result from `response.raw`. Behaviour is
unchanged — the V16 tests (including the example reproduction and runtime-only
consistency vs. the Thai runtime) still pass.

---

## 5. Tests

`test/validation/global_runtime_v17/global_reasoning_runtime_test.dart`:

- **Provider registration** — registry registers, discovery picks it up,
  registration is idempotent by id.
- **Runtime dispatch** — a Thai request is routed to the Thai provider;
  convenience methods set the capability; an unregistered module throws.
- **Capability detection** — the Thai provider's capabilities are exposed;
  unsupported modules/capabilities report empty/false.
- **Evidence aggregation** — responses carry module-tagged evidence; `aggregate`
  merges evidence across responses in order.

The V16 conversation suite continues to pass against the global runtime.

---

## 6. Scope & future

- **No deploy** — architecture only.
- **Future modules** (Western, BaZi, MBTI, Big Five, EQ, Compatibility) each add a
  `ReasoningProvider` and register it; no runtime change required.
- **Future consumers** (Simulation, Transit reuse, Compatibility, AI Conversation)
  can target the global runtime so they are not bound to a single system.

---

## Related documents

- [`THAI_REASONING_RUNTIME_V13.md`](THAI_REASONING_RUNTIME_V13.md) — the reference
  implementation this generalizes.
- [`THAI_MIRROR_CONVERSATION_V16.md`](THAI_MIRROR_CONVERSATION_V16.md) — the first
  consumer migrated to the global runtime.
- [`ARCHITECTURE.md`](ARCHITECTURE.md) — Global Reasoning Runtime section.
- [`DECISION_LOG.md`](DECISION_LOG.md) D-028 — the decision record.
- [`PROJECT_FREEZE.md`](PROJECT_FREEZE.md) — freeze registry.
