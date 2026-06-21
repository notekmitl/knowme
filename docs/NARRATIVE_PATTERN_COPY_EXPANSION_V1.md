# Narrative Pattern Copy Expansion V1

**Program:** Narrative Pattern Copy Expansion V1  
**Authority:** KNOWME MASTER CONTEXT vNEXT (FULL STRUCTURED v2)  
**Scope:** Narrative layer only — no Mirror, GF1, GF2, Human Model, or Human Pattern changes  
**Status:** PASS — all validation gates met  
**Date:** 2026-06-21

---

## Executive Summary

Pattern activation diversity (30 active patterns, 436 unique pattern sets) had outpaced narrative copy diversity (552 unique narratives, 446 profiles in collapse). This program expanded deterministic Thai copy in `narrative_pattern_copy.dart` for all 30 active patterns, added pair-specific interaction copy, family-specific compressed copy, and blind-spot copy — without adding patterns, sections, or fusion logic.

| Metric | Before (GF2 baseline) | After (V1 expansion) | Gate | Result |
|---|---:|---:|---|:---:|
| Unique narratives | 552 | **586** | > 552 | PASS |
| Profiles in collapse | 446 | **400** | < 446 | PASS |
| Max cluster | 16 | **14** | < 16 | PASS |
| Active patterns | 30 | **30** | ≥ 30 | PASS |
| Pattern coverage | 100% | **100%** | no regression | PASS |
| Narrative evidence coverage | 100% | **100%** | no regression | PASS |

**Net gain:** +34 unique narratives, −46 profiles in collapse, −2 max cluster size.

---

## 1. Coverage Audit

### 1.1 Method

1000-human synthetic population (V3 factory) with GF2 production recovery enabled. Audit runner:

```
dart run test/validation/synthetic_population_v3/analysis/narrative_copy_expansion_v1_runner.dart
```

Output: `test/validation/synthetic_population_v3/output/narrative_copy_expansion_v1.json`

### 1.2 Pre-Expansion Bottleneck (Before)

| Issue | Evidence |
|---|---|
| Generic fallback copy | 4 mode-level templates reused for ~20 patterns lacking `_specificCopy` |
| Shared interaction themes | Same theme key produced identical copy regardless of pattern pair |
| Compressed family collapse | Single template for all family clusters |
| Blind spot reuse | Blind spots fell through to generic relationship/identity templates |

**Pre-expansion generic copy groups (estimated from collapse forensics):**

| Copy group | Approx. usage | Collapse contribution |
|---|---:|---|
| `generic_identity` | ~997 profiles | High — `directional_meaning`, `purpose_guide` |
| `generic_growth` | ~939 profiles | High — `reinforced_strength`, `purpose_driven_motivation` |
| `generic_relationship` | ~579 profiles | Medium — `ignored_emotional_dimension` |
| `interaction_fallback` | ~370 profiles | Medium — agreement/tension label interpolation |
| `theme_consistency_theme` | ~370 profiles | Medium — structured + accountable pair |

### 1.3 Active Pattern Audit (30 patterns)

All 30 active patterns now have `hasSpecificCopy: true` in primary narrative mode.

| Pattern | Activations | Narrative usage | Copy status (after) |
|---|---:|---:|---|
| responsive_feeler | 1000 | 1000 | specific |
| calm_regulator | 1000 | 1000 | specific |
| diplomatic_binder | 998 | 998 | specific |
| directional_meaning | 997 | 997 | specific |
| decisive_actor | 948 | 948 | specific |
| reinforced_strength | 939 | 939 | specific |
| self_directed_identity | 930 | 930 | specific |
| progressive_builder | 829 | 829 | specific |
| structured_operator | 755 | 755 | specific |
| ignored_emotional_dimension | 579 | 579 | specific (blind spot) |
| analytical_thinker | 557 | 557 | specific |
| stable_accountability | 415 | 415 | specific |
| accountable_operator | 415 | 415 | specific |
| independent_decision_maker | 378 | 378 | specific |
| expressive_identity | 484 | 484 | specific |
| meaning_seeker | 258 | 258 | specific |
| stable_orientation | 258 | 258 | specific |
| adaptive_creator | 235 | 235 | specific |
| adaptive_growth | 235 | 235 | specific |
| purpose_driven_motivation | 216 | 216 | specific |
| supportive_connector | 224 | 224 | specific |
| relationship_stabilizer | 185 | 185 | specific |
| dual_nature_actor | 176 | 176 | specific |
| growth_edge_builder | 176 | 176 | specific |
| growth_edge_from_tension | 176 | 176 | specific |
| constructive_builder | 91 | 91 | specific |
| structured_builder_thinker | 91 | 91 | specific |
| relational_hidden_potential | 79 | 79 | specific (blind spot) |
| guiding_teacher | 54 | 54 | specific |
| purpose_guide | 54 | 54 | specific |

### 1.4 Most Overused Copy Groups (After)

High usage is expected for high-activation patterns; collapse risk is now at **combination level** (multi-paragraph fingerprints), not single-paragraph generic fallback.

| Rank | Copy group | Usage count |
|---:|---|---:|
| 1 | `specific_directional_meaning` | 983 |
| 2 | `specific_progressive_builder` | 802 |
| 3 | `specific_calm_regulator` | 802 |
| 4 | `specific_self_directed_identity` | 794 |
| 5 | `specific_reinforced_strength` | 714 |
| 6 | `specific_responsive_feeler` | 692 |
| 7 | `specific_ignored_emotional_dimension` | 579 |
| 8 | `specific_diplomatic_binder` | 546 |
| 9 | `pair_agreement_structured_operator+accountable_operator` | 370 |
| 10 | `pair_tension_analytical_thinker+decisive_actor` | 288 |

**Key shift:** Generic fallback groups (`generic_identity`, `generic_growth`, etc.) no longer appear in top-20 overuse list.

---

## 2. Copy Expansion Summary

### 2.1 File Changed

`lib/features/narrative_runtime/registry/narrative_pattern_copy.dart`

### 2.2 Pattern Copy Added (Task B)

Expanded `_specificCopy` from **17 pattern entries** to **41 pattern entries** across 4 narrative modes:

| Mode | New / corrected patterns |
|---|---|
| Identity | `belief_meaning`, `directional_meaning`, `purpose_guide`, `stable_orientation`, `identity_dual_signal` |
| Relationship | `emotional_depth`, `responsive_feeler`, `calm_regulator`, `ignored_emotional_dimension`, `asymmetric_identity_development` |
| Decision | `structured_explorer`, `reflective_builder`, `analytical_thinker`, `belief_architect`, `structured_builder_thinker`, `dual_nature_actor`, `internal_conflict_thinker`, `constructive_builder` (moved from identity) |
| Growth | `purpose_driven_motivation`, `resource_oriented_motivation`, `adaptive_creator`, `reinforced_strength`, `guiding_teacher`, `stable_accountability` |

Each copy entry uses a **distinct paragraph structure and semantic signature**:

- **Behavioral:** how the person acts (e.g. decisive_actor — speed to action)
- **Growth:** development trajectory (e.g. reinforced_strength — cross-source confirmation)
- **Relationship:** connection style (e.g. diplomatic_binder — harmonizing)
- **Decision:** choice mechanism (e.g. structured_explorer — bounded exploration)

Generic self-help phrasing ("คุณพัฒนาตัวเองผ่านการเรียนรู้และปรับตัวอย่างต่อเนื่อง") retained only as last-resort fallback for inactive patterns.

### 2.3 Helpers Added

- `hasSpecificCopy(patternId)` — audit support
- `copyGroupForText(text)` — collapse / reuse tracking
- `_textToCopyGroup` reverse index — deterministic copy group attribution

---

## 3. Interaction Expansion Summary

### 3.1 Pair-Specific Copy (Task C)

Added `_pairInteractionCopy` keyed by `primaryId+secondaryId` for existing interaction types:

| Type | Pairs covered |
|---|---|
| agreement | structured_operator+accountable_operator, supportive_connector+relationship_stabilizer, self_directed_identity+independent_decision_maker, constructive_builder+progressive_builder (+ reverse order) |
| tension | independent_decision_maker+relationship_stabilizer, analytical_thinker+decisive_actor (+ reverse order) |
| growthEdge | growth_edge_builder+analytical_thinker, growth_edge_from_tension+structured_operator (+ reverse order) |

Resolution order: **pair copy → theme copy → label-interpolation fallback**

### 3.2 Compressed Family Copy

10 family-specific `_compressedFamilyCopy` entries replace the single generic compressed template for:

`identity_style`, `meaning_style`, `thinking_style`, `emotional_style`, `relationship_style`, `decision_style`, `growth_style`, `growth_edge_pattern`, `motivation_style`, `theme_coverage_pattern`

### 3.3 Blind Spot Copy

Dedicated `_blindSpotCopy` for all 3 blind spot patterns:

- `relational_hidden_potential`
- `ignored_emotional_dimension`
- `asymmetric_identity_development`

No new interaction types added.

---

## 4. Diversity Metrics

### 4.1 Before vs After (1000-human, GF2+HP enabled)

| Metric | Before | After | Δ |
|---|---:|---:|---:|
| Unique narratives | 552 | 586 | **+34** |
| Profiles in collapse (≥3 identical) | 446 | 400 | **−46** |
| Max cluster size | 16 | 14 | **−2** |
| Unique pattern sets | 436 | 436 | 0 |
| Total activations | 13,732 | 13,732 | 0 |
| Pattern coverage | 30/30 (100%) | 30/30 (100%) | 0 |
| Narrative evidence coverage | 1000/1000 | 1000/1000 | 0 |

### 4.2 Validation Gates

| Gate | Target | Measured | Pass |
|---|---|---|:---:|
| Unique narratives | > 552 | 586 | ✓ |
| Profiles in collapse | < 446 | 400 | ✓ |
| Max cluster | < 16 | 14 | ✓ |
| Active patterns | ≥ 30 | 30 | ✓ |

---

## 5. Regression Audit

| Layer | Check | Result |
|---|---|:---:|
| Mirror | Fingerprint present on all 1000 profiles | PASS |
| GF1 | Foundation hash preserved | PASS |
| Human Model | Deterministic replay on GF1 input | PASS |
| Human Pattern | Total activations unchanged (13,732) | PASS |
| Human Pattern | Active pattern count unchanged (30) | PASS |
| GF2 | Production validation re-run passes | PASS |
| Narrative | Evidence present on all profiles | PASS |

Re-run GF2 production validation after copy expansion:

```
dart run test/validation/synthetic_population_v3/analysis/gf2_production_validation_v1_runner.dart
```

GF2 gates remain PASS; unique narrative count updated to 586 (expected — narrative layer change only).

---

## 6. Top Remaining Collapse Clusters

Collapse now occurs at **multi-paragraph fingerprint** level — profiles sharing the same combination of specific copy lines across modes.

| Cluster size | Dominant paragraph combination |
|---:|---|
| 14 | self_directed_identity + directional_meaning + calm_regulator (+ growth/decision lines) |
| 13 | self_directed_identity + directional_meaning + ignored_emotional_dimension |
| 11 | directional_meaning + meaning_seeker + reinforced_strength |
| 10 | expressive_identity + self_directed_identity + … |
| 9 | Multiple variants of identity + meaning + relationship core |

**Root cause:** 436 unique pattern sets map through a 12-paragraph budget (4 modes × 3 max) with deterministic prioritization — many profiles share the same top activations per mode despite distinct upstream fusion inputs.

---

## NARRATIVE_DIVERSITY_STATUS

### Current Narrative Diversity

- **586 unique narratives** / 1000 profiles (**58.6%** narrative diversity ratio)
- **436 unique pattern sets** — pattern layer remains the richer signal
- **Gap:** 150 pattern-set combinations still share narrative fingerprints

### Current Collapse Level

- **400 profiles** in collapse zones (≥3 identical full narratives) — down from 446
- **Max cluster: 14** — down from 16
- **Collapse stage:** primarily **narrative composition** (multi-paragraph assembly), not copy fallback

### Estimated Remaining Diversity Ceiling

| Lever | Estimated headroom |
|---|---:|
| Paragraph ordering / selection variation | +40–80 unique narratives |
| Mode-level copy variants (strength-tier phrasing) | +30–50 unique narratives |
| Interaction pair expansion (remaining catalog rules) | +15–25 unique narratives |
| **Theoretical ceiling at 1000-human scale** | **~650–720 unique narratives** |

Beyond ~720, gains require **plan selection changes** (Narrative Intelligence V3) — outside V1 scope.

### Recommended Next Program

**Narrative Intelligence Selection V3** — vary paragraph plan selection using activation strength tiers and evidence density, while keeping copy registry stable. Target: unique narratives > 650, profiles in collapse < 350, without touching Mirror/GF/HM/HP layers.

Secondary follow-up: **Interaction Catalog Copy Wave 2** — pair-specific copy for remaining theme keys (`speed_vs_balance`, remaining growth-edge themes) once selection V3 reduces combination collision rate.

---

## Artifacts

| Artifact | Path |
|---|---|
| Copy implementation | `lib/features/narrative_runtime/registry/narrative_pattern_copy.dart` |
| Validation runner | `test/validation/synthetic_population_v3/analysis/narrative_copy_expansion_v1_runner.dart` |
| Validation output | `test/validation/synthetic_population_v3/output/narrative_copy_expansion_v1.json` |
| GF2 re-validation | `test/validation/synthetic_population_v3/output/gf2_production_validation_v1.json` |
