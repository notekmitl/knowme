import 'package:knowme/features/astrology/fusion/domain/entities/fusion_category.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_signal.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/theme_family.dart';
import 'package:knowme/features/astrology/fusion/registry/theme_registry.dart';
import 'package:knowme/features/personality_mirror/domain/personality_core_themes.dart';

import '../../domain/global_core_themes.dart';
import '../../domain/global_theme_contract.dart';
import 'mirror_theme_mappings.dart';

/// Source-of-truth mapping policy for Global Theme Contract v1.
abstract final class GlobalThemeMappingPolicy {
  static const Map<ThemeFamily, GlobalThemeMappingDecision> familyMappings = {
    ThemeFamily.reflection: GlobalThemeMappingDecision.normalized(
      globalThemeId: GlobalThemeIds.reflection,
      reason: 'Contemplative inner-processing family maps to reflection.',
    ),
    ThemeFamily.structure: GlobalThemeMappingDecision.normalized(
      globalThemeId: GlobalThemeIds.structure,
      reason: 'Order and reliability family maps to structure.',
    ),
    ThemeFamily.adaptation: GlobalThemeMappingDecision.normalized(
      globalThemeId: GlobalThemeIds.adaptability,
      reason: 'Flexibility family maps to adaptability.',
    ),
    ThemeFamily.connection: GlobalThemeMappingDecision.normalized(
      globalThemeId: GlobalThemeIds.relationships,
      reason: 'Interpersonal bonding family maps to relationships.',
    ),
    ThemeFamily.expression: GlobalThemeMappingDecision.normalized(
      globalThemeId: GlobalThemeIds.expression,
      reason:
          'Outward visibility family maps to expression (split from growth in v1).',
    ),
    ThemeFamily.autonomy: GlobalThemeMappingDecision.normalized(
      globalThemeId: GlobalThemeIds.autonomy,
      reason:
          'Self-direction family maps to autonomy (resolved in GF-F1.5).',
    ),
  };

  static const Map<FusionSignalType, GlobalThemeMappingDecision> signalMappings =
      {
    FusionSignalType.reflection: GlobalThemeMappingDecision.normalized(
      globalThemeId: GlobalThemeIds.reflection,
      reason: 'Signal type reflection maps to reflection theme.',
    ),
    FusionSignalType.structure: GlobalThemeMappingDecision.normalized(
      globalThemeId: GlobalThemeIds.structure,
      reason: 'Signal type structure maps to structure theme.',
    ),
    FusionSignalType.adaptation: GlobalThemeMappingDecision.normalized(
      globalThemeId: GlobalThemeIds.adaptability,
      reason: 'Signal type adaptation maps to adaptability theme.',
    ),
    FusionSignalType.connection: GlobalThemeMappingDecision.normalized(
      globalThemeId: GlobalThemeIds.relationships,
      reason: 'Signal type connection maps to relationships theme.',
    ),
    FusionSignalType.growth: GlobalThemeMappingDecision.normalized(
      globalThemeId: GlobalThemeIds.growth,
      reason: 'Signal type growth maps to growth theme.',
    ),
    FusionSignalType.expression: GlobalThemeMappingDecision.normalized(
      globalThemeId: GlobalThemeIds.expression,
      reason: 'Signal type expression maps to expression theme.',
    ),
    FusionSignalType.autonomy: GlobalThemeMappingDecision.normalized(
      globalThemeId: GlobalThemeIds.autonomy,
      reason: 'Signal type autonomy maps to autonomy theme.',
    ),
    FusionSignalType.leadership: GlobalThemeMappingDecision.normalized(
      globalThemeId: GlobalThemeIds.autonomy,
      reason: 'Leadership signal aligns with autonomy family in AF V1.',
    ),
    FusionSignalType.creativity: GlobalThemeMappingDecision.normalized(
      globalThemeId: GlobalThemeIds.expression,
      reason: 'Creativity signal aligns with expression family in AF V1.',
    ),
    FusionSignalType.transformation: GlobalThemeMappingDecision.normalized(
      globalThemeId: GlobalThemeIds.growth,
      reason: 'Transformation signal aligns with growth and change path.',
    ),
  };

  static GlobalThemeMappingDecision forFamily(ThemeFamily family) {
    return familyMappings[family]!;
  }

  static GlobalThemeMappingDecision forSignalType(FusionSignalType type) {
    return signalMappings[type]!;
  }

  static GlobalThemeMappingDecision forPersonalityCoreTheme(String themeId) {
    final theme = PersonalityCoreThemeRegistry.get(themeId);
    if (theme == null) {
      return GlobalThemeMappingDecision.rejected(
        reason: 'Unknown personality core theme id: $themeId',
      );
    }
    return forFamily(theme.family);
  }

  static GlobalThemeMappingDecision forAstrologyThemeId(String themeId) {
    final theme = FusionThemeRegistry.getById(themeId);
    if (theme == null) {
      return GlobalThemeMappingDecision.rejected(
        reason: 'Unknown astrology fusion theme id: $themeId',
      );
    }
    return forFamily(theme.family);
  }

  static String? normalizedGlobalThemeId(GlobalThemeMappingDecision decision) {
    return decision.isNormalized ? decision.globalThemeId : null;
  }
}

/// Builds the GF-F1.5 theme coverage matrix across mirror sources.
abstract final class GlobalThemeCoverageMatrix {
  static List<ThemeCoverageRow> build() {
    final rows = <ThemeCoverageRow>[];

    for (final family in ThemeFamily.values) {
      final decision = GlobalThemeMappingPolicy.forFamily(family);
      rows.add(
        ThemeCoverageRow(
          sourceLayer: 'shared',
          sourceKind: 'theme_family',
          sourceId: family.id,
          themeFamily: family.id,
          outcome: decision.outcome,
          globalThemeId: decision.globalThemeId,
          reason: decision.reason,
        ),
      );
    }

    for (final type in FusionSignalType.values) {
      final decision = GlobalThemeMappingPolicy.forSignalType(type);
      rows.add(
        ThemeCoverageRow(
          sourceLayer: 'astrology_mirror',
          sourceKind: 'fusion_signal_type',
          sourceId: type.name,
          outcome: decision.outcome,
          globalThemeId: decision.globalThemeId,
          reason: decision.reason,
        ),
      );
    }

    for (final themeId in PersonalityCoreThemeIds.all) {
      final theme = PersonalityCoreThemeRegistry.get(themeId)!;
      final decision = GlobalThemeMappingPolicy.forPersonalityCoreTheme(themeId);
      rows.add(
        ThemeCoverageRow(
          sourceLayer: 'personality_mirror',
          sourceKind: 'personality_core_theme',
          sourceId: themeId,
          themeFamily: theme.family.id,
          outcome: decision.outcome,
          globalThemeId: decision.globalThemeId,
          reason: decision.reason,
        ),
      );
    }

    for (final theme in FusionThemeRegistry.all) {
      final decision = GlobalThemeMappingPolicy.forAstrologyThemeId(theme.id);
      rows.add(
        ThemeCoverageRow(
          sourceLayer: 'astrology_mirror',
          sourceKind: 'fusion_theme_registry',
          sourceId: theme.id,
          themeFamily: theme.family.id,
          outcome: decision.outcome,
          globalThemeId: decision.globalThemeId,
          reason: decision.reason,
        ),
      );
    }

    rows.sort((a, b) {
      final layer = a.sourceLayer.compareTo(b.sourceLayer);
      if (layer != 0) return layer;
      final kind = a.sourceKind.compareTo(b.sourceKind);
      if (kind != 0) return kind;
      return a.sourceId.compareTo(b.sourceId);
    });

    return rows;
  }

  static int get normalizedCount =>
      build().where((row) => row.outcome == GlobalThemeMappingOutcome.normalized).length;

  static int get rejectedCount =>
      build().where((row) => row.outcome == GlobalThemeMappingOutcome.rejected).length;
}
