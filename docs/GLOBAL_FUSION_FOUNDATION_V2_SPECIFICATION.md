# Global Fusion Foundation V2 Specification

**Program:** Global Fusion Foundation V2  
**Status:** Implemented — this design has shipped. See [`GF2_PRODUCTION_IMPLEMENTATION_V1.md`](GF2_PRODUCTION_IMPLEMENTATION_V1.md) for the production wiring and 1000-human validation. This document is retained as the architecture/design reference.  
**Canonical architecture:** Mirror Promotion Rules (MV2 / Tier C) + Supplemental Fusion Findings (GF2 / Tier B)  
**Evidence base:** [`GLOBAL_FUSION_FOUNDATION_VALIDATION_V2.md`](GLOBAL_FUSION_FOUNDATION_VALIDATION_V2.md)  
**Master Context alignment:** Priority 2 — Global Fusion Foundation; Truth First; Evidence Preservation; GF1/MV1 frozen

---

## 0. Scope & Non-Goals

### In scope

- MV2 mirror promotion for MV1-blocked keys
- GF2 supplemental fusion recovery for GF1-filtered keys
- Single composer producing downstream-compatible `GlobalFusionSnapshot`
- Validation harness + runtime integration path (RT1 pipeline)
- Evidence lineage for all recovered findings

### Out of scope (explicit)

- Human Model direct mirror bypass (Option D — rejected)
- Weakening GF1/MV1 core gates in place (Option A — rejected)
- Human Pattern registry or activation rule changes
- Fusion Result V1 UI changes
- Home integration (separate future program gate)
- AI narrative layer

### Frozen layers (unchanged behavior when recovery disabled)

| Layer | Version | Freeze |
|---|---|---|
| MV1 Mirror Engine | `v0.1.0` | Conditional freeze |
| GF1 Foundation | `v1.0.0` | Conditional freeze |
| HM1 Human Model mapper | current | Consumes fusion only |
| HP2 Pattern registry | current | No rule changes |

---

## 1. Architecture Overview

### 1.1 Two-tier recovery stack

```
Lens signals
    ↓
MV1 Mirror Engine (frozen)
    ↓
MV2 Promotion Engine (additive)
    ↓
KnowMeMirrorSnapshot  (= MV1 findings + promotedFindings)
    ↓
GF1 Foundation Builder (frozen)
    ↓
GlobalFusionSnapshot V1
    ↓
GF2 Recovery Builder (additive)
    ↓
GlobalFusionRecoveryComposer
    ↓
GlobalFusionComposedSnapshot  →  HM1  →  HP2  →  Narrative
```

### 1.2 Dead-zone routing (locked)

| Mirror Key | MV2 required | GF2 required | GF2 primary rules |
|---|---|---|---|
| `MIRROR_LIFE_DIRECTION` | No | **Yes** | `GF2-R002`, `GF2-R004` |
| `MIRROR_GROWTH_ORIENTATION` | No | **Yes** | `GF2-R002`, `GF2-R003`, `GF2-R004` |
| `MIRROR_STRUCTURE_PATTERN` | **Yes** (`MP-001`) | **Yes** (`GF2-R002` on promoted sources) | Both tiers |

### 1.3 Version contract

| Component | Version ID | Location |
|---|---|---|
| MV2 Promotion | `mirror.promotion.v1` | `lib/features/mirror_v3/promotion/` |
| GF2 Recovery | `global_fusion.recovery.v2` | `lib/features/global_fusion/v2/` |
| Composed snapshot lineage suffix | `+recovery.v2` | Composer output only |
| GF1 foundation | `v1.0.0` | unchanged |

---

## 2. Promotion Registry (MV2)

### 2.1 Registry location

```
lib/features/mirror_v3/promotion/registry/mirror_promotion_registry.dart
```

Registry is **closed** for V2 launch: exactly **one** active rule. New rules require registry version bump (`mirror.promotion.v2`).

### 2.2 Rule catalog

#### MP-001 — `single_system_evidence_promotion`

| Field | Value |
|---|---|
| **Rule ID** | `single_system_evidence_promotion` |
| **Target mirror keys** | `MIRROR_STRUCTURE_PATTERN` (only) |
| **Purpose** | Promote MV1-blocked single-system evidence to consumable mirror finding |
| **Risk tier** | Medium |
| **Enabled** | `true` |

**Activation conditions (ALL must pass):**

1. `mirrorKey` is in target list.
2. MV1 `agreements` contains **no** entry with this `mirrorKey`.
3. MV1 `reinforcements` contains **no** entry with this `mirrorKey`.
4. At least **1** evidence row exists with matching `mirrorKey`.
5. At least **1** input signal exists with matching `mirrorKey`.
6. Aggregated signal confidence (mean of matching signals) ≥ **0.55**.
7. Distinct `systemId` count on matching signals = **1** (single-system block confirmed).
8. `evidenceCount` on matching evidence rows ≥ **1**.

**Emission:**

- Exactly **1** `KnowMeMirrorPromotedFinding` per `(mirrorScopeId, mirrorKey)` per run.
- `findingType`: `promoted_agreement`
- `patternType`: `promoted_single_system_agreement`
- `confidence`: clamped mean signal confidence, max **0.75** (never exceeds MV1 cross-system agreement ceiling).
- `promotionRuleId`: `single_system_evidence_promotion`
- `sourceSignalIds`: all matching signal IDs
- `sourceEvidenceRowIds`: all matching evidence row IDs

**Non-target keys:** MP-001 does **not** run for `MIRROR_LIFE_DIRECTION` or `MIRROR_GROWTH_ORIENTATION` (those already produce MV1 mirror findings).

### 2.3 Explicitly excluded promotion patterns (locked decisions)

| Pattern | Decision | Reason |
|---|---|---|
| Cross-role evidence promotion at MV2 | **Rejected** | Cross-role coherence is a fusion-scope concern; handled by GF2 |
| Promoting raw signals without evidence rows | **Rejected** | Violates Evidence First |
| Promoting keys with existing MV1 agreement | **Rejected** | Duplicate finding |
| Global single-system promotion for all keys | **Rejected** | Coverage boosting; only STRUCTURE dead zone validated |

### 2.4 Engine execution order

```
KnowMeMirrorEngine.reflect(input)           // MV1 frozen
    ↓
MirrorPromotionEngine.apply(                // MV2
  engineResult: mv1Result,
  input: input,
  registry: MirrorPromotionRegistry.v1,
)
    ↓
KnowMeMirrorSnapshotBuilder.fromEngineResult( // includes promotedFindings
  promotionResult,
)
```

MV2 runs **after** MV1, **before** snapshot serialization. MV1 output is never mutated.

---

## 3. Promotion Finding Contracts (MV2)

### 3.1 Domain type

```dart
class KnowMeMirrorPromotedFinding {
  final String id;                    // promotion:{ruleId}:{mirrorKey}:{scopeHash}
  final String promotionRuleId;       // MP-001 rule id
  final String findingType;           // promoted_agreement | promoted_reinforcement
  final String patternType;           // promoted_single_system_agreement
  final String mirrorKey;
  final String mirrorDimension;       // from registry / signal sample
  final List<String> themeIds;        // sorted unique from source signals
  final List<String> supportingSystems; // single system for MP-001
  final List<String> supportingLensKeys;
  final double confidence;
  final List<String> sourceSignalIds;
  final List<String> sourceEvidenceRowIds;
  final String riskLevel;             // low | medium | high
}
```

### 3.2 Snapshot extension

`KnowMeMirrorSnapshot` gains one additive field:

```dart
final List<KnowMeMirrorPromotedFinding> promotedFindings;
```

**Defaults:** `const []` for backward-compatible deserialization of pre-MV2 snapshots.

**Codec:** New snapshot field `promotedFindings` in map codec. Snapshot version bump:

- `identity.snapshotVersion`: append `+promotion.v1` to structural hash suffix only when `promotedFindings.isNotEmpty`
- `engineVersion`: unchanged (`v0.1.0`); promotion version tracked in `lineage.promotionVersion`

### 3.3 Lineage extension

```dart
class KnowMeMirrorSnapshotLineage {
  // existing fields...
  final String? promotionVersion;       // null = MV2 not applied
  final List<String> promotionRuleIds;  // rules that emitted findings
}
```

### 3.4 Consumer contract

Promoted findings are **agreement-equivalent** for GF2 recovery only. They are **not** injected into MV1 `agreements` list.

GF2 engines MUST treat `promotedFindings` identically to `agreements` when evaluating recoverable single-role sources.

GF1 engines MUST **ignore** `promotedFindings` entirely (frozen).

---

## 4. Supplemental Fusion Contracts (GF2)

### 4.1 Wrapper type (existing, finalized)

```dart
class GlobalFusionRecoveredSnapshot {
  final GlobalFusionSnapshot foundationSnapshot;  // GF1 — immutable reference
  final List<GlobalFusionSupplementalAgreement> supplementalAgreements;
  final List<GlobalFusionSupplementalReinforcement> supplementalReinforcements;
  final List<GlobalFusionSupplementalThemeSignal> supplementalThemeSignals;
  final String recoveryVersion;                   // global_fusion.recovery.v2
  final DateTime createdAt;
}
```

### 4.2 Supplemental finding base fields (all types)

Every supplemental finding MUST include:

| Field | Required | Purpose |
|---|---|---|
| `id` | Yes | Deterministic: `gf_recov_{type}|{mirrorKey}|{roleSignature}|{sourceHash}` |
| `mirrorKey` | Yes | Target key |
| `mirrorDimension` | Yes | From source finding |
| `mirrorRoleIds` | Yes | Sorted; may be single-role for medium-risk |
| `mirrorFindingIds` | Yes | Source MV1 agreement/reinforcement/promoted IDs |
| `themeIds` | Yes | Sorted unique |
| `riskLevel` | Yes | `low` \| `medium` \| `high` |
| `recoveryRuleId` | Yes | From Recovery Rule Registry |
| `sourceFindingIds` | Yes | Full lineage to mirror-layer finding |

### 4.3 Supplemental type mapping to GF1 findings (composer output)

| Supplemental type | Composed GF1 type | Strength field |
|---|---|---|
| `GlobalFusionSupplementalAgreement` | `GlobalFusionCrossMirrorAgreement` | `agreementStrength` |
| `GlobalFusionSupplementalReinforcement` | `GlobalFusionCrossMirrorReinforcement` | `reinforcementBoost` |
| `GlobalFusionSupplementalThemeSignal` | **Not composed** in V2 launch | Audit-only |

**Locked decision:** `supplementalThemeSignals` are collected for audit but **excluded from composer output** in V2 launch. High-risk orphan theme recovery deferred to V2.1.

### 4.4 Eligible source finding sources (GF2 input)

GF2 recovery engines read from each mirror ref:

```
eligibleSources = snapshot.agreements
                + snapshot.reinforcements
                + snapshot.promotedFindings   // MV2 — agreement-equivalent
```

GF2 does **not** read raw signals or evidence rows directly.

---

## 5. Recovery Rule Registry (GF2)

### 5.1 Registry location

```
lib/features/global_fusion/v2/registry/fusion_recovery_rule_registry.dart
```

### 5.2 Execution order (locked)

```
Step 1: FusionCoverageAudit.analyze()           // FCR1 — audit only
Step 2: GF2-R001 reinforcement_agreement_bridge // low risk
Step 3: GF2-R003 single_mirror_reinforcement_recovery // medium risk
Step 4: GF2-R002 single_mirror_agreement_recovery   // medium risk
Step 5: GF2-R004 filtered_mirror_reinforcement_recovery // medium risk
Step 6: FusionCompressionAudit.analyze()        // FCR2
Step 7: RecoverableFindingsAudit.fromSupplemental() // FCR3
```

Rules execute in order; later rules skip `sourceFindingIds` already recovered.

### 5.3 Rule catalog

#### GF2-R001 — `reinforcement_agreement_bridge`

| Field | Value |
|---|---|
| **Risk** | Low |
| **Target keys** | All (not dead-zone specific) |
| **Condition** | Same `mirrorKey` has agreement/promoted-agreement in role A AND reinforcement in role B, `roleIds.length ≥ 2`, key not in GF1 findings |
| **Output** | `GlobalFusionSupplementalReinforcement` |
| **Boost formula** | `(0.12 × roles.length + evidenceCount × 0.04).clamp(0.15, 0.40)` |
| **Prototype** | `SupplementalReinforcementRecoveryEngine` |

#### GF2-R002 — `single_mirror_agreement_recovery`

| Field | Value |
|---|---|
| **Risk** | Medium |
| **Target keys** | `MIRROR_LIFE_DIRECTION`, `MIRROR_GROWTH_ORIENTATION`, `MIRROR_STRUCTURE_PATTERN` + any key filtered by GF3 |
| **Condition** | Single-role MV1 agreement OR MV2 promoted finding; not in GF1 findings; not already recovered |
| **Output** | `GlobalFusionSupplementalAgreement` |
| **Strength** | `source.confidence.clamp(0.0, 0.75)` — capped below true cross-mirror agreement |
| **mirrorRoleIds** | `[singleRoleId]` — explicitly single-role |
| **Prototype** | `SupplementalAgreementRecoveryEngine` |

**Validated impact:** +214 supplemental agreements for LIFE/GROWTH across 200-profile population.

#### GF2-R003 — `single_mirror_reinforcement_recovery`

| Field | Value |
|---|---|
| **Risk** | Medium |
| **Target keys** | All with filtered MV1 reinforcements |
| **Condition** | `reinforcement.evidenceCount ≥ 3`; not fused; not already recovered by R001/R002 |
| **Output** | `GlobalFusionSupplementalReinforcement` |
| **Boost formula** | `(0.10 + evidenceCount × 0.03).clamp(0.15, 0.35)` |
| **mirrorRoleIds** | `[singleRoleId]` |
| **Prototype** | `SupplementalSingleMirrorReinforcementEngine` |

#### GF2-R004 — `filtered_mirror_reinforcement_recovery`

| Field | Value |
|---|---|
| **Risk** | Medium |
| **Target keys** | `MIRROR_GROWTH_ORIENTATION` (primary), any key with GF1-filtered MV1 reinforcement |
| **Condition** | GF1 foundation has supplemental agreement for `mirrorKey` (from R002); MV1 mirror reinforcement exists on same key in same role; reinforcement not in GF1 findings |
| **Output** | `GlobalFusionSupplementalReinforcement` |
| **Boost formula** | `source.structuralWeight.clamp(0.15, 0.35)` |
| **Purpose** | Unlock `adaptive_creator`, `stable_orientation` (require `fusionFindingType: reinforcement`) |

**Locked decision:** R004 runs **after** R002 so agreement precedes reinforcement recovery for dependent HP2 rules.

#### GF2-R005 — `orphan_theme_signal_recovery` (audit-only V2 launch)

| Field | Value |
|---|---|
| **Risk** | High |
| **Composed** | **No** — excluded from composer in V2 launch |
| **Collected** | Yes — in `RecoverableFindingsAudit` high-risk bucket |
| **Prototype** | `SupplementalThemeRecoveryEngine` |

---

## 6. Composer Contracts

### 6.1 Single integration point

```dart
abstract final class GlobalFusionRecoveryComposer {
  static GlobalFusionComposedSnapshot compose({
    required GlobalFusionInput input,
    required GlobalFusionRecoveredSnapshot recovered,
  });
}
```

**All downstream consumers** (HM1, HP2, Narrative) MUST read `composedSnapshot.fusionSnapshot` — never `recovered.foundationSnapshot` directly.

### 6.2 Output type

```dart
class GlobalFusionComposedSnapshot {
  final GlobalFusionSnapshot fusionSnapshot;     // composed GF1-compatible
  final GlobalFusionSnapshot foundationSnapshot; // GF1 frozen reference
  final GlobalFusionRecoveredSnapshot recovery;  // supplemental bundle
  final int supplementalAgreementCount;
  final int supplementalReinforcementCount;
  final DateTime composedAt;
}
```

### 6.3 Composition rules (locked)

1. **Start** from `foundationSnapshot` lists (agreements, tensions, reinforcements, blindSpots).
2. **Append** supplemental agreements → map to `GlobalFusionCrossMirrorAgreement`.
3. **Append** supplemental reinforcements → map to `GlobalFusionCrossMirrorReinforcement`.
4. **Do not modify** GF1 tensions or blind spots in V2 launch.
5. **Do not append** supplemental theme signals in V2 launch.
6. **Re-run** `GlobalFusionEvidencePreserver.preserve()` on composed lists.
7. **Compute new** `structuralHash` with recovery suffix: `{gf1Hash}{supplementalCount.toRadixString(16).padLeft(4,'0')}`.
8. **Compute new** `snapshotId` via `GlobalFusionIdentityContract.snapshotId()` — foundation `snapshotId` preserved in `foundationSnapshot` reference unchanged.

### 6.4 Identity invariants

| Invariant | Rule |
|---|---|
| GF1 snapshot ID | Immutable in `foundationSnapshot` |
| Composed snapshot ID | New ID when supplemental count > 0 |
| `globalFusionId` | Unchanged from foundation |
| `sourceMirrorSnapshotIds` | Unchanged from foundation |
| Lineage `foundationVersion` | `{gf1Version}+recovery.v2` when recovery applied |

### 6.5 Disable switch

```dart
class GlobalFusionRecoveryConfig {
  static const enabled = true;  // validation + RT1 default
}
```

When `enabled == false`:
- Skip MV2 and GF2 entirely
- Pipeline identical to V1 baseline
- Used for regression comparison and frozen-surface paths

---

## 7. Validation Rules

### 7.1 Pre-merge gates (must pass before RT1/Home integration)

| Gate ID | Metric | Baseline (V1) | V2 target | Source |
|---|---|---:|---:|---|
| VG-001 | Dead-zone fusion findings | 0 for all 3 keys | > 0 for all 3 keys | Fusion dead zone trace |
| VG-002 | Dependent pattern reachability | 0 / 6 | **6 / 6** | HP2 activation audit |
| VG-003 | Unique pattern sets (200 pop) | 77 | **≥ 125** | Synthetic population |
| VG-004 | Unique narratives (200 pop) | 82 | **≥ 130** | Synthetic population |
| VG-005 | Collapse zones (≥3 identical) | 22 | **≤ 14** | Narrative collapse audit |
| VG-006 | Narrative diversity ratio | 0.41 | **≥ 0.55** | Synthetic population |
| VG-007 | GF1 snapshot ID stability | — | unchanged when recovery disabled | Regression test |
| VG-008 | Supplemental lineage completeness | — | 100% `sourceFindingIds` non-empty | Recoverable audit |
| VG-009 | MV1 agreement count | — | unchanged when promotion disabled | Regression test |
| VG-010 | Determinism | — | identical output for identical input × 2 runs | Harness test |

### 7.2 Per-key acceptance criteria

| Key | MV2 promoted findings (200 pop) | GF2 supplemental agreements | GF2 supplemental reinforcements | HP2 patterns unlocked |
|---|---:|---:|---:|---|
| `MIRROR_GROWTH_ORIENTATION` | 0 (not MP-001 target) | ≥ 167 | ≥ 47 (via R004) | `progressive_builder`, `adaptive_creator` |
| `MIRROR_LIFE_DIRECTION` | 0 | ≥ 47 | ≥ 0 (via R004 if MV1 reinforcement exists) | `meaning_seeker`, `purpose_driven_motivation`, `stable_orientation` |
| `MIRROR_STRUCTURE_PATTERN` | ≥ 195 profiles (MP-001) | ≥ 195 (via R002 on promoted) | 0 unless MV1 reinforcement exists | `structured_operator` |

### 7.3 Validation harness locations

```
test/validation/global_fusion_foundation_v2/     // trace + gates
test/validation/synthetic_population/              // population re-run
test/global_fusion/v2/                           // unit + integration tests
test/human_pattern_activation_audit_test.dart      // HP2 regression
```

### 7.4 Failure classification

| Failure | Action |
|---|---|
| VG-001..006 fail | Block merge; do not enable RT1 recovery |
| VG-007 or VG-009 fail | Block merge; V1 regression broken |
| VG-008 fail | Block merge; lineage contract violated |
| VG-010 fail | Block merge; non-deterministic recovery |

---

## 8. Evidence Lineage Rules

### 8.1 Chain of custody (required path)

```
Lens signal
  → MV1 evidence row (mirrorKey, sourceThemeId, systemId)
  → MV1 agreement | MV2 promoted finding
  → GF1 finding (cross-mirror) | GF2 supplemental finding
  → GF composed evidence row (GlobalFusionEvidence)
  → HM1 human evidence row (HumanEvidenceRow)
  → HP2 pattern activation lineage
  → Narrative evidence reference
```

No layer may skip upstream finding IDs.

### 8.2 Required lineage fields by layer

| Layer | Required fields |
|---|---|
| MV2 Promoted | `sourceSignalIds`, `sourceEvidenceRowIds`, `promotionRuleId` |
| GF2 Supplemental | `sourceFindingIds`, `recoveryRuleId`, `riskLevel` |
| GF Composed evidence | `globalFindingId`, `mirrorFindingIds`, `mirrorRoleIds`, `mirrorKey`, `sourceThemeId` |
| HM evidence | `humanPatternId`, `mirrorKey`, `systemId`, `fusionFindingId` |

### 8.3 Prohibited lineage patterns

| Pattern | Status |
|---|---|
| Human Model reading mirror snapshots directly | **Forbidden** |
| Supplemental finding without `sourceFindingIds` | **Forbidden** |
| Promoted finding without evidence row reference | **Forbidden** |
| Composed finding without recovery rule ID in audit trail | **Forbidden** |
| Synthetic theme generation to fill gaps | **Forbidden** (Truth Lock) |

### 8.4 Audit artifacts (required per validation run)

```json
{
  "promotionAudit": { "ruleId", "mirrorKey", "promotedCount", "sourceEvidenceRowIds" },
  "coverageAudit": { "fusedCount", "filteredCount", "filteredByRule" },
  "recoverableAudit": { "lowRisk", "mediumRisk", "highRisk" },
  "composedAudit": { "supplementalAgreementCount", "supplementalReinforcementCount" },
  "lineageCompleteness": { "totalSupplemental", "withSourceIds", "rate" }
}
```

Output path: `test/validation/global_fusion_foundation_v2/output/recovery_audit.json`

---

## 9. Risk Tier System

### 9.1 Tier definitions (locked)

| Tier | Meaning | Composed to GF1? | Confidence cap |
|---|---|---|---|
| **Low** | Cross-role bridge from existing MV1 findings of different types | Yes | 0.40 boost max |
| **Medium** | Single-role recovery of filtered MV1 or MV2 promoted finding | Yes | 0.75 agreement / 0.35 reinforcement |
| **High** | Orphan theme/signal without mirror finding | **No** (V2 launch) | N/A |

### 9.2 Rule-to-tier mapping

| Rule | Tier | Composed |
|---|---|---|
| MP-001 | Medium | Via GF2-R002 (not direct to GF1) |
| GF2-R001 | Low | Yes |
| GF2-R002 | Medium | Yes |
| GF2-R003 | Medium | Yes |
| GF2-R004 | Medium | Yes |
| GF2-R005 | High | No (audit only) |

### 9.3 Confidence composition rules

1. Supplemental agreement strength NEVER exceeds **0.75**.
2. Supplemental reinforcement boost NEVER exceeds **0.40**.
3. Composed findings do NOT receive MV1 agreement confidence boost stacking.
4. HM1 `FusionToHumanMapper` uses composed strength as-is; no additional recovery multiplier.
5. HP2 activation thresholds unchanged — recovery must produce sufficient `patternStrength` via normal HM mapping.

### 9.4 Risk disclosure in lineage

Every composed supplemental finding MUST appear in `GlobalFusionLineage` extension:

```dart
class GlobalFusionRecoveryLineage {
  final List<RecoveryLineageEntry> supplementalEntries;
}

class RecoveryLineageEntry {
  final String composedFindingId;
  final String recoveryRuleId;
  final String riskLevel;
  final List<String> sourceFindingIds;
}
```

Stored in composed snapshot metadata — not shown to end users in V2 launch.

---

## 10. Migration Strategy

### 10.1 Phase plan (locked sequence)

| Phase | Scope | Entry criteria | Exit criteria |
|---|---|---|---|
| **P0 — Spec** | This document | Validation V2 complete | Spec approved |
| **P1 — MV2** | Mirror promotion engine + snapshot extension | P0 | VG-009 pass; MP-001 promotes STRUCTURE on 200 pop |
| **P2 — GF2** | Recovery rules R001–R004 + composer | P1 | VG-001..006 pass |
| **P3 — RT1** | `KnowMeRuntimePipeline` uses composed snapshot | P2 | RT1 validation green |
| **P4 — Persistence** | Optional Firestore path for composed snapshots | P3 + explicit approval | Not in V2 launch scope |
| **P5 — Home** | User-facing integration | P4 + product gate | Separate program |

### 10.2 Backward compatibility guarantees

| Consumer | V1 behavior | V2 behavior |
|---|---|---|
| GF1 builder | Unchanged | Unchanged |
| GF1 snapshot consumers (Fusion Result V1) | Unchanged | Unchanged — does not use GF2 |
| RT1 / validation pipeline | V1 path | Opt-in via `GlobalFusionRecoveryConfig.enabled` |
| Mirror snapshot codec | `promotedFindings` defaults to `[]` | Additive field |
| HM1 builder | Reads fusion snapshot | Reads **composed** fusion snapshot in P3 only |

### 10.3 Feature flag contract

```dart
abstract final class GlobalFusionRecoveryConfig {
  /// Master switch — default false in production app until P3 exit.
  static bool enabled = false;

  /// MV2 promotion — requires enabled=true.
  static bool promotionEnabled = true;

  /// GF2 supplemental — requires enabled=true.
  static bool supplementalEnabled = true;

  /// Compose supplemental theme signals (GF2-R005) — default false V2 launch.
  static bool highRiskThemeRecoveryEnabled = false;
}
```

**Locked defaults for validation harness:** `enabled = true`, `highRiskThemeRecoveryEnabled = false`.

**Locked defaults for production app (until P3 exit):** `enabled = false`.

### 10.4 File layout (implementation map)

```
lib/features/mirror_v3/promotion/
  constants/mirror_promotion_version.dart
  domain/knowme_mirror_promoted_finding.dart
  engines/mirror_promotion_engine.dart
  registry/mirror_promotion_registry.dart
  validation/mirror_promotion_validation.dart

lib/features/global_fusion/v2/
  registry/fusion_recovery_rule_registry.dart     // NEW
  domain/global_fusion_composed_snapshot.dart     // NEW
  domain/global_fusion_recovery_lineage.dart      // NEW
  engines/filtered_mirror_reinforcement_recovery_engine.dart  // NEW (R004)
  config/global_fusion_recovery_config.dart       // NEW
  // existing: builder, composer, supplemental engines, audits

lib/features/runtime_integration/pipeline/
  knowme_runtime_pipeline.dart                    // P3: wire composed snapshot
```

### 10.5 Rollback procedure

1. Set `GlobalFusionRecoveryConfig.enabled = false`.
2. Pipeline reverts to GF1-only path with zero behavior change.
3. MV2 promoted findings ignored if snapshot contains them but recovery disabled.
4. No migration of persisted snapshots required (V2 launch has no persistence).

---

## 11. End-to-End Flow (Implementation Reference)

### 11.1 `MIRROR_GROWTH_ORIENTATION` (GF2 only)

```
Thai/BaZi signals
  → MV1 astro agreement (167 profiles)
  → GF1: filtered (single role)
  → GF2-R002: supplemental agreement (167)
  → GF2-R004: supplemental reinforcement from MV1 reinforcements (47)
  → Composer → HM1 → HP2
  → progressive_builder (167), adaptive_creator (47)
```

### 11.2 `MIRROR_LIFE_DIRECTION` (GF2 only)

```
Thai growth_path signals
  → MV1 astro agreement (47 profiles)
  → GF1: filtered
  → GF2-R002: supplemental agreement (47)
  → GF2-R004: if MV1 reinforcement exists on key
  → Composer → HM1 → HP2
  → meaning_seeker (47), purpose_driven_motivation (43), stable_orientation (if R004 fires)
```

### 11.3 `MIRROR_STRUCTURE_PATTERN` (MV2 + GF2)

```
Big Five/BaZi reliable signals
  → MV1: no agreement (single system)
  → MP-001: promoted finding per mirror scope (≤195 profiles per scope)
  → GF1: filtered (promoted findings ignored by GF1)
  → GF2-R002: supplemental agreement from promoted finding
  → Composer → HM1 → HP2
  → structured_operator
```

---

## 12. Implementation Checklist

| # | Deliverable | Depends on |
|---|---|---|
| 1 | `KnowMeMirrorPromotedFinding` + snapshot codec | — |
| 2 | `MirrorPromotionRegistry` + `MirrorPromotionEngine` | 1 |
| 3 | `MirrorPromotionValidation` + MP-001 unit tests | 2 |
| 4 | GF2 `FusionRecoveryRuleRegistry` | — |
| 5 | `FilteredMirrorReinforcementRecoveryEngine` (R004) | 4 |
| 6 | Update GF2 supplemental engines to read `promotedFindings` | 1, 4 |
| 7 | `GlobalFusionComposedSnapshot` + lineage extension | 6 |
| 8 | Update `GlobalFusionRecoveryComposer` | 7 |
| 9 | `GlobalFusionRecoveryConfig` feature flag | 8 |
| 10 | Validation gates VG-001..VG-010 | 9 |
| 11 | RT1 pipeline wiring (P3) | 10 |
| 12 | Population re-validation report | 10 |

---

## 13. Locked Architectural Decisions (No Open Items)

| # | Decision | Resolution |
|---|---|---|
| 1 | Canonical recovery architecture | MV2 (C) + GF2 (B), composed |
| 2 | MV1/GF1 core gate modification | **Never** — additive layers only |
| 3 | Human Model bypass | **Rejected** |
| 4 | MP-001 target keys | `MIRROR_STRUCTURE_PATTERN` only |
| 5 | Cross-role promotion location | GF2, not MV2 |
| 6 | High-risk theme recovery (R005) | Audit-only in V2 launch |
| 7 | Composer single entry point | `GlobalFusionRecoveryComposer.compose()` |
| 8 | Downstream consumer input | `GlobalFusionComposedSnapshot.fusionSnapshot` |
| 9 | Supplemental agreement confidence cap | 0.75 |
| 10 | Reinforcement recovery for HP2 dependents | GF2-R004 after GF2-R002 |
| 11 | Production default | Recovery disabled until P3 exit |
| 12 | Fusion Result V1 UI | Unchanged in V2 program |
| 13 | HP2 registry/rules | Unchanged |
| 14 | Validation population gate | 200 synthetic humans, VG-001..010 |
| 15 | Version IDs | `mirror.promotion.v1`, `global_fusion.recovery.v2` |

---

## 14. References

| Document | Purpose |
|---|---|
| [`GLOBAL_FUSION_FOUNDATION_VALIDATION_V2.md`](GLOBAL_FUSION_FOUNDATION_VALIDATION_V2.md) | Dead-zone evidence |
| [`SYNTHETIC_HUMAN_POPULATION_V1.md`](SYNTHETIC_HUMAN_POPULATION_V1.md) | Population harness |
| [`HUMAN_PATTERN_ACTIVATION_AUDIT_V1.md`](HUMAN_PATTERN_ACTIVATION_AUDIT_V1.md) | HP2 baseline |
| [`KNOWME_MASTER_CONTEXT.md`](KNOWME_MASTER_CONTEXT.md), [`GOVERNANCE.md`](GOVERNANCE.md) | Program authority |
| `lib/features/global_fusion/v2/` | GF2 prototype (upgrade target) |

---
_Global Fusion Foundation V2 Specification — implementation-ready, all decisions locked._
