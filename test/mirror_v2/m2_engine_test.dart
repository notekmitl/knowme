import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/foundation/models/profile_warning.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/foundation/v2/engines/thai_chart_engine.dart';
import 'package:knowme/features/astrology/thai/interpretation/thai_interpretation_engine.dart';
import 'package:knowme/features/astrology/thai/mirror_v2/contracts/thai_mirror_warning_contract.dart';
import 'package:knowme/features/astrology/thai/mirror_v2/enums/thai_mirror_dimension_id.dart';
import 'package:knowme/features/astrology/thai/mirror_v2/enums/thai_mirror_pattern_type.dart';
import 'package:knowme/features/astrology/thai/mirror_v2/enums/thai_mirror_structural_confidence.dart';
import 'package:knowme/features/astrology/thai/mirror_v2/models/thai_mirror_dimension.dart';
import 'package:knowme/features/astrology/thai/mirror_v2/models/thai_mirror_snapshot.dart';
import 'package:knowme/features/astrology/thai/mirror_v2/thai_mirror_engine.dart';
import 'package:knowme/features/astrology/thai/signal/thai_signal_extractor.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_confidence_level.dart';
import 'package:knowme/features/astrology/thai/theme_v2/constants/thai_theme_engine_version.dart';
import 'package:knowme/features/astrology/thai/theme_v2/enums/thai_theme_category.dart';
import 'package:knowme/features/astrology/thai/theme_v2/models/thai_theme_bundle.dart';
import 'package:knowme/features/astrology/thai/theme_v2/models/thai_theme_contribution.dart';
import 'package:knowme/features/astrology/thai/theme_v2/models/thai_theme_score.dart';
import 'package:knowme/features/astrology/thai/theme_v2/thai_theme_engine.dart';

const _bangkokOffset = Duration(hours: 7);

ThaiThemeContribution _contribution({
  required String sourceFactId,
  String contentKey = 'lagna_virgo',
  double contribution = 0.5,
}) {
  return ThaiThemeContribution(
    sourceFactId: sourceFactId,
    contentKey: contentKey,
    contribution: contribution,
  );
}

ThaiThemeScore _themeScore({
  required String themeId,
  required ThaiThemeCategory category,
  required double score,
  required int rank,
  ThaiThemeConfidenceLevel confidence = ThaiThemeConfidenceLevel.medium,
  List<ThaiThemeContribution>? contributions,
}) {
  return ThaiThemeScore(
    themeId: themeId,
    category: category,
    score: score,
    confidence: confidence,
    rank: rank,
    contributions: contributions ??
        [
          _contribution(sourceFactId: '$themeId-fact-1'),
        ],
  );
}

ThaiThemeBundle _themeBundle({
  required String bundleId,
  required List<ThaiThemeScore> themes,
  DateTime? generatedAt,
}) {
  return ThaiThemeBundle(
    bundleId: bundleId,
    sourceInterpretationBundleId: 'interpretation-$bundleId',
    generatedAt: generatedAt ?? DateTime.utc(2026, 6, 15, 14, 0),
    themes: themes,
  );
}

ThaiMirrorDimension? _dimension(
  ThaiMirrorSnapshot snapshot,
  ThaiMirrorDimensionId dimensionId,
) {
  for (final dimension in snapshot.dimensions) {
    if (dimension.dimensionId == dimensionId) {
      return dimension;
    }
  }
  return null;
}

List<String> _warningSignatures(List<ProfileWarning> warnings) {
  return warnings
      .map(
        (warning) =>
            '${warning.code}|${warning.severity.name}|${warning.message}|${warning.affectedFields.join(',')}',
      )
      .toList();
}

ThaiBirthData _bangkokBirth({
  required int year,
  required int month,
  required int day,
  int hour = 12,
  int minute = 0,
}) {
  return ThaiBirthData(
    localDateTime: DateTime(year, month, day, hour, minute),
    timeZoneOffset: _bangkokOffset,
    latitude: 13.75,
    longitude: 100.50,
    hasBirthTime: true,
  );
}

ThaiThemeBundle _themeBundleFromChart(ThaiBirthData birth) {
  final chart = ThaiChartEngine.generate(birth);
  final signalBundle = ThaiSignalExtractor.extract(
    ThaiSignalExtractorInput(chart: chart, birthData: birth),
  ).bundle;
  final interpretation = ThaiInterpretationEngine.interpret(signalBundle).bundle;
  return ThaiThemeEngine.aggregate(interpretation).bundle;
}

void main() {
  group('M2 dimension grouping', () {
    test('groups mapped categories into mirror dimensions', () {
      final bundle = _themeBundle(
        bundleId: 'grouping-bundle',
        themes: [
          _themeScore(
            themeId: 'analytical',
            category: ThaiThemeCategory.thinkingStyle,
            score: 0.8,
            rank: 1,
          ),
          _themeScore(
            themeId: 'communication',
            category: ThaiThemeCategory.strengths,
            score: 0.6,
            rank: 2,
          ),
          _themeScore(
            themeId: 'growth_seed',
            category: ThaiThemeCategory.growthAreas,
            score: 0.4,
            rank: 3,
          ),
          _themeScore(
            themeId: 'core_practical',
            category: ThaiThemeCategory.coreSelf,
            score: 0.9,
            rank: 4,
          ),
        ],
      );

      final snapshot = ThaiMirrorEngine.reflect(bundle).snapshot;

      expect(_dimension(snapshot, ThaiMirrorDimensionId.thinkingPattern), isNotNull);
      expect(_dimension(snapshot, ThaiMirrorDimensionId.prominentStrengths), isNotNull);
      expect(_dimension(snapshot, ThaiMirrorDimensionId.growthFocus), isNotNull);
      expect(
        snapshot.dimensions
            .expand((dimension) => dimension.evidence)
            .any((evidence) => evidence.category == ThaiThemeCategory.coreSelf),
        isFalse,
      );
    });
  });

  group('M2 prominence formula', () {
    test('prominence equals sum of theme scores in dimension', () {
      final bundle = _themeBundle(
        bundleId: 'prominence-bundle',
        themes: [
          _themeScore(
            themeId: 'analytical',
            category: ThaiThemeCategory.thinkingStyle,
            score: 0.8,
            rank: 1,
          ),
          _themeScore(
            themeId: 'curious',
            category: ThaiThemeCategory.thinkingStyle,
            score: 0.5,
            rank: 2,
          ),
        ],
      );

      final dimension = _dimension(
        ThaiMirrorEngine.reflect(bundle).snapshot,
        ThaiMirrorDimensionId.thinkingPattern,
      );

      expect(dimension, isNotNull);
      expect(dimension!.prominence, closeTo(1.3, 1e-9));
    });
  });

  group('M2 confidence formula', () {
    test('dimension confidence follows theme confidence tiers', () {
      expect(
        ThaiMirrorEngine.dimensionConfidence([
          _themeScore(
            themeId: 'a',
            category: ThaiThemeCategory.thinkingStyle,
            score: 0.5,
            rank: 1,
            confidence: ThaiThemeConfidenceLevel.low,
          ),
        ]),
        ThaiMirrorStructuralConfidence.low,
      );
      expect(
        ThaiMirrorEngine.dimensionConfidence([
          _themeScore(
            themeId: 'a',
            category: ThaiThemeCategory.thinkingStyle,
            score: 0.5,
            rank: 1,
            confidence: ThaiThemeConfidenceLevel.medium,
          ),
        ]),
        ThaiMirrorStructuralConfidence.medium,
      );
      expect(
        ThaiMirrorEngine.dimensionConfidence([
          _themeScore(
            themeId: 'a',
            category: ThaiThemeCategory.thinkingStyle,
            score: 0.5,
            rank: 1,
            confidence: ThaiThemeConfidenceLevel.low,
          ),
          _themeScore(
            themeId: 'b',
            category: ThaiThemeCategory.thinkingStyle,
            score: 0.4,
            rank: 2,
            confidence: ThaiThemeConfidenceLevel.high,
          ),
        ]),
        ThaiMirrorStructuralConfidence.high,
      );
    });
  });

  group('M2 leading themes ordering', () {
    test('orders leadingThemeIds by score desc then themeId asc', () {
      final bundle = _themeBundle(
        bundleId: 'leading-bundle',
        themes: [
          _themeScore(
            themeId: 'beta',
            category: ThaiThemeCategory.thinkingStyle,
            score: 0.7,
            rank: 2,
          ),
          _themeScore(
            themeId: 'alpha',
            category: ThaiThemeCategory.thinkingStyle,
            score: 0.7,
            rank: 3,
          ),
          _themeScore(
            themeId: 'gamma',
            category: ThaiThemeCategory.thinkingStyle,
            score: 0.9,
            rank: 1,
          ),
        ],
      );

      final dimension = _dimension(
        ThaiMirrorEngine.reflect(bundle).snapshot,
        ThaiMirrorDimensionId.thinkingPattern,
      );

      expect(dimension!.leadingThemeIds, ['gamma', 'alpha', 'beta']);
    });
  });

  group('M2 dominantTheme insight', () {
    test('emits dominantTheme when top score is at least 1.5x second score', () {
      final bundle = _themeBundle(
        bundleId: 'dominant-bundle',
        themes: [
          _themeScore(
            themeId: 'leader',
            category: ThaiThemeCategory.thinkingStyle,
            score: 0.9,
            rank: 1,
          ),
          _themeScore(
            themeId: 'follower',
            category: ThaiThemeCategory.thinkingStyle,
            score: 0.5,
            rank: 2,
          ),
        ],
      );

      final snapshot = ThaiMirrorEngine.reflect(bundle).snapshot;
      final dominantInsights = snapshot.insights.where(
        (insight) => insight.patternType == ThaiMirrorPatternType.dominantTheme,
      );

      expect(dominantInsights, hasLength(1));
      expect(dominantInsights.first.themeIds, ['leader']);
      expect(dominantInsights.first.dimensionId, ThaiMirrorDimensionId.thinkingPattern);
    });

    test('does not emit dominantTheme when ratio is below 1.5', () {
      final bundle = _themeBundle(
        bundleId: 'no-dominant-bundle',
        themes: [
          _themeScore(
            themeId: 'leader',
            category: ThaiThemeCategory.thinkingStyle,
            score: 0.6,
            rank: 1,
          ),
          _themeScore(
            themeId: 'follower',
            category: ThaiThemeCategory.thinkingStyle,
            score: 0.5,
            rank: 2,
          ),
        ],
      );

      final snapshot = ThaiMirrorEngine.reflect(bundle).snapshot;
      final dominantInsights = snapshot.insights.where(
        (insight) => insight.patternType == ThaiMirrorPatternType.dominantTheme,
      );

      expect(dominantInsights, isEmpty);
    });
  });

  group('M2 sparseCoverage insight', () {
    test('emits sparseCoverage when dimension has one theme', () {
      final bundle = _themeBundle(
        bundleId: 'sparse-bundle',
        themes: [
          _themeScore(
            themeId: 'solo',
            category: ThaiThemeCategory.emotionalWorld,
            score: 0.55,
            rank: 1,
          ),
        ],
      );

      final snapshot = ThaiMirrorEngine.reflect(bundle).snapshot;
      final sparseInsights = snapshot.insights.where(
        (insight) => insight.patternType == ThaiMirrorPatternType.sparseCoverage,
      );

      expect(sparseInsights, hasLength(1));
      expect(sparseInsights.first.themeIds, ['solo']);
      expect(sparseInsights.first.dimensionId, ThaiMirrorDimensionId.emotionalPattern);
    });
  });

  group('M2 warnings', () {
    test('emits insufficient coverage for empty dimensions', () {
      final bundle = _themeBundle(
        bundleId: 'warning-bundle',
        themes: [
          _themeScore(
            themeId: 'solo',
            category: ThaiThemeCategory.thinkingStyle,
            score: 0.5,
            rank: 1,
          ),
        ],
      );

      final result = ThaiMirrorEngine.reflect(bundle);
      final insufficientWarnings = result.warnings.where(
        (warning) =>
            warning.code == ThaiMirrorWarningContract.insufficientThemeCoverage,
      );

      expect(insufficientWarnings.length, 4);
      expect(
        insufficientWarnings.map((warning) => warning.affectedFields.first).toSet(),
        {
          'prominent_strengths',
          'emotional_pattern',
          'relationship_pattern',
          'growth_focus',
        },
      );
    });

    test('emits sparse dimension warning with sparseCoverage', () {
      final bundle = _themeBundle(
        bundleId: 'sparse-warning-bundle',
        themes: [
          _themeScore(
            themeId: 'solo',
            category: ThaiThemeCategory.relationships,
            score: 0.4,
            rank: 1,
          ),
        ],
      );

      final sparseWarnings = ThaiMirrorEngine.reflect(bundle).warnings.where(
        (warning) => warning.code == ThaiMirrorWarningContract.sparseDimension,
      );

      expect(sparseWarnings, hasLength(1));
      expect(sparseWarnings.first.affectedFields, ['relationship_pattern', 'solo']);
    });
  });

  group('M2 snapshot identity', () {
    test('snapshotId follows frozen identity contract', () {
      final bundle = _themeBundle(
        bundleId: 'theme-bundle-123|${ThaiThemeEngineVersionContract.themeEngineVersion}',
        themes: [
          _themeScore(
            themeId: 'solo',
            category: ThaiThemeCategory.thinkingStyle,
            score: 0.5,
            rank: 1,
          ),
        ],
      );

      final snapshot = ThaiMirrorEngine.reflect(bundle).snapshot;

      expect(
        snapshot.snapshotId,
        'theme-bundle-123|${ThaiThemeEngineVersionContract.themeEngineVersion}|v0.1.0',
      );
      expect(
        ThaiMirrorEngine.snapshotId(sourceThemeBundleId: bundle.bundleId),
        snapshot.snapshotId,
      );
      expect(snapshot.sourceThemeBundleId, bundle.bundleId);
      expect(snapshot.generatedAt, bundle.generatedAt);
    });
  });

  group('M2 deterministic run', () {
    test('100 runs produce identical reflection output', () {
      final bundle = _themeBundleFromChart(
        _bangkokBirth(year: 1990, month: 1, day: 15, hour: 10, minute: 30),
      );

      ThaiMirrorSnapshot? baseline;
      for (var run = 0; run < 100; run++) {
        final snapshot = ThaiMirrorEngine.reflect(bundle).snapshot;
        if (baseline == null) {
          baseline = snapshot;
          continue;
        }

        expect(snapshot.snapshotId, baseline.snapshotId);
        expect(snapshot.sourceThemeBundleId, baseline.sourceThemeBundleId);
        expect(snapshot.generatedAt, baseline.generatedAt);
        expect(snapshot.dimensions, baseline.dimensions);
        expect(snapshot.insights, baseline.insights);
        expect(_warningSignatures(snapshot.warnings), _warningSignatures(baseline.warnings));
      }
    });
  });

  group('M2 evidence mapping', () {
    test('maps ThaiThemeScore fields directly into ThaiMirrorEvidence', () {
      final bundle = _themeBundle(
        bundleId: 'evidence-bundle',
        themes: [
          _themeScore(
            themeId: 'analytical',
            category: ThaiThemeCategory.thinkingStyle,
            score: 0.82,
            rank: 3,
            confidence: ThaiThemeConfidenceLevel.high,
            contributions: [
              _contribution(sourceFactId: 'fact-a'),
              _contribution(sourceFactId: 'fact-b'),
            ],
          ),
        ],
      );

      final evidence = _dimension(
        ThaiMirrorEngine.reflect(bundle).snapshot,
        ThaiMirrorDimensionId.thinkingPattern,
      )!.evidence.single;

      expect(evidence.themeId, 'analytical');
      expect(evidence.category, ThaiThemeCategory.thinkingStyle);
      expect(evidence.score, 0.82);
      expect(evidence.rank, 3);
      expect(evidence.confidence, ThaiThemeConfidenceLevel.high);
      expect(evidence.distinctSourceFactCount, 2);
    });
  });

  group('M2 import boundary validation', () {
    test('mirror engine does not import forbidden packages', () {
      final source = File(
        'lib/features/astrology/thai/mirror_v2/thai_mirror_engine.dart',
      ).readAsStringSync();
      final forbiddenImportPatterns = [
        'signal/',
        'interpretation/',
        'content_lookup/',
        'fusion/',
      ];

      for (final pattern in forbiddenImportPatterns) {
        expect(
          RegExp("import '[^']*$pattern").hasMatch(source),
          isFalse,
          reason: 'thai_mirror_engine.dart must not import $pattern',
        );
      }
    });
  });
}
