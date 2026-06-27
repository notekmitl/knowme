# PROJECT FREEZE — System Freeze Registry

**Status:** CURRENT
**Audience:** Developers and AI agents.
**Last updated:** June 2026

This is the per-system freeze registry. It expands [`GOVERNANCE.md`](GOVERNANCE.md)
(policy) and is summarized in [`CURRENT_STATUS.md`](CURRENT_STATUS.md). Behavioral
rules for working with frozen systems are in
[`AI_ALIGNMENT_CONTEXT.md`](AI_ALIGNMENT_CONTEXT.md) §7.

---

## How to read this registry

Each module specifies:

- **Status** — current freeze state.
- **Frozen version** — the locked version/contract.
- **Owner** — the package/path that owns the system.
- **Modification policy** — the default rule.
- **When modification is allowed** — explicit allowed triggers.
- **Bug-only exceptions** — what counts as a permitted fix.
- **Architecture exceptions** — additive paths that may extend it without reopening it.
- **Future replacement plan** — how/when it would be unfrozen or replaced.

**Global change policy (all frozen systems):** changes limited to blocker fixes,
serious usability issues, analytics-driven improvements, and production incidents.
Avoid architecture rewrites, polish loops, and copy/spacing churn without product
reason. Gate question before any change: *Does this meaningfully improve user
understanding or product value?*

---

## Freeze map (quick reference)

| System | Status | Frozen version | Owner |
|--------|--------|----------------|-------|
| Western Astrology (Natal V1) | Temporary freeze | v1 | astrology services + `astrology/western_natal` |
| Chinese Astrology (BaZi V1) | Temporary freeze | v1 | `lib/features/bazi/` + backend |
| Thai Astrology — Engine (V2 Core) | Conditional freeze | v0.1.0 | `lib/features/astrology/thai/foundation/`, `theme/`, `mirror/` |
| Thai Astrology — Consumer Report | **Active (additive on frozen engine)** | V3–V8 | `lib/features/astrology/thai/mirror/presentation/` |
| Thai Astrology — Timeline Engine + Intelligence | **Active (additive, V9)** | V9 | `lib/features/astrology/thai/core/life_period/` |
| Thai Astrology — Prediction Intelligence Foundation | **Active (additive, V10)** | V10 | `lib/features/astrology/thai/core/prediction/` |
| Thai Astrology — Decision Intelligence Foundation | **Active (additive, V11)** | V11 | `lib/features/astrology/thai/core/decision/` |
| Thai Astrology — Evidence Composer | **Active (additive, V7)** | V7 | `presentation/copy/thai_mirror_evidence_composer.dart` |
| Thai Fusion V2 | Conditional freeze | v0.1.0 | `lib/features/astrology/thai/fusion_v2/` |
| Astrology Fusion V6 | Temporary freeze candidate | v6 | `lib/features/astrology/fusion/` |
| QA Harness (Astrology) | **Active (additive)** | V1 | `lib/features/astrology/thai/qa/harness/` |
| Fusion Result V1 (presentation) | Frozen | v1 | `lib/features/tests/fusion/` |
| MBTI Summary Fusion | Frozen-ish | v1.3 | `lib/features/tests/mbti_summary/` |
| EQ MVP | Usable+ / frozen-ish | v1 | `lib/features/tests/eq/` |
| Big Five V1 | Implemented (future MVP) | v1 | `lib/features/tests/big_five/` |
| Edit Profile V1 | Temporary freeze | v1 | profile pages + `profile_service.dart` |
| Personality Mirror V1 | Temporary freeze | v1 | `lib/features/personality_mirror/` |
| Mirror Platform MV1 (core gates) | Conditional freeze | v0.1.0 | `lib/features/mirror_v3/` |
| Mirror Promotion MV2 | Implemented (additive) | v2 | `lib/features/mirror_v3/promotion/` |
| Global Fusion GF1 | Conditional freeze | v1.0.0 | `lib/features/global_fusion/foundation/` |
| Global Fusion GF2 | Implemented + validated | v2 | `lib/features/global_fusion/v2/` |
| Human Model HM1 | Completed | v1 | `lib/features/human_model/` |
| Human Pattern + Recovery V2 | Completed | v2 | `lib/features/human_pattern/` |
| Narrative Runtime V5 | Frozen (terminal) | v5 | `lib/features/narrative_runtime/` |

---

## Astrology systems

### Western Astrology — Natal V1

| Field | Detail |
|-------|--------|
| **Status** | Temporary freeze — E2E verified June 2026 |
| **Frozen version** | v1 |
| **Owner** | Astrology generation services + Firestore `users/{uid}/astrology/western_natal` |
| **Modification policy** | Maintenance only; no result-page or chart redesign |
| **When allowed** | Blocker fixes, data correctness, usability |
| **Bug-only exceptions** | Chart computation/storage correctness, render crashes |
| **Architecture exceptions** | Consumed as fusion input — extend via fusion layer, not natal rewrite |
| **Future replacement plan** | Revisit only if Western becomes a primary surface; otherwise stays a fusion input |

### Chinese Astrology — BaZi V1

| Field | Detail |
|-------|--------|
| **Status** | Temporary freeze — backend + Flutter verified |
| **Frozen version** | v1 |
| **Owner** | `lib/features/bazi/`, `lib/services/bazi_firestore_service.dart`, backend BaZi API |
| **Source of truth** | `users/{uid}/astrology/chinese_bazi` (not `results/chinese_bazi`) |
| **Modification policy** | No Four Pillars / Day Master engine changes; no navigation redesign |
| **When allowed** | Blocker fixes, usability |
| **Bug-only exceptions** | Pillar/element computation correctness, render issues |
| **Architecture exceptions** | **Chinese Zodiac Personality Expansion** — additive content library + resolver only |
| **Future replacement plan** | Engine stable; expansion happens additively, not by reopening the core |

### Thai Astrology — Engine (V2 Core)

| Field | Detail |
|-------|--------|
| **Status** | Conditional freeze — production structural ready |
| **Frozen version** | v0.1.0 (foundation V1.1, assembler V1.1, narrative gen V1.2) |
| **Owner** | `foundation/`, `theme/`, `mirror/` under `lib/features/astrology/thai/` |
| **Modification policy** | Do not rewrite foundation/theme/assembler engines |
| **When allowed** | Blocker fixes, calculation correctness, data quality |
| **Bug-only exceptions** | Chart/theme scoring correctness, foundation engine bugs |
| **Architecture exceptions** | The **Consumer Report presentation layer (V3–V8)** is built additively on top and remains active |
| **Future replacement plan** | Lunar dataset expansion (license-blocked) would extend coverage without engine rewrite; V2 structural stack is the eventual fusion path |
| **Reference** | `THAI_MIRROR_SPECIFICATION_V1.md`, `THAI_FOUNDATION_ENGINE_V1_1_NOTES.md`, `EXECUTIVE_SUMMARY.md` |

### Thai Astrology — Consumer Report (presentation, V3–V8)

| Field | Detail |
|-------|--------|
| **Status** | **Active / actively maintained** — production deployed |
| **Frozen version** | n/a (additive layer on the frozen engine) |
| **Owner** | `lib/features/astrology/thai/mirror/presentation/` (presenter, copy/, timeline/, ui/) |
| **Modification policy** | Iterate on copy quality, narrative diversity, layout/UX, new sections |
| **When allowed** | Always, within the copy boundary and additive rules |
| **Bug-only exceptions** | n/a — this is the active surface |
| **Architecture exceptions** | Must not reach back into the frozen engine; must not duplicate the report UI |
| **Gate** | All changes must pass screenshot regression + story-coverage CI |
| **Future replacement plan** | UI-V2 Firestore hydrate (persist/cache assembled report) is the next milestone |
| **Reference** | `EXECUTIVE_SUMMARY.md`, `ASTROLOGY_QA_HARNESS_V1.md` |

### Thai Astrology — Timeline Engine + Intelligence (V8 → V9)

| Field | Detail |
|-------|--------|
| **Status** | **Active (additive, shipped V8; V9 Life Timeline Intelligence)** |
| **Frozen version** | V9 |
| **Owner** | `lib/features/astrology/thai/core/life_period/` (engine: evidence only); scoring/narrative/composers in `presentation/timeline/` |
| **Modification policy** | Engine returns evidence only — keep scoring/copy in presentation |
| **When allowed** | Additive improvements, diversity, new period scenarios, new intelligence evidence |
| **Bug-only exceptions** | Period sequence / relationship-matrix / element-model / intelligence correctness |
| **Architecture exceptions** | V9 adds an evidence-only Planet Relationship Engine (friend/enemy + element + combined bond), per-period intelligence, current-age analysis, and future-period preview, all reusable for future features (annual/future prediction, compatibility, fusion) |
| **Future replacement plan** | Extend engine for new prediction surfaces without changing the report contract |
| **Reference** | `THAI_LIFE_TIMELINE_INTELLIGENCE_V9.md`, `DECISION_LOG.md` D-009/D-019 |

### Thai Astrology — Prediction Intelligence Foundation (V10)

| Field | Detail |
|-------|--------|
| **Status** | **Active (additive, V10 — engine + tests + docs only)** |
| **Frozen version** | V10 |
| **Owner** | `lib/features/astrology/thai/core/prediction/` (engine: deterministic evidence only) |
| **Modification policy** | Evidence only — no copy, no AI, no presenter, no UI, no Firestore, no routing. Consumes V9 (`core/life_period/`) without modifying it |
| **When allowed** | Additive: new evidence sources, category/window refinements, new reason codes, new downstream consumers |
| **Bug-only exceptions** | Score/window/evidence correctness and determinism |
| **Architecture exceptions** | Reusable prediction substrate (category × window predictions with strength/confidence, evidence, opportunity/risk, timing/planet/life-period reasons) intended for reuse by Future Prediction, Transit, Compatibility and AI Conversation |
| **Future replacement plan** | A later presentation/feature layer maps `PredictionReasonCode`s → copy; engine stays evidence-only |
| **Reference** | `THAI_PREDICTION_INTELLIGENCE_FOUNDATION_V10.md`, `DECISION_LOG.md` D-020 |

### Thai Astrology — Decision Intelligence Foundation (V11)

| Field | Detail |
|-------|--------|
| **Status** | **Active (additive, V11 — engine + tests + docs only)** |
| **Frozen version** | V11 |
| **Owner** | `lib/features/astrology/thai/core/decision/` (engine: deterministic evidence only) |
| **Modification policy** | Evidence only — no copy, no AI, no presenter, no UI, no Firestore, no routing. Consumes V10 (`core/prediction/`) without modifying it |
| **When allowed** | Additive: new scenarios, scenario→category/stakes refinements, new reason/evidence sources, new downstream consumers |
| **Bug-only exceptions** | Verdict/confidence/timing/evidence correctness and determinism |
| **Architecture exceptions** | Reusable decision substrate (per-scenario verdict with confidence, reasons, supporting/conflicting evidence, best/worst timing, tradeoffs, outcome) intended for reuse by Transit, Compatibility, AI Conversation and Future Chat |
| **Future replacement plan** | A later presentation/feature layer maps `DecisionReasonCode`s → copy; engine stays evidence-only |
| **Reference** | `THAI_DECISION_INTELLIGENCE_V11.md`, `DECISION_LOG.md` D-022 |

### Thai Astrology — Evidence Composer (V7)

| Field | Detail |
|-------|--------|
| **Status** | **Active (additive, shipped V7)** |
| **Frozen version** | V7 |
| **Owner** | `presentation/copy/thai_mirror_evidence_composer.dart`, `thai_mirror_report_copy.dart` |
| **Modification policy** | Evidence-combination-driven copy; keep deterministic + traceable |
| **When allowed** | Copy diversity, grammar, personalization improvements |
| **Bug-only exceptions** | Grammar/templating bugs, duplication regressions |
| **Architecture exceptions** | Owns variable narrative text; engine still owns structure/evidence |
| **Future replacement plan** | Expand facet/tone coverage; no replacement planned |

### Thai Fusion V2

| Field | Detail |
|-------|--------|
| **Status** | Conditional freeze |
| **Frozen version** | v0.1.0 |
| **Owner** | `lib/features/astrology/thai/fusion_v2/` (+ `mirror_v2/`, `theme_v2/`, `interpretation/`, `signal/`) |
| **Modification policy** | Validation/data-quality only; no contract rewrites |
| **When allowed** | Blocker fixes, validation work |
| **Bug-only exceptions** | Engine correctness in the validation stack |
| **Architecture exceptions** | Not wired into the consumer report; future fusion path |
| **Future replacement plan** | Target v0.2.0 (tension detection, `FUSION_MIRROR_THEME_DIVERGENCE`) when fusion roadmap reaches astrology |

### Astrology Fusion V6

| Field | Detail |
|-------|--------|
| **Status** | Usable+ / temporary freeze candidate — narrative pass complete |
| **Frozen version** | v6 |
| **Owner** | `lib/features/astrology/fusion/` |
| **Modification policy** | No AI integration during freeze; no architecture rewrite or polish loops |
| **When allowed** | Blocker fixes, usability, data quality |
| **Bug-only exceptions** | Fusion correctness, render issues |
| **Architecture exceptions** | Separate from global cross-mirror fusion |
| **Future replacement plan** | Confirm freeze or fold into global fusion later |

### QA Harness (Astrology) — V1

| Field | Detail |
|-------|--------|
| **Status** | **Active (additive)** |
| **Frozen version** | V1 |
| **Owner** | `lib/features/astrology/thai/qa/harness/`, `lib/core/web/`, `test/validation/thai_mirror_qa_harness/` |
| **Modification policy** | Extend additively; never duplicate report UI |
| **When allowed** | New profiles, scenarios, viewports; reuse for other report domains |
| **Bug-only exceptions** | Harness/spec/route correctness |
| **Architecture exceptions** | Generic by design — Western/Chinese/Fusion/Compatibility harnesses planned |
| **Future replacement plan** | Generalize beyond Thai (see `ASTROLOGY_QA_HARNESS_V1.md` §6) |

---

## Personality test systems

### Fusion Result V1 (presentation)

| Field | Detail |
|-------|--------|
| **Status** | Frozen — polish passes 1–4 complete |
| **Frozen version** | v1 |
| **Owner** | `lib/features/tests/fusion/` |
| **Modification policy** | No spacing/copy churn or redesign loops |
| **When allowed** | Blocker fixes, meaningful friction, analytics usability |
| **Bug-only exceptions** | Layout breakage, wrong synthesis output |
| **Architecture exceptions** | Synthesis logic is explicitly *not* frozen; only presentation is |
| **Future replacement plan** | Stable; revisit only with product reason |
| **Reference** | `FUSION_RESULT_V1_SPEC.md` |

### MBTI Summary Fusion V1.3

| Field | Detail |
|-------|--------|
| **Status** | Stable / frozen-ish |
| **Frozen version** | v1.3 |
| **Owner** | `lib/features/tests/mbti_summary/` |
| **Modification policy** | Deterministic synthesis only; blocker fixes only |
| **When allowed** | Blocker fixes |
| **Bug-only exceptions** | Synthesis correctness |
| **Architecture exceptions** | None |
| **Future replacement plan** | None planned |
| **Reference** | `MBTI_ARCHITECTURE.md` |

### EQ MVP (6 modules)

| Field | Detail |
|-------|--------|
| **Status** | Usable+ / frozen-ish (maintenance mode) |
| **Frozen version** | v1 |
| **Owner** | `lib/features/tests/eq/` |
| **Modification policy** | No micro-polish loops or architecture changes |
| **When allowed** | Blocker fixes, usability, feedback-driven |
| **Bug-only exceptions** | Module scoring/session bugs |
| **Architecture exceptions** | None |
| **Future replacement plan** | Expand only if it becomes a funnel priority |

### Big Five V1

| Field | Detail |
|-------|--------|
| **Status** | Implemented; future MVP — not the primary funnel path |
| **Frozen version** | v1 |
| **Owner** | `lib/features/tests/big_five/` |
| **Modification policy** | Do not treat as recovery path over MBTI mini |
| **When allowed** | Blocker fixes |
| **Bug-only exceptions** | Scoring/session bugs |
| **Architecture exceptions** | None |
| **Future replacement plan** | Promote to primary MVP lens only if strategy changes |

### Edit Profile V1

| Field | Detail |
|-------|--------|
| **Status** | Temporary freeze — smoke + regression verified |
| **Frozen version** | v1 |
| **Owner** | Profile pages + `lib/services/profile_service.dart` |
| **Modification policy** | No profile-architecture rewrite; no legacy EditProfile revival |
| **When allowed** | Blocker fixes, usability |
| **Bug-only exceptions** | Birth-critical diff / conditional regeneration bugs |
| **Architecture exceptions** | Birth-critical fields trigger Western + BaZi refresh; name/gender do not |
| **Future replacement plan** | None planned |

### Personality Mirror V1

| Field | Detail |
|-------|--------|
| **Status** | Production ready / temporary freeze |
| **Frozen version** | v1 |
| **Owner** | `lib/features/personality_mirror/` |
| **Modification policy** | No engine/confidence redesign or narrative rewrite loops |
| **When allowed** | Blocker fixes, usability, analytics |
| **Bug-only exceptions** | Lens aggregation correctness |
| **Architecture exceptions** | None |
| **Future replacement plan** | None planned |

---

## Fusion & narrative pipeline

### Mirror Platform MV1 (core gates)

| Field | Detail |
|-------|--------|
| **Status** | Conditional freeze |
| **Frozen version** | v0.1.0 |
| **Owner** | `lib/features/mirror_v3/` |
| **Modification policy** | Core gates unchanged when GF2 recovery disabled |
| **When allowed** | Blocker fixes that do not weaken gates |
| **Bug-only exceptions** | Snapshot-builder correctness |
| **Architecture exceptions** | Extend via MV2 promotion + GF2 recovery, never by weakening MV1 |
| **Future replacement plan** | Stable foundation; not slated for replacement |

### Mirror Promotion MV2

| Field | Detail |
|-------|--------|
| **Status** | Implemented (additive) |
| **Frozen version** | v2 |
| **Owner** | `lib/features/mirror_v3/promotion/` |
| **Modification policy** | Additive recovery only |
| **When allowed** | Recovery rule improvements with validation |
| **Bug-only exceptions** | Promotion-rule correctness |
| **Architecture exceptions** | Does not modify MV1 gates |
| **Future replacement plan** | Evolve with fusion roadmap |
| **Reference** | `GLOBAL_FUSION_FOUNDATION_V2_SPECIFICATION.md`, `GF2_PRODUCTION_IMPLEMENTATION_V1.md` |

### Global Fusion Foundation GF1

| Field | Detail |
|-------|--------|
| **Status** | Conditional freeze |
| **Frozen version** | v1.0.0 |
| **Owner** | `lib/features/global_fusion/foundation/` |
| **Modification policy** | Consumes mirror snapshots; does not bypass contracts |
| **When allowed** | Blocker fixes |
| **Bug-only exceptions** | Foundation builder correctness |
| **Architecture exceptions** | Does not consume MV2 promoted findings directly |
| **Future replacement plan** | Stable; recovery handled in GF2 |

### Global Fusion Recovery GF2

| Field | Detail |
|-------|--------|
| **Status** | Implemented + validated (1000-human gate PASS) |
| **Frozen version** | v2 |
| **Owner** | `lib/features/global_fusion/v2/` |
| **Flag** | `GlobalFusionRecoveryConfig.enabled` |
| **Modification policy** | Additive recovery (R001–R004); preserve downstream contract |
| **When allowed** | Recovery improvements with synthetic validation |
| **Bug-only exceptions** | Composer/recovery-engine correctness |
| **Architecture exceptions** | Downstream reads `fusionSnapshot` when recovery enabled |
| **Future replacement plan** | Extend recovery engines as new dead zones are proven |
| **Reference** | `GF2_PRODUCTION_IMPLEMENTATION_V1.md` (implementation), `GF2_ROOT_CAUSE_ISOLATION_REPORT.md` (why) |

### Human Model HM1

| Field | Detail |
|-------|--------|
| **Status** | Completed |
| **Frozen version** | v1 |
| **Owner** | `lib/features/human_model/` |
| **Modification policy** | Consumes fusion output only — no mirror bypass |
| **When allowed** | Blocker fixes |
| **Bug-only exceptions** | Model-mapping correctness |
| **Architecture exceptions** | None |
| **Future replacement plan** | Stable |

### Human Pattern + Activation Recovery V2

| Field | Detail |
|-------|--------|
| **Status** | Completed |
| **Frozen version** | v2 |
| **Owner** | `lib/features/human_pattern/` (`PatternActivationEngine`) |
| **Modification policy** | Additive pattern coverage; preserve activation rules |
| **When allowed** | Recovery of additional dead patterns with validation |
| **Bug-only exceptions** | `_resolveSourcePattern` / activation correctness |
| **Architecture exceptions** | 2 patterns await GF1 tension (`identity_dual_signal`, `internal_conflict_thinker`) |
| **Future replacement plan** | Recover remaining patterns as upstream tension reaches the model |
| **Reference** | `HUMAN_PATTERN_ACTIVATION_RECOVERY_V2.md`, `HUMAN_PATTERN_DEAD_ZONE_FORENSICS_V1.md` |

### Narrative Runtime V5

| Field | Detail |
|-------|--------|
| **Status** | Frozen (terminal narrative state) — 1000/1000 unique on synthetic |
| **Frozen version** | v5 |
| **Owner** | `lib/features/narrative_runtime/` (intelligence: selection V3, topology V4, evidence branching V5) |
| **Modification policy** | No reopening of the intelligence stack without strong reason |
| **When allowed** | Blocker fixes, copy expansion (registry) |
| **Bug-only exceptions** | Generation determinism, copy correctness |
| **Architecture exceptions** | Copy layer (`narrative_pattern_copy.dart`) can expand additively |
| **Future replacement plan** | AI narrative layer is a deferred future program (depends on stable Mirror + GF + validation) |
| **Reference** | `NARRATIVE_EVIDENCE_BRANCHING_V5.md` |

---

## Exception programs (allowed additive work)

| Program | Constraint |
|---------|------------|
| Thai Consumer Report presentation (V3–V8) | Additive on frozen engine; copy boundary; CI-gated |
| Astrology QA Harness | Additive; never duplicate report UI |
| Funnel Recovery | Home cohesion + telemetry only — no engine rewrites |
| Chinese Zodiac Personality Expansion | Content library + resolver — no Four Pillars / Day Master changes |

---

## Related documents

- [`GOVERNANCE.md`](GOVERNANCE.md) — freeze policy + active/deferred programs.
- [`AI_ALIGNMENT_CONTEXT.md`](AI_ALIGNMENT_CONTEXT.md) — behavioral freeze rules.
- [`DECISION_LOG.md`](DECISION_LOG.md) — why systems were frozen (D-004–D-006, D-015, D-018).
- [`DOMAIN_MODEL.md`](DOMAIN_MODEL.md) — per-engine state in the conceptual model.
- [`CURRENT_STATUS.md`](CURRENT_STATUS.md) — status summary + technical debt register.
- [`EXECUTIVE_SUMMARY.md`](EXECUTIVE_SUMMARY.md) — freeze map in project context.
- [`PROJECT_INDEX.md`](PROJECT_INDEX.md) — full documentation index.
