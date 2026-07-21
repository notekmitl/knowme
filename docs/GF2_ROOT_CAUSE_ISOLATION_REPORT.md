# GF2 Root Cause Isolation Report

> **HISTORICAL (June 2026).** The pivotal investigation that re-attributed the `stable_orientation` failure to the Human Pattern layer (fixed in [`HUMAN_PATTERN_ACTIVATION_RECOVERY_V2.md`](HUMAN_PATTERN_ACTIVATION_RECOVERY_V2.md)), clearing GF2 to ship ([`GF2_PRODUCTION_IMPLEMENTATION_V1.md`](GF2_PRODUCTION_IMPLEMENTATION_V1.md)). Index: [`PROJECT_INDEX.md`](PROJECT_INDEX.md).

**Program:** GF2 Root Cause Isolation  
**Authority:** [`docs/KNOWME_MASTER_CONTEXT.md`](KNOWME_MASTER_CONTEXT.md), [`docs/GOVERNANCE.md`](GOVERNANCE.md)  
**Generated:** 2026-06-21  
**Scope:** Evidence and ownership only — no implementation, no redesign  
**Primary evidence:** `test/validation/synthetic_population_v3/output/stable_orientation_trace.json`

**Supporting reports:**

- [`stable_orientation_trace_report.md`](stable_orientation_trace_report.md) — Task A
- [`stable_orientation_layer_audit.md`](stable_orientation_layer_audit.md) — Task B
- [`vg002_scope_audit.md`](vg002_scope_audit.md) — Task C

**Trace runner:**

```bash
dart run test/validation/synthetic_population_v3/analysis/stable_orientation_trace_runner.dart
```

---

## 1. Stable Orientation Trace

End-to-end trace of `stable_orientation` across 1000 V3 profiles confirms the failure boundary is **exclusively** at Human Pattern Activation for all GF2-eligible profiles.

### Pipeline funnel

| Stage | Profiles |
|---|---:|
| Total population | 1000 |
| Lens LIFE signal | 774 |
| MV1 LIFE mirror reinforcement | 774 |
| GF2 composed LIFE reinforcement | **258** |
| Human Model LIFE reinforcement pattern | **258** |
| HP selects reinforcement source | **0** |
| `stable_orientation` activated | **0** |

### Termination distribution

| Code | Profiles | Layer |
|---|---:|---|
| `LENS_NO_LIFE_SIGNAL` | 226 | Lens |
| `GF2_NO_LIFE_AGREEMENT` | 516 | GF2 eligibility (R004 requires prior R002 on key) |
| `HP_SOURCE_WRONG_FUSION_FINDING_TYPE` | **258** | **Human Pattern Activation** |

**All 258 profiles where GF2 delivers composed LIFE reinforcement terminate at Human Pattern Activation** — not at GF2, not at Human Model.

### Smoking-gun evidence (every eligible profile)

Human Model snapshot contains **both**:

- `agreement_life_direction_shared_signal` (fusionFindingType: **agreement**)
- `reinforcement_life_direction_core_strength` (fusionFindingType: **reinforcement**)

Activation engine selects the **agreement** pattern first because `_resolveSourcePattern` returns the first human pattern whose `supportingMirrorKeys` contains `MIRROR_LIFE_DIRECTION`.

`stable_orientation` requires `requiredFusionFindingType: reinforcement`. Rule match fails. Reinforcement pattern is never evaluated as source.

---

## 2. Layer Ownership Matrix

| Layer | Verdict | Owns `stable_orientation` failure? |
|---|---|---|
| MV1 | **PASS** | No — 774 LIFE reinforcements |
| MV2 (MP-001) | **PASS** (N/A for LIFE) | No |
| GF1 | **PASS** (frozen by design) | No |
| GF2 Recovery | **PASS** | **No** — 258 LIFE fusion reinforcements |
| Human Model | **PASS** | **No** — 258 reinforcement HM patterns |
| Human Pattern Activation | **FAIL** | **Yes** — 0/258 activations |

Full matrix: [`stable_orientation_layer_audit.md`](stable_orientation_layer_audit.md)

---

## 3. VG-002 Scope Analysis

| GF2 deliverable | Delivered? |
|---|---|
| Source findings (R002 + R004 on LIFE) | **Yes** — 258 profiles |
| Recoveries (composed fusion reinforcement) | **Yes** — 258 profiles |
| Lineage (mirror → fusion → HM) | **Yes** — 258/258 |
| Downstream eligibility (HM reinforcement pattern) | **Yes** — 258/258 |
| HP2 activation | **No** — 0/258 |

**5 of 6** dependent patterns: GF2 delivery and HP consumption both succeed.

**1 of 6** (`stable_orientation`): GF2 delivery succeeds; HP consumption fails.

VG-002 as written measures **composite** (GF2 + HP) behavior. For `stable_orientation`, the composite fails at HP — not at GF2.

Full analysis: [`vg002_scope_audit.md`](vg002_scope_audit.md)

---

## 4. Architectural Ownership

### What GF2 did (measured)

- Created GF2-R002 LIFE supplemental agreements on 258 profiles
- Created GF2-R004 LIFE supplemental reinforcements and composed them into fusion snapshot on those same 258 profiles
- Enabled Human Model to map `reinforcement_life_direction_core_strength` on all 258

### What GF2 did not fail to do

- GF2 **did** generate a valid `stable_orientation` source chain through Human Model
- GF2 **did not** lose reinforcement findings at fusion or mapping boundaries
- The reinforcement human pattern **exists** on every eligible profile

### What Human Pattern Activation did (measured)

- Resolved a source on 258/258 eligible profiles
- Selected **agreement** type on 258/258 (0/258 reinforcement type)
- Failed `requiredFusionFindingType: reinforcement` rule match on 258/258
- Produced **0** `stable_orientation` activations

### Comparison: why `adaptive_creator` works but `stable_orientation` does not

| Pattern | Source resolution | Result |
|---|---|---|
| `adaptive_creator` | Uses `sourceHumanPatternKey: 'adaptive_creator'` — direct key lookup | **235 activations** |
| `stable_orientation` | Uses `requiredMirrorKey` scan — first LIFE pattern wins (agreement) | **0 activations** |

Both depend on GF2-R004 reinforcement recovery on their mirror keys. GF2 succeeds for both. HP activation engine behavior differs due to **frozen registry rule + resolution order**, not GF2 delivery.

---

## 5. Final Verdict

# HUMAN_PATTERN_FAILURE

**Reason:** GF2 generated a valid reinforcement source chain through Human Model on all 258 eligible profiles (`reinforcement_life_direction_core_strength`). The Human Pattern Activation Engine never consumes that source because `_resolveSourcePattern` selects the agreement-type LIFE human pattern first when both agreement (GF2-R002) and reinforcement (GF2-R004) coexist on `MIRROR_LIFE_DIRECTION`. The engine fails type matching for `stable_orientation` (`requiredFusionFindingType: reinforcement`) on 258/258 eligible profiles — producing zero activations despite complete upstream lineage.

---

## Decision Impact on Prior REJECT GF2

The prior **REJECT GF2** decision was based on VG-002 failure attributing `stable_orientation = 0` to the GF2 program boundary.

**This isolation audit proves that attribution was incorrect.**

| Prior assumption | Measured truth |
|---|---|
| GF2 cannot deliver LIFE reinforcement | **False** — 258 profiles |
| Failure is at GF2 recovery layer | **False** — terminates at HP activation |
| VG-002 tests GF2-only behavior | **False for stable_orientation** — tests HP consumption |

**Architectural ownership:** Human Pattern Activation Engine (frozen layer).

**Not in scope of this report:** Whether to revise VG-002 gate scope, split gates by layer, or change REJECT/IMPLEMENT decision. This report delivers ownership evidence only.

---
_Evidence only. No implementation. No redesign._
