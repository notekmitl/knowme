import 'thai_content_lookup_contract.dart';

/// Frozen identity formula for [ThaiContentResolutionBundle.resolutionBundleId].
///
/// Generation logic is implemented in C1+ — C0 stores the field only.
abstract final class ThaiContentBundleIdentityContract {
  /// `{sourceInterpretationBundleId}|{resolverVersion}`
  ///
  /// Excluded from identity: resolvedAt, warnings, text, fragments.
  static const resolutionBundleIdFormula =
      '{sourceInterpretationBundleId}${ThaiContentLookupContract.bundleIdDelimiter}{resolverVersion}';
}
