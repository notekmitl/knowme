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
| **Thai Mirror UI full Firestore hydrate** | `docs/THAI_MIRROR_UI_SPECIFICATION_V1.md` — UI-V2 milestone | Spec complete; full UI integration deferred |
| **Thai Astrology V3** | Deferred — scope not defined in `/docs/` | Do not invent scope |
| **Merge `feature/fusion-result` → `main`** | Repository state — operational | Required for production recovery from default branch |
| **GF1 tension reaching Human Model** | `HUMAN_PATTERN_ACTIVATION_RECOVERY_V2.md` — 2 patterns await GF1 tension | `identity_dual_signal`, `internal_conflict_thinker` |

**Explicitly not active:** see [`GOVERNANCE.md`](GOVERNANCE.md) §Not Active

---

## Roadmap Principles

1. **Evidence before expansion** — synthetic validation gates before production claims.
2. **Funnel before features** — real-user conversion is the current bottleneck, not engine diversity.
3. **Freeze what works** — Fusion V1 UI, BaZi V1, Thai V2, MBTI Summary are maintenance-only.
4. **No invented work** — if it is not in `/docs/` or code, it is not on this roadmap.
