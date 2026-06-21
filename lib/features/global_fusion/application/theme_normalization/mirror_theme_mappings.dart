import 'package:knowme/features/astrology/fusion/domain/entities/fusion_signal.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/theme_family.dart';
import 'package:knowme/features/personality_mirror/domain/personality_core_themes.dart';

import '../../domain/global_core_themes.dart';
import '../../domain/global_theme_contract.dart';
import 'global_theme_mapping_policy.dart';

/// Resolves mirror outputs into Global Theme Contract v1 decisions.
abstract final class AstrologyMirrorThemeMapping {
  static GlobalThemeMappingDecision decisionForFamily(ThemeFamily family) {
    return GlobalThemeMappingPolicy.forFamily(family);
  }

  static GlobalThemeMappingDecision decisionForSignalType(FusionSignalType type) {
    return GlobalThemeMappingPolicy.forSignalType(type);
  }

  static GlobalThemeMappingDecision decisionForSourceThemeId(String themeId) {
    return GlobalThemeMappingPolicy.forAstrologyThemeId(themeId);
  }

  static String? globalThemeForFamily(ThemeFamily family) {
    return GlobalThemeMappingPolicy.normalizedGlobalThemeId(
      decisionForFamily(family),
    );
  }

  static String? globalThemeForSignalType(FusionSignalType type) {
    return GlobalThemeMappingPolicy.normalizedGlobalThemeId(
      decisionForSignalType(type),
    );
  }

  static String? globalThemeForSourceThemeId(String themeId) {
    return GlobalThemeMappingPolicy.normalizedGlobalThemeId(
      decisionForSourceThemeId(themeId),
    );
  }
}

/// Resolves personality mirror core themes into Global Theme Contract v1.
abstract final class PersonalityMirrorThemeMapping {
  static GlobalThemeMappingDecision decisionForCoreTheme(String themeId) {
    return GlobalThemeMappingPolicy.forPersonalityCoreTheme(themeId);
  }

  static String? globalThemeForCoreTheme(String themeId) {
    return GlobalThemeMappingPolicy.normalizedGlobalThemeId(
      decisionForCoreTheme(themeId),
    );
  }
}
