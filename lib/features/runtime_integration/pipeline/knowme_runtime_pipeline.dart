import 'package:knowme/features/global_fusion/foundation/builder/global_fusion_foundation_builder.dart';
import 'package:knowme/features/global_fusion/foundation/contracts/global_fusion_input.dart';
import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_snapshot.dart';
import 'package:knowme/features/global_fusion/v2/builder/global_fusion_runtime_builder.dart';
import 'package:knowme/features/human_model/builder/human_model_foundation_builder.dart';
import 'package:knowme/features/human_model/contracts/human_model_input.dart';
import 'package:knowme/features/human_model/domain/human_model_snapshot.dart';
import 'package:knowme/features/human_pattern/builder/human_pattern_snapshot_builder.dart';
import 'package:knowme/features/human_pattern/contracts/human_pattern_input.dart';
import 'package:knowme/features/human_pattern/domain/human_pattern_snapshot.dart';
import 'package:knowme/features/mirror_v3/snapshot/builder/knowme_mirror_snapshot_builder.dart';
import 'package:knowme/features/mirror_v3/snapshot/models/knowme_mirror_snapshot.dart';
import 'package:knowme/features/personality_mirror/application/personality_lens_load_result.dart';

import '../adapters/runtime_personality_lens_loader.dart';
import 'runtime_mirror_input_builder.dart';

/// RT1 — end-to-end runtime pipeline result.
class KnowMeRuntimePipelineResult {
  const KnowMeRuntimePipelineResult({
    required this.astrologyMirrorSnapshot,
    required this.personalityMirrorSnapshot,
    required this.globalFusionSnapshot,
    required this.humanModelSnapshot,
    required this.humanPatternSnapshot,
    required this.themeCount,
    required this.personalityLensLoad,
    required this.generatedAt,
  });

  final KnowMeMirrorSnapshot astrologyMirrorSnapshot;
  final KnowMeMirrorSnapshot personalityMirrorSnapshot;
  final GlobalFusionSnapshot globalFusionSnapshot;
  final HumanModelSnapshot humanModelSnapshot;
  final HumanPatternSnapshot humanPatternSnapshot;
  final int themeCount;
  final PersonalityLensLoadResult personalityLensLoad;
  final DateTime generatedAt;
}

/// RT1 — orchestrates real lens data through frozen foundation layers.
abstract final class KnowMeRuntimePipeline {
  static KnowMeRuntimePipelineResult run({DateTime? generatedAt}) {
    final now = (generatedAt ?? DateTime.now()).toUtc();
    final personalityLoad = RuntimePersonalityLensLoader.loadQaProfile();

    final astrologyInput =
        RuntimeMirrorInputBuilder.buildAstrologyInput(generatedAt: now);
    final personalityInput = RuntimeMirrorInputBuilder.buildPersonalityInput(
      lensLoad: personalityLoad,
      generatedAt: now,
    );

    final astrologyMirror = KnowMeMirrorSnapshotBuilder.fromReflectInput(
      astrologyInput,
      createdAt: now,
    );
    final personalityMirror = KnowMeMirrorSnapshotBuilder.fromReflectInput(
      personalityInput,
      createdAt: now,
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

    final foundationSnapshot = GlobalFusionFoundationBuilder.build(
      fusionInput,
      createdAt: now,
    );

    final fusionSnapshot = GlobalFusionRuntimeBuilder.resolveFusionSnapshot(
      input: fusionInput,
      foundationSnapshot: foundationSnapshot,
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

    final themeCount = astrologyInput.signals.length +
        personalityInput.signals.length;

    return KnowMeRuntimePipelineResult(
      astrologyMirrorSnapshot: astrologyMirror,
      personalityMirrorSnapshot: personalityMirror,
      globalFusionSnapshot: fusionSnapshot,
      humanModelSnapshot: humanModelSnapshot,
      humanPatternSnapshot: humanPatternSnapshot,
      themeCount: themeCount,
      personalityLensLoad: personalityLoad,
      generatedAt: now,
    );
  }
}
