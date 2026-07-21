# KnowMe Platform P2 — Cross-System Fusion Runtime

**Status:** CURRENT (implementation record · cross-system fusion layer)
**Audience:** Developers, validation, AI agents.
**Last updated:** June 2026
**Builds on:** V17 Global Reasoning Runtime
([`GLOBAL_REASONING_RUNTIME_V17.md`](GLOBAL_REASONING_RUNTIME_V17.md)) — Thai
remains the only provider.

---

## 1. Goal

P2 adds the **Fusion Runtime** — a layer that sits **above** the Global Runtime,
collects responses from multiple providers, and produces **one** unified
reasoning result.

```
Global Runtime
      ↓
Fusion Runtime  ⭐
      ↓
Conversation
      ↓
Future AI
```

It is, explicitly:

- **Not a replacement** for the Global Runtime — it composes it.
- **Single-provider-aware** — with only Thai registered it runs in
  **single-provider mode** and still produces a valid result.
- **Architecture only** — no AI, no presenter, no UI, no deploy.

---

## 2. Architecture — `lib/features/runtime/fusion/`

| Type | Role |
| --- | --- |
| `FusionContext` | A cross-system request: a `ReasoningCapability` + common inputs + `parameters`, fanned out across every provider that supports it (optionally restricted by `modules`). |
| `FusionObservation` | One provider's contribution: its module, confidence, flattened evidence and native response (`raw` preserved for system-aware consumers). |
| `FusionAgreement` | A domain where ≥2 providers point the same way (shared direction + combined magnitude). |
| `FusionConflict` | A domain where providers point opposite ways (positive vs negative modules + spread). |
| `FusionEvidence` | Per-domain merged evidence: signed net magnitude across providers + contributing modules. |
| `FusionPriority` | A domain's place in the ranked ordering (rank, score, agreement-boosted flag). |
| `FusionConfidence` | The fused confidence value + band + provider count. |
| `FusionRule` | Deterministic thresholds (agreement bonus, conflict penalty, priority boost, confidence bands). |
| `FusionResult` | The single unified output (observations, agreements, conflicts, merged evidence, priorities, confidence, `singleProviderMode`, missing evidence). |
| `FusionRuntime` | The engine: fan out → observe → detect → merge → one `FusionResult`. |

---

## 3. How fusion works

For a `FusionContext`, `FusionRuntime.fuse`:

1. **Collect** — for each provider in the Global Runtime that supports the
   capability (and passes the optional module filter), dispatch through
   `ReasoningRuntime.run` and wrap the response as a `FusionObservation`.
2. **Group** — sum each provider's evidence per `domain` (a signed net).
3. **Detect** per domain:
   - **Agreement** — ≥2 providers contribute and all non-zero nets share a sign.
   - **Conflict** — both positive and negative providers exist.
   - **Missing evidence** — a domain not covered by every provider.
4. **Merge** — one `FusionEvidence` per domain (net magnitude + modules).
5. **Prioritise** — rank domains by `|net| (+ agreement boost)`, ties broken by
   domain name for determinism.
6. **Confidence** — average provider confidence, `+` agreement bonus, `−` conflict
   penalty, clamped to 0–100 and banded via `FusionRule`.

### Single-provider mode

With only the Thai provider registered, exactly one observation is produced:
`singleProviderMode == true`, no agreements/conflicts, no missing evidence, and
the fused confidence **passes through** the provider's confidence unchanged. The
result shape is identical to multi-provider fusion, so consumers need no special
case.

---

## 4. Conversation now consumes the Fusion Runtime

The Mirror Conversation (V16) previously consumed the Global `ReasoningRuntime`.
As of P2 `ConversationFlow` takes a **`FusionRuntime`** (default: a fusion runtime
over a Global Runtime hosting only the Thai provider). It builds a `FusionContext`
from the selected question, fuses, and reads its rich V12 result from the **Thai
observation** (`primary.response.raw`). `ConversationAnswer` now carries the
`FusionResult` and the primary `FusionObservation`; its `confidence` is the fused
value (equal to Thai's in single-provider mode). Behaviour is unchanged — the V16
suite still passes.

---

## 5. Tests

`test/validation/fusion_runtime_p2/fusion_runtime_test.dart` (deterministic stub
providers for the multi-provider cases):

- **Single-provider mode** — Thai only ⇒ `singleProviderMode`, no
  agreement/conflict, confidence passthrough.
- **Agreement detection** — same-sign domains across two providers agree and lift
  confidence.
- **Conflict detection** — opposite-sign domains conflict and lower confidence.
- **Priority ordering** — domains rank by strength with the agreement boost;
  ranks are contiguous and ordered.
- **Evidence merge & missing** — per-domain magnitudes sum across providers;
  partial coverage is flagged missing.
- **Confidence banding** — fused value bands via `FusionRule`.

The V16 conversation and V17 global-runtime suites continue to pass.

---

## 6. Scope & future

- **No deploy** — architecture only.
- **Future providers** (Western, BaZi, MBTI, EQ, Big Five, Compatibility) are
  fused automatically once registered — no fusion change required.
- **Future AI** consumes the Fusion Runtime's unified result, not individual
  providers.

---

## Related documents

- [`GLOBAL_REASONING_RUNTIME_V17.md`](GLOBAL_REASONING_RUNTIME_V17.md) — the layer
  fusion sits above.
- [`THAI_MIRROR_CONVERSATION_V16.md`](THAI_MIRROR_CONVERSATION_V16.md) — the
  consumer migrated to fusion.
- [`ARCHITECTURE.md`](ARCHITECTURE.md) — Global/Fusion runtime sections.
- [`DECISION_LOG.md`](DECISION_LOG.md) D-029 — the decision record.
