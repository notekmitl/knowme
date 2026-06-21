import 'package:knowme/features/global_fusion/foundation/builder/global_fusion_foundation_builder.dart';
import 'package:knowme/features/global_fusion/foundation/contracts/global_fusion_input.dart';
import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_snapshot.dart';
import 'package:knowme/features/global_fusion/v2/builder/global_fusion_runtime_builder.dart';
import 'package:knowme/features/global_fusion/v2/config/global_fusion_recovery_config.dart';
import 'package:knowme/features/human_model/builder/human_model_foundation_builder.dart';
import 'package:knowme/features/human_model/contracts/human_model_input.dart';
import 'package:knowme/features/human_model/domain/human_model_snapshot.dart';
import 'package:knowme/features/human_pattern/builder/human_pattern_snapshot_builder.dart';
import 'package:knowme/features/human_pattern/contracts/human_pattern_input.dart';
import 'package:knowme/features/human_pattern/domain/human_pattern_snapshot.dart';
import 'package:knowme/features/mirror_v3/engine/models/knowme_mirror_engine_input.dart';
import 'package:knowme/features/mirror_v3/snapshot/builder/knowme_mirror_snapshot_builder.dart';
import 'package:knowme/features/mirror_v3/snapshot/models/knowme_mirror_snapshot.dart';
import 'package:knowme/features/narrative_runtime/domain/narrative_result.dart';
import 'package:knowme/features/narrative_runtime/service/narrative_runtime_service.dart';
import 'package:knowme/features/personality_mirror/application/personality_lens_load_result.dart';

import '../adapters/real_user_lens_loader.dart';
import '../adapters/real_user_mirror_input_builder.dart';
import '../models/real_user_export_record.dart';

class RealUserPipelineResult {
  const RealUserPipelineResult({
    required this.user,
    required this.generatedAt,
    required this.astrologyInput,
    required this.personalityInput,
    required this.astrologyMirrorSnapshot,
    required this.personalityMirrorSnapshot,
    required this.foundationFusionSnapshot,
    required this.composedFusionSnapshot,
    required this.humanModelSnapshot,
    required this.humanPatternSnapshot,
    required this.narrativeResult,
    required this.personalityLensLoad,
    required this.gf2AgreementCount,
    required this.gf2ReinforcementCount,
    required this.pipelineErrors,
  });

  final RealUserExportRecord user;
  final DateTime generatedAt;
  final KnowMeMirrorEngineInput? astrologyInput;
  final KnowMeMirrorEngineInput? personalityInput;
  final KnowMeMirrorSnapshot? astrologyMirrorSnapshot;
  final KnowMeMirrorSnapshot? personalityMirrorSnapshot;
  final GlobalFusionSnapshot? foundationFusionSnapshot;
  final GlobalFusionSnapshot? composedFusionSnapshot;
  final HumanModelSnapshot? humanModelSnapshot;
  final HumanPatternSnapshot? humanPatternSnapshot;
  final NarrativeResult? narrativeResult;
  final PersonalityLensLoadResult? personalityLensLoad;
  final int gf2AgreementCount;
  final int gf2ReinforcementCount;
  final List<String> pipelineErrors;

  bool get reachedMirror =>
      astrologyMirrorSnapshot != null && personalityMirrorSnapshot != null;

  bool get reachedGf1 => foundationFusionSnapshot != null;

  bool get reachedGf2 => composedFusionSnapshot != null;

  bool get reachedHumanModel => humanModelSnapshot != null;

  bool get reachedHumanPattern =>
      humanPatternSnapshot != null &&
      humanPatternSnapshot!.activations.isNotEmpty;

  bool get reachedNarrative =>
      narrativeResult != null && narrativeResult!.paragraphCount > 0;

  GlobalFusionSnapshot? get effectiveFusion =>
      composedFusionSnapshot ?? foundationFusionSnapshot;

  String get narrativeFingerprint {
    final result = narrativeResult;
    if (result == null) return '';
    final parts = <String>[];
    for (final section in result.sections) {
      for (final paragraph in section.paragraphs) {
        parts.add(paragraph.text.trim().toLowerCase());
      }
    }
    return parts.join('\n');
  }
}

abstract final class RealUserPipelineRunner {
  static RealUserPipelineResult run(
    RealUserExportRecord user, {
    DateTime? generatedAt,
  }) {
    final now = (generatedAt ?? DateTime.utc(2026, 6, 21, 12)).toUtc();
    final errors = <String>[];

    final astrologyInput = RealUserMirrorInputBuilder.buildAstrologyInput(
      user,
      generatedAt: now,
    );
    final personalityInput = RealUserMirrorInputBuilder.buildPersonalityInput(
      user,
      generatedAt: now,
    );
    final lensLoad = RealUserLensLoader.load(user);

    if (astrologyInput == null) {
      errors.add('missing astrology input (profile birth data required)');
    }
    if (personalityInput == null) {
      errors.add('missing personality input (no completed personality tests)');
    }

    if (astrologyInput == null || personalityInput == null) {
      return RealUserPipelineResult(
        user: user,
        generatedAt: now,
        astrologyInput: astrologyInput,
        personalityInput: personalityInput,
        astrologyMirrorSnapshot: null,
        personalityMirrorSnapshot: null,
        foundationFusionSnapshot: null,
        composedFusionSnapshot: null,
        humanModelSnapshot: null,
        humanPatternSnapshot: null,
        narrativeResult: null,
        personalityLensLoad: lensLoad,
        gf2AgreementCount: 0,
        gf2ReinforcementCount: 0,
        pipelineErrors: errors,
      );
    }

    final astrologyMirror = KnowMeMirrorSnapshotBuilder.fromReflectInput(
      astrologyInput,
      createdAt: now,
      applyPromotion: GlobalFusionRecoveryConfig.promotionEnabled,
    );
    final personalityMirror = KnowMeMirrorSnapshotBuilder.fromReflectInput(
      personalityInput,
      createdAt: now,
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
      createdAt: now,
    );

    final composed = GlobalFusionRecoveryConfig.enabled &&
            GlobalFusionRecoveryConfig.supplementalEnabled
        ? GlobalFusionRuntimeBuilder.composeRecovery(
            input: fusionInput,
            foundationSnapshot: foundation,
            createdAt: now,
          )
        : null;

    final fusionSnapshot = composed?.fusionSnapshot ?? foundation;
    final humanModel = HumanModelFoundationBuilder.build(
      HumanModelInput(fusionSnapshot: fusionSnapshot),
      createdAt: now,
    );
    final humanPattern = HumanPatternSnapshotBuilder.build(
      HumanPatternInput(humanModelSnapshot: humanModel),
      createdAt: now,
    );
    final narrative = NarrativeRuntimeService.generate(
      patternSnapshot: humanPattern,
      createdAt: now,
    );

    return RealUserPipelineResult(
      user: user,
      generatedAt: now,
      astrologyInput: astrologyInput,
      personalityInput: personalityInput,
      astrologyMirrorSnapshot: astrologyMirror,
      personalityMirrorSnapshot: personalityMirror,
      foundationFusionSnapshot: foundation,
      composedFusionSnapshot: fusionSnapshot,
      humanModelSnapshot: humanModel,
      humanPatternSnapshot: humanPattern,
      narrativeResult: narrative,
      personalityLensLoad: lensLoad,
      gf2AgreementCount: composed?.recovery?.supplementalAgreements.length ?? 0,
      gf2ReinforcementCount:
          composed?.recovery?.supplementalReinforcements.length ?? 0,
      pipelineErrors: errors,
    );
  }
}
