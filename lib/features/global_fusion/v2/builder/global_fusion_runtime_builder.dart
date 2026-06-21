import '../../foundation/contracts/global_fusion_input.dart';
import '../../foundation/domain/global_fusion_snapshot.dart';
import '../config/global_fusion_recovery_config.dart';
import '../domain/global_fusion_composed_snapshot.dart';
import 'global_fusion_coverage_recovery_builder.dart';
import '../engines/global_fusion_recovery_composer.dart';

/// Production GF2 recovery orchestration — GF1 foundation preserved.
abstract final class GlobalFusionRuntimeBuilder {
  static GlobalFusionComposedSnapshot composeRecovery({
    required GlobalFusionInput input,
    required GlobalFusionSnapshot foundationSnapshot,
    DateTime? createdAt,
  }) {
    final recovery = GlobalFusionCoverageRecoveryBuilder.build(
      input: input,
      foundationSnapshot: foundationSnapshot,
      createdAt: createdAt,
    );

    return GlobalFusionRecoveryComposer.compose(
      input: input,
      recovered: recovery.recoveredSnapshot,
    );
  }

  static GlobalFusionSnapshot resolveFusionSnapshot({
    required GlobalFusionInput input,
    required GlobalFusionSnapshot foundationSnapshot,
    DateTime? createdAt,
  }) {
    if (!GlobalFusionRecoveryConfig.enabled ||
        !GlobalFusionRecoveryConfig.supplementalEnabled) {
      return foundationSnapshot;
    }

    return composeRecovery(
      input: input,
      foundationSnapshot: foundationSnapshot,
      createdAt: createdAt,
    ).fusionSnapshot;
  }
}
