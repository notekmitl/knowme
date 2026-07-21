import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/foundation/models/profile_warning.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_confidence_level.dart';
import 'package:knowme/features/astrology/thai/theme_v2/constants/thai_theme_engine_version.dart';
import 'package:knowme/features/astrology/thai/theme_v2/contracts/thai_theme_bundle_identity_contract.dart';
import 'package:knowme/features/astrology/thai/theme_v2/contracts/thai_theme_engine_contract.dart';
import 'package:knowme/features/astrology/thai/theme_v2/enums/thai_theme_category.dart';
import 'package:knowme/features/astrology/thai/theme_v2/models/thai_theme_bundle.dart';
import 'package:knowme/features/astrology/thai/theme_v2/models/thai_theme_contribution.dart';
import 'package:knowme/features/astrology/thai/theme_v2/models/thai_theme_score.dart';

ThaiThemeContribution _sampleContribution({
  String sourceFactId =
      'lagna_sign_rule_v1:LAGNA_SIGN_IS:virgo@lagna_sign_virgo',
  String contentKey = 'lagna_virgo',
  double contribution = 0.42,
}) {
  return ThaiThemeContribution(
    sourceFactId: sourceFactId,
    contentKey: contentKey,
    contribution: contribution,
  );
}

ThaiThemeScore _sampleThemeScore({
  String themeId = 'analytical_mind',
  ThaiThemeCategory category = ThaiThemeCategory.thinkingStyle,
  double score = 0.73,
  ThaiThemeConfidenceLevel confidence = ThaiThemeConfidenceLevel.high,
  int rank = 1,
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
          _sampleContribution(),
          _sampleContribution(
            sourceFactId:
                'lagna_lord_rule_v1:LAGNA_LORD_IS:mercury@lagna_lord_mercury',
            contentKey: 'lagna_lord_mercury',
            contribution: 0.31,
          ),
        ],
  );
}

ThaiThemeBundle _sampleBundle() {
  return ThaiThemeBundle(
    bundleId: 'interpretation-bundle-id|v0.1.0',
    sourceInterpretationBundleId: 'interpretation-bundle-id',
    generatedAt: DateTime.utc(2026, 6, 15, 14, 0),
    themes: [
      _sampleThemeScore(),
      _sampleThemeScore(
        themeId: 'core_identity',
        category: ThaiThemeCategory.coreSelf,
        score: 0.55,
        confidence: ThaiThemeConfidenceLevel.medium,
        rank: 2,
        contributions: [
          _sampleContribution(
            sourceFactId:
                'lagna_lord_rule_v1:LAGNA_LORD_IS:mercury@lagna_lord_mercury',
            contentKey: 'lagna_lord_mercury',
            contribution: 0.55,
          ),
        ],
      ),
    ],
    warnings: const [
      ProfileWarning(
        code: 'THEME_CONTENT_SECTION_NOT_FOUND',
        severity: ProfileWarningSeverity.medium,
        message: 'test warning',
      ),
    ],
  );
}

void main() {
  group('T1 model construction', () {
    test('ThaiThemeScore holds aggregation fields without text', () {
      final theme = _sampleThemeScore();

      expect(theme.themeId, 'analytical_mind');
      expect(theme.category, ThaiThemeCategory.thinkingStyle);
      expect(theme.score, 0.73);
      expect(theme.confidence, ThaiThemeConfidenceLevel.high);
      expect(theme.rank, 1);
      expect(theme.contributions, hasLength(2));
    });

    test('ThaiThemeContribution holds lean trace fields only', () {
      final contribution = _sampleContribution();

      expect(contribution.sourceFactId, contains('LAGNA_SIGN_IS'));
      expect(contribution.contentKey, 'lagna_virgo');
      expect(contribution.contribution, 0.42);
    });

    test('ThaiThemeScore rejects empty contributions', () {
      expect(
        () => ThaiThemeScore(
          themeId: 'test',
          category: ThaiThemeCategory.coreSelf,
          score: 0.5,
          confidence: ThaiThemeConfidenceLevel.low,
          rank: 1,
          contributions: const [],
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('ThaiThemeBundle stores bundleId without generating it', () {
      final bundle = _sampleBundle();

      expect(bundle.bundleId, 'interpretation-bundle-id|v0.1.0');
      expect(bundle.sourceInterpretationBundleId, 'interpretation-bundle-id');
      expect(bundle.themes, hasLength(2));
    });

    test('ThaiThemeCategory covers all eight categories', () {
      expect(ThaiThemeCategory.values, hasLength(8));
      expect(ThaiThemeEngineContract.supportedCategoryIds, hasLength(8));
    });
  });

  group('T1 serialization', () {
    test('ThaiThemeContribution round-trips through map', () {
      final original = _sampleContribution();
      final restored = ThaiThemeContribution.fromMap(original.toMap());

      expect(restored, original);
    });

    test('ThaiThemeScore round-trips through map', () {
      final original = _sampleThemeScore();
      final restored = ThaiThemeScore.fromMap(original.toMap());

      expect(restored, original);
      expect(restored.confidence.id, 'high');
    });

    test('ThaiThemeBundle round-trips through map', () {
      final original = _sampleBundle();
      final restored = ThaiThemeBundle.fromMap(original.toMap());

      expect(restored, original);
      expect(restored.themes, hasLength(2));
      expect(restored.warnings.first.code, 'THEME_CONTENT_SECTION_NOT_FOUND');
    });

    test('category parses from string id', () {
      expect(
        parseThaiThemeCategory('work_ambition'),
        ThaiThemeCategory.workAmbition,
      );
    });
  });

  group('T1 equality', () {
    test('ThaiThemeScore value equality', () {
      final left = _sampleThemeScore();
      final right = _sampleThemeScore();

      expect(left, right);
      expect(left.hashCode, right.hashCode);
    });

    test('ThaiThemeContribution value equality', () {
      final left = _sampleContribution();
      final right = _sampleContribution();

      expect(left, right);
      expect(left.hashCode, right.hashCode);
    });

    test('ThaiThemeBundle value equality', () {
      final left = _sampleBundle();
      final right = _sampleBundle();

      expect(left, right);
      expect(left.hashCode, right.hashCode);
    });
  });

  group('T1 forbidden field audit', () {
    test('allowed score fields are not forbidden', () {
      for (final allowed in ['score', 'rank', 'contributions']) {
        expect(
          ThaiThemeEngineContract.forbiddenThemeFieldNames,
          isNot(contains(allowed)),
        );
      }
    });

    test('forbidden presentation fields are not on score model', () {
      for (final forbidden in ['title', 'summary', 'narrative']) {
        expect(
          ThaiThemeEngineContract.themeScoreFieldNames,
          isNot(contains(forbidden)),
        );
        expect(
          ThaiThemeEngineContract.forbiddenThemeFieldNames,
          contains(forbidden),
        );
      }
    });

    test('theme model sources do not declare forbidden fields', () {
      final modelPaths = [
        'lib/features/astrology/thai/theme_v2/models/thai_theme_score.dart',
        'lib/features/astrology/thai/theme_v2/models/thai_theme_contribution.dart',
        'lib/features/astrology/thai/theme_v2/models/thai_theme_bundle.dart',
      ];

      for (final path in modelPaths) {
        final source = File(path).readAsStringSync();
        for (final forbidden in ThaiThemeEngineContract.forbiddenThemeFieldNames) {
          expect(
            source.contains('final $forbidden'),
            isFalse,
            reason: '$path must not declare forbidden field $forbidden',
          );
        }
      }
    });

    test('serialized score map keys match allowed field names only', () {
      final keys = _sampleThemeScore().toMap().keys.toList();
      for (final key in keys) {
        expect(
          ThaiThemeEngineContract.themeScoreFieldNames,
          contains(key),
        );
      }
    });

    test('serialized contribution map keys match allowed field names only', () {
      final keys = _sampleContribution().toMap().keys.toList();
      for (final key in keys) {
        expect(
          ThaiThemeEngineContract.themeContributionFieldNames,
          contains(key),
        );
      }
    });
  });

  group('T1 identity contract audit', () {
    test('bundleId formula uses sourceInterpretationBundleId', () {
      expect(
        ThaiThemeBundleIdentityContract.bundleIdFormula,
        contains('sourceInterpretationBundleId'),
      );
      expect(
        ThaiThemeBundleIdentityContract.bundleIdFormula,
        isNot(contains('sourceResolutionBundleId')),
      );
      expect(ThaiThemeEngineVersionContract.themeEngineVersion, 'v0.1.0');
    });
  });

  group('T1 import boundary validation', () {
    test('theme_v2 sources do not import forbidden packages', () {
      final themeDir = Directory('lib/features/astrology/thai/theme_v2');
      final forbiddenImportPatterns = [
        'signal/',
        'interpretation/rules/',
        'interpretation/router/',
        'interpretation/thai_interpretation_engine.dart',
        'content_lookup/',
        'mirror/',
        'fusion/',
      ];

      final dartFiles = themeDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .toList();

      expect(dartFiles, isNotEmpty);

      for (final file in dartFiles) {
        final source = file.readAsStringSync();
        for (final pattern in forbiddenImportPatterns) {
          expect(
            RegExp("import '[^']*$pattern").hasMatch(source),
            isFalse,
            reason: '${file.path} must not import $pattern',
          );
        }
      }
    });
  });
}
