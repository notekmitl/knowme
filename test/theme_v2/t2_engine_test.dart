import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/foundation/models/profile_warning.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/foundation/v2/engines/thai_chart_engine.dart';
import 'package:knowme/features/astrology/thai/interpretation/constants/thai_interpreter_version.dart';
import 'package:knowme/features/astrology/thai/interpretation/enums/thai_interpretation_fact_tier.dart';
import 'package:knowme/features/astrology/thai/interpretation/enums/thai_meaning_predicate.dart';
import 'package:knowme/features/astrology/thai/interpretation/models/thai_interpretation_bundle.dart';
import 'package:knowme/features/astrology/thai/interpretation/models/thai_interpretation_evidence.dart';
import 'package:knowme/features/astrology/thai/interpretation/models/thai_interpretation_fact.dart';
import 'package:knowme/features/astrology/thai/interpretation/models/thai_interpretation_provenance.dart';
import 'package:knowme/features/astrology/thai/interpretation/thai_interpretation_engine.dart';
import 'package:knowme/features/astrology/thai/signal/constants/thai_signal_extractor_version.dart';
import 'package:knowme/features/astrology/thai/signal/thai_signal_extractor.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_confidence_level.dart';
import 'package:knowme/features/astrology/thai/theme_v2/constants/thai_theme_engine_version.dart';
import 'package:knowme/features/astrology/thai/theme_v2/enums/thai_theme_category.dart';
import 'package:knowme/features/astrology/thai/theme_v2/models/thai_theme_bundle.dart';
import 'package:knowme/features/astrology/thai/theme_v2/models/thai_theme_score.dart';
import 'package:knowme/features/astrology/thai/theme_v2/thai_theme_engine.dart';

const _bangkokOffset = Duration(hours: 7);

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
  required ThaiMeaningPredicate predicate,
  required String objectRef,
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

ThaiInterpretationBundle _bundle({
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

ThaiInterpretationBundle _interpretedBundle(ThaiBirthData birth) {
  final chart = ThaiChartEngine.generate(birth);
  final signalBundle = ThaiSignalExtractor.extract(
    ThaiSignalExtractorInput(chart: chart, birthData: birth),
  ).bundle;
  return ThaiInterpretationEngine.interpret(signalBundle).bundle;
}

ThaiThemeScore? _theme(
  ThaiThemeBundle bundle, {
  required String themeId,
  ThaiThemeCategory? category,
}) {
  for (final theme in bundle.themes) {
    if (theme.themeId == themeId &&
        (category == null || theme.category == category)) {
      return theme;
    }
  }
  return null;
}

void main() {
  group('T2 single theme aggregation', () {
    test('aggregates one theme from one mapped fact', () {
      final bundle = _bundle(
        bundleId: 'single-theme-bundle',
        facts: [
          _fact(
            factId: 'fact-virgo',
            predicate: ThaiMeaningPredicate.lagnaSignIs,
            objectRef: 'virgo',
            confidence: 0.8,
          ),
        ],
      );

      final result = ThaiThemeEngine.aggregate(bundle);
      final analytical = _theme(
        result.bundle,
        themeId: 'analytical',
        category: ThaiThemeCategory.thinkingStyle,
      );

      expect(analytical, isNotNull);
      expect(analytical!.score, closeTo(0.9 * 0.8, 1e-9));
      expect(analytical.contributions, hasLength(1));
      expect(analytical.contributions.first.sourceFactId, 'fact-virgo');
      expect(analytical.contributions.first.contentKey, 'lagna_virgo');
      expect(
        analytical.contributions.first.contribution,
        closeTo(0.72, 1e-9),
      );
    });
  });

  group('T2 multi theme aggregation', () {
    test('one fact expands into multiple theme scores', () {
      final bundle = _bundle(
        bundleId: 'multi-theme-bundle',
        facts: [
          _fact(
            factId: 'fact-virgo',
            predicate: ThaiMeaningPredicate.lagnaSignIs,
            objectRef: 'virgo',
          ),
        ],
      );

      final result = ThaiThemeEngine.aggregate(bundle);
      final themeIds = result.bundle.themes.map((theme) => theme.themeId).toSet();

      expect(themeIds, containsAll(['practical', 'analytical', 'specialist']));
      expect(result.bundle.themes, hasLength(3));
    });
  });

  group('T2 rank ordering', () {
    test('sorts by score desc then themeId asc and assigns ranks from 1', () {
      final bundle = _bundle(
        bundleId: 'rank-bundle',
        facts: [
          _fact(
            factId: 'fact-virgo',
            predicate: ThaiMeaningPredicate.lagnaSignIs,
            objectRef: 'virgo',
            confidence: 1.0,
          ),
          _fact(
            factId: 'fact-aquarius',
            predicate: ThaiMeaningPredicate.lagnaSignIs,
            objectRef: 'aquarius',
            confidence: 0.5,
          ),
        ],
      );

      final result = ThaiThemeEngine.aggregate(bundle);
      final themes = result.bundle.themes;

      expect(themes.first.rank, 1);
      expect(themes.last.rank, themes.length);
      for (var i = 1; i < themes.length; i++) {
        final previous = themes[i - 1];
        final current = themes[i];
        final scoreCompare = previous.score.compareTo(current.score);
        expect(scoreCompare, greaterThanOrEqualTo(0));
        if (scoreCompare == 0) {
          expect(previous.themeId.compareTo(current.themeId), lessThanOrEqualTo(0));
        }
        expect(current.rank, previous.rank + 1);
      }
    });
  });

  group('T2 confidence tiers', () {
    test('maps distinct sourceFactId counts to low, medium, and high', () {
      expect(
        ThaiThemeEngine.confidenceFromDistinctSourceFacts(1),
        ThaiThemeConfidenceLevel.low,
      );
      expect(
        ThaiThemeEngine.confidenceFromDistinctSourceFacts(2),
        ThaiThemeConfidenceLevel.medium,
      );
      expect(
        ThaiThemeEngine.confidenceFromDistinctSourceFacts(3),
        ThaiThemeConfidenceLevel.medium,
      );
      expect(
        ThaiThemeEngine.confidenceFromDistinctSourceFacts(4),
        ThaiThemeConfidenceLevel.high,
      );
    });

    test('theme confidence follows distinct sourceFactId count', () {
      final bundle = _bundle(
        bundleId: 'confidence-bundle',
        facts: [
          _fact(
            factId: 'fact-virgo',
            predicate: ThaiMeaningPredicate.lagnaSignIs,
            objectRef: 'virgo',
          ),
          _fact(
            factId: 'fact-aquarius',
            predicate: ThaiMeaningPredicate.lagnaSignIs,
            objectRef: 'aquarius',
          ),
          _fact(
            factId: 'fact-mercury-lord',
            predicate: ThaiMeaningPredicate.lagnaLordIs,
            objectRef: 'mercury',
          ),
          _fact(
            factId: 'fact-myanmar-4',
            predicate: ThaiMeaningPredicate.myanmarPositionIs,
            objectRef: 'myanmar_seven_4',
          ),
        ],
      );

      final analytical = _theme(
        ThaiThemeEngine.aggregate(bundle).bundle,
        themeId: 'analytical',
        category: ThaiThemeCategory.thinkingStyle,
      );

      expect(analytical, isNotNull);
      expect(analytical!.confidence, ThaiThemeConfidenceLevel.high);
      expect(
        analytical.contributions.map((item) => item.sourceFactId).toSet(),
        hasLength(4),
      );
    });
  });

  group('T2 bundleId determinism', () {
    test('bundleId follows frozen identity contract', () {
      final bundle = _bundle(
        bundleId: 'interpretation-bundle-123',
        facts: [
          _fact(
            factId: 'fact-virgo',
            predicate: ThaiMeaningPredicate.lagnaSignIs,
            objectRef: 'virgo',
          ),
        ],
      );

      final result = ThaiThemeEngine.aggregate(bundle);

      expect(
        result.bundle.bundleId,
        'interpretation-bundle-123|${ThaiThemeEngineVersionContract.themeEngineVersion}',
      );
      expect(
        ThaiThemeEngine.bundleId(
          sourceInterpretationBundleId: bundle.bundleId,
        ),
        result.bundle.bundleId,
      );
      expect(
        result.bundle.sourceInterpretationBundleId,
        bundle.bundleId,
      );
    });
  });

  group('T2 deterministic run', () {
    test('100 runs produce identical aggregation output', () {
      final bundle = _interpretedBundle(
        _bangkokBirth(year: 1990, month: 1, day: 15, hour: 10, minute: 30),
      );

      ThaiThemeBundle? baseline;
      for (var run = 0; run < 100; run++) {
        final result = ThaiThemeEngine.aggregate(bundle);
        if (baseline == null) {
          baseline = result.bundle;
          continue;
        }

        expect(result.bundle.bundleId, baseline.bundleId);
        expect(result.bundle.sourceInterpretationBundleId,
            baseline.sourceInterpretationBundleId);
        expect(result.bundle.generatedAt, baseline.generatedAt);
        expect(result.bundle.themes, baseline.themes);
        expect(result.bundle.warnings, baseline.warnings);
      }
    });
  });

  group('T2 missing mapping warning', () {
    test('emits THEME_MAPPING_NOT_FOUND for unknown content key', () {
      final bundle = _bundle(
        bundleId: 'missing-mapping-bundle',
        facts: [
          _fact(
            factId: 'fact-unknown-lagna',
            predicate: ThaiMeaningPredicate.lagnaSignIs,
            objectRef: 'unknown_sign',
          ),
        ],
      );

      final result = ThaiThemeEngine.aggregate(bundle);

      expect(result.bundle.themes, isEmpty);
      expect(result.warnings, hasLength(1));
      expect(result.warnings.single.code, ThaiThemeEngine.warningMappingNotFound);
      expect(
        result.warnings.single.affectedFields,
        ['fact-unknown-lagna', 'lagna_unknown_sign'],
      );
    });

    test('bundle warnings are limited to THEME_MAPPING_NOT_FOUND', () {
      final bundle = _bundle(
        bundleId: 'warning-code-bundle',
        facts: [
          _fact(
            factId: 'fact-unknown-lagna',
            predicate: ThaiMeaningPredicate.lagnaSignIs,
            objectRef: 'unknown_sign',
          ),
        ],
      );

      final result = ThaiThemeEngine.aggregate(bundle);
      for (final warning in result.bundle.warnings) {
        expect(warning.code, ThaiThemeEngine.warningMappingNotFound);
      }
    });
  });

  group('T2 import boundary validation', () {
    test('theme engine does not import forbidden packages', () {
      final engineFile = File(
        'lib/features/astrology/thai/theme_v2/thai_theme_engine.dart',
      );
      final source = engineFile.readAsStringSync();
      final forbiddenImportPatterns = [
        'signal/',
        'mirror/',
        'fusion/',
      ];

      for (final pattern in forbiddenImportPatterns) {
        expect(
          RegExp("import '[^']*$pattern").hasMatch(source),
          isFalse,
          reason: 'thai_theme_engine.dart must not import $pattern',
        );
      }
    });
  });

  group('T2 aggregation formula', () {
    test('score equals sum of mappingWeight x fact.confidence contributions', () {
      final bundle = _bundle(
        bundleId: 'formula-bundle',
        facts: [
          _fact(
            factId: 'fact-virgo',
            predicate: ThaiMeaningPredicate.lagnaSignIs,
            objectRef: 'virgo',
            confidence: 0.8,
          ),
          _fact(
            factId: 'fact-aquarius',
            predicate: ThaiMeaningPredicate.lagnaSignIs,
            objectRef: 'aquarius',
            confidence: 0.5,
          ),
        ],
      );

      final analytical = _theme(
        ThaiThemeEngine.aggregate(bundle).bundle,
        themeId: 'analytical',
        category: ThaiThemeCategory.thinkingStyle,
      );

      expect(analytical, isNotNull);
      final expectedScore = analytical!.contributions
          .fold<double>(0, (total, item) => total + item.contribution);
      expect(analytical.score, closeTo(expectedScore, 1e-9));
      expect(analytical.score, closeTo((0.9 * 0.8) + (0.85 * 0.5), 1e-9));
    });
  });
}
