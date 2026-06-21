import 'package:knowme/features/global_fusion/foundation/builder/global_fusion_foundation_builder.dart';
import 'package:knowme/features/global_fusion/foundation/contracts/global_fusion_input.dart';
import 'package:knowme/features/human_model/builder/human_model_foundation_builder.dart';
import 'package:knowme/features/human_model/contracts/human_model_input.dart';
import 'package:knowme/features/human_pattern/builder/human_pattern_snapshot_builder.dart';
import 'package:knowme/features/human_pattern/contracts/human_pattern_input.dart';
import 'package:knowme/features/mirror_v3/engine/knowme_mirror_engine.dart';
import 'package:knowme/features/mirror_v3/snapshot/builder/knowme_mirror_snapshot_builder.dart';
import 'package:knowme/features/narrative_runtime/service/narrative_runtime_service.dart';

import '../../synthetic_population/models/synthetic_human_profile.dart';
import '../../synthetic_population/pipeline/synthetic_human_mirror_input_builder.dart';
import '../../synthetic_population/pipeline/synthetic_human_run_record.dart';
import '../overlay/life_direction_reinforcement_coverage_overlay.dart';

/// V3 validation pipeline — V2 profiles + LIFE_DIRECTION reinforcement overlay.
abstract final class SyntheticHumanPipelineRunnerV3 {
  static SyntheticHumanRunRecord run(
    SyntheticHumanProfile profile, {
    DateTime? generatedAt,
  }) {
    final now = (generatedAt ?? DateTime.utc(2026, 6, 21)).toUtc();

    final rawAstrology = SyntheticHumanMirrorInputBuilder.buildAstrologyInput(
      profile,
      generatedAt: now,
    );
    final astrologyInput =
        LifeDirectionReinforcementCoverageOverlay.augmentAstrologyInput(
      input: rawAstrology,
      profileId: profile.profileId,
    );
    final personalityInput =
        SyntheticHumanMirrorInputBuilder.buildPersonalityInput(
      profile,
      generatedAt: now,
    );

    final astrologyMirror = KnowMeMirrorSnapshotBuilder.fromEngineResult(
      KnowMeMirrorEngine.reflect(astrologyInput),
      createdAt: now,
    );
    final personalityMirror = KnowMeMirrorSnapshotBuilder.fromEngineResult(
      KnowMeMirrorEngine.reflect(personalityInput),
      createdAt: now,
    );

    final fusionSnapshot = GlobalFusionFoundationBuilder.build(
      GlobalFusionInput(
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
      ),
      createdAt: now,
    );

    final humanModelSnapshot = HumanModelFoundationBuilder.build(
      HumanModelInput(fusionSnapshot: fusionSnapshot),
      createdAt: now,
    );

    final humanPatternSnapshot = HumanPatternSnapshotBuilder.build(
      HumanPatternInput(humanModelSnapshot: humanModelSnapshot),
      createdAt: now,
    );

    final narrativeResult = NarrativeRuntimeService.generate(
      patternSnapshot: humanPatternSnapshot,
      createdAt: now,
    );

    return SyntheticHumanRunRecord(
      profile: profile,
      astrologyInput: astrologyInput,
      personalityInput: personalityInput,
      astrologyMirrorSnapshot: astrologyMirror,
      personalityMirrorSnapshot: personalityMirror,
      globalFusionSnapshot: fusionSnapshot,
      humanPatternSnapshot: humanPatternSnapshot,
      narrativeResult: narrativeResult,
      generatedAt: now,
    );
  }
}
