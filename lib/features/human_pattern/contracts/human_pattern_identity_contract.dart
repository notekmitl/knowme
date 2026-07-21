import '../constants/human_pattern_system_version.dart';

abstract final class HumanPatternIdentityContract {
  static const delimiter = '|';

  static String snapshotId({
    required String sourceHumanModelSnapshotId,
    required String structuralHash,
    required String registryVersion,
  }) {
    return [
      sourceHumanModelSnapshotId,
      structuralHash,
      registryVersion,
      HumanPatternSystemVersion.snapshotVersion,
    ].join(delimiter);
  }

  static String humanPatternSystemId({
    required String sourceHumanModelSnapshotId,
  }) {
    return [
      sourceHumanModelSnapshotId,
      HumanPatternSystemVersion.systemVersion,
    ].join(delimiter);
  }
}
