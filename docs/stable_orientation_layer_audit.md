# stable_orientation Layer Ownership Audit

**Program:** GF2 Root Cause Isolation — Task B  
**Generated:** 2026-06-21  
**Eligible cohort:** 258 profiles with GF2 composed LIFE reinforcement  
**Evidence:** `test/validation/synthetic_population_v3/output/stable_orientation_trace.json`

---

## Layer Matrix

| Layer | Source exists? | Evidence exists? | Lineage exists? | Output exists? | Verdict |
|---|---|---|---|---|---|
| **MV1** | Yes (774) | Yes (774) | Yes (774) | Yes (774 mirror reinforcements) | **PASS** |
| **MV2 Promotion (MP-001)** | N/A for LIFE | N/A | N/A | Yes (755 STRUCTURE promotions) | **PASS** (not on LIFE path) |
| **GF1** | Yes | Yes | Yes | Blocked by design (frozen) | **PASS** (expected V1 behavior) |
| **GF2 Recovery** | Yes (258 LIFE agreements) | Yes (526 R004 total; 258 LIFE composed) | Yes (258/258 eligible) | Yes (258 fusion LIFE reinforcements) | **PASS** |
| **Human Model** | Yes | Yes | Yes | Yes (258 `reinforcement_life_direction_core_strength`) | **PASS** |
| **Human Pattern Activation** | Yes (258 HM reinforcement patterns) | Yes (258 lineage rows on resolved source) | Yes | **No (0 activations)** | **FAIL** |

---

## Per-Layer Detail

### 1. MV1 — PASS

| Check | Result |
|---|---|
| Source | 774 profiles produce LIFE mirror reinforcements after V3 overlay |
| Evidence | 774 signals with evidenceCount ≥ 2 |
| Lineage | Mirror reinforcement IDs trace to theme signals |
| Output | MV1 `reinforcements` contain `MIRROR_LIFE_DIRECTION` |

MV1 is not the failure boundary for eligible profiles.

### 2. MV2 Promotion — PASS (out of scope for LIFE)

MP-001 targets `MIRROR_STRUCTURE_PATTERN` only. Not required for `stable_orientation`. Promotions occur (755 profiles) but are orthogonal to LIFE reinforcement path.

### 3. GF1 — PASS (frozen gate)

GF1 intentionally produces zero LIFE fusion findings at V1. This is documented dead-zone behavior, not a defect. GF2 exists to recover beyond GF1.

### 4. GF2 Recovery — PASS

| Check | Result |
|---|---|
| Source | 774 MV1 LIFE reinforcements available |
| Evidence | GF2-R002 creates 258 LIFE supplemental agreements |
| Lineage | R004 supplemental reinforcements compose into fusion snapshot |
| Output | **258 composed LIFE fusion reinforcements** |

GF2 successfully creates the reinforcement finding type that `stable_orientation` requires.

### 5. Human Model — PASS

| Check | Result |
|---|---|
| Source | 258 fusion LIFE reinforcements |
| Evidence | HM maps to `reinforcement_life_direction_core_strength` |
| Lineage | `fusionFindingIds`, mirror keys, evidence rows present |
| Output | Reinforcement human pattern exists on all 258 eligible profiles |

Human Model delivers a valid reinforcement source. Both agreement and reinforcement HM patterns coexist on every eligible profile.

### 6. Human Pattern Activation — FAIL

| Check | Result |
|---|---|
| Source | 258 reinforcement HM patterns exist |
| Evidence | 258 profiles have lineage evidence (on agreement source selected first) |
| Lineage | Complete for selected source — wrong source selected |
| Output | **0 `stable_orientation` activations** |

Failure mode: `_resolveSourcePattern` returns first LIFE-supporting pattern (`agreement_life_direction_shared_signal`). Rule requires `requiredFusionFindingType: reinforcement`. Type mismatch → rule fails → no activation.

Reinforcement pattern `reinforcement_life_direction_core_strength` is present in snapshot but **never selected**.

---

## Ownership Summary

| Layer | Owns failure? |
|---|---|
| MV1 | No |
| MV2 | No |
| GF1 | No (by design) |
| GF2 | **No** |
| Human Model | **No** |
| Human Pattern Activation | **Yes** |

---
_Evidence only. No implementation._
