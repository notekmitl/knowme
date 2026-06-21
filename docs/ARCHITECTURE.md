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
| Thai Astrology | `lib/features/astrology/thai/` | Theme bundles, Thai mirror sections |
| Western Natal | Astrology services + providers | Chart model for fusion |
| Chinese BaZi | `lib/features/bazi/` | Four pillars, element balance |
| MBTI | `lib/features/tests/mbti/` | Personality type + dimensions |
| EQ | `lib/features/tests/eq/` | 6 module scores |
| Big Five | `lib/features/tests/big_five/` | Five factor scores |
| Personality Mirror | `lib/features/personality_mirror/` | Cross-personality-lens coverage |

**Loader:** `PersonalityLensLoader` aggregates available personality snapshots for a user.

**Astrology-specific fusion (within lens tier):** `lib/features/astrology/fusion/` — Astrology Fusion V6 for multi-system astrology reflection (separate from global cross-mirror fusion).

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

## Package Ownership Map

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

---

## What This Document Does Not Cover

- UI polish specs for Fusion V1 (frozen — see master context §50.2)
- Thai astrology foundation engine internals (see `docs/THAI_FOUNDATION_ENGINE_V1_1_NOTES.md`)
- Scoring algorithms for individual tests (see respective `lib/features/tests/` packages)
- Backend BaZi API (`backend/` — separate from Flutter architecture)
