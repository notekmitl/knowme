import '../constants/thai_mirror_version_contract.dart';
import 'thai_mirror_engine_contract.dart';

/// Frozen identity formula for [ThaiMirrorSnapshot.snapshotId].
///
/// Generation logic is implemented in M2+ — M1 stores the field only.
abstract final class ThaiMirrorSnapshotIdentityContract {
  /// `{sourceThemeBundleId}|{mirrorVersion}`
  ///
  /// Excluded from identity: generatedAt, dimensions, insights, warnings.
  static const snapshotIdFormula =
      '{sourceThemeBundleId}${ThaiMirrorEngineContract.snapshotIdDelimiter}{mirrorVersion}';

  static const mirrorVersion = ThaiMirrorVersionContract.mirrorVersion;
}
