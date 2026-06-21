# KnowMe Master Context

**Canonical project reference.**  
**Last updated:** June 2026  
**Supersedes:** `KNOWME MASTER CONTEXT vNEXT (FULL STRUCTURED v2).txt` (repo root — same authority, this file is the maintained `/docs/` entry point)

---

## 1. Product Vision

**KnowMe** is a personalized astrology-inspired self-understanding platform.

**Product goal:** Help users understand themselves more deeply across personality, thinking, behavior, life tendencies, and growth — by combining multiple lenses into progressively deeper insight.

**End state mental model:** *Digital mirror for self-understanding.*

KnowMe is **not**:

- a generic horoscope app
- a quiz app
- an MBTI clone
- a clinical psychology dashboard

**Hybrid strategy (B front door, A core):**

| Surface | Experience |
|---------|------------|
| Outside | Feels like astrology that understands you |
| Inside | Uses structured tests (MBTI, EQ, Big Five, etc.) to personalize reflection |

**Tagline mental model:** *ดวงที่เข้าใจตัวคุณมากขึ้น* — not horoscope alone, not psychology dashboard alone.

---

## 2. Product Philosophy

### Insight > Label

Labels (ESTJ, sun sign, etc.) are entry points. Value is reflective insight: how someone tends to think, feel, decide, and respond.

### Self-understanding > Entertainment

Tone: grounded, reflective, emotionally resonant, psychologically plausible.  
Avoid: fate claims, destiny language, overclaiming, deterministic identity.

### Deterministic before AI

Current strategy: **deterministic engines first**, AI enhancement later.

- Predictable, debuggable, explainable, stable UX
- No LLM dependency in core astrology, MBTI summary fusion, or narrative runtime today

### Progressive understanding

Low friction first, depth later:

```
Astrology → immediate emotional entry
MBTI → quick personality orientation
EQ / Big Five → deeper personalization
Fusion + Narrative → integrated self mirror
```

### Readability > technical accuracy dump

Output should feel human and personally relevant — not an engineering report or taxonomy dump.

### Product maturity principle

Prioritize **believable reflection**, **emotional usefulness**, **product cohesion**, and **progressive personalization** over scientific over-complexity, excessive psychometric detail, feature quantity, or endless UI polishing.

**Rule before polishing:** *Does this meaningfully improve user understanding or product value?* If no, move forward.

---

## 3. Mental Model

### Multiple mirrors, not truth hierarchy

Each lens reflects a different aspect of self. No single lens is "the truth."

| Lens | Role | Mental model |
|------|------|--------------|
| Astrology (Thai + Western + BaZi) | Emotional front door | "Your first mirror" |
| MBTI | Personality tendencies | "How I tend to think and approach life" |
| Cognitive (MBTI cognitive) | Processing style | "How my mind tends to work" |
| EQ | Emotional handling | "How I handle emotions and relationships" |
| Big Five | Trait dimensions | "Stable trait tendencies" |
| Fusion | Cross-lens reflection | "What multiple lenses agree on" |
| Narrative | Human-readable synthesis | "What KnowMe understands about me" |

### Progressive profile depth

Users discover more of their profile as they complete lenses. Narrative is the deepest layer — requires sufficient lens coverage and pipeline activation.

---

## 4. User Journey

### Production app flow (implemented)

```
App launch
  → AuthGate (Firebase Auth)
  → ProfileGate (Firestore users/{uid}/profile/main)
      → ProfileSetupPage (if no profile)
      → HomePage (if profile exists)
```

**Reference:** `lib/main.dart`, `lib/presentation/pages/auth/auth_gate.dart`, `lib/presentation/pages/profile/profile_gate.dart`

### Intended product journey

```
1. Sign up / log in
2. Complete birth profile (name, date, time, place)
3. Receive astrology value (Thai themes, Western natal, BaZi)
4. Explore Home — emotional identity + astrology reflection
5. Complete personality tests (MBTI mini → optional deeper tests)
6. Unlock deeper profile progress + narrative preview
7. Explore Fusion / full insight when enough lenses exist
8. Continue deepening (EQ modules, Big Five, extended MBTI)
```

### Funnel reality (Real User Runtime Validation V1, 38 Firestore users)

| Stage | Rate |
|-------|-----:|
| Profile created | 81.6% |
| Astrology input | 81.6% |
| MBTI saved | **2.6%** |
| Big Five saved | **0%** |
| EQ (any module) | 5.3% |
| Narrative reached | **2.6%** |

**Dominant drop-off:** After astrology, before any personality test.  
**Recovery direction:** Home unlock CTA, profile completion bar, MBTI mini → instant narrative preview (Funnel Recovery V2 — implemented in `lib/features/home_cohesion/`).

---

## 5. Major Subsystems

### Lens systems (data acquisition)

| System | Location | Role |
|--------|----------|------|
| Thai Astrology V2 | `lib/features/astrology/thai/` | Foundation → theme → mirror pipeline |
| Western Natal | `lib/features/astrology/` + Firestore `astrology/western_natal` | Natal chart storage + fusion input |
| Chinese BaZi V1 | `lib/features/bazi/`, `lib/services/bazi_firestore_service.dart` | Four pillars + element balance |
| MBTI Progressive | `lib/features/tests/mbti/` | 16 → 40 → 80 question flow |
| MBTI Cognitive | `lib/features/tests/mbti_cognitive/` | Cognitive function layer |
| MBTI Summary Fusion | `lib/features/tests/mbti_summary/` | Deterministic MBTI synthesis |
| EQ | `lib/features/tests/eq/` | 6 mini modules |
| Big Five | `lib/features/tests/big_five/` | Progressive 10 → 44 → 80 |
| Astrology Fusion V6 | `lib/features/astrology/fusion/` | Multi-lens astrology fusion UI |
| Personality Mirror | `lib/features/personality_mirror/` | Personality lens aggregation |
| Cross-lens Fusion (user-facing) | `lib/features/tests/fusion/` | Fusion result presentation |

### Mirror Platform V3

**Location:** `lib/features/mirror_v3/`  
**Role:** Normalize lens signals into `KnowMeMirrorSnapshot` with agreements, tensions, reinforcements, evidence lineage.

Engines: Agreement, Tension, Reinforcement, Blind Spot.  
Promotion layer (MV2): `lib/features/mirror_v3/promotion/`

### Global Fusion

| Layer | Location | Version | Role |
|-------|----------|---------|------|
| GF1 Foundation | `lib/features/global_fusion/foundation/` | v1.0.0 | Cross-mirror consensus architecture |
| GF2 Recovery | `lib/features/global_fusion/v2/` | v2 | MV2 promotion + supplemental recovery (R001–R004) |

**Production flag:** `GlobalFusionRecoveryConfig` in `lib/features/global_fusion/v2/config/global_fusion_recovery_config.dart`

### Human Model

**Location:** `lib/features/human_model/`  
**Role:** Map fusion snapshot → structured human model dimensions for pattern activation.

### Human Pattern

**Location:** `lib/features/human_pattern/`  
**Role:** Activate pattern registry entries from human model. Recovery V2 fixed Category B/E activation rules.

### Narrative Runtime

**Location:** `lib/features/narrative_runtime/`  
**Role:** Generate deterministic narrative paragraphs from `HumanPatternSnapshot`.

Intelligence layers (validated on 1000-human synthetic population):

- V2 selection → V3 evidence-aware selection → V4 plan topology → V5 evidence branching

### Home Experience

**Location:** `lib/features/home_cohesion/`  
**Role:** Home V3.8 emotional surface — hero, signature, insight cards, profile strip, psychology tests, funnel recovery UI.

**Loader:** `HomeV3Loader` → `HomeV2Loader` + `NarrativeRuntimeLoader` → `HomeV3Assembler`

### Runtime Integration

**Location:** `lib/features/runtime_integration/`  
**Role:** Adapters connecting Firestore birth data, Thai themes, personality lenses, and mirror input builders.

**Production pipeline entry:** `UserRuntimePipelineService` in `lib/features/narrative_runtime/integration/`

### Funnel Telemetry

**Location:** `lib/features/funnel_telemetry/`  
**Role:** Firestore funnel events (`home_view`, `mbti_start`, `mbti_complete`, `narrative_preview_seen`, etc.)

### Exploration / Discovery

**Location:** `lib/features/exploration_overview/`  
**Role:** Discovery grouping and exploration profile contracts for Home sources.

---

## 6. Frozen Systems

Changes limited to blocker fixes, serious usability issues, analytics-driven improvements, and production incidents. Avoid architecture rewrites.

| System | Status | Notes |
|--------|--------|-------|
| Fusion Result V1 presentation | **Frozen v1** | Polish passes 1–4 complete. See master context §50.2 |
| MBTI Summary V1.3 | **Stable / frozen-ish** | Deterministic synthesis only |
| EQ MVP | **Usable+ / frozen-ish** | Maintenance mode |
| Thai Astrology V2 Core | **Conditional freeze v0.1.0** | Production structural ready |
| Thai Fusion V2 | **Conditional freeze v0.1.0** | Lineage, agreement, coverage, confidence engines validated |
| Western Natal V1 | **Temporary freeze** | E2E verified June 2026 |
| Chinese BaZi V1 | **Temporary freeze** | Backend + Flutter verified |
| Astrology Fusion V6 | **Temporary freeze candidate** | Narrative pass complete |
| MV1 Mirror Engine | **Conditional freeze v0.1.0** | Core gates unchanged when recovery disabled |
| GF1 Foundation | **Conditional freeze v1.0.0** | Consumes mirror snapshots |

**Maintenance-only rule:** Do not reopen frozen architecture without strong reason.

---

## 7. Active Systems

| System | Status | Evidence |
|--------|--------|----------|
| Home V3 + Funnel Recovery V2 | **Active / implemented** | `lib/features/home_cohesion/`, `lib/features/funnel_telemetry/` |
| GF2 Production | **Implemented + validated** | `docs/GF2_PRODUCTION_IMPLEMENTATION_V1.md` |
| Human Pattern Activation Recovery V2 | **Complete** | `docs/HUMAN_PATTERN_ACTIVATION_RECOVERY_V2.md` |
| Narrative V5 (Evidence Branching) | **Complete** | `docs/NARRATIVE_EVIDENCE_BRANCHING_V5.md` — 1000/1000 unique on synthetic |
| Real-user funnel conversion | **Active priority** | `docs/REAL_USER_RUNTIME_VALIDATION_V1.md`, `docs/PRODUCTION_FUNNEL_RECOVERY_V1.md` |
| Chinese Zodiac Personality Expansion | **Approved additive program** | Low blast radius — content library, not BaZi core rewrite |
| Big Five | **Future MVP** | Implemented in code; not primary production focus |

**Not active (avoid scope creep):**

- Astrology fusion redesign
- Personality mirror redesign
- MBTI/EQ expansion beyond maintenance
- AI narrative layer (future program — depends on Mirror + GF + validation)
- Thai astrology architecture rewrite

---

## 8. Current Architecture

### End-to-end runtime pipeline (production)

```
Firestore profile + lens results
        ↓
PersonalityLensLoader / Thai birth data / BaZi chart
        ↓
RuntimeMirrorInputBuilder
        ↓
KnowMeMirrorSnapshotBuilder (MV1 + MV2 promotion)
   ├── Astrology mirror (Thai themes + BaZi signals)
   └── Personality mirror (MBTI / Big Five / EQ lenses)
        ↓
GlobalFusionFoundationBuilder (GF1)
        ↓
GlobalFusionRuntimeBuilder.composeRecovery (GF2)   [when enabled]
        ↓
HumanModelFoundationBuilder
        ↓
HumanPatternSnapshotBuilder
        ↓
NarrativeRuntimeService.generate
        ↓
HomeV3Assembler / Profile sections / Fusion UI
```

**Reference implementations:**

- `lib/features/narrative_runtime/integration/user_runtime_pipeline_service.dart`
- `lib/features/home_cohesion/application/home_v3_loader.dart`

### GF2 disabled vs enabled

| Mode | Path |
|------|------|
| Default (recovery off) | Mirror → GF1 → HM → HP → Narrative |
| Production recovery on | Mirror → MV2 Promotion → GF1 → GF2 Recovery → HM → HP → Narrative |

Downstream consumers read `fusionSnapshot` from composed output when recovery is enabled — not `foundationSnapshot` directly.

### Firestore ownership (key paths)

| Path | Owner |
|------|-------|
| `users/{uid}/profile/main` | Profile setup / edit |
| `users/{uid}/results/*` | Test results (MBTI, EQ, Big Five) |
| `users/{uid}/astrology/western_natal` | Western chart |
| `users/{uid}/astrology/chinese_bazi` | BaZi chart (source of truth for BaZi UI) |
| `users/{uid}/funnel_telemetry/*` | Funnel Recovery V2 telemetry |

### Validation framework

Synthetic validation uses 200–1000 human factories replaying the full pipeline:

```
test/validation/synthetic_population_v3/
test/validation/real_user_runtime_v1/
test/validation/human_pattern_activation_audit/
```

See `docs/HANDOFF.md` for runner commands.

---

## 9. Important Rules for All Work

1. **Trace before editing** — inspect navigation, Firestore paths, providers, and existing services before changes.
2. **Prefer minimal safe changes** — no unnecessary rewrites of working systems.
3. **Never duplicate systems blindly** — reuse QuestionService, ScoringRouter, existing loaders where possible.
4. **Preserve production flow:** `main.dart` → AuthGate → ProfileGate → HomePage.
5. **Do not assume module consistency** — some module IDs are inconsistent across legacy and new architecture.
6. **Stability > correctness > architecture purity > speed.**

---

## 10. Source Documents

| Document | Purpose |
|----------|---------|
| `KNOWME MASTER CONTEXT vNEXT (FULL STRUCTURED v2).txt` | Full historical context (~11k lines) |
| `docs/GLOBAL_FUSION_FOUNDATION_V2_SPECIFICATION.md` | GF2 architecture spec |
| `docs/THAI_MIRROR_SPECIFICATION_V1.md` | Thai Mirror domain contract |
| `docs/NARRATIVE_EVIDENCE_BRANCHING_V5.md` | Narrative V5 validation |
| `docs/REAL_USER_RUNTIME_VALIDATION_V1.md` | Production user funnel audit |
| `docs/PRODUCTION_FUNNEL_RECOVERY_V1.md` | Funnel recovery strategy |

For current status and roadmap, see `CURRENT_STATUS.md` and `ROADMAP.md`.
