# KnowMe Platform P3 — Global Mirror Experience

**Status:** CURRENT (implementation record · first product experience)
**Audience:** Developers, validation, AI agents.
**Last updated:** June 2026
**Builds on:** P2 Cross-System Fusion Runtime
([`GLOBAL_FUSION_RUNTIME_P2.md`](GLOBAL_FUSION_RUNTIME_P2.md)) — consumed via the
`FusionRuntime` only.

---

## 1. Goal

P3 is the **first real product experience** powered by the completed Runtime
Platform. It is a **UX milestone, not an engine milestone**: no new reasoning
engine, no new runtime, no new provider, no new fusion layer. Everything the
experience shows is derived from the **Fusion Runtime**.

```
Home
  ↓
Your Current Life
  ↓
Prediction
  ↓
Decision
  ↓
Ask More
  ↓
Conversation
  ↓
Reflection
```

Guiding principles:

- **Explain life, not astrology.** No astrology terminology, no planet names, no
  engine names anywhere on the surface.
- **Emotion first, evidence second.** The card surface is warm and human; the
  numbers (signal strength, clarity) live behind an expandable "What this is
  based on" section.
- **Conversation starts from cards**, never an empty chat box.

---

## 2. Architecture — `lib/features/mirror_experience/`

The experience consumes the **`FusionRuntime` only**. It never imports a provider
or a system runtime in its reasoning path. The single place that names a provider
is the composition root (`MirrorExperienceRuntime`), and even there only to build
the `FusionRuntime` that is then handed down.

| Type | Role |
| --- | --- |
| `MirrorExperienceInput` | System-agnostic input: birth date + optional `asOf`. No astrology types. |
| `MirrorExperienceService` | The **only** fusion consumer. Turns a `FusionResult` into plain-language view models (`currentLife`, `prediction`, `decision`, `reflection`). |
| `mirror_view_models.dart` | `MirrorInsight`, `MirrorPrediction`, `MirrorDecision`, `MirrorReflectionData`, `MirrorLifeArea`, `MirrorClarity`, plus `MirrorTone`/`MirrorLean`. |
| `MirrorCopy` | All surface copy — life-area titles, tone/clarity phrasing, headlines. Enforces "explain life, not astrology". |
| `MirrorExperienceRuntime` | Composition root: the one `FusionRuntime` constant (Thai provider today). |
| `MirrorExperienceEntryService` | Loads the chart anchor (birth date) from the profile. Reads data only — no reasoning. |
| `MirrorExperienceEntryPage` | Production entry: resolve profile → render `MirrorHome`, or prompt to complete the profile. |
| `MirrorExperienceRoutes` | Additive `/mirror-experience` route plugged into the app route chain. |

UI (`lib/features/mirror_experience/ui/`):

| Widget | Role |
| --- | --- |
| `MirrorHome` | Warm entry surface + "Begin" CTA into the journey. |
| `MirrorJourney` | The guided five-stage flow; owns one `MirrorExperienceService`. |
| `MirrorInsightCard` | "Where your life stands now". |
| `MirrorPredictionCard` | "The season ahead". |
| `MirrorDecisionCard` | A gentle lean (move / prepare / wait) — never a command. |
| `MirrorQuestionCard` | Tappable prompt card (topics, questions, suggestions). |
| `MirrorConversationEntry` | Card-driven conversation over the V16 flow + Fusion Runtime. |
| `MirrorReflection` | Closing reflection; ends on the user. |
| `MirrorTheme` / `mirror_cards_common.dart` | Shared visual language (tone colours, chips, clarity pill, expandable evidence). |

---

## 3. How a read is built (Fusion → life)

`MirrorExperienceService` calls `FusionRuntime.fuse` with a `FusionContext` for
the relevant capability (`evaluate`, `predict`, `decide`) and reads only the
**cross-system structured fields** of the `FusionResult`:

1. **Life areas** — `priorities` (ranked domains) joined with `mergedEvidence`
   (signed net per domain). Each becomes a `MirrorLifeArea` with a plain-language
   title and a **tone**: `strong` (net > 0), `tender` (net < 0), `steady` (0).
2. **Clarity** — `confidence.value` + band → "still taking shape / coming into
   focus / clear".
3. **Decision lean** — derived from the focus area's tone and the fused
   confidence: tender ⇒ *wait*; clear & supportive ⇒ *move*; otherwise *prepare*.

Because it reads only `priorities`, `mergedEvidence` and `confidence`, the
experience touches **no Thai types** and would render any future provider's
contribution unchanged.

### Conversation

`MirrorConversationEntry` drives the V16 `ConversationFlow` (which already
consumes the `FusionRuntime`). The user opens a **topic card**, taps a predefined
**question card**, the runtime answers, and the flow offers **suggestion cards**.
The answer is framed as life (lead area tone + clarity), never as stance jargon.
No free text, no parser, no AI.

---

## 4. Wiring & entry points

- **Production:** additive route `/mirror-experience` →
  `MirrorExperienceEntryPage`. The AuthGate → ProfileGate → HomePage flow is
  **unchanged**; the route is plugged into the existing `onGenerateRoute` chain.
- **Preview/QA:** `lib/main_mirror_experience.dart` boots straight into
  `MirrorHome` with a sample chart (no Firebase/auth) for screenshots and the web
  release bundle.

---

## 5. Tests

`test/validation/mirror_experience_p3/`:

- **Service (fusion-only)** — current-life / prediction / decision / reflection
  reads are bounded (≤4 areas, clarity 0–100), **deterministic** for the same
  input, the lean is consistent with focus tone + clarity, and **all surface copy
  is free of astrology/engine vocabulary** (planet names, "astrology", "runtime",
  "fusion", "thai", etc.).
- **Widget smoke** — `MirrorHome` renders the CTA; `MirrorJourney` walks every
  stage (Current Life → Prediction → Decision → Ask More → Conversation →
  Reflection), including opening a topic and asking a question through fusion.

The V16, V17 and P2 suites continue to pass.

---

## 6. Scope & future

- **Deploy:** Yes — the first platform-level production release.
- **Future providers** (Western, BaZi, MBTI, EQ, Big Five, Compatibility) surface
  automatically once registered; the experience code does not change.
- **Future AI** can plug into the same card-driven surface via the Fusion
  Runtime, never the providers.

---

## Related documents

- [`GLOBAL_FUSION_RUNTIME_P2.md`](GLOBAL_FUSION_RUNTIME_P2.md) — the layer the
  experience consumes.
- [`THAI_MIRROR_CONVERSATION_V16.md`](THAI_MIRROR_CONVERSATION_V16.md) — the
  conversation flow the experience drives.
- [`ARCHITECTURE.md`](ARCHITECTURE.md) — Global Mirror Experience section.
- [`DECISION_LOG.md`](DECISION_LOG.md) D-030 — the decision record.
