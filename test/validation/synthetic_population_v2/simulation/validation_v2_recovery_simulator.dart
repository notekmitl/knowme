import 'package:knowme/features/global_fusion/foundation/builder/global_fusion_foundation_builder.dart';
import 'package:knowme/features/global_fusion/foundation/contracts/global_fusion_input.dart';
import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_snapshot.dart';
import 'package:knowme/features/global_fusion/v2/builder/global_fusion_runtime_builder.dart';
import 'package:knowme/features/global_fusion/v2/config/global_fusion_recovery_config.dart';
import 'package:knowme/features/human_model/builder/human_model_foundation_builder.dart';
import 'package:knowme/features/human_model/contracts/human_model_input.dart';
import 'package:knowme/features/human_pattern/builder/human_pattern_snapshot_builder.dart';
import 'package:knowme/features/human_pattern/contracts/human_pattern_input.dart';
import 'package:knowme/features/human_pattern/domain/human_pattern_snapshot.dart';
import 'package:knowme/features/mirror_v3/snapshot/builder/knowme_mirror_snapshot_builder.dart';
import 'package:knowme/features/narrative_runtime/domain/narrative_result.dart';
import 'package:knowme/features/narrative_runtime/service/narrative_runtime_service.dart';

import '../../synthetic_population/pipeline/synthetic_human_run_record.dart';

/// Production GF2 recovery path for validation comparison.
abstract final class ValidationV2RecoverySimulator {
  static ValidationV2SimulationResult simulateRecord(
    SyntheticHumanRunRecord record,
  ) {
    final astrologyMirror = KnowMeMirrorSnapshotBuilder.fromReflectInput(
      record.astrologyInput,
      createdAt: record.generatedAt,
      applyPromotion: GlobalFusionRecoveryConfig.promotionEnabled,
    );
    final personalityMirror = KnowMeMirrorSnapshotBuilder.fromReflectInput(
      record.personalityInput,
      createdAt: record.generatedAt,
      applyPromotion: GlobalFusionRecoveryConfig.promotionEnabled,
    );

    final fusionInput = GlobalFusionInput(
      mirrors: [
        GlobalFusionMirrorRef(
          mirrorRoleId: GlobalFusionMirrorRoles.astrology,
          snapshot: astrologyMirror,
        ),
        GlobalFusionMirrorRef(
          mirrorRoleId: GlobalFusionMirrorRoles.personality,
          snapshot: personalityMirror,
        ),
      ],
    );

    final foundation = GlobalFusionFoundationBuilder.build(
      fusionInput,
      createdAt: record.generatedAt,
    );

    final composed = GlobalFusionRecoveryConfig.enabled &&
            GlobalFusionRecoveryConfig.supplementalEnabled
        ? GlobalFusionRuntimeBuilder.composeRecovery(
            input: fusionInput,
            foundationSnapshot: foundation,
            createdAt: record.generatedAt,
          )
        : null;

    final fusionSnapshot =
        composed?.fusionSnapshot ?? foundation;

    final afterHuman = HumanModelFoundationBuilder.build(
      HumanModelInput(fusionSnapshot: fusionSnapshot),
      createdAt: record.generatedAt,
    );
    final afterPattern = HumanPatternSnapshotBuilder.build(
      HumanPatternInput(humanModelSnapshot: afterHuman),
      createdAt: record.generatedAt,
    );
    final afterNarrative = NarrativeRuntimeService.generate(
      patternSnapshot: afterPattern,
      createdAt: record.generatedAt,
    );

    final recovery = composed?.recovery;
    final promotedCount = astrologyMirror.promotedFindings.length +
        personalityMirror.promotedFindings.length;

    return ValidationV2SimulationResult(
      composedFusion: fusionSnapshot,
      humanPatternSnapshot: afterPattern,
      narrativeFingerprint: _narrativeFingerprint(afterNarrative),
      mp001AgreementCount: promotedCount,
      r004ReinforcementCount: recovery == null
          ? 0
          : recovery.supplementalReinforcements
              .where(
                (item) =>
                    item.recoveryRuleId ==
                    'filtered_mirror_reinforcement_recovery',
              )
              .length,
      gf2AgreementCount: recovery?.supplementalAgreements.length ?? 0,
      gf2ReinforcementCount: recovery == null
          ? 0
          : recovery.supplementalReinforcements.length -
              recovery.supplementalReinforcements
                  .where(
                    (item) =>
                        item.recoveryRuleId ==
                        'filtered_mirror_reinforcement_recovery',
                  )
                  .length,
    );
  }

  static String _narrativeFingerprint(NarrativeResult narrativeResult) {
    final parts = <String>[];
    for (final section in narrativeResult.sections) {
      for (final paragraph in section.paragraphs) {
        parts.add(paragraph.text.trim().toLowerCase());
      }
    }
    return parts.join('\n');
  }
}

class ValidationV2SimulationResult {
  const ValidationV2SimulationResult({
    required this.composedFusion,
    required this.humanPatternSnapshot,
    required this.narrativeFingerprint,
    required this.mp001AgreementCount,
    required this.r004ReinforcementCount,
    required this.gf2AgreementCount,
    required this.gf2ReinforcementCount,
  });

  final GlobalFusionSnapshot composedFusion;
  final HumanPatternSnapshot humanPatternSnapshot;
  final String narrativeFingerprint;
  final int mp001AgreementCount;
  final int r004ReinforcementCount;
  final int gf2AgreementCount;
  final int gf2ReinforcementCount;
}
