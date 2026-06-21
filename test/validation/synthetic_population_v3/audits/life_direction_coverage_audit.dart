import 'package:knowme/features/human_model/builder/human_model_foundation_builder.dart';
import 'package:knowme/features/human_model/contracts/human_model_input.dart';

import '../../synthetic_population/pipeline/synthetic_human_mirror_input_builder.dart';
import '../../synthetic_population/pipeline/synthetic_human_run_record.dart';
import '../../synthetic_population_v2/simulation/validation_v2_recovery_simulator.dart';
import '../overlay/life_direction_reinforcement_coverage_overlay.dart';

/// Task A — Life Direction reinforcement coverage report.
abstract final class LifeDirectionCoverageAudit {
  static const lifeKey = 'MIRROR_LIFE_DIRECTION';

  static Map<String, dynamic> analyze(List<SyntheticHumanRunRecord> records) {
    var coverageProfiles = 0;
    var mirrorReinforcements = 0;
    var profilesWithMirrorReinforcement = 0;
    var baselineStableOrientation = 0;
    var simulatedStableOrientation = 0;
    var r004LifeRecoveries = 0;
    var profilesWithFusionLifeReinforcement = 0;
    var profilesWithHumanModelLifeReinforcement = 0;
    var profilesWithAgreementShadowBlock = 0;
    final lineageSamples = <Map<String, dynamic>>[];

    for (final record in records) {
      final raw = SyntheticHumanMirrorInputBuilder.buildAstrologyInput(
        record.profile,
        generatedAt: record.generatedAt,
      );
      if (!LifeDirectionReinforcementCoverageOverlay.shouldAugment(raw)) {
        continue;
      }
      coverageProfiles++;

      final astroReinforcements = record.astrologyMirrorSnapshot.reinforcements
          .where((r) => r.mirrorKey == lifeKey)
          .length;
      mirrorReinforcements += astroReinforcements;
      if (astroReinforcements > 0) profilesWithMirrorReinforcement++;

      if (record.humanPatternSnapshot.activations
          .any((a) => a.patternId == 'stable_orientation')) {
        baselineStableOrientation++;
      }

      final sim = ValidationV2RecoverySimulator.simulateRecord(record);
      if (sim.humanPatternSnapshot.activations
          .any((a) => a.patternId == 'stable_orientation')) {
        simulatedStableOrientation++;
        if (lineageSamples.length < 5) {
          lineageSamples.add(_lineageSample(record, sim));
        }
      }

      if (sim.composedFusion.reinforcements.any((r) => r.mirrorKey == lifeKey)) {
        profilesWithFusionLifeReinforcement++;
      }

      final afterHuman = HumanModelFoundationBuilder.build(
        HumanModelInput(fusionSnapshot: sim.composedFusion),
        createdAt: record.generatedAt,
      );
      final hasLifeReinforcementPattern = afterHuman.patterns.any(
        (p) =>
            p.fusionFindingType == 'reinforcement' &&
            p.supportingMirrorKeys.contains(lifeKey),
      );
      if (hasLifeReinforcementPattern) {
        profilesWithHumanModelLifeReinforcement++;
      }

      final stableRule = afterHuman.patterns
          .where(
            (p) =>
                p.supportingMirrorKeys.contains(lifeKey) &&
                p.fusionFindingType == 'agreement',
          )
          .isNotEmpty;
      if (hasLifeReinforcementPattern && stableRule) {
        profilesWithAgreementShadowBlock++;
      }

      r004LifeRecoveries += sim.r004ReinforcementCount;
    }

    return {
      'populationSize': records.length,
      'coverageProfiles': coverageProfiles,
      'mirrorReinforcementCounts': {
        'totalLifeReinforcements': mirrorReinforcements,
        'profilesWithLifeReinforcement': profilesWithMirrorReinforcement,
      },
      'stableOrientation': {
        'baselineActivations': baselineStableOrientation,
        'simulatedActivations': simulatedStableOrientation,
        'validated': simulatedStableOrientation > 0,
      },
      'recoveryPipelineReach': {
        'profilesWithFusionLifeReinforcement':
            profilesWithFusionLifeReinforcement,
        'profilesWithHumanModelLifeReinforcementPattern':
            profilesWithHumanModelLifeReinforcement,
        'profilesWithAgreementShadowBlock': profilesWithAgreementShadowBlock,
        'blocker':
            'HP2 PatternActivationEngine resolves first LIFE human pattern (agreement) before reinforcement pattern; stable_orientation requires reinforcement source.',
      },
      'r004LifeReinforcementsApplied': r004LifeRecoveries,
      'evidenceLineageSamples': lineageSamples,
      'overlayRuleId': LifeDirectionReinforcementCoverageOverlay.overlayRuleId,
    };
  }

  static Map<String, dynamic> _lineageSample(
    SyntheticHumanRunRecord record,
    ValidationV2SimulationResult sim,
  ) {
    final afterHuman = HumanModelFoundationBuilder.build(
      HumanModelInput(fusionSnapshot: sim.composedFusion),
      createdAt: record.generatedAt,
    );

    return {
      'profileId': record.profile.profileId,
      'mirrorReinforcementIds': record.astrologyMirrorSnapshot.reinforcements
          .where((r) => r.mirrorKey == lifeKey)
          .map((r) => r.id)
          .toList(),
      'composedFusionReinforcementIds': sim.composedFusion.reinforcements
          .where((r) => r.mirrorKey == lifeKey)
          .map((r) => r.id)
          .toList(),
      'humanModelLifePatterns': afterHuman.patterns
          .where((p) => p.supportingMirrorKeys.contains(lifeKey))
          .map(
            (p) => {
              'patternKey': p.patternKey,
              'fusionFindingType': p.fusionFindingType,
            },
          )
          .toList(),
      'stableOrientationActivation': sim.humanPatternSnapshot.activations
          .where((a) => a.patternId == 'stable_orientation')
          .map(
            (a) => {
              'patternId': a.patternId,
              'sourceHumanPatternKey': a.sourceHumanPatternKey,
            },
          )
          .toList(),
      'r004ReinforcementsOnRecord': sim.r004ReinforcementCount,
    };
  }
}
