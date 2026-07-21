import '../constants/knowme_mirror_snapshot_version_contract.dart';

/// Deterministic MV3 snapshot identity formulas.
abstract final class KnowMeMirrorSnapshotIdentityContract {
  static const delimiter = '|';

  /// Bundle-level persisted snapshot id — excludes [createdAt].
  static String snapshotId({
    required String mirrorScopeId,
    required String mirrorBundleId,
    required String structuralHash,
  }) {
    return [
      mirrorScopeId,
      mirrorBundleId,
      structuralHash,
      KnowMeMirrorSnapshotVersionContract.snapshotVersion,
    ].join(delimiter);
  }
}
