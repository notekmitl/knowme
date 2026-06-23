# Narrative Plan Topology V4

**Program:** Narrative Plan Topology V4  
**Authority:** [`docs/KNOWME_MASTER_CONTEXT.md`](KNOWME_MASTER_CONTEXT.md), [`docs/GOVERNANCE.md`](GOVERNANCE.md)  
**Scope:** Narrative intelligence layer only — no Mirror, GF1, GF2, Human Model, Human Pattern, or copy changes  
**Status:** PASS — all validation gates met  
**Date:** 2026-06-21

---

## Executive Summary

Selection V3 raised unique narratives to 875 (87.5%) but 76 profiles still collapsed because identical **plan topologies** (blind spot → interaction → compression → singles) produced identical pattern selections despite different evidence. V4 introduces deterministic **phase-order branching** per mode, cross-mode evidence rebalancing, and hash-spread secondary slot picks — breaking structural convergence without new copy, patterns, or sections.

| Metric | Before V4 (V3) | After V4 | Gate | Result |
|---|---:|---:|---|:---:|
| Unique narratives | 875 | **969** | ≥ 930 | PASS |
| Profiles in collapse | 76 | **12** | ≤ 40 | PASS |
| Max cluster | 6 | **3** | ≤ 4 | PASS |
| Topology fingerprints | 860 | **1000** | ≥ 920 | PASS |
| Selection fingerprints | 860 | **967** | increase | PASS |
| Active patterns | 30 | **30** | no regression | PASS |
| Deterministic replay | 100% | **100%** | required | PASS |

**Net gain:** +94 unique narratives, −64 profiles in collapse, −3 max cluster, +140 topology fingerprints (860 → 1000 unique).

---

## 1. Topology Audit

### 1.1 Method

1000-human synthetic population (V3 factory) with GF2 production recovery enabled.

```
dart run test/validation/synthetic_population_v3/analysis/narrative_plan_topology_v4_runner.dart
```

Output: `test/validation/synthetic_population_v3/output/narrative_plan_topology_v4.json`

For each profile the audit captures:

| Dimension | Measurement |
|---|---|
| Topology shape | Per-mode preset name (standard, interactionFirst, etc.) |
| Interaction allocation | Agreement / tension / growthEdge / blind spot / compressed counts |
| Mode allocation | Paragraph plans per mode (max 3 each) |
| Evidence allocation | Mode evidence density, source diversity, fusion diversity |
| Source allocation | Mirror roles, fusion finding spread |

### 1.2 Pre-V4 Convergence Root Cause

| Symptom | Cause |
|---|---|
| 860 selection fingerprints but 76-profile collapse | Same phase order → same pattern consumption order |
| Max narrative cluster = 6 | Identical topology + identical top patterns → identical copy sequence |
| Different evidence, same plan shape | Fixed pipeline: blind spot → interaction → compression → singles |

**Example pre-V4 convergence:**

```
Profile A & B (different structuralHash, same activations):
  identity:     single → single → single
  relationship: single → single → single
  decision:     agreement → single
  growth:       single → single → compressed
```

V3 scoring changed *which* patterns filled slots but not *when* phases consumed them — profiles with overlapping activations still converged.

### 1.3 Top Collapse Clusters (Pre-V4)

| Cluster size | Dominant narrative signature |
|---:|---|
| 6 | self_directed_identity + directional_meaning + responsive_feeler core |
| 5 | + expressive_identity variant |
| 4 | + blind_spot / interaction variants of same core |

All clusters shared **standard or anchorSingles topology** on identity + **standard topology** on relationship.

---

## 2. Topology Expansion Rules

### 2.1 New Module

`lib/features/narrative_runtime/intelligence/narrative_plan_topology.dart`

### 2.2 Topology Presets (7)

Each preset defines a **phase execution order** within a mode:

| Preset | Phase order |
|---|---|
| `standard` | blind spot → interaction → compression → singles |
| `interactionFirst` | interaction → singles → blind spot → compression |
| `evidenceDense` | compression → interaction → singles → blind spot |
| `anchorSingles` | singles → blind spot → interaction → compression |
| `tensionAnchor` | interaction (tension-first) → blind spot → singles → compression |
| `blindSpotAnchor` | blind spot → singles → interaction → compression |
| `growthFirst` | compression → singles → interaction → blind spot |

### 2.3 Deterministic Topology Resolution

1. **Analyze** per-mode evidence profiles (density, source diversity, fusion diversity, blind spot / tension / compression signals)
2. **Rank modes** by composite evidence score (cross-mode rebalancing)
3. **Build candidate pool** from evidence-eligible presets (mode-specific + rank-based)
4. **Pick preset** via `hash(structuralHash + mode) × pool.length` — same profile always gets same topology

Cross-mode examples:

| Profile signal | Identity topology | Relationship topology |
|---|---|---|
| Strongest evidence in relationship | `anchorSingles` | `blindSpotAnchor` or `interactionFirst` |
| Strongest evidence in growth | `standard` | `standard` | `growthFirst` |
| Decision tension rules active | `tensionAnchor` on decision mode | varies by hash |

### 2.4 Phase Arbitration Rules

| Rule | Trigger | Effect |
|---|---|---|
| `shouldSkipCompression` | evidenceDense/growthFirst topology + hash ≥ 0.82 | Skip compression phase → more singles diversity |
| `shouldSkipInteractions` | hash ≥ 0.875 (except interactionFirst/tensionAnchor) | Skip interaction phase |
| `maxInteractionPlans` | interactionFirst: 2; tensionAnchor: 1; else: 1 | Limits interaction consumption |
| `singlePickIndex` slot 0 | hash bands OR index 0 | Primary slot stays strength-biased |
| `singlePickIndex` slot ≥ 1 | `hash(structuralHash + slot + topology) × candidates` | Spreads secondary/tertiary picks |

### 2.5 Files Modified

| File | Change |
|---|---|
| `narrative_plan_topology.dart` | **New** — topology presets, resolver, fingerprints |
| `narrative_intelligence_layer.dart` | Phase-ordered plan builder (V4) |
| `narrative_selection_scorer.dart` | Topology-aware tie-break in ranking |
| `narrative_runtime_version.dart` | `narrative.runtime.v4` |

**Unchanged:** `narrative_pattern_copy.dart`, pattern registry, sections, paragraph budget (4 modes × 3 max).

---

## 3. Cross-Mode Rebalancing

### 3.1 Mode Evidence Ranking

Modes ranked by:

```
composite = evidenceDensity×0.40 + sourceDiversity×0.25 + fusionDiversity×0.20 + activationCountNorm×0.15
```

### 3.2 Rank → Topology Bias

| Evidence rank | Topology bias |
|---|---|
| 0 (strongest) | evidenceDense or interactionFirst |
| 1 | interactionFirst |
| 2 | standard or blindSpotAnchor (hash) |
| 3 (weakest) | anchorSingles or interactionFirst (hash) |

### 3.3 Divergence Example

Two profiles sharing `self_directed_identity` as dominant identity pattern:

| | Profile A | Profile B |
|---|---|---|
| Strongest mode | relationship | growth |
| Identity topology | anchorSingles | evidenceDense |
| Relationship topology | blindSpotAnchor | standard |
| Growth topology | growthFirst | interactionFirst |
| Result | Different phase consumption → different pattern sets → different narrative |

---

## 4. Diversity Metrics

### 4.1 V3 vs V4 (1000-human)

| Metric | V3 | V4 | Δ |
|---|---:|---:|---:|
| Unique narratives | 875 | 969 | **+94** |
| Unique selection fingerprints | 860 | 967 | **+107** |
| Unique topology fingerprints | 860 | 1000 | **+140** |
| Unique topology shapes | — | 610 | — |
| Profiles in collapse | 76 | 12 | **−64** |
| Max cluster | 6 | 3 | **−3** |
| Pattern activations | 13,732 | 13,732 | 0 |

### 4.2 Validation Gates

| Gate | Target | Measured | Pass |
|---|---|---|:---:|
| Unique narratives | ≥ 930 | 969 | ✓ |
| Profiles in collapse | ≤ 40 | 12 | ✓ |
| Max cluster | ≤ 4 | 3 | ✓ |
| Topology fingerprints | ≥ 920 | 1000 | ✓ |
| Active patterns | 30 | 30 | ✓ |
| Deterministic replay | 100% | 1000/1000 | ✓ |

---

## 5. Regression Audit

| Layer | Check | Result |
|---|---|:---:|
| Mirror | Fingerprint present on all profiles | PASS |
| GF1 | Foundation hash preserved | PASS |
| Human Model | Deterministic replay on GF1 input | PASS |
| Human Pattern | Total activations = 13,732 | PASS |
| Human Pattern | Active patterns = 30 | PASS |
| GF2 | Production validation re-run | PASS |
| Narrative | Deterministic replay | PASS |

GF2 re-validation after V4:

```
dart run test/validation/synthetic_population_v3/analysis/gf2_production_validation_v1_runner.dart
```

Result: all GF2 gates PASS; unique narratives updated to 969.

---

## 6. Remaining Collapse Clusters

Post-V4 collapse is minimal (12 profiles, max cluster 3).

| Cluster size | Notes |
|---:|---|
| 3 | Residual — identical activation set + identical evidence + hash collision on all slots |
| 3 | Variant with blind spot ordering difference but same copy output |
| 3 | Mixed interaction/single shape with identical final copy |

**Root cause:** Profiles with fully identical `HumanPatternSnapshot` structural hash and activation/evidence composition cannot diverge further without upstream layer changes.

---

## NARRATIVE_TOPOLOGY_STATUS

### Current Narrative Diversity

- **969 unique narratives** / 1000 profiles (**96.9%** diversity ratio)
- Up from 87.5% post V3 — **+9.4 percentage points**

### Current Topology Diversity

- **1000 unique topology fingerprints** / 1000 profiles (**100%**)
- **610 unique topology shapes** (preset + interaction-type sequence without pattern IDs)
- **967 unique selection fingerprints**

### Current Collapse Severity

- **12 profiles** in collapse zones (≥3 identical) — down from 76
- **Max cluster: 3** — down from 6
- **Collapse rate: 1.2%** — down from 7.6%
- Collapse stage: **residual hash collision** on identical snapshots only

### Estimated Ceiling Before Narrative V5

| Lever | Estimated headroom |
|---|---:|
| Slot-0 hash spread (currently strength-first) | +5–15 unique narratives |
| Conditional paragraph reordering by topology | +10–20 unique narratives |
| Evidence-threshold plan branching (V5) | +15–25 unique narratives |
| **Theoretical ceiling at 1000-human scale** | **~985–995 unique narratives** |

Beyond ~995, gains require **upstream snapshot differentiation** or **copy-variant selection** (V5+).

### Recommended Next Program

**Narrative Evidence Branching V5** — introduce deterministic plan branches when evidence margin between top-2 candidates falls below threshold (e.g. emit alternate interaction plan vs single plan based on fusion finding density). Target: unique narratives > 985, profiles in collapse ≤ 5, max cluster ≤ 2.

Secondary: **Production Topology Telemetry** — monitor topology fingerprint distribution in real user populations to detect re-collapse if activation mix shifts.

---

## Artifacts

| Artifact | Path |
|---|---|
| Topology planner | `lib/features/narrative_runtime/intelligence/narrative_plan_topology.dart` |
| Intelligence layer V4 | `lib/features/narrative_runtime/intelligence/narrative_intelligence_layer.dart` |
| Selection scorer (topology tie-break) | `lib/features/narrative_runtime/intelligence/narrative_selection_scorer.dart` |
| Validation runner | `test/validation/synthetic_population_v3/analysis/narrative_plan_topology_v4_runner.dart` |
| Validation output | `test/validation/synthetic_population_v3/output/narrative_plan_topology_v4.json` |
| GF2 re-validation | `test/validation/synthetic_population_v3/output/gf2_production_validation_v1.json` |
