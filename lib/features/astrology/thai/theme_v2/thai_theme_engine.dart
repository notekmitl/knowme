import '../content/models/thai_fusion_theme_category.dart';
import '../content/registry/thai_content_registry.dart';
import '../foundation/models/profile_warning.dart';
import '../interpretation/models/thai_interpretation_bundle.dart';
import '../interpretation/models/thai_interpretation_fact.dart';
import '../theme/models/thai_theme_confidence_level.dart';
import 'ports/thai_fact_to_content_key_mapper_port.dart';
import 'contracts/thai_theme_engine_contract.dart';
import 'enums/thai_theme_category.dart';
import 'models/thai_theme_bundle.dart';
import 'models/thai_theme_contribution.dart';
import 'models/thai_theme_score.dart';

class ThaiThemeEngineResult {
  const ThaiThemeEngineResult({
    required this.bundle,
    required this.warnings,
  });

  final ThaiThemeBundle bundle;
  final List<ProfileWarning> warnings;
}

/// Aggregates interpretation facts into ranked theme scores.
///
/// Aggregation only — no narrative, mirror, fusion, or signal access.
abstract final class ThaiThemeEngine {
  static const warningMappingNotFound = 'THEME_MAPPING_NOT_FOUND';

  static ThaiThemeEngineResult aggregate(ThaiInterpretationBundle bundle) {
    final accumulators = <String, _ThemeAccumulator>{};
    final warnings = <ProfileWarning>[];

    for (final fact in bundle.facts) {
      if (!ThaiFactToContentKeyMapper.canResolve(fact)) {
        continue;
      }

      final contentKey = ThaiFactToContentKeyMapper.resolveKey(fact);
      if (contentKey == null) {
        continue;
      }

      final section = ThaiContentRegistry.resolve(contentKey);
      if (section == null || section.themeMappings.isEmpty) {
        warnings.add(_mappingNotFoundWarning(fact, contentKey));
        continue;
      }

      for (final mapping in section.themeMappings) {
        final category = _toThemeCategory(mapping.category);
        if (category == null) {
          continue;
        }

        final themeKey = _themeKey(category, mapping.theme);
        final accumulator = accumulators.putIfAbsent(
          themeKey,
          () => _ThemeAccumulator(
            themeId: mapping.theme,
            category: category,
          ),
        );

        accumulator.contributions.add(
          ThaiThemeContribution(
            sourceFactId: fact.factId,
            contentKey: contentKey,
            contribution: mapping.weight * fact.confidence,
          ),
        );
      }
    }

    final themes = accumulators.values
        .map(_toThemeScore)
        .toList(growable: false)
      ..sort(_compareThemeScores);

    final rankedThemes = _assignRanks(themes);

    warnings.sort((a, b) => a.affectedFields.first.compareTo(b.affectedFields.first));

    final themeBundle = ThaiThemeBundle(
      bundleId: bundleId(sourceInterpretationBundleId: bundle.bundleId),
      sourceInterpretationBundleId: bundle.bundleId,
      generatedAt: bundle.interpretedAt.toUtc(),
      themes: List<ThaiThemeScore>.unmodifiable(rankedThemes),
      warnings: List<ProfileWarning>.unmodifiable(warnings),
    );

    return ThaiThemeEngineResult(
      bundle: themeBundle,
      warnings: themeBundle.warnings,
    );
  }

  static String bundleId({required String sourceInterpretationBundleId}) {
    return '$sourceInterpretationBundleId'
        '${ThaiThemeEngineContract.bundleIdDelimiter}'
        '${ThaiThemeEngineContract.themeEngineVersion}';
  }

  static ThaiThemeConfidenceLevel confidenceFromDistinctSourceFacts(
    int distinctSourceFactCount,
  ) {
    if (distinctSourceFactCount >= 4) {
      return ThaiThemeConfidenceLevel.high;
    }
    if (distinctSourceFactCount >= 2) {
      return ThaiThemeConfidenceLevel.medium;
    }
    return ThaiThemeConfidenceLevel.low;
  }

  static ThaiThemeCategory? _toThemeCategory(ThaiFusionThemeCategory category) {
    return switch (category) {
      ThaiFusionThemeCategory.coreSelf => ThaiThemeCategory.coreSelf,
      ThaiFusionThemeCategory.thinkingStyle => ThaiThemeCategory.thinkingStyle,
      ThaiFusionThemeCategory.emotionalWorld =>
        ThaiThemeCategory.emotionalWorld,
      ThaiFusionThemeCategory.relationships => ThaiThemeCategory.relationships,
      ThaiFusionThemeCategory.workAndAmbition => ThaiThemeCategory.workAmbition,
      ThaiFusionThemeCategory.strengths => ThaiThemeCategory.strengths,
      ThaiFusionThemeCategory.growthAreas => ThaiThemeCategory.growthAreas,
      ThaiFusionThemeCategory.growthPath => ThaiThemeCategory.growthPath,
    };
  }

  static String _themeKey(ThaiThemeCategory category, String themeId) {
    return '${category.id}|$themeId';
  }

  static ThaiThemeScore _toThemeScore(_ThemeAccumulator accumulator) {
    final contributions = List<ThaiThemeContribution>.from(
      accumulator.contributions,
    )..sort((a, b) {
        final factCompare = a.sourceFactId.compareTo(b.sourceFactId);
        if (factCompare != 0) {
          return factCompare;
        }
        return a.contentKey.compareTo(b.contentKey);
      });

    final score = contributions.fold<double>(
      0,
      (total, item) => total + item.contribution,
    );

    final distinctSourceFactIds = contributions
        .map((item) => item.sourceFactId)
        .toSet()
        .length;

    return ThaiThemeScore(
      themeId: accumulator.themeId,
      category: accumulator.category,
      score: score,
      confidence: confidenceFromDistinctSourceFacts(distinctSourceFactIds),
      rank: 0,
      contributions: contributions,
    );
  }

  static int _compareThemeScores(ThaiThemeScore a, ThaiThemeScore b) {
    final scoreCompare = b.score.compareTo(a.score);
    if (scoreCompare != 0) {
      return scoreCompare;
    }
    return a.themeId.compareTo(b.themeId);
  }

  static List<ThaiThemeScore> _assignRanks(List<ThaiThemeScore> themes) {
    final ranked = <ThaiThemeScore>[];
    for (var index = 0; index < themes.length; index++) {
      final theme = themes[index];
      ranked.add(
        ThaiThemeScore(
          themeId: theme.themeId,
          category: theme.category,
          score: theme.score,
          confidence: theme.confidence,
          rank: index + 1,
          contributions: theme.contributions,
        ),
      );
    }
    return ranked;
  }

  static ProfileWarning _mappingNotFoundWarning(
    ThaiInterpretationFact fact,
    String contentKey,
  ) {
    return ProfileWarning(
      code: warningMappingNotFound,
      severity: ProfileWarningSeverity.medium,
      message: 'Theme mapping not found for $contentKey (${fact.factId})',
      affectedFields: [fact.factId, contentKey],
    );
  }
}

final class _ThemeAccumulator {
  _ThemeAccumulator({
    required this.themeId,
    required this.category,
  });

  final String themeId;
  final ThaiThemeCategory category;
  final List<ThaiThemeContribution> contributions = [];
}
