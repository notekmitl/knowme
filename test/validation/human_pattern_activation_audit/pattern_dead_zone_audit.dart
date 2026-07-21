import 'package:knowme/features/human_model/builder/human_model_foundation_builder.dart';
import 'package:knowme/features/human_model/contracts/human_model_input.dart';
import 'package:knowme/features/human_model/domain/human_dimension.dart';
import 'package:knowme/features/human_pattern/registry/human_pattern_registry.dart';

import '../synthetic_population/pipeline/synthetic_human_run_record.dart';
import 'pattern_activation_forensics.dart';

/// Audit A — forensic report for never-activated and rare patterns.
class PatternDeadZoneReport {
  const PatternDeadZoneReport({
    required this.populationSize,
    required this.entries,
  });

  final int populationSize;
  final List<PatternDeadZoneEntry> entries;

  List<PatternDeadZoneEntry> get neverActivated =>
      entries.where((item) => item.activationCount == 0).toList();

  Map<String, dynamic> toJson() {
    return {
      'populationSize': populationSize,
      'neverActivatedCount': neverActivated.length,
      'entries': entries.map((item) => item.toJson()).toList(),
    };
  }
}

class PatternDeadZoneEntry {
  const PatternDeadZoneEntry({
    required this.patternId,
    required this.label,
    required this.patternFamilyId,
    required this.dimension,
    required this.activationCount,
    required this.activationRule,
    required this.requiredInputs,
    required this.deadZoneClass,
    required this.primaryBlockReason,
    required this.outcomeDistribution,
    required this.sourceResolutionRate,
    required this.rulePassRate,
    required this.theoreticallyPossible,
    required this.sampleBlockingProfiles,
  });

  final String patternId;
  final String label;
  final String patternFamilyId;
  final String dimension;
  final int activationCount;
  final Map<String, dynamic> activationRule;
  final Map<String, dynamic> requiredInputs;
  final PatternDeadZoneClass deadZoneClass;
  final String primaryBlockReason;
  final Map<String, int> outcomeDistribution;
  final double sourceResolutionRate;
  final double rulePassRate;
  final bool theoreticallyPossible;
  final List<String> sampleBlockingProfiles;

  Map<String, dynamic> toJson() {
    return {
      'patternId': patternId,
      'label': label,
      'patternFamilyId': patternFamilyId,
      'dimension': dimension,
      'activationCount': activationCount,
      'activationRule': activationRule,
      'requiredInputs': requiredInputs,
      'deadZoneClass': deadZoneClass.key,
      'primaryBlockReason': primaryBlockReason,
      'outcomeDistribution': outcomeDistribution,
      'sourceResolutionRate': sourceResolutionRate,
      'rulePassRate': rulePassRate,
      'theoreticallyPossible': theoreticallyPossible,
      'sampleBlockingProfiles': sampleBlockingProfiles,
    };
  }
}

abstract final class PatternDeadZoneAudit {
  static PatternDeadZoneReport analyze(List<SyntheticHumanRunRecord> records) {
    final populationSize = records.length;
    final entries = <PatternDeadZoneEntry>[];

    for (final registryEntry in HumanPatternRegistry.allEntries) {
      final patternId = registryEntry.patternId;
      final rule = registryEntry.activationRule;
      final outcomes = <String, int>{};
      var sourceResolved = 0;
      var rulePassed = 0;
      var activationCount = 0;
      final blockingProfiles = <String>[];

      for (final record in records) {
        final humanModel = HumanModelFoundationBuilder.build(
          HumanModelInput(fusionSnapshot: record.globalFusionSnapshot),
          createdAt: record.generatedAt,
        );

        final diagnosis = PatternActivationForensics.diagnose(
          snapshot: humanModel,
          patternId: patternId,
        );

        outcomes[diagnosis.outcome.key] =
            (outcomes[diagnosis.outcome.key] ?? 0) + 1;

        if (diagnosis.sourcePattern != null) sourceResolved++;
        if (diagnosis.outcome == PatternActivationOutcome.activated) {
          activationCount++;
          rulePassed++;
        } else if (diagnosis.sourcePattern != null &&
            diagnosis.outcome != PatternActivationOutcome.noSourcePattern &&
            diagnosis.outcome != PatternActivationOutcome.noLineageEvidence) {
          // partial rule progress
        } else if (diagnosis.outcome == PatternActivationOutcome.noLineageEvidence) {
          rulePassed++;
        }

        if (!diagnosis.isActivated && blockingProfiles.length < 5) {
          blockingProfiles.add(record.profile.profileId);
        }
      }

      final sourceRate =
          populationSize == 0 ? 0.0 : sourceResolved / populationSize;
      final passRate =
          sourceResolved == 0 ? 0.0 : rulePassed / sourceResolved;

      final primaryBlock = _primaryBlock(outcomes);
      final deadZoneClass = _classify(
        activationCount: activationCount,
        populationSize: populationSize,
        sourceResolutionRate: sourceRate,
        rulePassRate: passRate,
        primaryBlock: primaryBlock,
      );

      entries.add(
        PatternDeadZoneEntry(
          patternId: patternId,
          label: registryEntry.label,
          patternFamilyId: registryEntry.patternFamilyId,
          dimension: registryEntry.dimension.key,
          activationCount: activationCount,
          activationRule: rule.toMap(),
          requiredInputs: {
            'sourceHumanPatternKey': rule.sourceHumanPatternKey,
            'requiredMirrorKey': rule.requiredMirrorKey,
            'requiredDimensionKey': rule.requiredDimensionKey,
            'requiredFusionFindingType': rule.requiredFusionFindingType,
            'minPatternStrength': rule.minPatternStrength,
            'minDimensionActivation': rule.minDimensionActivation,
          },
          deadZoneClass: deadZoneClass,
          primaryBlockReason: primaryBlock,
          outcomeDistribution: outcomes,
          sourceResolutionRate: sourceRate,
          rulePassRate: passRate,
          theoreticallyPossible: sourceRate > 0 && passRate > 0,
          sampleBlockingProfiles: blockingProfiles,
        ),
      );
    }

    entries.sort((a, b) => a.activationCount.compareTo(b.activationCount));
    return PatternDeadZoneReport(
      populationSize: populationSize,
      entries: entries,
    );
  }

  static String _primaryBlock(Map<String, int> outcomes) {
    var bestKey = 'unknown';
    var bestCount = -1;
    for (final entry in outcomes.entries) {
      if (entry.key == PatternActivationOutcome.activated.key) continue;
      if (entry.value > bestCount) {
        bestCount = entry.value;
        bestKey = entry.key;
      }
    }
    return bestKey;
  }

  static PatternDeadZoneClass _classify({
    required int activationCount,
    required int populationSize,
    required double sourceResolutionRate,
    required double rulePassRate,
    required String primaryBlock,
  }) {
    if (activationCount > 0 && activationCount <= 5) {
      return PatternDeadZoneClass.activeButRare;
    }
    if (activationCount > 5) {
      return PatternDeadZoneClass.activeButRare;
    }

    if (sourceResolutionRate == 0) {
      return PatternDeadZoneClass.structurallyImpossible;
    }

    if (rulePassRate == 0) {
      if (primaryBlock == PatternActivationOutcome.dimensionActivationBelowMin.key) {
        return PatternDeadZoneClass.extremelyDifficult;
      }
      return PatternDeadZoneClass.practicallyImpossible;
    }

    if (primaryBlock == PatternActivationOutcome.noLineageEvidence.key) {
      return PatternDeadZoneClass.practicallyImpossible;
    }

    return PatternDeadZoneClass.extremelyDifficult;
  }
}
