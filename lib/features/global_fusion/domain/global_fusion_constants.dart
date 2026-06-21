import 'global_theme_contract.dart';

/// Locked contract metadata for Global Fusion Foundation (GF-F0+).
abstract final class GlobalFusionContract {
  static const String version = 'global_fusion.v0_foundation';

  /// Global Theme Contract consumed by synthesis (GF-F1.5).
  static const String themeContractVersion = GlobalThemeContract.version;

  /// Astrology mirror contract consumed by Global Fusion.
  static const String astrologyMirrorVersion = 'astrology_fusion_v1';

  /// Personality mirror contract consumed by Global Fusion.
  static const String personalityMirrorVersion = 'personality_mirror.v1';
}