# KnowMe Roadmap

**Last updated:** June 2026  
**Rule:** Items listed here are backed by repository evidence only. Nothing invented.

Sources: `docs/*.md`, `lib/features/*`, validation outputs.

---

## Completed

### Platform & architecture

| Item | Evidence |
|------|----------|
| Thai Astrology V2 Core — production structural ready | `docs/THAI_ASTROLOGY_DOMAIN_VALIDATION_V1.md`, `lib/features/astrology/thai/` |
| Thai Mirror domain + pipeline | `docs/THAI_MIRROR_SPECIFICATION_V1.md`, mirror assembler + presenter implemented |
| Thai Consumer Report V3–V8 — production deployed | `docs/EXECUTIVE_SUMMARY.md` — evidence-driven narrative (V7), article-style result page (V4), Life Timeline + life-period engine (V8) |
| Thai Life Timeline Intelligence V9 — engine + presentation | `docs/THAI_LIFE_TIMELINE_INTELLIGENCE_V9.md` — planet relationship engine (friend/enemy + element + bond), per-period intelligence, current-age analysis, future-period preview (evidence only) |
| Thai Prediction Intelligence Foundation V10 — engine only | `docs/THAI_PREDICTION_INTELLIGENCE_FOUNDATION_V10.md` — deterministic prediction substrate over V9 (category × window evidence, strength/confidence, opportunity/risk, reasons); reusable by Future Prediction/Transit/Compatibility/AI; no AI, no transit, no presenter |
| Thai Future Prediction Presentation V10.5 — first production release | D-021 — Future Prediction section inside the existing consumer report (Life Timeline → Future Prediction → Signature Insight); `PredictionComposer`/`PredictionReasonCopy`/`ThaiMirrorFuturePredictionSection`; consumes `PredictionIntelligence` only, tendency copy, copy boundary preserved; story-coverage + screenshot gates extended |
| Thai Decision Intelligence Foundation V11 — engine only | `docs/THAI_DECISION_INTELLIGENCE_V11.md` — deterministic per-scenario decision substrate over V10 (10 scenarios → verdict/confidence/reasons/evidence/timing/tradeoffs/outcome); reusable by Transit/Compatibility/AI Conversation/Future Chat; no AI, no transit, no compatibility, no presenter |
| Thai Question Reasoning Foundation V12 — engine only | `docs/THAI_QUESTION_REASONING_FOUNDATION_V12.md` — deterministic structured-intent → decision-query resolver over V11 (10 topics × 6 intents → resolved scenario, relevant windows/evidence, priority reasons, structured answer, confidence); reusable by Transit/Compatibility/Future AI/Voice Assistant; no AI, no LLM, no parser, no presenter |
| Thai Unified Reasoning Runtime V13 — engine only | `docs/THAI_REASONING_RUNTIME_V13.md` — single orchestration entry point over V9–V12 (`evaluate`/`predict`/`decide`/`question`/`answer` → unified Timeline/Prediction/Decision/Question snapshots + flattened evidence + trace + confidence); the only public reasoning entry point; reusable by Transit/Compatibility/AI Conversation; no AI, no transit, no compatibility, no presenter, no LLM |
| Thai Scenario Simulation Foundation V14 — engine only | `docs/THAI_SCENARIO_SIMULATION_V14.md` — deterministic hypothetical decision-path evaluation over the V13 runtime (7 scenarios × Act now/Best window/Alternative window/Do nothing → expected/opportunity/risk/tradeoffs/timing/confidence/evidence + ranked comparison); consumes the runtime only; reusable by Transit/Compatibility/AI Conversation; no AI, no presenter, no parser, no UI |
| Thai Transit Intelligence Integration V15 — engine only | `docs/THAI_TRANSIT_INTEGRATION_V15.md` — day-of-week-ruler transit assessed vs natal + current period via the shared V9 relationship engine, converted to evidence and merged through an Enhanced Runtime wrapper (Runtime + Transit → Enhanced Runtime); enhancement layer, not a parallel architecture; transit contributes evidence only; runtime untouched; reusable by Compatibility/AI Conversation; no AI, no presenter, no UI |
| Mirror Conversation Experience Foundation V16 — foundation only | `docs/THAI_MIRROR_CONVERSATION_V16.md` — deterministic guided conversation over the V13 runtime (8 topics, predefined question catalog → runtime `evaluate`/`predict`/`decide`/`question` → structured answer → suggested follow-ups); consumes the runtime only; no AI, no LLM, no chat model, no parser, no free text; experience foundation (no UI/deploy) |
| Global Reasoning Runtime Foundation V17 — architecture only | `docs/GLOBAL_REASONING_RUNTIME_V17.md` — system-agnostic runtime (`ReasoningProvider`/`Runtime`/`Module`/`Capability`/`Request`/`Response`/`Evidence`/`Trace`) generalizing the V13 Thai runtime (now the reference implementation); provider discovery, dispatch, capability detection, evidence aggregation; only `ThaiRuntimeAdapter` implemented; no hard-coded Thai dependency; Mirror Conversation consumes the global runtime; no AI/UI/presenter/routing/Firestore/deploy |
| Thai Astrology QA Harness V1 | `docs/ASTROLOGY_QA_HARNESS_V1.md` — consumer-preview route, profiles A–H, screenshot regression + story-coverage CI, service-worker freshness fix |
| Western Natal V1 — verified E2E | Master context §45.1, Firestore `western_natal` |
| Chinese BaZi V1 — backend + Flutter verified | Master context §58, `lib/features/bazi/` |
| Mirror Platform V3 (MV1) | `lib/features/mirror_v3/` — agreement, tension, reinforcement, blind spot |
| Mirror Promotion MV2 (MP-001) | `lib/features/mirror_v3/promotion/` |
| Global Fusion Foundation GF1 | `lib/features/global_fusion/foundation/` |
| Global Fusion Recovery GF2 | `docs/GF2_PRODUCTION_IMPLEMENTATION_V1.md` — production implementation + 1000-human validation |
| Human Model HM1 | `lib/features/human_model/` |
| Human Pattern HP2 + Activation Recovery V2 | `docs/HUMAN_PATTERN_ACTIVATION_RECOVERY_V2.md` |
| Narrative Runtime — V2 through V5 | `docs/NARRATIVE_INTELLIGENCE_V2.md` through `docs/NARRATIVE_EVIDENCE_BRANCHING_V5.md` |
| Synthetic validation framework (200 → 1000 humans) | `docs/SYNTHETIC_HUMAN_POPULATION_V1.md`, `docs/SYNTHETIC_POPULATION_V2_1000_REPORT.md`, `test/validation/synthetic_population_v3/` |
| Real User Runtime Validation V1 | `docs/REAL_USER_RUNTIME_VALIDATION_V1.md` |
| Home V3.8 emotional surface | `lib/features/home_cohesion/` |
| Funnel Recovery V2 (product implementation) | Home unlock, completion bar, MBTI preview loop, telemetry — `lib/features/home_cohesion/`, `lib/features/funnel_telemetry/` |
| Repository Survival V1 | Architecture snapshot on GitHub (`780a4c1`, 1,534 tracked files) |
| Public Deployment V1 | [`DEPLOYMENT.md`](DEPLOYMENT.md) — https://knowme-app-694e1.web.app |
| Production Funnel Recovery V1 (strategy) | `docs/PRODUCTION_FUNNEL_RECOVERY_V1.md` |

### Test ecosystem (implemented)

| Lens | Status | Location |
|------|--------|----------|
| MBTI Progressive (16 → 40 → 80) | Implemented | `lib/features/tests/mbti/` |
| MBTI Cognitive | Implemented | `lib/features/tests/mbti_cognitive/` |
| MBTI Summary Fusion V1.3 | Frozen-ish | `lib/features/tests/mbti_summary/` |
| EQ (6 modules) | Usable+ / frozen-ish | `lib/features/tests/eq/` |
| Big Five Progressive | Implemented | `lib/features/tests/big_five/` |
| Fusion Result V1 presentation | **Frozen v1** | `lib/features/tests/fusion/` |
| Astrology Fusion V6 | Usable+ / freeze candidate | `lib/features/astrology/fusion/` |

### Validation gates passed (synthetic)

| Gate | Result | Doc |
|------|--------|-----|
| GF2 production | PASS (1000-human) | `GF2_PRODUCTION_IMPLEMENTATION_V1.md` |
| Narrative V5 | 1000/1000 unique, 0 collapse | `NARRATIVE_EVIDENCE_BRANCHING_V5.md` |
| Human Pattern Recovery V2 | 9/20 dead patterns active | `HUMAN_PATTERN_ACTIVATION_RECOVERY_V2.md` |
| GF1 foundation V2 spec validation | Evidence base complete | `GLOBAL_FUSION_FOUNDATION_VALIDATION_V2.md` |

---

## Active

| Item | Why active | Evidence |
|------|------------|----------|
| **Funnel conversion (astrology → personality → narrative)** | Real users: 2.6% narrative reach; 97% drop-off before MBTI | `REAL_USER_RUNTIME_VALIDATION_V1.md`, Funnel Recovery V2 code |
| **Funnel telemetry measurement** | Track MBTI adoption, narrative preview, completion funnel | `lib/features/funnel_telemetry/` |
| **Home experience refinement** | Primary post-astrology product surface | `lib/features/home_cohesion/`, `PRODUCTION_FUNNEL_RECOVERY_V1.md` |
| **Chinese Zodiac Personality Expansion** | Approved additive program, low blast radius | [`GOVERNANCE.md`](GOVERNANCE.md) exception programs |
| **Real-user validation re-runs** | Measure funnel changes against 38-user baseline | `test/validation/real_user_runtime_v1/` |

**Active rule (from master context):** Maintenance only on frozen systems. Prefer depth over breadth. Do not reopen frozen architecture without strong reason.

---

## Future

Items documented as future in master context or specs — **not yet active priorities**.

| Item | Source | Dependency / note |
|------|--------|-----------------|
| **AI Narrative Layer** | [`GOVERNANCE.md`](GOVERNANCE.md) — deferred | Depends on Mirror + Global Fusion + Validation Layer |
| **Big Five as primary MVP lens** | [`GOVERNANCE.md`](GOVERNANCE.md) | Code exists; MBTI mini is recovery path |
| **Thai Mirror UI full Firestore hydrate** | `docs/THAI_MIRROR_UI_SPECIFICATION_V1.md` — UI-V2 milestone | Consumer Report renders from the live pipeline; persisting/caching the assembled report to Firestore is still deferred |
| **Thai lunar dataset full coverage** | `docs/THAI_LUNAR_DATASET_ACQUISITION_V1.md` | License-blocked; repository currently ships limited verified entries, so arbitrary Gregorian birth dates fall back gracefully |
| **Prediction surfaces beyond the consumer report** | `docs/THAI_PREDICTION_INTELLIGENCE_FOUNDATION_V10.md`, D-021 | Engine (V10) + the consumer-report Future Prediction surface (V10.5) shipped; dedicated Future Prediction / Transit / Compatibility / AI Conversation surfaces reusing the same `PredictionIntelligence` substrate remain future work |
| **Decision Intelligence surfaces** | `docs/THAI_DECISION_INTELLIGENCE_V11.md`, D-022 | Engine (V11) shipped (per-scenario decision substrate over V10); a presentation layer mapping `DecisionReasonCode`s → copy, plus Transit / Compatibility / AI Conversation reuse, remain future work |
| **Question Reasoning surfaces** | `docs/THAI_QUESTION_REASONING_FOUNDATION_V12.md`, D-023 | Engine (V12) shipped (structured-intent → decision-query resolver over V11); a presentation/AI layer mapping stances/codes → copy, plus voice-assistant / future-AI front-ends, remain future work |
| **Reasoning Runtime consumers** | `docs/THAI_REASONING_RUNTIME_V13.md`, D-024 | Runtime (V13) shipped (single orchestration entry point over V9–V12); Transit / Compatibility / AI Conversation features that consume the runtime, and any presentation layer over its snapshots, remain future work |
| **Scenario Simulation consumers** | `docs/THAI_SCENARIO_SIMULATION_V14.md`, D-025 | Engine (V14) shipped (hypothetical decision-path evaluation over the runtime); a presentation/AI layer over simulation results, plus Transit / Compatibility reuse, remain future work |
| **Enhanced Runtime consumers** | `docs/THAI_TRANSIT_INTEGRATION_V15.md`, D-026 | Transit integration (V15) shipped (Enhanced Runtime = Runtime + Transit evidence); wiring Simulation/Consumer and future Compatibility / AI Conversation onto the Enhanced Runtime, plus any presentation over transit evidence, remain future work |
| **Mirror Conversation surfaces** | `docs/THAI_MIRROR_CONVERSATION_V16.md`, D-027 | Conversation foundation (V16) shipped (deterministic guided graph over the runtime); a presentation layer mapping question/answer/suggestion ids → Thai copy, the Mirror UI wiring, and future Compatibility / AI Conversation surfaces remain future work |
| **Global Reasoning Runtime providers** | `docs/GLOBAL_REASONING_RUNTIME_V17.md`, D-028 | Cross-system runtime foundation (V17) shipped with only the `ThaiRuntimeAdapter`; Western / BaZi / MBTI / Big Five / EQ / Compatibility providers, and migrating other consumers onto the global runtime, remain future work |
| **Reuse QA Harness for other report domains** | `docs/ASTROLOGY_QA_HARNESS_V1.md` §6 | Pattern is generic; Western / Chinese / Fusion / Compatibility harnesses not yet built |
| **Merge `feature/fusion-result` → `main`** | Repository state — operational | Required for production recovery from default branch |
| **GF1 tension reaching Human Model** | `HUMAN_PATTERN_ACTIVATION_RECOVERY_V2.md` — 2 patterns await GF1 tension | `identity_dual_signal`, `internal_conflict_thinker` |

**Explicitly not active:** see [`GOVERNANCE.md`](GOVERNANCE.md) §Not Active

---

## Roadmap Principles

1. **Evidence before expansion** — synthetic validation gates before production claims.
2. **Funnel before features** — real-user conversion is the current bottleneck, not engine diversity.
3. **Freeze what works** — Fusion V1 UI, BaZi V1, Thai V2, MBTI Summary are maintenance-only.
4. **No invented work** — if it is not in `/docs/` or code, it is not on this roadmap.
