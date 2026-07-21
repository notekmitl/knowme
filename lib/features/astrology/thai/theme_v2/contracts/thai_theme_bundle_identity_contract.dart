import 'thai_theme_engine_contract.dart';

/// Frozen identity formula for [ThaiThemeBundle.bundleId].
///
/// Generation logic is implemented in T2+ — T1 stores the field only.
abstract final class ThaiThemeBundleIdentityContract {
  /// `{sourceInterpretationBundleId}|{themeEngineVersion}`
  ///
  /// Excluded from identity: generatedAt, warnings, themes, scores.
  static const bundleIdFormula =
      '{sourceInterpretationBundleId}${ThaiThemeEngineContract.bundleIdDelimiter}{themeEngineVersion}';
}
