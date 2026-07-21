import '../domain/human_dimension.dart';
import '../semantics/human_meaning_category.dart';

/// HPC4 — runtime-observed theme meaning definition (not speculative).
class RuntimeThemeMeaningDefinition {
  const RuntimeThemeMeaningDefinition({
    required this.themeId,
    required this.patternKey,
    required this.label,
    required this.primaryDimension,
    required this.secondaryDimensions,
    required this.meaningCategory,
    required this.baseStrength,
  });

  final String themeId;
  final String patternKey;
  final String label;
  final HumanDimensionId primaryDimension;
  final List<HumanDimensionId> secondaryDimensions;
  final HumanMeaningCategory meaningCategory;
  final double baseStrength;
}

/// Themes confirmed in real runtime fusion evidence (QA profile).
abstract final class RuntimeThemeMeaningCatalog {
  static const entries = <RuntimeThemeMeaningDefinition>[
    RuntimeThemeMeaningDefinition(
      themeId: 'builder',
      patternKey: 'theme_builder_constructive_force',
      label: 'Constructive Builder',
      primaryDimension: HumanDimensionId.action,
      secondaryDimensions: [HumanDimensionId.thinking, HumanDimensionId.growth],
      meaningCategory: HumanMeaningCategory.coreStrength,
      baseStrength: 0.52,
    ),
    RuntimeThemeMeaningDefinition(
      themeId: 'responsible',
      patternKey: 'theme_responsible_accountable_operator',
      label: 'Accountable Operator',
      primaryDimension: HumanDimensionId.action,
      secondaryDimensions: [HumanDimensionId.motivation],
      meaningCategory: HumanMeaningCategory.stablePattern,
      baseStrength: 0.50,
    ),
    RuntimeThemeMeaningDefinition(
      themeId: 'teacher',
      patternKey: 'theme_teacher_guiding_influence',
      label: 'Guiding Teacher',
      primaryDimension: HumanDimensionId.growth,
      secondaryDimensions: [HumanDimensionId.meaning, HumanDimensionId.relationship],
      meaningCategory: HumanMeaningCategory.naturalOrientation,
      baseStrength: 0.48,
    ),
  ];

  static RuntimeThemeMeaningDefinition? byThemeId(String themeId) {
    for (final entry in entries) {
      if (entry.themeId == themeId) return entry;
    }
    return null;
  }

  static List<String> get supportedThemeIds {
    return entries.map((item) => item.themeId).toList()..sort();
  }
}
