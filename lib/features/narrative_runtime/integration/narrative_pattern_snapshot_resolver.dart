import 'package:knowme/features/global_fusion/foundation/contracts/global_fusion_input.dart';
import 'package:knowme/features/global_fusion/v2/simulation/fusion_recovery_runtime_simulation.dart';
import 'package:knowme/features/human_pattern/domain/human_pattern_snapshot.dart';
import 'package:knowme/features/runtime_integration/pipeline/knowme_runtime_pipeline.dart';

/// Integration resolver — builds pattern snapshot for narrative surfaces.
/// Narrative runtime itself never reads fusion/mirror; this is glue only.
abstract final class NarrativePatternSnapshotResolver {
  static HumanPatternSnapshot resolveWithRecoverySimulation({
    DateTime? generatedAt,
  }) {
    final at = generatedAt ?? DateTime.now().toUtc();
    final pipeline = KnowMeRuntimePipeline.run(generatedAt: at);

    if (pipeline.humanPatternSnapshot.activations.isNotEmpty) {
      return pipeline.humanPatternSnapshot;
    }

    final simulation = FusionRecoveryRuntimeSimulation.run(
      mirrorSnapshots: [
        pipeline.astrologyMirrorSnapshot,
        pipeline.personalityMirrorSnapshot,
      ],
      mirrorRoleIds: [
        GlobalFusionMirrorRoles.astrology,
        GlobalFusionMirrorRoles.personality,
      ],
      foundationSnapshot: pipeline.globalFusionSnapshot,
      baselineHumanModelSnapshot: pipeline.humanModelSnapshot,
      baselineHumanPatternSnapshot: pipeline.humanPatternSnapshot,
      generatedAt: at,
    );

    return simulation.simulatedHumanPatternSnapshot;
  }
}
