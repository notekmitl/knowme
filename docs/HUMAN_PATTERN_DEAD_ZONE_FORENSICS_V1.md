# Human Pattern Dead Zone Forensics V1

> **HISTORICAL (June 2026).** 1000-human per-pattern dead-zone taxonomy that drove the shipped fix in [`HUMAN_PATTERN_ACTIVATION_RECOVERY_V2.md`](HUMAN_PATTERN_ACTIVATION_RECOVERY_V2.md). Retained as the definitive classification matrix. Index: [`PROJECT_INDEX.md`](PROJECT_INDEX.md).

**Program:** Human Pattern Dead Zone Forensics  
**Authority:** [`docs/KNOWME_MASTER_CONTEXT.md`](KNOWME_MASTER_CONTEXT.md), [`docs/GOVERNANCE.md`](GOVERNANCE.md)  
**Generated:** 2026-06-21  
**Scope:** Evidence only — no implementation, no redesign, no production changes

**Population:** 1000 synthetic humans (V3 pipeline, V2 profile factory)  
**Registry:** 41 Human Patterns  
**V1 activation audit baseline:** 21 activated / 20 dead  
**Evidence artifact:** `test/validation/synthetic_population_v3/output/dead_zone_forensics.json`

**Forensics runner:**

```bash
dart run test/validation/synthetic_population_v3/analysis/dead_zone_forensics_runner.dart
```

---

## Method

Each of the 20 V1-dead patterns was traced end-to-end on all 1000 profiles through:

1. V3 baseline pipeline (GF1 only)
2. Validation GF2 recovery simulation (`ValidationV2RecoverySimulator`)
3. `PatternActivationForensics` diagnosis on post-GF2 Human Model snapshots

Per-pattern counterfactual diversity impact was measured **one pattern at a time** (no combined fixes):

- **Category B:** swap only that pattern’s GF2-recovered narrative fingerprint onto V1 baseline; all other profiles stay at V1 baseline
- **Category E:** inject single-pattern activation with correct fusion-finding source onto GF2 baseline; regenerate narrative

Baseline narrative quality (V1): 176 unique narratives, 865 profiles in collapse (≥3 share), max cluster 118  
GF2 simulation quality: 407 unique narratives, 617 profiles in collapse, max cluster 25

---

## 1. Dead Pattern Inventory

Seven forensic questions per pattern (measured on GF2-augmented pipeline unless noted):

| # | Question |
|---|---|
| 1 | Source exists? (lens/mirror signal or HM source key) |
| 2 | Human Model pattern exists? |
| 3 | Fusion finding exists? (GF1 baseline or GF2 composed) |
| 4 | Lineage exists? (HM evidence → HP source) |
| 5 | Activation attempted? (HP source resolved) |
| 6 | Activation blocked? (rule mismatch after source resolution) |
| 7 | Narrative reachable? (registry pattern has dedicated narrative copy) |

### Full inventory

| Pattern | Src | HM | Fusion | Lineage | HP tried | HP blocked | Narr copy | V1 act | GF2 act | Eligible profiles |
|---|---|---|---|---|---|---|---|---:|---:|---:|
| adaptive_creator | Y | Y | GF2 | Y | Y | N | N | 0 | 235 | 235 |
| adaptive_growth | Y | Y | — | Y | Y | N | Y | 0 | 235 | 235 |
| asymmetric_identity_development | N | N | N | N | N | N | N | 0 | 0 | 0 |
| belief_architect | N | N | N | N | N | N | N | 0 | 0 | 0 |
| belief_meaning | N | N | N | N | N | N | N | 0 | 0 | 0 |
| emotional_depth | N | N | N | N | N | N | N | 0 | 0 | 0 |
| identity_dual_signal | Y | N* | N | Y | Y | Y | N | 0 | 0 | 339† |
| internal_conflict_thinker | Y | N* | N | Y | Y | Y | N | 0 | 0 | 198† |
| meaning_seeker | Y | N* | GF2 | Y | Y | N | Y | 0 | 258 | 258 |
| progressive_builder | Y | N* | GF2 | Y | Y | N | Y | 0 | 829 | 829 |
| purpose_driven_motivation | Y | N* | GF2 | Y | Y | partial | N | 0 | 216 | 258 |
| reflective_builder | N | N | N | N | N | N | N | 0 | 0 | 0 |
| reinforced_strength | N‡ | Y | GF1+GF2 | N | N | N | N | 0 | 0 | 939§ |
| relationship_stabilizer | Y | Y | GF2 | Y | Y | N | Y | 0 | 185 | 185 |
| resource_oriented_motivation | N | N | N | N | N | N | N | 0 | 0 | 0 |
| stable_orientation | Y | Y | GF2 | Y | Y | Y | N | 0 | 0 | 258 |
| structured_explorer | N | N | N | N | N | N | N | 0 | 0 | 0 |
| structured_operator | Y | N* | GF2 | Y | Y | N | Y | 0 | 755 | 755 |
| transformation_seeker | N | N | N | N | N | N | N | 0 | 0 | 0 |
| visible_identity | N | N | N | N | N | N | N | 0 | 0 | 0 |

\* HM pattern exists indirectly via mirror-key resolution at HP layer; no typed HM row required for dimension-only rules.  
† Profiles where correct tension-type HM source exists with sufficient strength but HP resolves wrong finding type first.  
‡ No mirror-key signal; fusion reinforcement exists without mirror-key anchor in rule.  
§ HM reinforcement patterns exist; HP `_resolveSourcePattern` returns null (rule has `requiredFusionFindingType` only — no mirror key, source key, or dimension key).

---

## 2. Category Classification

Every V1-dead pattern classified into exactly one category.

| Pattern | Category | Profiles affected | Root cause |
|---|---|---:|---|
| adaptive_creator | **B — SOURCE EXISTS** | 235 | `MIRROR_GROWTH_ORIENTATION` reinforcement reaches HM only after GF2 R004; GF1 fusion = 0 on key |
| adaptive_growth | **B — SOURCE EXISTS** | 235 | Depends on HM `adaptive_creator` source; blocked at V1 until parent chain recovers via GF2 |
| asymmetric_identity_development | **A — TRUE DEAD** | 0 | No `MIRROR_PUBLIC_VISIBILITY` blind-spot signal in population |
| belief_architect | **A — TRUE DEAD** | 0 | No `MIRROR_BELIEF_STRUCTURE` lens signal |
| belief_meaning | **A — TRUE DEAD** | 0 | No `MIRROR_BELIEF_STRUCTURE` lens signal |
| emotional_depth | **A — TRUE DEAD** | 0 | No `MIRROR_INNER_WORLD` lens signal |
| identity_dual_signal | **E — WRONG FINDING TYPE** | 339 (974 blocked) | HP resolves agreement on `MIRROR_SELF_IDENTITY` before tension; rule requires `tension` |
| internal_conflict_thinker | **E — WRONG FINDING TYPE** | 198 (557 blocked) | HP resolves agreement on `MIRROR_THINKING_PATTERN` before tension; rule requires `tension` |
| meaning_seeker | **B — SOURCE EXISTS** | 258 | `MIRROR_LIFE_DIRECTION` blocked at GF1; GF2 R002+R004 restores agreement path |
| progressive_builder | **B — SOURCE EXISTS** | 829 | `MIRROR_GROWTH_ORIENTATION` blocked at GF1; GF2 recovery enables growth-dimension activation |
| purpose_driven_motivation | **B — SOURCE EXISTS** | 216 (42 dim-blocked) | LIFE direction recovered by GF2; 42 profiles fail motivation dimension threshold |
| reflective_builder | **A — TRUE DEAD** | 0 | No `MIRROR_INNER_WORLD` reinforcement signal |
| reinforced_strength | **B — SOURCE EXISTS** | 939 (0 HP resolve) | GF1/GF2 deliver reinforcement findings and HM patterns; HP resolver cannot bind type-only rule (no mirror/source/dimension key) — activation never evaluated |
| relationship_stabilizer | **B — SOURCE EXISTS** | 185 | `MIRROR_RELATIONAL_PATTERN` agreement blocked at GF1; partial GF2 recovery |
| resource_oriented_motivation | **A — TRUE DEAD** | 0 | No `MIRROR_RESOURCE_ORIENTATION` lens signal |
| stable_orientation | **E — WRONG FINDING TYPE** | 258 | GF2 delivers LIFE reinforcement + HM `reinforcement_life_direction_core_strength`; HP selects `agreement_life_direction_shared_signal` first → `HP_SOURCE_WRONG_FUSION_FINDING_TYPE` (proven in [`GF2_ROOT_CAUSE_ISOLATION_REPORT.md`](GF2_ROOT_CAUSE_ISOLATION_REPORT.md)) |
| structured_explorer | **A — TRUE DEAD** | 0 | No `MIRROR_BELIEF_STRUCTURE` agreement path to HM `structured_explorer` |
| structured_operator | **B — SOURCE EXISTS** | 755 | `MIRROR_STRUCTURE_PATTERN` blocked at GF1; GF2 MP-001 + R004 recovery |
| transformation_seeker | **A — TRUE DEAD** | 0 | No `MIRROR_TRANSFORMATION_PATTERN` lens signal |
| visible_identity | **A — TRUE DEAD** | 0 | No `MIRROR_PUBLIC_VISIBILITY` lens signal |

### Category totals

| Category | Count | Patterns |
|---|---:|---|
| **A — TRUE DEAD** | 9 | asymmetric_identity_development, belief_architect, belief_meaning, emotional_depth, reflective_builder, resource_oriented_motivation, structured_explorer, transformation_seeker, visible_identity |
| **B — SOURCE EXISTS** | 8 | adaptive_creator, adaptive_growth, meaning_seeker, progressive_builder, purpose_driven_motivation, reinforced_strength, relationship_stabilizer, structured_operator |
| **C — SHADOWED** | 0 | — |
| **D — ACTIVATES BUT UNUSED** | 0 | — |
| **E — WRONG FINDING TYPE** | 3 | identity_dual_signal, internal_conflict_thinker, stable_orientation |

**Misclassification confirmed:** At least **11 of 20** V1-dead patterns are not truly dead. Only **9** have no recoverable source chain on this population. The V1 audit’s blanket `no_source_pattern` label masked GF1 blocking (Category B) and HP source-selection failures (Category E).

**Post-GF2 simulation:** 7 of 20 V1-dead patterns activate (2,923 total activations). **13 remain dead** (9 true dead + 3 wrong finding type + 1 type-only HP resolver gap).

---

## 3. Ownership Audit

Layer ownership: first **FAIL** boundary in the chain Mirror → GF1 → GF2 → Human Model → Human Pattern → Narrative.

| Pattern | Mirror | GF1 | GF2 | Human Model | Human Pattern | Narrative | Owner |
|---|---|---|---|---|---|---|---|
| adaptive_creator | PASS | **FAIL** | PASS | PASS | PASS | **FAIL** | GF1 |
| adaptive_growth | PASS | **FAIL** | FAIL | PASS | PASS | PASS | GF1 |
| asymmetric_identity_development | **FAIL** | FAIL | FAIL | FAIL | FAIL | FAIL | Mirror |
| belief_architect | **FAIL** | FAIL | FAIL | FAIL | FAIL | FAIL | Mirror |
| belief_meaning | **FAIL** | FAIL | FAIL | FAIL | FAIL | FAIL | Mirror |
| emotional_depth | **FAIL** | FAIL | FAIL | FAIL | FAIL | FAIL | Mirror |
| identity_dual_signal | PASS | **FAIL** | FAIL | FAIL | **FAIL** | FAIL | Human Pattern |
| internal_conflict_thinker | PASS | **FAIL** | FAIL | FAIL | **FAIL** | FAIL | Human Pattern |
| meaning_seeker | PASS | **FAIL** | PASS | FAIL | PASS | PASS | GF1 |
| progressive_builder | PASS | **FAIL** | PASS | FAIL | PASS | PASS | GF1 |
| purpose_driven_motivation | PASS | **FAIL** | PASS | FAIL | PASS | **FAIL** | GF1 |
| reflective_builder | **FAIL** | FAIL | FAIL | FAIL | FAIL | FAIL | Mirror |
| reinforced_strength | FAIL | PASS | PASS | PASS | **FAIL** | FAIL | Human Pattern |
| relationship_stabilizer | PASS | **FAIL** | PASS | PASS | PASS | PASS | GF1 |
| resource_oriented_motivation | **FAIL** | FAIL | FAIL | FAIL | FAIL | FAIL | Mirror |
| stable_orientation | PASS | **FAIL** | PASS | PASS | **FAIL** | **FAIL** | Human Pattern |
| structured_explorer | **FAIL** | FAIL | FAIL | FAIL | FAIL | FAIL | Mirror |
| structured_operator | PASS | **FAIL** | PASS | FAIL | PASS | PASS | GF1 |
| transformation_seeker | **FAIL** | FAIL | FAIL | FAIL | FAIL | FAIL | Mirror |
| visible_identity | **FAIL** | FAIL | FAIL | FAIL | FAIL | FAIL | Mirror |

### Ownership summary

| Layer | Patterns owned (first FAIL) |
|---|---:|
| Mirror | 9 (all Category A) |
| GF1 | 7 (Category B with GF2 recovery path) |
| Human Pattern | 4 (3 Category E + `reinforced_strength`) |
| Narrative | 0 primary owners (downstream of HP); 4 patterns lack narrative copy after successful HP activation |

---

## 4. Diversity Impact Analysis

Counterfactual recovery simulated **one pattern at a time**. Reference baseline: V1 for Category B; GF2 simulation for Category E.

| Pattern | Cat | Δ activations | Δ unique narratives | Δ collapse profiles | Δ max cluster | Δ pattern sets |
|---|---|---:|---:|---:|---:|---:|
| progressive_builder | B | 829 | **+203** | −217 | −92 | +150 |
| structured_operator | B | 755 | **+175** | −191 | −81 | +120 |
| meaning_seeker | B | 258 | **+81** | −70 | −30 | +79 |
| relationship_stabilizer | B | 185 | **+69** | −82 | −11 | +59 |
| purpose_driven_motivation | B | 216 | **+65** | −56 | −19 | +61 |
| adaptive_creator | B | 235 | **+60** | −58 | −34 | +53 |
| adaptive_growth | B | 235 | **+60** | −58 | −34 | +53 |
| stable_orientation | E | 258 | **0** | 0 | 0 | — |
| identity_dual_signal | E | 0 | 0 | 0 | 0 | — |
| internal_conflict_thinker | E | 0 | 0 | 0 | 0 | — |
| reinforced_strength | B | 0 | 0 | 0 | 0 | 0 |

### Key diversity findings

1. **GF1-blocked mirror keys dominate recoverable diversity.** The three mirror dead zones (`MIRROR_GROWTH_ORIENTATION`, `MIRROR_LIFE_DIRECTION`, `MIRROR_STRUCTURE_PATTERN`) account for all large narrative gains when individually recovered from V1 baseline.

2. **`stable_orientation` HP fix alone yields zero narrative diversity gain.** Counterfactual injected 258 activations on GF2 baseline; narrative fingerprint unchanged on all profiles — no dedicated narrative copy exists (`narrativeCopyExists: false`). This is HP-layer recoverable but narrative-layer unreachable today.

3. **Tension patterns (`identity_dual_signal`, `internal_conflict_thinker`) have no GF2 tension recovery path.** Correct-source counterfactual yields 0 additional activations on GF2 baseline because GF2 simulation does not compose tension findings for these keys; HP wrong-type selection is real but downstream narrative impact unmeasurable until fusion delivers tension.

4. **`reinforced_strength` has 939 HM reinforcement rows but 0 recoverable activations** until HP resolver supports type-only rules.

---

## 5. Recovery Priority Ranking

Ranked by potential diversity gain (Δ unique narratives, then Δ activations). Top 10 of 11 recoverable patterns (Categories B + E):

| Rank | Pattern | Category | Δ narratives | Δ activations | Rationale |
|---:|---|---|---:|---:|---|
| 1 | progressive_builder | B | +203 | 829 | Largest single-pattern narrative expansion; growth-family anchor |
| 2 | structured_operator | B | +175 | 755 | Second-largest; unlocks action-family structure path |
| 3 | meaning_seeker | B | +81 | 258 | LIFE direction agreement recovery; has narrative copy |
| 4 | relationship_stabilizer | B | +69 | 185 | Relational agreement recovery; has narrative copy |
| 5 | purpose_driven_motivation | B | +65 | 216 | LIFE direction → motivation cross-dimension |
| 6 | adaptive_creator | B | +60 | 235 | Unlocks motivation reinforcement chain |
| 7 | adaptive_growth | B | +60 | 235 | Dependent on adaptive_creator; has narrative copy |
| 8 | stable_orientation | E | 0 | 258 | High activation potential; blocked at HP source selection; narrative copy missing |
| 9 | reinforced_strength | B | 0 | 0 | 939 HM rows; HP resolver gap |
| 10 | identity_dual_signal | E | 0 | 0 | 339 HP-eligible profiles; needs tension fusion + source fix |

*(Rank 11: `internal_conflict_thinker` — 198 HP-eligible profiles; same tension-path gap as rank 10.)*

---

## 6. Final Summary

### How many of the 20 V1-dead patterns fall into each category?

| Category | Label | Count |
|---|---|---:|
| **A** | Truly dead (no source chain) | **9** |
| **B** | Reachable but blocked (source exists; activation not evaluated at V1) | **8** |
| **C** | Shadowed (higher-priority pattern consumes slot) | **0** |
| **D** | Activated but unused (narrative never consumes) | **0** |
| **E** | Wrong finding type (HP source-selection mismatch) | **3** |

### Verdict

The V1 dead-zone inventory **over-counted true dead patterns by 2×**. Root cause isolation on `stable_orientation` generalizes: **3 patterns fail at Human Pattern source selection (Category E)**, **8 patterns fail at GF1 with recoverable mirror sources (Category B)**, and only **9 patterns are genuinely unreachable** on the 1000-human V3 population (Category A — Mirror layer signal absence).

**GF2 simulation alone recovers 7 of 20** V1-dead patterns without any HP fix. The remaining high-value recovery requires:

1. **GF1/GF2 promotion** for the three mirror dead-zone keys (already validated in simulation for 6 patterns)
2. **HP activation engine source-selection fix** for Category E (`stable_orientation`, tension conflict patterns)
3. **HP resolver extension** for type-only rules (`reinforced_strength`)
4. **Narrative copy expansion** before Category E patterns (`stable_orientation`, `purpose_driven_motivation`, `adaptive_creator`) produce user-visible diversity

No architecture redesign is implied by this evidence. All findings are reproducible from the validation harness only.

---

## Evidence chain

| Artifact | Role |
|---|---|
| `test/validation/synthetic_population_v3/output/dead_zone_forensics.json` | Primary metrics for this report |
| `test/validation/synthetic_population_v3/output/calibration_results.json` | GF2 simulation gate scorecard |
| `test/validation/synthetic_population_v3/output/stable_orientation_trace.json` | Category E proof for `stable_orientation` |
| `docs/GF2_ROOT_CAUSE_ISOLATION_REPORT.md` | Prior isolation — HP failure, not GF2 |
| `test/validation/human_pattern_activation_audit/output/results.json` | V1 200-human audit (superseded for classification) |
