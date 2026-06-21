# Narrative Intelligence Selection V3

**Program:** Narrative Intelligence Selection V3  
**Authority:** KNOWME MASTER CONTEXT vNEXT (FULL STRUCTURED v2)  
**Scope:** Narrative intelligence layer only — no Mirror, GF1, GF2, Human Model, or Human Pattern changes  
**Status:** PASS — all validation gates met  
**Date:** 2026-06-21

---

## Executive Summary

Copy expansion (V1) raised unique narratives from 552 → 586 but collapse remained high (400 profiles, max cluster 14) because V2 selection always picked the same dominant patterns in strength order. V3 introduces deterministic, evidence-aware selection scoring that diverges paragraph plans when upstream evidence differs — even when top activations match.

| Metric | Before V3 (post copy V1) | After V3 | Gate | Result |
|---|---:|---:|---|:---:|
| Unique narratives | 586 | **875** | ≥ 650 | PASS |
| Profiles in collapse | 400 | **76** | ≤ 320 | PASS |
| Max cluster | 14 | **6** | ≤ 10 | PASS |
| Selection fingerprints | ~436 | **860** | increase | PASS |
| Active patterns | 30 | **30** | no regression | PASS |
| Deterministic replay | — | **100%** | required | PASS |

**Net gain:** +289 unique narratives, −324 profiles in collapse, −8 max cluster, +424 unique selection fingerprints.

---

## 1. Fingerprint Audit

### 1.1 Method

1000-human synthetic population (V3 factory) with GF2 production recovery enabled. For each profile the audit captures:

1. Selected patterns per mode (from `NarrativeInsightPlan.referencedPatternIds`)
2. Discarded patterns (activated but not referenced in plans)
3. Interaction plans (agreement / tension / growthEdge)
4. Compression plans (compressed family clusters)
5. Mode allocation (up to 3 paragraphs × 4 modes)

Audit runner:

```
dart run test/validation/synthetic_population_v3/analysis/narrative_intelligence_selection_v3_runner.dart
```

Output: `test/validation/synthetic_population_v3/output/narrative_intelligence_selection_v3.json`

### 1.2 Pre-V3 Selection Bottleneck

| Symptom | Root cause |
|---|---|
| 436 unique pattern sets → 586 unique narratives | Selection collapsed upstream diversity |
| Max selection cluster ≈ pattern-set cluster | Strength-first ordering ignored evidence composition |
| Identical top-3 patterns across modes | Fixed priority: blind spot → interaction → compression → strength singles |
| Interaction rules in catalog order | Same pairs always won regardless of evidence density |

**Pre-V3 dominant selection fingerprint (conceptual):**

```
identity:single:self_directed_identity
identity:single:directional_meaning
relationship:single:calm_regulator
relationship:single:responsive_feeler
decision:agreement:structured_operator+accountable_operator
growth:single:reinforced_strength
growth:single:progressive_builder
```

This fingerprint appeared in **14+ profiles** with identical narrative text after copy V1.

### 1.3 Top 20 Selection Fingerprints (After V3)

Max selection fingerprint cluster reduced from **14 → 6** profiles.

| Rank | Profile count | Dominant selection signature |
|---:|---:|---|
| 1 | 6 | self_directed + directional_meaning + responsive_feeler + calm_regulator + diplomatic_binder + decision agreement |
| 2 | 5 | self_directed + expressive_identity + directional_meaning + relationship triple |
| 3 | 4 | self_directed + directional_meaning + relationship triple + decision single variant |
| 4 | 4 | + blind_spot:ignored_emotional_dimension |
| 5 | 4 | + blind_spot:ignored_emotional_dimension (relationship stabilizer variant) |
| 6 | 4 | calm_regulator first ordering variant |
| 7 | 4 | expressive_identity + blind_spot combination |
| 8 | 4 | blind_spot + stabilizer variant |
| 9 | 4 | calm_regulator ordering variant |
| 10 | 3 | + stable_orientation in identity slot 3 |
| 11 | 3 | + decision tension variant |
| 12 | 3 | + growth single variant |
| 13 | 3 | + meaning_seeker in identity |
| 14 | 3 | + relational_hidden_potential blind spot |
| 15–20 | 3 each | Mixed interaction / blind spot / third identity slot variants |

**Key shift:** 860 unique selection fingerprints vs 436 unique pattern sets — selection now diverges for **424 additional profiles** compared to activation-only diversity.

---

## 2. Selection Expansion Rules

### 2.1 New Module

`lib/features/narrative_runtime/intelligence/narrative_selection_scorer.dart`

Deterministic composite scoring using existing snapshot evidence only (no randomness, no registry changes).

### 2.2 Scoring Signals

| Signal | Source | Purpose |
|---|---|---|
| Evidence density | Pattern evidence row count + weight sum | Prefer patterns with richer lineage |
| Source diversity | Unique mirror roles, keys, systems, themes | Diverge when fusion/mirror mix differs |
| Fusion finding diversity | Unique fusionFindingId + humanModelPatternId | Surface distinct upstream paths |
| Confidence composite | `PatternConfidence.composite` | Weight HP confidence spread |
| Evidence diversity | `PatternConfidence.evidenceDiversityScore` | Prefer under-surfaced supporting patterns |
| Activation balance | Strength rank bonus for non-dominant patterns | Rotate slot 2–3 away from always-strongest |
| Profile tie-break | Hash(`structuralHash` + `patternId` + mode + slot) | Deterministic per-profile divergence |

### 2.3 Slot-Bias Weight Profiles

Singles selection uses rotating weight profiles by paragraph slot index:

| Slot bias | Strength | Evidence diversity | Source diversity | Tie-break |
|---|---:|---:|---:|---:|
| 0 (first single) | 0.38 | 0.16 | 0.08 | 0.03 |
| 1 (second single) | 0.18 | 0.24 | 0.12 | 0.03 |
| 2 (third single) | 0.12 | 0.18 | 0.22 | 0.06 |

Profiles sharing the same top activation now diverge on slots 1–2 when supporting evidence differs.

### 2.4 Phase-Level Changes

| Phase | V2 behavior | V3 behavior |
|---|---|---|
| Blind spot | Strength order | Evidence-ranked blind spots |
| Interaction | Catalog order | Rule score = sum of matched pattern scores + theme tie-break |
| Compression | Set iteration order | Family cluster score = density + diversity + size |
| Singles | Strength order loop | While-loop with slot-bias ranking |
| Prioritizer | Strength-only tiers | Evidence-aware ranked tiers |

### 2.5 Files Modified

| File | Change |
|---|---|
| `narrative_selection_scorer.dart` | **New** — scoring + fingerprint helper |
| `narrative_intelligence_layer.dart` | V3 selection pipeline |
| `narrative_pattern_prioritizer.dart` | Evidence-aware tier classification |
| `narrative_runtime_version.dart` | `narrative.runtime.v3` |

**Unchanged:** `narrative_pattern_copy.dart`, interaction catalog rules, paragraph builder, section structure.

---

## 3. Diversity Metrics

### 3.1 Before vs After (1000-human)

| Metric | Copy V1 (before V3) | V3 (after) | Δ |
|---|---:|---:|---:|
| Unique narratives | 586 | 875 | **+289** |
| Unique selection fingerprints | ~436 | 860 | **+424** |
| Profiles in collapse | 400 | 76 | **−324** |
| Max cluster | 14 | 6 | **−8** |
| Unique pattern sets | 436 | 436 | 0 |
| Total activations | 13,732 | 13,732 | 0 |
| Pattern coverage | 100% | 100% | 0 |

### 3.2 Validation Gates

| Gate | Target | Measured | Pass |
|---|---|---|:---:|
| Unique narratives | ≥ 650 | 875 | ✓ |
| Profiles in collapse | ≤ 320 | 76 | ✓ |
| Max cluster | ≤ 10 | 6 | ✓ |
| Active patterns | 30 | 30 | ✓ |
| Deterministic replay | 100% | 1000/1000 | ✓ |

---

## 4. Regression Audit

| Layer | Check | Result |
|---|---|:---:|
| Mirror | Fingerprint present on all profiles | PASS |
| GF1 | Foundation hash preserved | PASS |
| Human Model | Deterministic replay on GF1 input | PASS |
| Human Pattern | Total activations = 13,732 | PASS |
| Human Pattern | Active patterns = 30 | PASS |
| GF2 | Production validation re-run | PASS |
| Narrative | Deterministic replay (same snapshot → same fingerprint) | PASS |

GF2 production re-validation after V3:

```
dart run test/validation/synthetic_population_v3/analysis/gf2_production_validation_v1_runner.dart
```

Result: all GF2 gates PASS; unique narratives updated to 875 (narrative-layer change only).

---

## 5. Top Remaining Collapse Clusters

Collapse is now rare and small. Remaining clusters share both **selection fingerprint** and **copy combination**.

| Cluster size | Dominant narrative combination |
|---:|---|
| 6 | self_directed_identity + directional_meaning + responsive_feeler + calm_regulator + diplomatic_binder |
| 5 | + expressive_identity |
| 4 | blind_spot / interaction variants of above core |
| 3 | + stable_orientation, meaning_seeker, or tension interaction variants |

**Root cause:** Profiles with identical activation sets AND identical evidence composition still receive identical plans. Further gains require plan-level variation beyond evidence scoring (V4).

---

## NARRATIVE_SELECTION_STATUS

### Current Narrative Diversity

- **875 unique narratives** / 1000 profiles (**87.5%** diversity ratio)
- Up from 58.6% post copy V1 — **+28.9 percentage points**

### Current Narrative Fingerprints

- **860 unique selection fingerprints** / 1000 profiles (**86.0%**)
- Gap to pattern sets narrowed: 436 pattern sets → 860 selection plans (only 24 profiles share selection fingerprint with a duplicate narrative source)

### Current Collapse Severity

- **76 profiles** in collapse zones (≥3 identical) — down from 400
- **Max cluster: 6** — down from 14
- **Collapse rate: 7.6%** — down from 40.0%
- Collapse stage: residual — identical activation + identical evidence + identical selection

### Estimated Ceiling Before Narrative V4

| Lever | Estimated headroom |
|---|---:|
| Slot rotation when evidence scores tie | +20–40 unique narratives |
| Interaction vs single arbitration by evidence margin | +15–30 unique narratives |
| Cross-mode pattern rebalancing | +10–20 unique narratives |
| **Theoretical ceiling at 1000-human scale** | **~920–960 unique narratives** |

Beyond ~960, gains require **Narrative V4 plan topology** (variable paragraph ordering, conditional interaction suppression, evidence-threshold plan branching) — outside V3 scope.

### Recommended Next Program

**Narrative Plan Topology V4** — introduce deterministic plan branching when evidence margin between candidates is below threshold (e.g. prefer single over interaction when pair evidence diversity < 0.15). Target: unique narratives > 920, profiles in collapse < 40, max cluster ≤ 4.

Secondary: **Selection Fingerprint Telemetry** — production analytics on selection fingerprint distribution to detect re-collapse in real user populations.

---

## Artifacts

| Artifact | Path |
|---|---|
| Selection scorer | `lib/features/narrative_runtime/intelligence/narrative_selection_scorer.dart` |
| Intelligence layer V3 | `lib/features/narrative_runtime/intelligence/narrative_intelligence_layer.dart` |
| Validation runner | `test/validation/synthetic_population_v3/analysis/narrative_intelligence_selection_v3_runner.dart` |
| Validation output | `test/validation/synthetic_population_v3/output/narrative_intelligence_selection_v3.json` |
| GF2 re-validation | `test/validation/synthetic_population_v3/output/gf2_production_validation_v1.json` |
