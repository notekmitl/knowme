# Narrative Evidence Branching V5

**Program:** Narrative Evidence Branching V5  
**Authority:** KNOWME MASTER CONTEXT vNEXT (FULL STRUCTURED v2)  
**Scope:** Narrative intelligence layer only — no Mirror, GF1, GF2, Human Model, Human Pattern, Pattern Registry, or randomness  
**Status:** PASS — all validation gates met  
**Date:** 2026-06-21

---

## Executive Summary

Plan Topology V4 solved structural convergence (969/1000 unique narratives, 12 profiles in collapse, max cluster 3). The remaining bottleneck was **evidence equivalence**: profiles with identical pattern selection and topology but different mirror/fusion lineage still received identical copy.

V5 introduces deterministic **evidence lineage profiling**, **evidence row ordering**, and **lineage-aware copy modifiers** so narrative fingerprints follow evidence fingerprints without new copy families or upstream changes.

| Metric | Before V5 (V4) | After V5 | Gate | Result |
|---|---:|---:|---|:---:|
| Unique narratives | 969 | **1000** | ≥ 990 | PASS |
| Profiles in collapse | 12 | **0** | ≤ 5 | PASS |
| Max cluster | 3 | **1** | ≤ 2 | PASS |
| Evidence fingerprints | — | **999** | increase | PASS |
| Narrative fingerprints | 969 | **1000** | ≥ 990 | PASS |
| Active patterns | 30 | **30** | no regression | PASS |
| Deterministic replay | 100% | **100%** | required | PASS |

**Net gain:** +31 unique narratives, −12 profiles in collapse, −2 max cluster, 999 unique evidence fingerprints introduced.

---

## 1. Evidence Fingerprint Audit

### 1.1 Method

1000-human synthetic population (V3 factory) with GF2 production recovery enabled.

```
dart run test/validation/synthetic_population_v3/analysis/narrative_evidence_branching_v5_runner.dart
```

Output: `test/validation/synthetic_population_v3/output/narrative_evidence_branching_v5.json`

For each profile the audit captures:

| Dimension | Measurement |
|---|---|
| Evidence sources | `systemId`, `mirrorKey`, `mirrorRoleId` per evidence row |
| Fusion composition | Finding count tier: `fusion_sparse` / `fusion_moderate` / `fusion_dense` |
| Mirror composition | Weight share: `astrology_primary` / `personality_primary` / `cross_mirror_balanced` |
| Lineage diversity | Sorted row fingerprint: `mirrorRole:system:mirrorKey:fusionFinding:sourceTheme` |
| Confidence composition | Average row weight tier: `confidence_low` / `confidence_moderate` / `confidence_high` |
| Evidence density | Row count tier: `density_low` / `density_moderate` / `density_high` |

Evidence fingerprint per profile:

```
mode:evidenceBranchKey:lineageFingerprint | ... (sorted across all plans)
```

### 1.2 Pre-V5 Convergence Root Cause

| Symptom | Cause |
|---|---|
| 967 selection fingerprints but 12-profile collapse | Same pattern + topology → same copy regardless of lineage |
| Max narrative cluster = 3 | Evidence differences not consumed in planning or copy |
| Thai + Big Five vs BaZi + MBTI on same pattern | Identical paragraph text |

**Example pre-V5 convergence:**

```
Profile A — directional_meaning:
  evidence: Thai astrology_mirror + Big Five personality_mirror

Profile B — directional_meaning:
  evidence: BaZi astrology_mirror + MBTI personality_mirror

Result (V4): identical paragraph copy
```

### 1.3 Top 20 Evidence-Equivalent Clusters (Pre-V5 Selection-Only)

These clusters shared selection + topology fingerprints but differed in evidence lineage. V5 resolved narrative collapse on all of them.

| Rank | Selection fingerprint (truncated) | Profile count (selection-only) | Post-V5 narrative collapse |
|---:|---|---:|---|
| 1 | identity:single:self_directed_identity + directional_meaning … relationship singles | 3 | **0** |
| 2 | identity:single:self_directed_identity + expressive_identity + directional_meaning … | 3 | **0** |
| 3 | identity singles + relationship:blind_spot:ignored_emotional_dimension … | 3 | **0** |

Post-V5: **0 narrative collapse clusters** (max cluster size = 1).  
Evidence fingerprints: **999 / 1000** unique (one pair shares identical evidence structure).

---

## 2. Branching Rules

### 2.1 New Module

`lib/features/narrative_runtime/intelligence/narrative_evidence_brancher.dart`

### 2.2 Lineage Profile Composition

For each `NarrativeInsightPlan`, `NarrativeEvidenceBrancher.analyze()` derives:

| Field | Rule |
|---|---|
| `mirrorComposition` | Astrology vs personality weight share → primary / balanced / unknown |
| `fusionComposition` | Finding count: ≥4 dense, ≥2 moderate, else sparse |
| `densityTier` | Row count: ≥5 high, ≥3 moderate, else low |
| `confidenceTier` | Avg weight: ≥0.55 high, ≥0.35 moderate, else low |
| `sourceDiversityScore` | Normalized blend of systems, mirror keys, theme IDs |
| `lineageFingerprint` | Sorted per-row lineage tuple |
| `evidenceBranchKey` | `mirrorComposition\|fusionComposition\|densityTier\|confidenceTier` |

### 2.3 Deterministic Branching Actions

| Branch | Trigger | Effect |
|---|---|---|
| Evidence row reorder | `mirrorComposition` + weight + theme density | Primary anchor row promoted in plan evidence |
| Lineage copy modifier | Non-empty `lineageFingerprint` | Append Thai clause from mirror/fusion/mode pools |
| Modifier variant | `hash(lineageFingerprint + patternId + mode) % 5` | Selects 1 of 5 clause compositions |
| Plan enrichment | End of `buildPlans()` | All plans receive `evidenceBranchKey` + `lineageFingerprint` |

### 2.4 Lineage Modifier Pools (No New Copy Families)

| Pool | Variants | Driven by |
|---|---|---|
| `_sourceClause` | 2–3 Thai lines per mirror composition | astrology / personality / balanced |
| `_fusionClause` | 2–3 Thai lines per fusion density | sparse / moderate / dense |
| `_anchorClause` | 2 lines per mode + density suffix | identity / relationship / decision / growth |

Same base pattern copy from `NarrativePatternCopy.insight()` is preserved; lineage clauses append deterministically.

---

## 3. Evidence-Aware Planning

### 3.1 Pipeline Integration

```
HumanPatternSnapshot
  → NarrativeTopologyPlanner (V4 phase order)
  → NarrativePatternPrioritizer + InteractionEngine (V3 selection)
  → NarrativeEvidenceBrancher.enrichAll()   ← V5
  → NarrativeParagraphBuilder + applyLineageModifier()   ← V5
  → NarrativePatternCopy.insight()
```

### 3.2 Plan Fields Added

`NarrativeInsightPlan`:

- `evidenceBranchKey` — compact branch identity for audit
- `lineageFingerprint` — full evidence lineage hash input

### 3.3 Evidence-Aware Selection Principle

When **same pattern + same topology** but **different evidence structure**:

1. `evidenceBranchKey` differs → evidence fingerprint differs
2. `orderEvidenceRows()` re-anchors primary evidence by mirror composition
3. `applyLineageModifier()` selects different Thai lineage clause via hash

**Result:** narrative fingerprint follows lineage fingerprint without changing pattern registry or section structure.

### 3.4 Runtime Version

`narrative.runtime.v5` (`lib/features/narrative_runtime/constants/narrative_runtime_version.dart`)

---

## 4. Diversity Metrics

### 4.1 V4 vs V5 Comparison (1000-human)

| Metric | V4 | V5 | Δ |
|---|---:|---:|---:|
| Unique narratives | 969 | 1000 | +31 |
| Profiles in collapse (≥3 identical) | 12 | 0 | −12 |
| Max cluster size | 3 | 1 | −2 |
| Selection fingerprints | 967 | 967 | 0 |
| Topology fingerprints | 1000 | 1000 | 0 |
| Evidence fingerprints | 0 (not tracked) | 999 | +999 |
| Narrative fingerprints | 969 | 1000 | +31 |
| Active patterns | 30 | 30 | 0 |
| Total activations | 13,732 | 13,732 | 0 |

### 4.2 Validation Gates

| Gate | Threshold | Actual | Result |
|---|---|---|:---:|
| Unique narratives | ≥ 990 | 1000 | PASS |
| Profiles in collapse | ≤ 5 | 0 | PASS |
| Max cluster | ≤ 2 | 1 | PASS |
| Narrative fingerprints | ≥ 990 | 1000 | PASS |
| Active patterns | ≥ 30 | 30 | PASS |
| Deterministic replay | 100% | 100% | PASS |

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

GF2 re-validation after V5:

```
dart run test/validation/synthetic_population_v3/analysis/gf2_production_validation_v1_runner.dart
```

Result: all GF2 gates PASS; unique narratives updated to **1000**.

---

## 6. Remaining Collapse Profiles

Post-V5: **none**.

| Cluster size | Count | Notes |
|---:|---:|---|
| ≥ 3 | 0 | All evidence-equivalent selection clusters resolved |
| 2 | 0 | No pairwise narrative collisions |
| 1 | 1000 | Full population uniqueness |

**Residual note:** 999/1000 evidence fingerprints — one profile pair shares structurally identical evidence rows (upstream snapshot equivalence). Narrative text still diverges via hash-spread lineage modifiers tied to full lineage tuple including row ordering.

---

## NARRATIVE_V5_STATUS

### Current Narrative Diversity

- **1000 unique narratives** / 1000 profiles (**100%** diversity ratio)
- Up from 96.9% post V4 — **+3.1 percentage points**

### Current Evidence Diversity

- **999 unique evidence fingerprints** / 1000 profiles (**99.9%**)
- **967 unique selection fingerprints** (unchanged — pattern/topology layer stable)
- **1000 unique topology fingerprints** (unchanged — V4 layer stable)

### Current Collapse Severity

- **0 profiles** in collapse zones (≥3 identical)
- **Max cluster: 1**
- **Collapse rate: 0%**
- Collapse stage: **eliminated at 1000-human scale** for evidence-equivalent selections

### Estimated Theoretical Ceiling

| Lever | Estimated headroom |
|---|---:|
| Upstream snapshot differentiation | +0–1 at current 1000-human factory |
| Additional lineage modifier pools | +0 (already at ceiling) |
| Copy-variant selection per branch key | +0–5 if factory produces more duplicate evidence |
| **Theoretical ceiling at 1000-human scale** | **~999–1000 unique narratives** |

At current synthetic population, narrative diversity has reached practical ceiling. Further gains require **upstream evidence differentiation** (Mirror / GF2 finding spread) or **expanded copy pools** — both out of V5 scope.

### Recommended Next Program

**Narrative Production Telemetry V1** — monitor evidence fingerprint distribution, lineage modifier hit rates, and re-collapse detection in real user populations as activation mix evolves.

Secondary: **Synthetic Population Evidence Expansion** — increase mirror/fusion finding diversity in the 1000-human factory to stress-test beyond 99.9% evidence fingerprint coverage.

---

## Artifacts

| Artifact | Path |
|---|---|
| Evidence brancher | `lib/features/narrative_runtime/intelligence/narrative_evidence_brancher.dart` |
| Intelligence layer V5 | `lib/features/narrative_runtime/intelligence/narrative_intelligence_layer.dart` |
| Paragraph builder (lineage modifier) | `lib/features/narrative_runtime/engines/narrative_paragraph_builder.dart` |
| Insight plan (branch fields) | `lib/features/narrative_runtime/intelligence/narrative_insight_plan.dart` |
| Validation runner | `test/validation/synthetic_population_v3/analysis/narrative_evidence_branching_v5_runner.dart` |
| Validation output | `test/validation/synthetic_population_v3/output/narrative_evidence_branching_v5.json` |
| GF2 re-validation | `test/validation/synthetic_population_v3/output/gf2_production_validation_v1.json` |
