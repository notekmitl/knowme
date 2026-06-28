# KnowMe Architecture

**Purpose:** Explain how the product stack fits together.  
**Audience:** Developers and AI agents working on KnowMe.  
**Last updated:** June 2026

For philosophy and product rules, see [`KNOWME_MASTER_CONTEXT.md`](KNOWME_MASTER_CONTEXT.md).

---

## Stack Overview

```
User (Firestore profile + test results)
        ↓
Lens Systems
        ↓
Mirror (MV1 + MV2 Promotion)
        ↓
GF1 — Global Fusion Foundation
        ↓
GF2 — Global Fusion Recovery
        ↓
Human Model
        ↓
Human Pattern
        ↓
Narrative Runtime
        ↓
Home Experience (+ Fusion / Result pages)
```

Each layer consumes the output of the layer above. Downstream layers do not bypass upstream contracts.

---

## Layer 1 — User & Data

**What enters the system:**

| Input | Source | Path |
|-------|--------|------|
| Birth profile | Profile setup / edit | `users/{uid}/profile/main` |
| MBTI / EQ / Big Five results | Test flows | `users/{uid}/results/*` |
| Western natal chart | Astrology generation | `users/{uid}/astrology/western_natal` |
| BaZi chart | Backend + Firestore | `users/{uid}/astrology/chinese_bazi` |

**App entry:** `AuthGate` → `ProfileGate` → `HomePage`  
**Reference:** `lib/presentation/pages/auth/`, `lib/presentation/pages/profile/`

---

## Layer 2 — Lens Systems

Lens systems convert raw user data into **domain-specific signals and snapshots**. Each lens is independently usable; none is authoritative alone.

| Lens | Package | Output |
|------|---------|--------|
| Thai Astrology | `lib/features/astrology/thai/` | Theme bundles, Thai mirror sections, full consumer report (see sub-stack below) |
| Western Natal | Astrology services + providers | Chart model for fusion |
| Chinese BaZi | `lib/features/bazi/` | Four pillars, element balance |
| MBTI | `lib/features/tests/mbti/` | Personality type + dimensions |
| EQ | `lib/features/tests/eq/` | 6 module scores |
| Big Five | `lib/features/tests/big_five/` | Five factor scores |
| Personality Mirror | `lib/features/personality_mirror/` | Cross-personality-lens coverage |

**Loader:** `PersonalityLensLoader` aggregates available personality snapshots for a user.

**Astrology-specific fusion (within lens tier):** `lib/features/astrology/fusion/` — Astrology Fusion V6 for multi-system astrology reflection (separate from global cross-mirror fusion).

### Thai Astrology Consumer Report (self-contained sub-stack)

The Thai lens ships an end-to-end **consumer report** that runs independently of the
global narrative pipeline above. It has its own deterministic pipeline, presentation
layer, and QA harness. Full detail: [`EXECUTIVE_SUMMARY.md`](EXECUTIVE_SUMMARY.md).

```
ThaiBirthData (Firestore profile or QA harness)
  → ThaiFoundationEngine            (lagna, Myanmar Seven, Mahabhuta)
  → ThaiMirrorProfileEnrichment     (fallback lens keys)
  → Theme scoring (resolver → engine → presenter)
  → ThaiMirrorAssembler             (V1 "Truth Lock": structural sections/evidence, no copy)
  → ThaiMirrorNarrativeGenerator    (internal section summaries)
  → LifePeriodEngine.fromBirthDate  (V8: traditional 8-planet life-period sequence)
  → ThaiMirrorConsumerPresenter     (all user-facing Thai copy)
  → ThaiMirrorResultPage            (article-style consumer page)
```

| Concern | Owner |
|---------|-------|
| Birth → profile foundation | `lib/features/astrology/thai/foundation/` |
| Life-period engine (V8) | `lib/features/astrology/thai/core/life_period/` |
| Pipeline orchestration | `lib/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart` |
| Structural assembly | `lib/features/astrology/thai/mirror/` |
| Consumer copy + timeline | `lib/features/astrology/thai/mirror/presentation/` (copy/, timeline/) |
| QA harness + preview route | `lib/features/astrology/thai/qa/harness/`, `lib/core/web/` |

A parallel **V2 structural stack** (`foundation/v2/` → `signal/` → `interpretation/`
→ `theme_v2/` → `mirror_v2/` → `fusion_v2/`) exists for validation/fusion work and
is **not** wired into the consumer pipeline today.

The Thai lens also exposes a **deterministic reasoning stack** built additively on
the life-period engine: Timeline Intelligence (V9) → Prediction (V10) → Decision
(V11) → Question (V12) → **Thai Reasoning Runtime (V13)**, the single Thai entry
point, with Scenario Simulation (V14) and Transit (V15) layered on top, and the
deterministic **Mirror Conversation** (V16) as the first guided experience. See
`THAI_REASONING_RUNTIME_V13.md` and `THAI_MIRROR_CONVERSATION_V16.md`.

### Global Reasoning Runtime (V17 — cross-system foundation)

**Owner:** `lib/features/runtime/`

The Thai Reasoning Runtime (V13) is now the **reference implementation** for a
system-agnostic runtime architecture. V17 generalizes it **without merging or
rewriting Thai** — Thai remains the first and only implementation, wrapped by an
adapter.

```
ReasoningRuntime  (discovers providers; no hard-coded system dependency)
        ↓ dispatch by ReasoningModule + ReasoningCapability
ReasoningProvider  →  ThaiRuntimeAdapter  →  Thai Reasoning Runtime (V13, frozen)
        ↓
ReasoningResponse  (module-tagged ReasoningEvidence + ReasoningTrace + confidence + raw)
```

| Concern | Owner |
|---------|-------|
| Contracts (`ReasoningProvider`/`Request`/`Response`/`Evidence`/`Trace`/`Module`/`Capability`) | `lib/features/runtime/` |
| Dispatch + capability detection + evidence aggregation | `lib/features/runtime/reasoning_runtime.dart` |
| Provider discovery (no system import) | `lib/features/runtime/reasoning_provider_registry.dart` |
| Thai provider (the only V17 implementation) | `lib/features/runtime/adapters/thai_runtime_adapter.dart` |

Future systems (Western, BaZi, MBTI, Big Five, EQ, Compatibility) add their own
`ReasoningProvider` and register it — the runtime needs no change. See
`GLOBAL_REASONING_RUNTIME_V17.md`.

### Cross-System Fusion Runtime (P2)

**Owner:** `lib/features/runtime/fusion/`

The Fusion Runtime sits **above** the Global Runtime (it composes, never replaces
it). It fans one capability out across every supporting provider, then detects
agreement / conflict / missing evidence / priority and merges everything into one
`FusionResult`.

```
Global Runtime
        ↓ fan out a capability across providers
Fusion Runtime  (agreement · conflict · missing · priority · merged evidence · fused confidence)
        ↓
Conversation  →  Future AI
```

With only the Thai provider registered, fusion runs in **single-provider mode**:
one observation, no agreement/conflict, confidence passed through — same result
shape as multi-provider fusion. The Mirror Conversation (V16) now consumes the
**`FusionRuntime`** (which hosts the Global Runtime with the Thai provider) rather
than the Global Runtime directly. See `GLOBAL_FUSION_RUNTIME_P2.md`.

### Global Mirror Experience (P3 — first product experience)

**Owner:** `lib/features/mirror_experience/`

The platform's first real product surface — a **UX milestone, not an engine**. It
consumes the **`FusionRuntime` only** (never a provider, never a system runtime):
`MirrorExperienceService` reads the cross-system fields of a `FusionResult`
(`priorities`, `mergedEvidence`, `confidence`) and turns them into plain-language
view models, so it touches no Thai types.

```
MirrorHome
        ↓ Begin
MirrorJourney  (Current Life → Prediction → Decision → Ask More → Conversation → Reflection)
        ↓ each stage
MirrorExperienceService → FusionRuntime.fuse(evaluate | predict | decide)
```

Principles: **explain life, not astrology** (no planet/engine terminology on the
surface), **emotion first, evidence second** (numbers behind an expandable
section), and **conversation starts from cards** (driving the V16 flow over
fusion). Wired additively at `/mirror-experience`; the production AuthGate →
ProfileGate → HomePage boot flow is unchanged. A standalone preview boots from
`lib/main_mirror_experience.dart`. See `GLOBAL_MIRROR_EXPERIENCE_P3.md`.

### Product Validation (Phase A — measurement only)

**Owner:** `lib/features/product_validation/`

Instrumentation that **observes** the P3 experience to answer "do users WOW, and
where do they stop?" — no engine/provider/AI, no UI redesign, no runtime change.
The P3 widgets call `ProductValidation.tracker.<event>()` at the measurable
moments; a deterministic `ProductInsightsEngine` turns sessions into per-session
`ProductMetrics`, an engagement `ProductFunnel` and `ProductInsights` (WOW /
curiosity / engagement / drop-off).

```
P3 experience  → ProductValidation.tracker (additive track calls)
                         ↓ in-memory recorder
ProductInsightsEngine → funnel + metrics + insights
                         ↓
Internal dashboard  (/internal/product-validation — not linked from any user surface)
```

Events are in-memory (read by the internal dashboard in-session); a persistent
sink can be added behind the tracker without changing callers. See
`PRODUCT_VALIDATION.md`.

---

## Layer 3 — Mirror

**Owner:** `lib/features/mirror_v3/`

**Role:** Normalize lens signals into a **`KnowMeMirrorSnapshot`** — agreements, tensions, reinforcements, blind spots, evidence lineage.

```
Lens signals (Thai, BaZi, MBTI, …)
        ↓
KnowMeMirrorEngineInput
        ↓
KnowMeMirrorSnapshotBuilder (MV1)
        ↓
Mirror Promotion Engine (MV2) — optional, additive
        ↓
KnowMeMirrorSnapshot (+ promotedFindings)
```

**Mirror roles in global fusion:**

- `GlobalFusionMirrorRoles.astrology` — Thai + BaZi merged signals
- `GlobalFusionMirrorRoles.personality` — MBTI / Big Five / EQ lenses

**Adapters:** `knowme_mirror_astrology_adapter.dart`, `knowme_mirror_bazi_adapter.dart`  
**Integration:** `lib/features/runtime_integration/pipeline/runtime_mirror_input_builder.dart`

**Freeze:** MV1 core gates unchanged when recovery disabled.

---

## Layer 4 — GF1 (Global Fusion Foundation)

**Owner:** `lib/features/global_fusion/foundation/`

**Role:** Aggregate multiple mirror snapshots into a **`GlobalFusionSnapshot`** — cross-mirror agreements, tensions, normalized themes, confidence.

```
GlobalFusionInput (mirror refs)
        ↓
GlobalFusionFoundationBuilder
        ↓
GlobalFusionSnapshot (GF1)
```

**Freeze:** GF1 v1.0.0 — conditional freeze. Does not consume MV2 promoted findings directly for foundation build.

---

## Layer 5 — GF2 (Global Fusion Recovery)

**Owner:** `lib/features/global_fusion/v2/`

**Role:** Recover findings filtered by GF1/MV1 gates without weakening core gates. Produces a **composed fusion snapshot** for downstream layers.

```
GF1 foundationSnapshot
        ↓
GF2 Recovery Engines (R001–R004)
        ↓
GlobalFusionRecoveryComposer
        ↓
GlobalFusionComposedSnapshot.fusionSnapshot
```

**Feature flag:** `GlobalFusionRecoveryConfig.enabled`  
**Production default for narrative pipeline:** enabled (see `UserRuntimePipelineService`)

**Validated:** 1000-human synthetic gate — `docs/GF2_PRODUCTION_IMPLEMENTATION_V1.md`

---

## Layer 6 — Human Model

**Owner:** `lib/features/human_model/`

**Role:** Map fusion snapshot → structured human model with dimensions and source patterns for activation.

```
HumanModelInput(fusionSnapshot)
        ↓
HumanModelFoundationBuilder
        ↓
HumanModelSnapshot
```

Human Model consumes **fusion output only** — no direct mirror bypass.

---

## Layer 7 — Human Pattern

**Owner:** `lib/features/human_pattern/`

**Role:** Activate entries from the pattern registry based on human model sources.

```
HumanPatternInput(humanModelSnapshot)
        ↓
HumanPatternSnapshotBuilder
        ↓
HumanPatternSnapshot (activations)
```

**Recovery V2:** Fixed Category B/E activation resolution in `PatternActivationEngine` — see `docs/HUMAN_PATTERN_ACTIVATION_RECOVERY_V2.md`.

If activations are empty, narrative cannot generate.

---

## Layer 8 — Narrative Runtime

**Owner:** `lib/features/narrative_runtime/`

**Role:** Generate deterministic **`NarrativeResult`** paragraphs from pattern activations.

```
HumanPatternSnapshot
        ↓
NarrativeRuntimeService.generate
        ↓
NarrativeResult (sections: identity, relationship, decision, growth, …)
```

**Intelligence stack (validated synthetic):**

| Version | Focus |
|---------|-------|
| V2 | Selection ordering |
| V3 | Evidence-aware selection scoring |
| V4 | Plan topology (structural convergence) |
| V5 | Evidence lineage branching (copy divergence) |

**Loaders:**

- `NarrativeRuntimeLoader.loadForUser(uid)` — production Home path
- `UserRuntimePipelineService.loadNarrativeForUser(uid)` — full Firestore → pipeline

**Requires:** Birth profile + at least one personality lens + non-empty pattern activations.

---

## Layer 9 — Home Experience

**Owner:** `lib/features/home_cohesion/`

**Role:** Present the emotional product surface — hero, signature themes, insight cards, profile strip, psychology test cards, funnel recovery UI.

```
HomeV2Loader (Firestore bundle)
        +
NarrativeRuntimeLoader (optional narrative overlay)
        ↓
HomeV3Assembler
        ↓
HomeScreenV3Data → HomeScreenV3 widgets
```

**Funnel Recovery V2 additions:**

- Profile completion bar (`HomeProfileCompletion`)
- Unlock hero + MBTI CTA
- Narrative preview card
- Recovery banner
- Funnel telemetry hooks

**Related presentation (outside home_cohesion):**

- `lib/presentation/pages/bazi/bazi_result_page.dart`
- `lib/features/tests/fusion/` — Fusion result page
- `lib/features/astrology/fusion/presentation/` — Astrology fusion entry

---

## Major Runtime Paths

### Path A — Production Home load

```
HomePage.initState
  → HomeV3Loader.load(uid)
  → HomeV2Loader.loadBundle(uid)
  → NarrativeRuntimeLoader.loadForUser(uid)
  → HomeV3Assembler.fromSources
  → HomeScreenV3 render
```

### Path B — Full user narrative pipeline

```
UserRuntimePipelineService.loadNarrativeForUser(uid)
  → UserProfileBirthLoader + PersonalityLensLoader
  → RuntimeMirrorInputBuilder
  → Dual KnowMeMirrorSnapshotBuilder (astrology + personality)
  → GlobalFusionFoundationBuilder + GlobalFusionRuntimeBuilder.composeRecovery
  → HumanModelFoundationBuilder + HumanPatternSnapshotBuilder
  → NarrativeRuntimeService.generate
```

### Path C — MBTI completion → narrative preview

```
MbtiMiniTestPage.finish
  → FunnelTelemetry (mbti_complete)
  → MbtiNarrativePreviewPage
  → NarrativeRuntimeLoader.loadForUser
  → FunnelTelemetry (narrative_preview_seen)
  → Return to Home (reload)
```

### Path D — Validation replay (synthetic)

```
test/validation/synthetic_population_v3/pipeline/synthetic_human_pipeline_runner_v3.dart
  → Full stack replay on factory-generated profiles
  → JSON output in test/validation/synthetic_population_v3/output/
```

---

## What This Document Does Not Cover

- UI polish specs for Fusion V1 (frozen — see [`FUSION_RESULT_V1_SPEC.md`](FUSION_RESULT_V1_SPEC.md))
- Thai astrology foundation engine internals (see `docs/THAI_FOUNDATION_ENGINE_V1_1_NOTES.md`)
- Scoring algorithms for individual tests (see [`MBTI_ARCHITECTURE.md`](MBTI_ARCHITECTURE.md) and respective `lib/features/tests/` packages)
- Firestore session semantics (see [`FIRESTORE_SCHEMA.md`](FIRESTORE_SCHEMA.md))
- Backend BaZi API (`backend/` — separate from Flutter architecture)

---

## Code Organization

**Preferred layout under `lib/`:**

```
lib/
  core/           # Shared app logic (i18n, theme, constants) — no feature business logic
  data/           # Shared static data (question banks, test_modules.dart)
  features/       # Feature-owned logic (preferred architecture)
  presentation/   # Legacy/general UI — coexistence expected
  services/       # App-wide services (profile, question_service)
```

### Feature pattern

```
lib/features/<feature>/
  domain/
  application/
  data/
  presentation/
  widgets/
```

**Test features:** `lib/features/tests/mbti/`, `mbti_cognitive/`, `mbti_summary/`, etc.

**Rules:**

- Feature owns its logic — avoid cross-feature leakage
- Small focused files; deterministic helpers; presentation isolation
- Avoid 1000-line god files
- Prefer **additive** new folders over rewriting existing systems

### Package ownership (runtime)

| Concern | Owns |
|---------|------|
| Birth profile CRUD | `lib/services/profile_service.dart`, profile pages |
| Test sessions + Firestore writes | `lib/features/tests/*` |
| Mirror contracts + engines | `lib/features/mirror_v3/` |
| Cross-mirror fusion | `lib/features/global_fusion/` |
| Pattern activation | `lib/features/human_pattern/` |
| Narrative generation | `lib/features/narrative_runtime/` |
| Firestore → pipeline adapters | `lib/features/runtime_integration/` |
| Home presentation | `lib/features/home_cohesion/` |
| Funnel analytics | `lib/features/funnel_telemetry/` |
| Validation harnesses | `test/validation/` |

### Hybrid architecture note

Legacy `UniversalTestPage` + feature-specific test architecture coexist intentionally. Do not aggressively unify — see [`CURRENT_STATUS.md`](CURRENT_STATUS.md) technical debt.
