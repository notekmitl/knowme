import '../constants/global_fusion_foundation_version.dart';

/// Deterministic global fusion identity formulas.
abstract final class GlobalFusionIdentityContract {
  static const delimiter = '|';

  static String snapshotId({
    required List<String> sourceMirrorSnapshotIds,
    required String structuralHash,
  }) {
    final sortedIds = List<String>.from(sourceMirrorSnapshotIds)..sort();
    return [
      sortedIds.join(','),
      structuralHash,
      GlobalFusionFoundationVersion.snapshotVersion,
    ].join(delimiter);
  }

  static String globalFusionId({
    required List<String> mirrorRoleIds,
    required List<String> sourceMirrorSnapshotIds,
  }) {
    final roles = List<String>.from(mirrorRoleIds)..sort();
    final ids = List<String>.from(sourceMirrorSnapshotIds)..sort();
    return [
      roles.join(','),
      ids.join(','),
      GlobalFusionFoundationVersion.foundationVersion,
    ].join(delimiter);
  }
}
