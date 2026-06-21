import '../constants/human_model_version.dart';

/// Deterministic human model identity formulas.
abstract final class HumanModelIdentityContract {
  static const delimiter = '|';

  static String snapshotId({
    required String sourceGlobalFusionSnapshotId,
    required String structuralHash,
  }) {
    return [
      sourceGlobalFusionSnapshotId,
      structuralHash,
      HumanModelFoundationVersion.snapshotVersion,
    ].join(delimiter);
  }

  static String humanModelId({
    required String sourceGlobalFusionSnapshotId,
  }) {
    return [
      sourceGlobalFusionSnapshotId,
      HumanModelFoundationVersion.foundationVersion,
    ].join(delimiter);
  }
}
