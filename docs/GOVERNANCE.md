# KnowMe Governance — Freeze Registry & Programs

**Purpose:** Operational freeze rules, allowed changes, active vs deferred programs.  
**Canonical entry:** [`CURRENT_STATUS.md`](CURRENT_STATUS.md) summarizes; this file is the full registry.  
**Last updated:** June 2026

**Rule before any frozen-system change:** *Does this meaningfully improve user understanding or product value?* If no, move forward.

---

## Change Policy (All Frozen Systems)

Changes limited to:

- Blocker fixes
- Serious usability issues
- Analytics-driven improvements
- Production incidents

Avoid: architecture rewrites, polish loops, copy/spacing churn without product reason.

---

## Frozen / Maintenance-Only

### Fusion Result V1 (presentation)

| | |
|--|--|
| **Status** | Frozen v1 — polish passes 1–4 complete |
| **Spec** | [`FUSION_RESULT_V1_SPEC.md`](FUSION_RESULT_V1_SPEC.md) |
| **Allowed** | Blocker fixes, meaningful friction, analytics usability |
| **Avoid** | Spacing/copy churn, redesign loops |

### MBTI Summary V1.3

| | |
|--|--|
| **Status** | Stable / frozen-ish |
| **Allowed** | Blocker fixes only |
| **Avoid** | Architecture reopen, redesign loops |

### EQ MVP (6 modules)

| | |
|--|--|
| **Status** | Usable+ / frozen-ish |
| **Allowed** | Blocker fixes, usability, feedback-driven |
| **Avoid** | Micro polish loops, architecture changes |

### Thai Astrology V2 Core

| | |
|--|--|
| **Status** | Conditional freeze v0.1.0 — production structural ready |
| **Spec** | `docs/THAI_MIRROR_SPECIFICATION_V1.md` |
| **Allowed** | Blocker fixes, usability, analytics |
| **Avoid** | Houses/aspects UI expansion, architecture rewrite |

### Thai Fusion V2

| | |
|--|--|
| **Status** | Conditional freeze v0.1.0 |
| **Deferred** | Tension detection, `FUSION_MIRROR_THEME_DIVERGENCE` (target v0.2.0) |
| **Allowed** | Blocker fixes, validation/data quality |
| **Avoid** | Contract rewrites, fusion redesign |

### Western Natal V1

| | |
|--|--|
| **Status** | Temporary freeze — E2E verified June 2026 |
| **Path** | `users/{uid}/astrology/western_natal` |
| **Avoid** | Western natal redesign, result page redesign |

### Chinese BaZi V1

| | |
|--|--|
| **Status** | Temporary freeze — backend + Flutter verified |
| **Source of truth** | `users/{uid}/astrology/chinese_bazi` (not `results/chinese_bazi`) |
| **Allowed** | Blocker fixes, usability |
| **Avoid** | Engine rewrite, navigation redesign |
| **Exception** | Chinese Zodiac Personality Expansion — additive content only |

### Edit Profile V1

| | |
|--|--|
| **Status** | Temporary freeze — smoke + regression verified |
| **Flow** | Edit → `profile/main` → birth-critical diff → conditional Western + BaZi refresh |
| **Birth-critical** | `birthDate`, `birthTime`, `birthPlace`, `latitude`, `longitude`, `timezone` |
| **No regeneration** | name, gender only |
| **Avoid** | Profile architecture rewrite, legacy EditProfile revival |

### Astrology Fusion V6

| | |
|--|--|
| **Status** | Usable+ / temporary freeze candidate — narrative pass complete |
| **Allowed** | Blocker fixes, usability, data quality |
| **Avoid** | Architecture rewrite, AI integration during freeze, polish loops |

### Personality Mirror V1

| | |
|--|--|
| **Status** | Production ready / temporary freeze |
| **Allowed** | Blocker fixes, usability, analytics |
| **Avoid** | Engine redesign, confidence redesign, narrative rewrite loops |

### Mirror Platform MV1 (core gates)

| | |
|--|--|
| **Status** | Conditional freeze v0.1.0 |
| **Rule** | Core gates unchanged when GF2 recovery disabled |
| **Extend via** | MV2 promotion + GF2 recovery — do not weaken MV1 gates |

### Global Fusion Foundation GF1

| | |
|--|--|
| **Status** | Conditional freeze v1.0.0 |
| **Rule** | Consumes mirror snapshots; does not bypass contracts |

### Global Fusion Recovery GF2

| | |
|--|--|
| **Status** | Implemented + validated (1000-human gate PASS) |
| **Flag** | `GlobalFusionRecoveryConfig.enabled` |
| **Spec** | `docs/GF2_PRODUCTION_IMPLEMENTATION_V1.md` |

### Big Five V1

| | |
|--|--|
| **Status** | Implemented; future MVP — not primary funnel path |
| **Avoid** | Treating as recovery path over MBTI mini |

---

## Completed Programs (Do Not Re-open Without Cause)

| Program | Evidence |
|---------|----------|
| Human Model HM1 | `lib/features/human_model/` |
| Human Pattern + Activation Recovery V2 | `docs/HUMAN_PATTERN_ACTIVATION_RECOVERY_V2.md` |
| Narrative Runtime V2–V5 | `docs/NARRATIVE_EVIDENCE_BRANCHING_V5.md` |
| Funnel Recovery V2 (product) | `lib/features/home_cohesion/`, `lib/features/funnel_telemetry/` |
| Repository Survival V1 | Architecture on `feature/fusion-result` |

---

## Active Programs

| Program | Why active |
|---------|------------|
| **Funnel conversion** | 2.6% narrative reach; astrology → MBTI cliff |
| **Funnel telemetry measurement** | Post-deploy conversion not yet validated |
| **Chinese Zodiac Personality Expansion** | Approved additive — content library, not BaZi core |
| **Real-user validation re-runs** | Baseline: 38 users — `docs/REAL_USER_RUNTIME_VALIDATION_V1.md` |
| **Merge `feature/fusion-result` → `main`** | Operational — `main` far behind |

---

## Not Active (Explicit Deferrals)

- AI Narrative Layer (depends on stable Mirror + GF + validation)
- Astrology Fusion redesign
- Personality Mirror redesign
- MBTI / EQ expansion beyond maintenance
- Thai astrology architecture rewrite
- Chinese BaZi architecture rewrite
- Big Five as primary funnel (MBTI mini is recovery path)
- Thai Astrology V3 expansion (spec not defined — do not invent scope)

---

## Exception Programs (Allowed Additive Work)

| Program | Constraint |
|---------|------------|
| Funnel Recovery | Home cohesion + telemetry only — no engine rewrites |
| Chinese Zodiac Personality Expansion | Content library + resolver — no Four Pillars / Day Master engine changes |
