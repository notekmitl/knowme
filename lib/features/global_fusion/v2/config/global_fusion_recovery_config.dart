/// GF2 recovery master switch — default false in production until enabled.
abstract final class GlobalFusionRecoveryConfig {
  /// Master switch — false preserves V1 GF1-only runtime path.
  static bool enabled = false;

  /// MV2 promotion — requires [enabled].
  static bool promotionEnabled = true;

  /// GF2 supplemental recovery — requires [enabled].
  static bool supplementalEnabled = true;

  /// GF2-R005 theme recovery — excluded from V2 launch composer.
  static bool highRiskThemeRecoveryEnabled = false;
}
