import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/foundation/models/profile_warning.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/foundation/v2/engines/thai_chart_engine.dart';
import 'package:knowme/features/astrology/thai/fusion_v2/contracts/thai_fusion_engine_contract.dart';
import 'package:knowme/features/astrology/thai/fusion_v2/contracts/thai_fusion_warning_contract.dart';
import 'package:knowme/features/astrology/thai/fusion_v2/enums/thai_fusion_category_id.dart';
import 'package:knowme/features/astrology/thai/fusion_v2/enums/thai_fusion_confidence_level.dart';
import 'package:knowme/features/astrology/thai/fusion_v2/enums/thai_fusion_pattern_type.dart';
import 'package:knowme/features/astrology/thai/fusion_v2/models/thai_fusion_category_activation.dart';
import 'package:knowme/features/astrology/thai/fusion_v2/models/thai_fusion_snapshot.dart';
import 'package:knowme/features/astrology/thai/fusion_v2/thai_fusion_engine.dart';
import 'package:knowme/features/astrology/thai/interpretation/constants/thai_interpreter_version.dart';
import 'package:knowme/features/astrology/thai/interpretation/enums/thai_interpretation_fact_tier.dart';
import 'package:knowme/features/astrology/thai/interpretation/enums/thai_meaning_predicate.dart';
import 'package:knowme/features/astrology/thai/interpretation/models/thai_interpretation_bundle.dart';
import 'package:knowme/features/astrology/thai/interpretation/models/thai_interpretation_evidence.dart';
import 'package:knowme/features/astrology/thai/interpretation/models/thai_interpretation_fact.dart';
import 'package:knowme/features/astrology/thai/interpretation/models/thai_interpretation_provenance.dart';
import 'package:knowme/features/astrology/thai/interpretation/thai_interpretation_engine.dart';
import 'package:knowme/features/astrology/thai/mirror_v2/contracts/thai_mirror_warning_contract.dart';
import 'package:knowme/features/astrology/thai/mirror_v2/enums/thai_mirror_dimension_id.dart';
import 'package:knowme/features/astrology/thai/mirror_v2/models/thai_mirror_snapshot.dart';
import 'package:knowme/features/astrology/thai/mirror_v2/thai_mirror_engine.dart';
import 'package:knowme/features/astrology/thai/signal/constants/thai_signal_extractor_version.dart';
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

ThaiInterpretationEvidence _evidence({required String signalId}) {
  return ThaiInterpretationEvidence(
    primarySignalId: signalId,
    sourceSignalIds: [signalId],
    structuralFactKeys: [signalId],
    auditRef: 'test',
  );
}

ThaiInterpretationProvenance _provenance({required String ruleId}) {
  return ThaiInterpretationProvenance(
    interpreterVersion: ThaiInterpreterVersionContract.interpreterVersion,
    ruleId: ruleId,
    ruleVersion: 'v1',
    derived: false,
  );
}

ThaiInterpretationFact _fact({
  required String factId,
  ThaiMeaningPredicate predicate = ThaiMeaningPredicate.lagnaSignIs,
  String objectRef = 'virgo',
  double confidence = 0.9,
}) {
  return ThaiInterpretationFact(
    factId: factId,
    predicate: predicate,
    objectRef: objectRef,
    context: const {},
    tier: ThaiInterpretationFactTier.core,
    evidence: _evidence(signalId: factId),
    confidence: confidence,
    provenance: _provenance(ruleId: '${predicate.id}_rule'),
  );
}

ThaiInterpretationBundle _interpretationBundle({
  required String bundleId,
  required List<ThaiInterpretationFact> facts,
}) {
  return ThaiInterpretationBundle(
    bundleId: bundleId,
    sourceBundleId: 'signal-$bundleId',
    extractorVersion: ThaiSignalExtractorContract.extractorVersion,
    interpreterVersion: ThaiInterpreterVersionContract.interpreterVersion,
    interpretedAt: DateTime.utc(2026, 6, 15, 12, 0),
    hasBirthTime: true,
    facts: facts,
  );
}

List<ThaiInterpretationFact> _factsForThemes(List<ThaiThemeScore> themes) {
  final factIds = <String>{};
  for (final theme in themes) {
    for (final contribution in theme.contributions) {
      factIds.add(contribution.sourceFactId);
    }
  }

  return factIds.map((factId) => _fact(factId: factId)).toList(growable: false);
}

ThaiThemeBundle _themeBundle({
  required String interpretationBundleId,
  required List<ThaiThemeScore> themes,
  DateTime? generatedAt,
}) {
  return ThaiThemeBundle(
    bundleId:
        '$interpretationBundleId|${ThaiThemeEngineVersionContract.themeEngineVersion}',
    sourceInterpretationBundleId: interpretationBundleId,
    generatedAt: generatedAt ?? DateTime.utc(2026, 6, 15, 14, 0),
    themes: themes,
  );
}

ThaiFusionEngineResult _synthesizeAligned({
  required List<ThaiThemeScore> themes,
  String interpretationBundleId = 'interp-aligned',
  List<ThaiInterpretationFact>? facts,
}) {
  final themeBundle = _themeBundle(
    interpretationBundleId: interpretationBundleId,
    themes: themes,
  );
  final interpretation = _interpretationBundle(
    bundleId: interpretationBundleId,
    facts: facts ?? _factsForThemes(themes),
  );
  final mirror = ThaiMirrorEngine.reflect(themeBundle).snapshot;

  return ThaiFusionEngine.synthesize(
    mirror: mirror,
    theme: themeBundle,
    interpretation: interpretation,
  );
}

List<String> _warningCodes(List<ProfileWarning> warnings) {
  return warnings.map((warning) => warning.code).toList();
}

ThaiFusionCategoryActivation? _categoryActivation(
  ThaiFusionSnapshot snapshot,
  ThaiFusionCategoryId categoryId,
) {
  for (final category in snapshot.categories) {
    if (category.categoryId == categoryId) {
      return category;
    }
  }
  return null;
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


void main() {
  group('F2 lineage validation', () {
    test('emits FUSION_INPUT_LINEAGE_MISMATCH when mirror theme bundle id mismatches', () {
      final themes = [
        _themeScore(
          themeId: 'analytical',
          category: ThaiThemeCategory.thinkingStyle,
          score: 0.8,
          rank: 1,
        ),
      ];
      final themeBundle = _themeBundle(
        interpretationBundleId: 'interp-lineage',
        themes: themes,
      );
      final interpretation = _interpretationBundle(
        bundleId: 'interp-lineage',
        facts: _factsForThemes(themes),
      );
      final mirror = ThaiMirrorEngine.reflect(themeBundle).snapshot;
      final mismatchedMirror = ThaiMirrorSnapshot(
        snapshotId: mirror.snapshotId,
        sourceThemeBundleId: 'wrong-theme-bundle',
        mirrorVersion: mirror.mirrorVersion,
        generatedAt: mirror.generatedAt,
        dimensions: mirror.dimensions,
        insights: mirror.insights,
        warnings: mirror.warnings,
      );

      final result = ThaiFusionEngine.synthesize(
        mirror: mismatchedMirror,
        theme: themeBundle,
        interpretation: interpretation,
      );

      expect(
        _warningCodes(result.warnings),
        contains(ThaiFusionWarningContract.inputLineageMismatch),
      );
    });

    test('emits FUSION_INPUT_LINEAGE_MISMATCH when theme bundle id does not start with interpretation id', () {
      final themes = [
        _themeScore(
          themeId: 'analytical',
          category: ThaiThemeCategory.thinkingStyle,
          score: 0.8,
          rank: 1,
        ),
      ];
      final themeBundle = ThaiThemeBundle(
        bundleId: 'orphan-theme|${ThaiThemeEngineVersionContract.themeEngineVersion}',
        sourceInterpretationBundleId: 'interp-lineage-2',
        generatedAt: DateTime.utc(2026, 6, 15, 14, 0),
        themes: themes,
      );
      final interpretation = _interpretationBundle(
        bundleId: 'interp-lineage-2',
        facts: _factsForThemes(themes),
      );
      final mirror = ThaiMirrorEngine.reflect(themeBundle).snapshot;

      final result = ThaiFusionEngine.synthesize(
        mirror: mirror,
        theme: themeBundle,
        interpretation: interpretation,
      );

      expect(
        _warningCodes(result.warnings),
        contains(ThaiFusionWarningContract.inputLineageMismatch),
      );
    });
  });

  group('F2 category activation', () {
    test('builds prominence themeCount and factCount from theme bundle only', () {
      final result = _synthesizeAligned(
        themes: [
          _themeScore(
            themeId: 'analytical',
            category: ThaiThemeCategory.thinkingStyle,
            score: 0.8,
            rank: 1,
            contributions: [
              _contribution(sourceFactId: 'fact-a'),
              _contribution(sourceFactId: 'fact-b'),
            ],
          ),
          _themeScore(
            themeId: 'curious',
            category: ThaiThemeCategory.thinkingStyle,
            score: 0.5,
            rank: 2,
            contributions: [
              _contribution(sourceFactId: 'fact-b'),
              _contribution(sourceFactId: 'fact-c'),
            ],
          ),
        ],
      );

      final activation = _categoryActivation(
        result.snapshot,
        ThaiFusionCategoryId.thinkingStyle,
      );

      expect(activation, isNotNull);
      expect(activation!.prominence, closeTo(1.3, 1e-9));
      expect(activation.themeCount, 2);
      expect(activation.factCount, 3);
      expect(activation.dimensionRefId, ThaiMirrorDimensionId.thinkingPattern.id);
      expect(activation.confidence, ThaiFusionConfidenceLevel.medium);
    });
  });

  group('F2 agreement generation', () {
    test('creates agreement when category has themes and interpretation facts', () {
      final result = _synthesizeAligned(
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
        ],
      );

      expect(result.snapshot.agreements, hasLength(2));
      final thinkingAgreement = result.snapshot.agreements.firstWhere(
        (agreement) => agreement.categoryId == ThaiFusionCategoryId.thinkingStyle,
      );

      expect(thinkingAgreement.themeIds, ['analytical']);
      expect(thinkingAgreement.factIds, ['analytical-fact-1']);
      expect(thinkingAgreement.strength, 2);
      expect(thinkingAgreement.confidence, ThaiFusionConfidenceLevel.medium);
      expect(
        result.snapshot.insights.where(
          (insight) =>
              insight.patternType == ThaiFusionPatternType.crossLayerAgreement &&
              insight.categoryId == ThaiFusionCategoryId.thinkingStyle,
        ),
        hasLength(1),
      );
    });
  });

  group('F2 coverage gap', () {
    test('emits coverageGap insights for categories missing themes or facts', () {
      final result = _synthesizeAligned(
        themes: [
          _themeScore(
            themeId: 'analytical',
            category: ThaiThemeCategory.thinkingStyle,
            score: 0.8,
            rank: 1,
          ),
        ],
      );

      final gapInsights = result.snapshot.insights.where(
        (insight) => insight.patternType == ThaiFusionPatternType.coverageGap,
      );

      expect(gapInsights.length, greaterThan(0));
      expect(
        gapInsights.any(
          (insight) => insight.categoryId == ThaiFusionCategoryId.emotionalWorld,
        ),
        isTrue,
      );
    });
  });

  group('F2 sparse synthesis', () {
    test('emits sparseFusionCoverage insight when mirror has MIRROR_SPARSE_DIMENSION', () {
      final result = _synthesizeAligned(
        themes: [
          _themeScore(
            themeId: 'solo',
            category: ThaiThemeCategory.emotionalWorld,
            score: 0.55,
            rank: 1,
          ),
        ],
      );

      expect(
        result.snapshot.insights.where(
          (insight) =>
              insight.patternType == ThaiFusionPatternType.sparseFusionCoverage,
        ),
        hasLength(1),
      );
      expect(
        _warningCodes(result.warnings),
        contains(ThaiFusionWarningContract.sparseSynthesis),
      );
      expect(result.snapshot.coverage.hasSparseDimensions, isTrue);
    });
  });

  group('F2 confidence', () {
    test('overall confidence is high when mirror and theme are high and facts >= 10', () {
      final facts = List<ThaiInterpretationFact>.generate(
        10,
        (index) => _fact(factId: 'fact-$index'),
      );
      final themes = [
        _themeScore(
          themeId: 'analytical',
          category: ThaiThemeCategory.thinkingStyle,
          score: 0.9,
          rank: 1,
          confidence: ThaiThemeConfidenceLevel.high,
          contributions: facts
              .map((fact) => _contribution(sourceFactId: fact.factId))
              .toList(growable: false),
        ),
        _themeScore(
          themeId: 'leader',
          category: ThaiThemeCategory.strengths,
          score: 0.5,
          rank: 2,
          confidence: ThaiThemeConfidenceLevel.high,
          contributions: [
            _contribution(sourceFactId: facts.first.factId),
          ],
        ),
      ];

      final result = _synthesizeAligned(
        interpretationBundleId: 'interp-confidence-high',
        themes: themes,
        facts: facts,
      );

      expect(result.snapshot.confidence.mirrorLevel, ThaiFusionConfidenceLevel.high);
      expect(result.snapshot.confidence.themeLevel, ThaiFusionConfidenceLevel.high);
      expect(result.snapshot.confidence.interpretationLevel, ThaiFusionConfidenceLevel.high);
      expect(result.snapshot.confidence.overallLevel, ThaiFusionConfidenceLevel.high);
      expect(result.snapshot.confidence.distinctSourceFactCount, 10);
    });

    test('overall confidence is medium when at least two layers are medium', () {
      expect(
        ThaiFusionEngine.overallConfidenceLevel(
          mirrorLevel: ThaiFusionConfidenceLevel.medium,
          themeLevel: ThaiFusionConfidenceLevel.medium,
          interpretationLevel: ThaiFusionConfidenceLevel.low,
          interpretationFactCount: 2,
        ),
        ThaiFusionConfidenceLevel.medium,
      );
      expect(
        ThaiFusionEngine.overallConfidenceLevel(
          mirrorLevel: ThaiFusionConfidenceLevel.low,
          themeLevel: ThaiFusionConfidenceLevel.medium,
          interpretationLevel: ThaiFusionConfidenceLevel.medium,
          interpretationFactCount: 5,
        ),
        ThaiFusionConfidenceLevel.medium,
      );
    });

    test('overall confidence is low when fewer than two medium layers', () {
      expect(
        ThaiFusionEngine.overallConfidenceLevel(
          mirrorLevel: ThaiFusionConfidenceLevel.low,
          themeLevel: ThaiFusionConfidenceLevel.low,
          interpretationLevel: ThaiFusionConfidenceLevel.low,
          interpretationFactCount: 1,
        ),
        ThaiFusionConfidenceLevel.low,
      );
    });
  });

  group('F2 coverage', () {
    test('reports mapped mirror and interpretation coverage counts', () {
      final result = _synthesizeAligned(
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
        ],
      );

      expect(result.snapshot.coverage.mappedCategoryCount, 2);
      expect(result.snapshot.coverage.totalCategoryCount, 8);
      expect(result.snapshot.coverage.mirrorDimensionCount, 2);
      expect(result.snapshot.coverage.interpretationFactCount, 2);
      expect(
        _warningCodes(result.warnings),
        contains(ThaiFusionWarningContract.insufficientCoverage),
      );
    });
  });

  group('F2 snapshot identity', () {
    test('fusionSnapshotId follows frozen identity contract and uses mirror generatedAt', () {
      final generatedAt = DateTime.utc(2026, 6, 15, 14, 0);
      final result = _synthesizeAligned(
        themes: [
          _themeScore(
            themeId: 'analytical',
            category: ThaiThemeCategory.thinkingStyle,
            score: 0.8,
            rank: 1,
          ),
        ],
      );
      final themeBundle = _themeBundle(
        interpretationBundleId: 'interp-aligned',
        themes: [
          _themeScore(
            themeId: 'analytical',
            category: ThaiThemeCategory.thinkingStyle,
            score: 0.8,
            rank: 1,
          ),
        ],
        generatedAt: generatedAt,
      );
      final mirror = ThaiMirrorEngine.reflect(themeBundle).snapshot;
      final interpretation = _interpretationBundle(
        bundleId: 'interp-aligned',
        facts: _factsForThemes(themeBundle.themes),
      );
      final identityResult = ThaiFusionEngine.synthesize(
        mirror: mirror,
        theme: themeBundle,
        interpretation: interpretation,
      );

      expect(
        identityResult.snapshot.fusionSnapshotId,
        '${mirror.snapshotId}${ThaiFusionEngineContract.fusionSnapshotIdDelimiter}'
        '${ThaiFusionEngineContract.fusionVersion}',
      );
      expect(
        ThaiFusionEngine.fusionSnapshotId(sourceMirrorSnapshotId: mirror.snapshotId),
        identityResult.snapshot.fusionSnapshotId,
      );
      expect(identityResult.snapshot.generatedAt, generatedAt);
      expect(identityResult.snapshot.sourceMirrorSnapshotId, mirror.snapshotId);
      expect(identityResult.snapshot.sourceThemeBundleId, themeBundle.bundleId);
      expect(
        identityResult.snapshot.sourceInterpretationBundleId,
        interpretation.bundleId,
      );
      expect(result.snapshot.tensions, isEmpty);
    });
  });

  group('F2 deterministic run', () {
    test('100 runs produce identical synthesis output', () {
      final birth = _bangkokBirth(year: 1990, month: 1, day: 15, hour: 10, minute: 30);
      final chart = ThaiChartEngine.generate(birth);
      final signalBundle = ThaiSignalExtractor.extract(
        ThaiSignalExtractorInput(chart: chart, birthData: birth),
      ).bundle;
      final interpretation = ThaiInterpretationEngine.interpret(signalBundle).bundle;
      final theme = ThaiThemeEngine.aggregate(interpretation).bundle;
      final mirror = ThaiMirrorEngine.reflect(theme).snapshot;

      ThaiFusionSnapshot? baseline;
      for (var run = 0; run < 100; run++) {
        final snapshot = ThaiFusionEngine.synthesize(
          mirror: mirror,
          theme: theme,
          interpretation: interpretation,
        ).snapshot;
        if (baseline == null) {
          baseline = snapshot;
          continue;
        }

        expect(snapshot.fusionSnapshotId, baseline.fusionSnapshotId);
        expect(snapshot.sourceMirrorSnapshotId, baseline.sourceMirrorSnapshotId);
        expect(snapshot.sourceThemeBundleId, baseline.sourceThemeBundleId);
        expect(snapshot.sourceInterpretationBundleId, baseline.sourceInterpretationBundleId);
        expect(snapshot.generatedAt, baseline.generatedAt);
        expect(snapshot.categories, baseline.categories);
        expect(snapshot.insights, baseline.insights);
        expect(snapshot.agreements, baseline.agreements);
        expect(snapshot.tensions, baseline.tensions);
        expect(snapshot.confidence, baseline.confidence);
        expect(snapshot.coverage, baseline.coverage);
        expect(_warningCodes(snapshot.warnings), _warningCodes(baseline.warnings));
      }
    });
  });

  group('F2 import boundary validation', () {
    test('fusion engine does not import forbidden packages', () {
      final source = File(
        'lib/features/astrology/thai/fusion_v2/thai_fusion_engine.dart',
      ).readAsStringSync();
      final forbiddenImportPatterns = [
        'signal/',
        'content_lookup/',
        'chart/',
        'birthdata/',
        'ui/',
      ];

      for (final pattern in forbiddenImportPatterns) {
        expect(
          RegExp("import '[^']*$pattern").hasMatch(source),
          isFalse,
          reason: 'thai_fusion_engine.dart must not import $pattern',
        );
      }
    });
  });
}
