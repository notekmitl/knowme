import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/foundation/models/profile_warning.dart';
import 'package:knowme/features/astrology/thai/mirror_v2/constants/thai_mirror_version_contract.dart';
import 'package:knowme/features/astrology/thai/mirror_v2/contracts/thai_mirror_dimension_mapping_contract.dart';
import 'package:knowme/features/astrology/thai/mirror_v2/contracts/thai_mirror_engine_contract.dart';
import 'package:knowme/features/astrology/thai/mirror_v2/contracts/thai_mirror_snapshot_identity_contract.dart';
import 'package:knowme/features/astrology/thai/mirror_v2/contracts/thai_mirror_warning_contract.dart';
import 'package:knowme/features/astrology/thai/mirror_v2/enums/thai_mirror_dimension_id.dart';
import 'package:knowme/features/astrology/thai/mirror_v2/enums/thai_mirror_pattern_type.dart';
import 'package:knowme/features/astrology/thai/mirror_v2/enums/thai_mirror_structural_confidence.dart';
import 'package:knowme/features/astrology/thai/mirror_v2/models/thai_mirror_dimension.dart';
import 'package:knowme/features/astrology/thai/mirror_v2/models/thai_mirror_evidence.dart';
import 'package:knowme/features/astrology/thai/mirror_v2/models/thai_mirror_insight.dart';
import 'package:knowme/features/astrology/thai/mirror_v2/models/thai_mirror_snapshot.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_confidence_level.dart';
import 'package:knowme/features/astrology/thai/theme_v2/enums/thai_theme_category.dart';

ThaiMirrorEvidence _sampleEvidence({
  String themeId = 'analytical',
  ThaiThemeCategory category = ThaiThemeCategory.thinkingStyle,
  double score = 0.82,
  int rank = 1,
  ThaiThemeConfidenceLevel confidence = ThaiThemeConfidenceLevel.high,
  int distinctSourceFactCount = 3,
}) {
  return ThaiMirrorEvidence(
    themeId: themeId,
    category: category,
    score: score,
    rank: rank,
    confidence: confidence,
    distinctSourceFactCount: distinctSourceFactCount,
  );
}

ThaiMirrorDimension _sampleDimension() {
  return ThaiMirrorDimension(
    dimensionId: ThaiMirrorDimensionId.thinkingPattern,
    prominence: 0.74,
    confidence: ThaiMirrorStructuralConfidence.high,
    leadingThemeIds: const ['analytical', 'curious'],
    evidence: [
      _sampleEvidence(),
      _sampleEvidence(
        themeId: 'curious',
        score: 0.61,
        rank: 2,
        confidence: ThaiThemeConfidenceLevel.medium,
        distinctSourceFactCount: 2,
      ),
    ],
  );
}

ThaiMirrorInsight _sampleInsight() {
  return ThaiMirrorInsight(
    insightId: 'thinking_pattern:dominant_theme:analytical',
    dimensionId: ThaiMirrorDimensionId.thinkingPattern,
    patternType: ThaiMirrorPatternType.dominantTheme,
    themeIds: const ['analytical'],
    structuralWeight: 0.82,
    confidence: ThaiMirrorStructuralConfidence.high,
  );
}

ThaiMirrorSnapshot _sampleSnapshot() {
  return ThaiMirrorSnapshot(
    snapshotId: 'theme-bundle-id|v0.1.0',
    sourceThemeBundleId: 'theme-bundle-id|v0.1.0',
    mirrorVersion: ThaiMirrorVersionContract.mirrorVersion,
    generatedAt: DateTime.utc(2026, 6, 15, 16, 0),
    dimensions: [_sampleDimension()],
    insights: [_sampleInsight()],
    warnings: const [
      ProfileWarning(
        code: ThaiMirrorWarningContract.sparseDimension,
        severity: ProfileWarningSeverity.low,
        message: 'test warning',
      ),
    ],
  );
}

void main() {
  group('M1 model construction', () {
    test('ThaiMirrorEvidence holds theme-signal trace fields only', () {
      final evidence = _sampleEvidence();

      expect(evidence.themeId, 'analytical');
      expect(evidence.category, ThaiThemeCategory.thinkingStyle);
      expect(evidence.score, 0.82);
      expect(evidence.rank, 1);
      expect(evidence.confidence, ThaiThemeConfidenceLevel.high);
      expect(evidence.distinctSourceFactCount, 3);
    });

    test('ThaiMirrorDimension holds structural dimension fields', () {
      final dimension = _sampleDimension();

      expect(dimension.dimensionId, ThaiMirrorDimensionId.thinkingPattern);
      expect(dimension.prominence, 0.74);
      expect(dimension.confidence, ThaiMirrorStructuralConfidence.high);
      expect(dimension.leadingThemeIds, ['analytical', 'curious']);
      expect(dimension.evidence, hasLength(2));
    });

    test('ThaiMirrorInsight holds structural pattern fields', () {
      final insight = _sampleInsight();

      expect(insight.insightId, contains('dominant_theme'));
      expect(insight.dimensionId, ThaiMirrorDimensionId.thinkingPattern);
      expect(insight.patternType, ThaiMirrorPatternType.dominantTheme);
      expect(insight.themeIds, ['analytical']);
      expect(insight.structuralWeight, 0.82);
      expect(insight.confidence, ThaiMirrorStructuralConfidence.high);
    });

    test('ThaiMirrorSnapshot stores snapshotId without generating it', () {
      final snapshot = _sampleSnapshot();

      expect(snapshot.snapshotId, 'theme-bundle-id|v0.1.0');
      expect(snapshot.sourceThemeBundleId, 'theme-bundle-id|v0.1.0');
      expect(snapshot.mirrorVersion, 'v0.1.0');
      expect(snapshot.dimensions, hasLength(1));
      expect(snapshot.insights, hasLength(1));
    });

    test('ThaiMirrorDimensionId covers all five dimensions', () {
      expect(ThaiMirrorDimensionId.values, hasLength(5));
      expect(ThaiMirrorEngineContract.supportedDimensionIds, hasLength(5));
    });

    test('ThaiMirrorPatternType covers all four pattern types', () {
      expect(ThaiMirrorPatternType.values, hasLength(4));
      expect(ThaiMirrorEngineContract.supportedPatternTypeIds, hasLength(4));
    });

    test('ThaiMirrorEvidence rejects non-positive distinctSourceFactCount', () {
      expect(
        () => ThaiMirrorEvidence(
          themeId: 'test',
          category: ThaiThemeCategory.coreSelf,
          score: 0.5,
          rank: 1,
          confidence: ThaiThemeConfidenceLevel.low,
          distinctSourceFactCount: 0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('M1 serialization', () {
    test('ThaiMirrorEvidence round-trips through map', () {
      final original = _sampleEvidence();
      final restored = ThaiMirrorEvidence.fromMap(original.toMap());

      expect(restored, original);
    });

    test('ThaiMirrorDimension round-trips through map', () {
      final original = _sampleDimension();
      final restored = ThaiMirrorDimension.fromMap(original.toMap());

      expect(restored, original);
    });

    test('ThaiMirrorInsight round-trips through map', () {
      final original = _sampleInsight();
      final restored = ThaiMirrorInsight.fromMap(original.toMap());

      expect(restored, original);
      expect(restored.patternType.id, 'dominant_theme');
    });

    test('ThaiMirrorSnapshot round-trips through map', () {
      final original = _sampleSnapshot();
      final restored = ThaiMirrorSnapshot.fromMap(original.toMap());

      expect(restored, original);
      expect(restored.warnings.first.code, ThaiMirrorWarningContract.sparseDimension);
    });

    test('dimension id parses from string id', () {
      expect(
        parseThaiMirrorDimensionId('growth_focus'),
        ThaiMirrorDimensionId.growthFocus,
      );
    });
  });

  group('M1 equality', () {
    test('ThaiMirrorEvidence value equality', () {
      final left = _sampleEvidence();
      final right = _sampleEvidence();

      expect(left, right);
      expect(left.hashCode, right.hashCode);
    });

    test('ThaiMirrorDimension value equality', () {
      final left = _sampleDimension();
      final right = _sampleDimension();

      expect(left, right);
      expect(left.hashCode, right.hashCode);
    });

    test('ThaiMirrorInsight value equality', () {
      final left = _sampleInsight();
      final right = _sampleInsight();

      expect(left, right);
      expect(left.hashCode, right.hashCode);
    });

    test('ThaiMirrorSnapshot value equality', () {
      final left = _sampleSnapshot();
      final right = _sampleSnapshot();

      expect(left, right);
      expect(left.hashCode, right.hashCode);
    });
  });

  group('M1 forbidden field audit', () {
    test('forbidden presentation fields are not on mirror models', () {
      for (final forbidden in ['title', 'summary', 'narrative', 'prediction']) {
        expect(
          ThaiMirrorEngineContract.forbiddenMirrorFieldNames,
          contains(forbidden),
        );
        expect(
          ThaiMirrorEngineContract.snapshotFieldNames,
          isNot(contains(forbidden)),
        );
      }
    });

    test('mirror model sources do not declare forbidden fields', () {
      final modelPaths = [
        'lib/features/astrology/thai/mirror_v2/models/thai_mirror_snapshot.dart',
        'lib/features/astrology/thai/mirror_v2/models/thai_mirror_dimension.dart',
        'lib/features/astrology/thai/mirror_v2/models/thai_mirror_evidence.dart',
        'lib/features/astrology/thai/mirror_v2/models/thai_mirror_insight.dart',
      ];

      for (final path in modelPaths) {
        final source = File(path).readAsStringSync();
        for (final forbidden in ThaiMirrorEngineContract.forbiddenMirrorFieldNames) {
          expect(
            source.contains('final $forbidden'),
            isFalse,
            reason: '$path must not declare forbidden field $forbidden',
          );
        }
      }
    });

    test('serialized snapshot map keys match allowed field names only', () {
      final keys = _sampleSnapshot().toMap().keys.toList();
      for (final key in keys) {
        expect(
          ThaiMirrorEngineContract.snapshotFieldNames,
          contains(key),
        );
      }
    });

    test('evidence forbids content-layer trace fields', () {
      for (final forbidden in ['contentKey', 'contentTitle', 'lensSource']) {
        expect(
          ThaiMirrorEngineContract.evidenceFieldNames,
          isNot(contains(forbidden)),
        );
        expect(
          ThaiMirrorEngineContract.forbiddenMirrorFieldNames,
          contains(forbidden),
        );
      }
    });
  });

  group('M1 identity contract audit', () {
    test('snapshotId formula uses sourceThemeBundleId and mirrorVersion', () {
      expect(
        ThaiMirrorSnapshotIdentityContract.snapshotIdFormula,
        contains('sourceThemeBundleId'),
      );
      expect(
        ThaiMirrorSnapshotIdentityContract.snapshotIdFormula,
        contains('mirrorVersion'),
      );
      expect(ThaiMirrorSnapshotIdentityContract.mirrorVersion, 'v0.1.0');
      expect(
        ThaiMirrorEngineContract.allowedInputTypeName,
        'ThaiThemeBundle',
      );
    });
  });

  group('M1 dimension mapping contract audit', () {
    test('maps theme categories to mirror dimensions per M0', () {
      expect(
        ThaiMirrorDimensionMappingContract.dimensionForCategory(
          ThaiThemeCategory.strengths,
        ),
        ThaiMirrorDimensionId.prominentStrengths,
      );
      expect(
        ThaiMirrorDimensionMappingContract.dimensionForCategory(
          ThaiThemeCategory.thinkingStyle,
        ),
        ThaiMirrorDimensionId.thinkingPattern,
      );
      expect(
        ThaiMirrorDimensionMappingContract.dimensionForCategory(
          ThaiThemeCategory.growthPath,
        ),
        ThaiMirrorDimensionId.growthFocus,
      );
      expect(
        ThaiMirrorDimensionMappingContract.dimensionForCategory(
          ThaiThemeCategory.coreSelf,
        ),
        isNull,
      );
      expect(
        ThaiMirrorDimensionMappingContract.isInsightOnlyCategory(
          ThaiThemeCategory.workAmbition,
        ),
        isTrue,
      );
    });

    test('warning contract allows only mirror warning codes', () {
      expect(
        ThaiMirrorWarningContract.allowedWarningCodes,
        [
          'MIRROR_INSUFFICIENT_THEME_COVERAGE',
          'MIRROR_SPARSE_DIMENSION',
        ],
      );
    });
  });

  group('M1 import boundary validation', () {
    test('mirror_v2 sources do not import forbidden packages', () {
      final mirrorDir = Directory('lib/features/astrology/thai/mirror_v2');
      final forbiddenImportPatterns = [
        'signal/',
        'interpretation/',
        'content_lookup/',
        'fusion/',
      ];

      final dartFiles = mirrorDir
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
