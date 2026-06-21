import '../constants/thai_fusion_version_contract.dart';
import 'thai_fusion_engine_contract.dart';

/// Frozen identity formula for [ThaiFusionSnapshot.fusionSnapshotId].
///
/// Generation logic is implemented in F2+ — F1 stores the field only.
abstract final class ThaiFusionIdentityContract {
  /// `{sourceMirrorSnapshotId}|{fusionVersion}`
  ///
  /// Excluded from identity: generatedAt, categories, insights, warnings.
  static const fusionSnapshotIdFormula =
      '{sourceMirrorSnapshotId}${ThaiFusionEngineContract.fusionSnapshotIdDelimiter}{fusionVersion}';

  static const fusionVersion = ThaiFusionVersionContract.fusionVersion;
}
