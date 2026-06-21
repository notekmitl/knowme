import '../foundation/models/profile_warning.dart';
import '../theme/models/thai_theme_confidence_level.dart';
import '../theme_v2/models/thai_theme_bundle.dart';
import '../theme_v2/models/thai_theme_score.dart';
import 'contracts/thai_mirror_dimension_mapping_contract.dart';
import 'contracts/thai_mirror_engine_contract.dart';
import 'contracts/thai_mirror_warning_contract.dart';
import 'enums/thai_mirror_dimension_id.dart';
import 'enums/thai_mirror_pattern_type.dart';
import 'enums/thai_mirror_structural_confidence.dart';
import 'models/thai_mirror_dimension.dart';
import 'models/thai_mirror_evidence.dart';
import 'models/thai_mirror_insight.dart';
import 'models/thai_mirror_snapshot.dart';

class ThaiMirrorEngineResult {
  const ThaiMirrorEngineResult({
    required this.snapshot,
    required this.warnings,
  });

  final ThaiMirrorSnapshot snapshot;
  final List<ProfileWarning> warnings;
}

/// Reflects [ThaiThemeBundle] into a structural [ThaiMirrorSnapshot].
///
/// Self-understanding only — no narrative, content text, or upstream layer reads.
abstract final class ThaiMirrorEngine {
  static const dominantThemeScoreRatio = 1.5;

  static ThaiMirrorEngineResult reflect(ThaiThemeBundle bundle) {
    final grouped = _groupThemesByDimension(bundle.themes);
    final dimensions = <ThaiMirrorDimension>[];
    final insights = <ThaiMirrorInsight>[];
    final warnings = <ProfileWarning>[];

    for (final dimensionId in ThaiMirrorDimensionId.values) {
      final themes = grouped[dimensionId] ?? const <ThaiThemeScore>[];

      if (themes.isEmpty) {
        warnings.add(_insufficientCoverageWarning(dimensionId));
        continue;
      }

      final sortedThemes = _sortThemes(themes);
      final dimension = _buildDimension(dimensionId, sortedThemes);
      dimensions.add(dimension);
      insights.addAll(_buildInsights(dimensionId, sortedThemes, dimension.confidence));

      if (sortedThemes.length == 1) {
        warnings.add(_sparseDimensionWarning(dimensionId, sortedThemes.first.themeId));
      }
    }

    warnings.sort((a, b) {
      final fieldCompare = a.affectedFields.first.compareTo(b.affectedFields.first);
      if (fieldCompare != 0) {
        return fieldCompare;
      }
      return a.code.compareTo(b.code);
    });

    insights.sort((a, b) {
      final dimensionCompare = a.dimensionId.id.compareTo(b.dimensionId.id);
      if (dimensionCompare != 0) {
        return dimensionCompare;
      }
      final patternCompare = a.patternType.id.compareTo(b.patternType.id);
      if (patternCompare != 0) {
        return patternCompare;
      }
      return a.insightId.compareTo(b.insightId);
    });

    final snapshot = ThaiMirrorSnapshot(
      snapshotId: snapshotId(sourceThemeBundleId: bundle.bundleId),
      sourceThemeBundleId: bundle.bundleId,
      mirrorVersion: ThaiMirrorEngineContract.mirrorVersion,
      generatedAt: bundle.generatedAt.toUtc(),
      dimensions: List<ThaiMirrorDimension>.unmodifiable(dimensions),
      insights: List<ThaiMirrorInsight>.unmodifiable(insights),
      warnings: List<ProfileWarning>.unmodifiable(warnings),
    );

    return ThaiMirrorEngineResult(
      snapshot: snapshot,
      warnings: snapshot.warnings,
    );
  }

  static String snapshotId({required String sourceThemeBundleId}) {
    return '$sourceThemeBundleId'
        '${ThaiMirrorEngineContract.snapshotIdDelimiter}'
        '${ThaiMirrorEngineContract.mirrorVersion}';
  }

  static ThaiMirrorStructuralConfidence dimensionConfidence(
    Iterable<ThaiThemeScore> themes,
  ) {
    var hasHigh = false;
    var hasMedium = false;

    for (final theme in themes) {
      if (theme.confidence == ThaiThemeConfidenceLevel.high) {
        hasHigh = true;
      } else if (theme.confidence == ThaiThemeConfidenceLevel.medium) {
        hasMedium = true;
      }
    }

    if (hasHigh) {
      return ThaiMirrorStructuralConfidence.high;
    }
    if (hasMedium) {
      return ThaiMirrorStructuralConfidence.medium;
    }
    return ThaiMirrorStructuralConfidence.low;
  }

  static Map<ThaiMirrorDimensionId, List<ThaiThemeScore>> _groupThemesByDimension(
    List<ThaiThemeScore> themes,
  ) {
    final grouped = <ThaiMirrorDimensionId, List<ThaiThemeScore>>{};

    for (final theme in themes) {
      final dimensionId = ThaiMirrorDimensionMappingContract.dimensionForCategory(
        theme.category,
      );
      if (dimensionId == null) {
        continue;
      }

      grouped.putIfAbsent(dimensionId, () => []).add(theme);
    }

    return grouped;
  }

  static List<ThaiThemeScore> _sortThemes(List<ThaiThemeScore> themes) {
    final sorted = List<ThaiThemeScore>.from(themes)
      ..sort((a, b) {
        final scoreCompare = b.score.compareTo(a.score);
        if (scoreCompare != 0) {
          return scoreCompare;
        }
        return a.themeId.compareTo(b.themeId);
      });
    return sorted;
  }

  static ThaiMirrorDimension _buildDimension(
    ThaiMirrorDimensionId dimensionId,
    List<ThaiThemeScore> sortedThemes,
  ) {
    final evidence = sortedThemes.map(_buildEvidence).toList(growable: false);
    final prominence = sortedThemes.fold<double>(
      0,
      (total, theme) => total + theme.score,
    );

    return ThaiMirrorDimension(
      dimensionId: dimensionId,
      prominence: prominence,
      confidence: dimensionConfidence(sortedThemes),
      leadingThemeIds: sortedThemes.map((theme) => theme.themeId).toList(),
      evidence: evidence,
    );
  }

  static ThaiMirrorEvidence _buildEvidence(ThaiThemeScore theme) {
    return ThaiMirrorEvidence(
      themeId: theme.themeId,
      category: theme.category,
      score: theme.score,
      rank: theme.rank,
      confidence: theme.confidence,
      distinctSourceFactCount: theme.contributions
          .map((contribution) => contribution.sourceFactId)
          .toSet()
          .length,
    );
  }

  static List<ThaiMirrorInsight> _buildInsights(
    ThaiMirrorDimensionId dimensionId,
    List<ThaiThemeScore> sortedThemes,
    ThaiMirrorStructuralConfidence dimensionConfidence,
  ) {
    final insights = <ThaiMirrorInsight>[];

    if (sortedThemes.length == 1) {
      final theme = sortedThemes.first;
      insights.add(
        ThaiMirrorInsight(
          insightId: _insightId(
            dimensionId: dimensionId,
            patternType: ThaiMirrorPatternType.sparseCoverage,
            themeIds: [theme.themeId],
          ),
          dimensionId: dimensionId,
          patternType: ThaiMirrorPatternType.sparseCoverage,
          themeIds: [theme.themeId],
          structuralWeight: theme.score,
          confidence: dimensionConfidence,
        ),
      );
      return insights;
    }

    final topTheme = sortedThemes.first;
    final secondTheme = sortedThemes[1];
    if (topTheme.score >= secondTheme.score * dominantThemeScoreRatio) {
      insights.add(
        ThaiMirrorInsight(
          insightId: _insightId(
            dimensionId: dimensionId,
            patternType: ThaiMirrorPatternType.dominantTheme,
            themeIds: [topTheme.themeId],
          ),
          dimensionId: dimensionId,
          patternType: ThaiMirrorPatternType.dominantTheme,
          themeIds: [topTheme.themeId],
          structuralWeight: topTheme.score,
          confidence: dimensionConfidence,
        ),
      );
    }

    return insights;
  }

  static String _insightId({
    required ThaiMirrorDimensionId dimensionId,
    required ThaiMirrorPatternType patternType,
    required List<String> themeIds,
  }) {
    return '${dimensionId.id}:${patternType.id}:${themeIds.join(',')}';
  }

  static ProfileWarning _insufficientCoverageWarning(
    ThaiMirrorDimensionId dimensionId,
  ) {
    return ProfileWarning(
      code: ThaiMirrorWarningContract.insufficientThemeCoverage,
      severity: ProfileWarningSeverity.medium,
      message: 'Insufficient theme coverage for ${dimensionId.id}',
      affectedFields: [dimensionId.id],
    );
  }

  static ProfileWarning _sparseDimensionWarning(
    ThaiMirrorDimensionId dimensionId,
    String themeId,
  ) {
    return ProfileWarning(
      code: ThaiMirrorWarningContract.sparseDimension,
      severity: ProfileWarningSeverity.low,
      message: 'Sparse dimension coverage for ${dimensionId.id}',
      affectedFields: [dimensionId.id, themeId],
    );
  }
}
