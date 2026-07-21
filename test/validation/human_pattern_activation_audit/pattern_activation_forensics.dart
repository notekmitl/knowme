import 'package:knowme/features/human_model/domain/human_dimension.dart';
import 'package:knowme/features/human_model/domain/human_model_snapshot.dart';
import 'package:knowme/features/human_model/domain/human_pattern.dart';
import 'package:knowme/features/human_pattern/engines/pattern_activation_engine.dart';
import 'package:knowme/features/human_pattern/registry/human_pattern_activation_rule.dart';
import 'package:knowme/features/human_pattern/registry/human_pattern_registry.dart';

/// Why a registry pattern did or did not activate (read-only forensics).
enum PatternActivationOutcome {
  activated('activated'),
  noSourcePattern('no_source_pattern'),
  patternStrengthBelowMin('pattern_strength_below_min'),
  fusionFindingTypeMismatch('fusion_finding_type_mismatch'),
  mirrorKeyMissing('mirror_key_missing'),
  dimensionActivationBelowMin('dimension_activation_below_min'),
  noLineageEvidence('no_lineage_evidence');

  const PatternActivationOutcome(this.key);
  final String key;
}

class PatternActivationDiagnosis {
  const PatternActivationDiagnosis({
    required this.patternId,
    required this.outcome,
    required this.rule,
    this.sourcePattern,
    this.sourcePatternStrength,
    this.requiredMinStrength,
    this.dimensionActivation,
    this.requiredMinDimensionActivation,
    this.requiredMirrorKey,
    this.requiredFusionFindingType,
    this.sourceFusionFindingType,
  });

  final String patternId;
  final PatternActivationOutcome outcome;
  final HumanPatternActivationRule rule;
  final HumanPattern? sourcePattern;
  final double? sourcePatternStrength;
  final double? requiredMinStrength;
  final double? dimensionActivation;
  final double? requiredMinDimensionActivation;
  final String? requiredMirrorKey;
  final String? requiredFusionFindingType;
  final String? sourceFusionFindingType;

  bool get isActivated => outcome == PatternActivationOutcome.activated;

  Map<String, dynamic> toJson() {
    return {
      'patternId': patternId,
      'outcome': outcome.key,
      'rule': rule.toMap(),
      'sourcePatternKey': sourcePattern?.patternKey,
      'sourcePatternStrength': sourcePatternStrength,
      'requiredMinStrength': requiredMinStrength,
      'dimensionActivation': dimensionActivation,
      'requiredMinDimensionActivation': requiredMinDimensionActivation,
      'requiredMirrorKey': requiredMirrorKey,
      'requiredFusionFindingType': requiredFusionFindingType,
      'sourceFusionFindingType': sourceFusionFindingType,
    };
  }
}

/// Read-only activation forensics — mirrors [PatternActivationEngine] with diagnostics.
abstract final class PatternActivationForensics {
  static PatternActivationDiagnosis diagnose({
    required HumanModelSnapshot snapshot,
    required String patternId,
  }) {
    final entry = HumanPatternRegistry.byId(patternId);
    if (entry == null) {
      throw ArgumentError('Unknown patternId: $patternId');
    }

    final rule = entry.activationRule;
    final source = PatternActivationEngine.resolveSourceForAudit(snapshot, rule);
    if (source == null) {
      return PatternActivationDiagnosis(
        patternId: patternId,
        outcome: PatternActivationOutcome.noSourcePattern,
        rule: rule,
        requiredMirrorKey: rule.requiredMirrorKey,
        requiredFusionFindingType: rule.requiredFusionFindingType,
        requiredMinStrength: rule.minPatternStrength,
        requiredMinDimensionActivation: rule.minDimensionActivation,
      );
    }

    if (source.patternStrength < rule.minPatternStrength) {
      return PatternActivationDiagnosis(
        patternId: patternId,
        outcome: PatternActivationOutcome.patternStrengthBelowMin,
        rule: rule,
        sourcePattern: source,
        sourcePatternStrength: source.patternStrength,
        requiredMinStrength: rule.minPatternStrength,
        requiredMirrorKey: rule.requiredMirrorKey,
        requiredFusionFindingType: rule.requiredFusionFindingType,
      );
    }

    if (rule.requiredFusionFindingType != null &&
        source.fusionFindingType != rule.requiredFusionFindingType) {
      return PatternActivationDiagnosis(
        patternId: patternId,
        outcome: PatternActivationOutcome.fusionFindingTypeMismatch,
        rule: rule,
        sourcePattern: source,
        sourcePatternStrength: source.patternStrength,
        requiredFusionFindingType: rule.requiredFusionFindingType,
        sourceFusionFindingType: source.fusionFindingType,
        requiredMirrorKey: rule.requiredMirrorKey,
      );
    }

    if (rule.requiredMirrorKey != null &&
        !source.supportingMirrorKeys.contains(rule.requiredMirrorKey)) {
      final evidenceMatch = snapshot.evidence.any(
        (row) =>
            row.humanPatternId == source.id &&
            row.mirrorKey == rule.requiredMirrorKey,
      );
      if (!evidenceMatch) {
        return PatternActivationDiagnosis(
          patternId: patternId,
          outcome: PatternActivationOutcome.mirrorKeyMissing,
          rule: rule,
          sourcePattern: source,
          sourcePatternStrength: source.patternStrength,
          requiredMirrorKey: rule.requiredMirrorKey,
          requiredFusionFindingType: rule.requiredFusionFindingType,
        );
      }
    }

    double dimensionActivation = 0;
    if (rule.requiredDimensionKey != null) {
      dimensionActivation = snapshot.profile.dimensions
          .where((item) => item.dimensionKey == rule.requiredDimensionKey)
          .map((item) => item.activation)
          .fold(0.0, (max, value) => value > max ? value : max);
      if (dimensionActivation < rule.minDimensionActivation) {
        return PatternActivationDiagnosis(
          patternId: patternId,
          outcome: PatternActivationOutcome.dimensionActivationBelowMin,
          rule: rule,
          sourcePattern: source,
          sourcePatternStrength: source.patternStrength,
          dimensionActivation: dimensionActivation,
          requiredMinDimensionActivation: rule.minDimensionActivation,
          requiredMirrorKey: rule.requiredMirrorKey,
          requiredFusionFindingType: rule.requiredFusionFindingType,
        );
      }
    }

    final hasLineage = snapshot.evidence.any((row) => row.humanPatternId == source.id);
    if (!hasLineage) {
      return PatternActivationDiagnosis(
        patternId: patternId,
        outcome: PatternActivationOutcome.noLineageEvidence,
        rule: rule,
        sourcePattern: source,
        sourcePatternStrength: source.patternStrength,
        dimensionActivation: dimensionActivation,
        requiredMirrorKey: rule.requiredMirrorKey,
        requiredFusionFindingType: rule.requiredFusionFindingType,
      );
    }

    return PatternActivationDiagnosis(
      patternId: patternId,
      outcome: PatternActivationOutcome.activated,
      rule: rule,
      sourcePattern: source,
      sourcePatternStrength: source.patternStrength,
      dimensionActivation: dimensionActivation,
      requiredMirrorKey: rule.requiredMirrorKey,
      requiredFusionFindingType: rule.requiredFusionFindingType,
    );
  }
}

/// Dead-zone feasibility classification from measured population data.
enum PatternDeadZoneClass {
  activeButRare('A_active_but_rare'),
  extremelyDifficult('B_extremely_difficult'),
  practicallyImpossible('C_practically_impossible'),
  structurallyImpossible('D_structurally_impossible');

  const PatternDeadZoneClass(this.key);
  final String key;
}
