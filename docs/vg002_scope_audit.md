# VG-002 Scope Audit

**Program:** GF2 Root Cause Isolation — Task C  
**Generated:** 2026-06-21  
**Gate:** VG-002 — Dependent pattern reachability (6/6)  
**Evidence:** `test/validation/synthetic_population_v3/output/stable_orientation_trace.json`

---

## Original Intent

VG-002 validates whether **GF2 recovery unlocks dead-zone dependent registry patterns** that were unreachable under V1.

Target patterns tied to dead zones:

| Pattern | Required mirror key | Required fusion type |
|---|---|---|
| `progressive_builder` | GROWTH | agreement |
| `adaptive_creator` | GROWTH | reinforcement |
| `meaning_seeker` | LIFE | agreement |
| `purpose_driven_motivation` | LIFE | agreement |
| `stable_orientation` | LIFE | **reinforcement** |
| `structured_operator` | STRUCTURE | agreement |

Current VG-002 measurement: **HP2 activation count > 0** after GF2 simulation.

---

## Did GF2 Successfully Create…?

### Source findings

| Finding type | LIFE profiles | Verdict |
|---|---:|---|
| GF2-R002 supplemental agreements | 258 | **Yes** |
| GF2-R004 supplemental reinforcements (LIFE composed) | 258 | **Yes** |
| MV1 mirror reinforcements (input to R004) | 774 | **Yes** |

### Recoveries

| Recovery | Count | Verdict |
|---|---:|---|
| Composed fusion LIFE reinforcement | 258 | **Yes** |
| GF2 dead-zone keys recovered (VG-001) | 3/3 | **Yes** |

### Lineage

| Layer | Complete on 258 eligible? |
|---|---|
| Mirror reinforcement → GF2-R004 → fusion reinforcement | **Yes** |
| Fusion reinforcement → HM pattern | **Yes** |
| HM pattern → HP evidence rows | **Yes** (on selected source) |

### Downstream eligibility

| Eligibility signal | Result |
|---|---|
| HM reinforcement pattern exists | **258/258** |
| Pattern rule inputs present (mirror key + reinforcement type in HM) | **258/258** |
| HP2 activation | **0/258** |

GF2 creates full downstream eligibility at Human Model layer. Eligibility is not consumed at Human Pattern layer.

---

## Pattern-by-Pattern VG-002 Interpretation

| Pattern | GF2 creates required source? | HP activates? | VG-002 pass? | GF2 or HP? |
|---|---|---|---|---|
| `progressive_builder` | Yes (GROWTH agreement) | 829 | Yes | GF2 validated |
| `adaptive_creator` | Yes (GROWTH reinforcement via R004) | 235 | Yes | GF2 validated — uses `sourceHumanPatternKey` bypass |
| `meaning_seeker` | Yes (LIFE agreement) | 258 | Yes | GF2 validated |
| `purpose_driven_motivation` | Yes (LIFE agreement) | 216 | Yes | GF2 validated |
| `structured_operator` | Yes (STRUCTURE via MP-001 + GF2) | 755 | Yes | GF2 validated |
| `stable_orientation` | **Yes (LIFE reinforcement via R004)** | **0** | **No** | **HP failure** |

5/6 patterns: GF2 source creation **and** HP consumption align.

1/6 pattern: GF2 source creation **succeeds**; HP consumption **fails** due to source resolution order when agreement and reinforcement coexist on same mirror key.

---

## Scope Conclusion

**VG-002 as currently implemented conflates two responsibilities:**

1. **GF2 recovery delivery** — Did fusion recovery produce the findings required by registry rules?
2. **Human Pattern consumption** — Did the activation engine select the correct source and activate?

For `stable_orientation`, GF2 satisfies (1) on all 258 eligible profiles. Human Pattern Activation fails (2) exclusively.

**Conclusion:** VG-002 failure for `stable_orientation` **does not demonstrate GF2 recovery failure**. It demonstrates that VG-002 measures **Human Pattern activation behavior** for reinforcement-dependent patterns that share a mirror key with agreement patterns also recovered by GF2-R002.

A GF2-only gate would pass LIFE reinforcement delivery. The current composite gate fails because HP2 never consumes the reinforcement source GF2 delivers.

---
_Evidence only. No implementation._
