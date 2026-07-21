import 'package:knowme/features/astrology/fusion/domain/entities/fusion_signal.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/theme_family.dart';
import 'package:knowme/features/personality_mirror/domain/personality_core_themes.dart';

import '../application/theme_normalization/global_theme_mapping_policy.dart';
import '../domain/global_core_themes.dart';
import '../domain/global_theme_contract.dart';

/// Validates Global Theme Contract v1 completeness — no silent drops.
abstract final class GlobalThemeMappingValidator {
  static List<String> validateContractCompleteness() {
    final issues = <String>[];

    issues.addAll(_validateFamilies());
    issues.addAll(_validateSignalTypes());
    issues.addAll(_validatePersonalityCoreThemes());
    issues.addAll(_validateGlobalThemeRegistry());
    issues.addAll(_validateCoverageMatrix());

    return issues;
  }

  static bool get isComplete => validateContractCompleteness().isEmpty;

  static List<String> _validateFamilies() {
    final issues = <String>[];

    for (final family in ThemeFamily.values) {
      if (!GlobalThemeMappingPolicy.familyMappings.containsKey(family)) {
        issues.add('theme family missing mapping policy: ${family.id}');
        continue;
      }

      final decision = GlobalThemeMappingPolicy.forFamily(family);
      if (decision.isRejected) {
        issues.add('theme family explicitly rejected without v1 path: ${family.id}');
      }
    }

    if (GlobalThemeMappingPolicy.familyMappings.length != ThemeFamily.values.length) {
      issues.add('theme family mapping count mismatch');
    }

    return issues;
  }

  static List<String> _validateSignalTypes() {
    final issues = <String>[];

    for (final type in FusionSignalType.values) {
      if (!GlobalThemeMappingPolicy.signalMappings.containsKey(type)) {
        issues.add('fusion signal type missing mapping policy: ${type.name}');
        continue;
      }

      final decision = GlobalThemeMappingPolicy.forSignalType(type);
      if (decision.isRejected) {
        issues.add('fusion signal type explicitly rejected: ${type.name}');
      }
    }

    if (GlobalThemeMappingPolicy.signalMappings.length !=
        FusionSignalType.values.length) {
      issues.add('fusion signal mapping count mismatch');
    }

    return issues;
  }

  static List<String> _validatePersonalityCoreThemes() {
    final issues = <String>[];

    for (final themeId in PersonalityCoreThemeIds.all) {
      final decision = GlobalThemeMappingPolicy.forPersonalityCoreTheme(themeId);
      if (decision.isRejected) {
        issues.add('personality core theme rejected: $themeId');
      }
      if (decision.globalThemeId != null &&
          !GlobalThemeRegistry.contains(decision.globalThemeId!)) {
        issues.add('personality core theme maps to unknown global id: $themeId');
      }
    }

    return issues;
  }

  static List<String> _validateGlobalThemeRegistry() {
    final issues = <String>[];

    if (GlobalThemeRegistry.byId.length != GlobalThemeIds.v1Themes.length) {
      issues.add('global theme registry count mismatch with v1 theme list');
    }

    for (final themeId in GlobalThemeIds.v1Themes) {
      final theme = GlobalThemeRegistry.get(themeId);
      if (theme == null) {
        issues.add('v1 theme missing registry entry: $themeId');
        continue;
      }
      if (theme.intent.trim().isEmpty) {
        issues.add('v1 theme missing intent: $themeId');
      }
    }

    final inboundGlobalIds = <String>{
      ...GlobalThemeMappingPolicy.familyMappings.values
          .where((decision) => decision.isNormalized)
          .map((decision) => decision.globalThemeId!),
      ...GlobalThemeMappingPolicy.signalMappings.values
          .where((decision) => decision.isNormalized)
          .map((decision) => decision.globalThemeId!),
    };

    for (final themeId in GlobalThemeIds.v1Themes) {
      if (!inboundGlobalIds.contains(themeId)) {
        issues.add('v1 theme has no inbound mapping path: $themeId');
      }
    }

    return issues;
  }

  static List<String> _validateCoverageMatrix() {
    final issues = <String>[];
    final rows = GlobalThemeCoverageMatrix.build();

    final familyRows = rows.where((row) => row.sourceKind == 'theme_family');
    if (familyRows.any((row) => row.outcome == GlobalThemeMappingOutcome.rejected)) {
      issues.add('coverage matrix contains rejected theme family rows');
    }

    final personalityRows =
        rows.where((row) => row.sourceKind == 'personality_core_theme');
    if (personalityRows.any((row) => row.outcome == GlobalThemeMappingOutcome.rejected)) {
      issues.add('coverage matrix contains rejected personality core themes');
    }

    final astrologyThemeRows =
        rows.where((row) => row.sourceKind == 'fusion_theme_registry');
    if (astrologyThemeRows.any((row) => row.outcome == GlobalThemeMappingOutcome.rejected)) {
      issues.add('coverage matrix contains rejected astrology registry themes');
    }

    return issues;
  }
}
