# stable_orientation Trace Report

**Program:** GF2 Root Cause Isolation — Task A  
**Generated:** 2026-06-21  
**Population:** 1000 synthetic humans (V3 — LIFE reinforcement overlay)  
**Evidence:** `test/validation/synthetic_population_v3/output/stable_orientation_trace.json`

---

## Trace Pipeline

```
Lens → Mirror Signal → Mirror Finding → Promotion → GF2 Recovery → Human Model Pattern → Human Pattern Activation
```

## Stage Reach Counts (1000 profiles)

| Stage | Profiles reaching stage | % of 1000 |
|---|---:|---:|
| Lens LIFE signal | 774 | 77.4% |
| Mirror signal eligible (evidence ≥ 2) | 774 | 77.4% |
| MV1 mirror reinforcement finding | 774 | 77.4% |
| MP-001 promotion (any key) | 755 | 75.5% |
| GF2-R002 LIFE agreement | 258 | 25.8% |
| GF2-R004 recovery (any key) | 526 | 52.6% |
| GF2 composed LIFE reinforcement | **258** | **25.8%** |
| Human Model LIFE reinforcement pattern | **258** | **25.8%** |
| HP source resolved | 258 | 25.8% |
| HP source is reinforcement type | **0** | **0.0%** |
| HP rule matches | **0** | **0.0%** |
| HP lineage evidence | 258 | 25.8% |
| **stable_orientation activated** | **0** | **0.0%** |

## Termination Points (all profiles)

| Termination code | Profiles | Meaning |
|---|---:|---|
| `LENS_NO_LIFE_SIGNAL` | 226 | No LIFE theme in lens input |
| `GF2_NO_LIFE_AGREEMENT` | 516 | MV1 LIFE reinforcement exists but GF2-R002 agreement absent — R004 cannot compose LIFE reinforcement |
| `HP_SOURCE_WRONG_FUSION_FINDING_TYPE` | **258** | Full GF2 + HM chain present; HP resolves wrong source type |

## Eligible Profiles (258 with composed LIFE reinforcement)

**100% terminate at:** `HP_SOURCE_WRONG_FUSION_FINDING_TYPE`

No eligible profile terminates at any GF2, MV1, or Human Model layer.

## Sample Trace (pop2_001_variantc)

| Layer | Status | Evidence |
|---|---|---|
| Lens | PASS | LIFE signal present |
| Mirror signal | PASS | evidenceCount ≥ 2 (V3 overlay) |
| MV1 reinforcement | PASS | astrology mirror reinforcement on LIFE |
| MP-001 | Present | STRUCTURE promotion (not LIFE path) |
| GF2-R002 | PASS | LIFE supplemental agreement |
| GF2-R004 | PASS | reinforcement recovered |
| GF2 composed | PASS | fusion reinforcement on LIFE |
| Human Model | PASS | Two LIFE patterns mapped |

Human Model LIFE patterns on this profile:

| patternKey | fusionFindingType | patternStrength |
|---|---|---:|
| `agreement_life_direction_shared_signal` | **agreement** | 0.55 |
| `reinforcement_life_direction_core_strength` | **reinforcement** | 0.35 |

HP resolution result:

| Field | Value |
|---|---|
| Source resolved | Yes |
| Selected source | `agreement_life_direction_shared_signal` |
| Selected type | **agreement** |
| Required type | **reinforcement** |
| Rule match | **FAIL** |
| Activated | **No** |

## Exact Termination Point

For all 258 GF2-eligible profiles, the chain terminates at:

**Human Pattern Activation Engine — source resolution selects agreement-type human pattern before reinforcement-type pattern.**

Mechanism (frozen code):

```69:72:lib/features/human_pattern/engines/pattern_activation_engine.dart
    if (mirrorKey != null) {
      for (final pattern in snapshot.patterns) {
        if (pattern.supportingMirrorKeys.contains(mirrorKey)) return pattern;
      }
```

```115:117:lib/features/human_pattern/engines/pattern_activation_engine.dart
    if (rule.requiredFusionFindingType != null &&
        source.fusionFindingType != rule.requiredFusionFindingType) {
      return false;
```

GF2 and Human Model deliver both agreement and reinforcement patterns. Activation engine never reaches the reinforcement pattern.

---
_Evidence only. No implementation._
