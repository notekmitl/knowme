import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/foundation/models/profile_warning.dart';
import 'package:knowme/features/astrology/thai/fusion_v2/constants/thai_fusion_version_contract.dart';
import 'package:knowme/features/astrology/thai/fusion_v2/contracts/thai_fusion_engine_contract.dart';
import 'package:knowme/features/astrology/thai/fusion_v2/contracts/thai_fusion_identity_contract.dart';
import 'package:knowme/features/astrology/thai/fusion_v2/contracts/thai_fusion_warning_contract.dart';
import 'package:knowme/features/astrology/thai/fusion_v2/enums/thai_fusion_category_id.dart';
import 'package:knowme/features/astrology/thai/fusion_v2/enums/thai_fusion_confidence_level.dart';
import 'package:knowme/features/astrology/thai/fusion_v2/enums/thai_fusion_pattern_type.dart';
import 'package:knowme/features/astrology/thai/fusion_v2/enums/thai_fusion_source_layer.dart';
import 'package:knowme/features/astrology/thai/fusion_v2/models/thai_fusion_agreement.dart';
import 'package:knowme/features/astrology/thai/fusion_v2/models/thai_fusion_category_activation.dart';
import 'package:knowme/features/astrology/thai/fusion_v2/models/thai_fusion_confidence.dart';
import 'package:knowme/features/astrology/thai/fusion_v2/models/thai_fusion_coverage.dart';
import 'package:knowme/features/astrology/thai/fusion_v2/models/thai_fusion_evidence.dart';
import 'package:knowme/features/astrology/thai/fusion_v2/models/thai_fusion_insight.dart';
import 'package:knowme/features/astrology/thai/fusion_v2/models/thai_fusion_snapshot.dart';
import 'package:knowme/features/astrology/thai/fusion_v2/models/thai_fusion_source_refs.dart';
import 'package:knowme/features/astrology/thai/fusion_v2/models/thai_fusion_tension.dart';

ThaiFusionEvidence _sampleEvidence({
  ThaiFusionSourceLayer sourceLayer = ThaiFusionSourceLayer.theme,
  String sourceRefId = 'analytical',
  ThaiFusionCategoryId categoryId = ThaiFusionCategoryId.thinkingStyle,
  double structuralWeight = 0.82,
  ThaiFusionConfidenceLevel confidence = ThaiFusionConfidenceLevel.high,
}) {
  return ThaiFusionEvidence(
    sourceLayer: sourceLayer,
    sourceRefId: sourceRefId,
    categoryId: categoryId,
    structuralWeight: structuralWeight,
    confidence: confidence,
  );
}

ThaiFusionInsight _sampleInsight() {
  return ThaiFusionInsight(
    insightId: 'thinking_style:cross_layer_agreement:analytical',
    categoryId: ThaiFusionCategoryId.thinkingStyle,
    patternType: ThaiFusionPatternType.crossLayerAgreement,
    structuralWeight: 0.82,
    confidence: ThaiFusionConfidenceLevel.high,
    evidence: [_sampleEvidence()],
    sourceRefs: ThaiFusionSourceRefs(
      dimensionIds: ['thinking_pattern'],
      themeIds: ['analytical'],
      factIds: ['fact-analytical'],
    ),
  );
}

ThaiFusionCategoryActivation _sampleCategory() {
  return ThaiFusionCategoryActivation(
    categoryId: ThaiFusionCategoryId.thinkingStyle,
    prominence: 1.45,
    themeCount: 2,
    factCount: 3,
    dimensionRefId: 'thinking_pattern',
    confidence: ThaiFusionConfidenceLevel.high,
  );
}

ThaiFusionAgreement _sampleAgreement() {
  return ThaiFusionAgreement(
    agreementId: 'agreement-thinking-style-1',
    categoryId: ThaiFusionCategoryId.thinkingStyle,
    themeIds: const ['analytical'],
    factIds: const ['fact-analytical'],
    dimensionIds: const ['thinking_pattern'],
    strength: 0.82,
    confidence: ThaiFusionConfidenceLevel.high,
  );
}

ThaiFusionTension _sampleTension() {
  return ThaiFusionTension(
    tensionId: 'tension-thinking-style-1',
    categoryId: ThaiFusionCategoryId.thinkingStyle,
    leftRefId: 'theme:analytical',
    rightRefId: 'fact:fact-other',
    tensionStrength: 0.35,
    confidence: ThaiFusionConfidenceLevel.medium,
  );
}

ThaiFusionConfidence _sampleConfidence() {
  return const ThaiFusionConfidence(
    overallLevel: ThaiFusionConfidenceLevel.high,
    mirrorLevel: ThaiFusionConfidenceLevel.high,
    themeLevel: ThaiFusionConfidenceLevel.medium,
    interpretationLevel: ThaiFusionConfidenceLevel.high,
    distinctSourceFactCount: 4,
  );
}

ThaiFusionCoverage _sampleCoverage() {
  return const ThaiFusionCoverage(
    mappedCategoryCount: 5,
    totalCategoryCount: 8,
    mirrorDimensionCount: 4,
    interpretationFactCount: 12,
    hasSparseDimensions: true,
  );
}

ThaiFusionSnapshot _sampleSnapshot() {
  return ThaiFusionSnapshot(
    fusionSnapshotId: 'mirror-bundle-id|v0.1.0|v0.1.0',
    sourceMirrorSnapshotId: 'mirror-bundle-id|v0.1.0',
    sourceThemeBundleId: 'theme-bundle-id|v0.1.0',
    sourceInterpretationBundleId: 'interpretation-bundle-id',
    fusionVersion: ThaiFusionVersionContract.fusionVersion,
    generatedAt: DateTime.utc(2026, 6, 15, 18, 0),
    categories: [_sampleCategory()],
    insights: [_sampleInsight()],
    agreements: [_sampleAgreement()],
    tensions: [_sampleTension()],
    confidence: _sampleConfidence(),
    coverage: _sampleCoverage(),
    warnings: const [
      ProfileWarning(
        code: ThaiFusionWarningContract.sparseSynthesis,
        severity: ProfileWarningSeverity.low,
        message: 'test warning',
      ),
    ],
  );
}

void main() {
  group('F1 model construction', () {
    test('ThaiFusionEvidence holds lean trace fields only', () {
      final evidence = _sampleEvidence();

      expect(evidence.sourceLayer, ThaiFusionSourceLayer.theme);
      expect(evidence.sourceRefId, 'analytical');
      expect(evidence.categoryId, ThaiFusionCategoryId.thinkingStyle);
      expect(evidence.structuralWeight, 0.82);
      expect(evidence.confidence, ThaiFusionConfidenceLevel.high);
    });

    test('ThaiFusionInsight holds synthesis fields without text', () {
      final insight = _sampleInsight();

      expect(insight.patternType, ThaiFusionPatternType.crossLayerAgreement);
      expect(insight.evidence, hasLength(1));
      expect(insight.sourceRefs.themeIds, ['analytical']);
    });

    test('ThaiFusionSnapshot stores fusionSnapshotId without generating it', () {
      final snapshot = _sampleSnapshot();

      expect(snapshot.fusionSnapshotId, 'mirror-bundle-id|v0.1.0|v0.1.0');
      expect(snapshot.sourceMirrorSnapshotId, 'mirror-bundle-id|v0.1.0');
      expect(snapshot.fusionVersion, 'v0.1.0');
      expect(snapshot.categories, hasLength(1));
      expect(snapshot.insights, hasLength(1));
      expect(snapshot.agreements, hasLength(1));
      expect(snapshot.tensions, hasLength(1));
    });

    test('ThaiFusionCategoryId covers all eight categories', () {
      expect(ThaiFusionCategoryId.values, hasLength(8));
      expect(ThaiFusionEngineContract.supportedCategoryIds, hasLength(8));
    });

    test('ThaiFusionPatternType covers all six pattern types', () {
      expect(ThaiFusionPatternType.values, hasLength(6));
      expect(ThaiFusionEngineContract.supportedPatternTypeIds, hasLength(6));
    });

    test('ThaiFusionInsight rejects empty evidence', () {
      expect(
        () => ThaiFusionInsight(
          insightId: 'test',
          categoryId: ThaiFusionCategoryId.coreSelf,
          patternType: ThaiFusionPatternType.coverageGap,
          structuralWeight: 0.5,
          confidence: ThaiFusionConfidenceLevel.low,
          evidence: const [],
          sourceRefs: ThaiFusionSourceRefs(themeIds: ['test']),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('F1 serialization', () {
    test('ThaiFusionEvidence round-trips through map', () {
      final original = _sampleEvidence();
      final restored = ThaiFusionEvidence.fromMap(original.toMap());

      expect(restored, original);
    });

    test('ThaiFusionInsight round-trips through map', () {
      final original = _sampleInsight();
      final restored = ThaiFusionInsight.fromMap(original.toMap());

      expect(restored, original);
      expect(restored.patternType.id, 'cross_layer_agreement');
    });

    test('ThaiFusionSnapshot round-trips through map', () {
      final original = _sampleSnapshot();
      final restored = ThaiFusionSnapshot.fromMap(original.toMap());

      expect(restored, original);
      expect(restored.warnings.first.code, ThaiFusionWarningContract.sparseSynthesis);
    });

    test('category id parses from string id', () {
      expect(
        parseThaiFusionCategoryId('work_ambition'),
        ThaiFusionCategoryId.workAmbition,
      );
    });
  });

  group('F1 equality', () {
    test('ThaiFusionEvidence value equality', () {
      final left = _sampleEvidence();
      final right = _sampleEvidence();

      expect(left, right);
      expect(left.hashCode, right.hashCode);
    });

    test('ThaiFusionInsight value equality', () {
      final left = _sampleInsight();
      final right = _sampleInsight();

      expect(left, right);
      expect(left.hashCode, right.hashCode);
    });

    test('ThaiFusionSnapshot value equality', () {
      final left = _sampleSnapshot();
      final right = _sampleSnapshot();

      expect(left, right);
      expect(left.hashCode, right.hashCode);
    });
  });

  group('F1 forbidden field audit', () {
    test('forbidden presentation fields are not on fusion models', () {
      for (final forbidden in [
        'title',
        'summary',
        'description',
        'narrative',
        'prediction',
        'contentText',
        'contentKey',
        'fragmentText',
      ]) {
        expect(
          ThaiFusionEngineContract.forbiddenFusionFieldNames,
          contains(forbidden),
        );
        expect(
          ThaiFusionEngineContract.snapshotFieldNames,
          isNot(contains(forbidden)),
        );
      }
    });

    test('fusion model sources do not declare forbidden fields', () {
      final modelPaths = [
        'lib/features/astrology/thai/fusion_v2/models/thai_fusion_snapshot.dart',
        'lib/features/astrology/thai/fusion_v2/models/thai_fusion_insight.dart',
        'lib/features/astrology/thai/fusion_v2/models/thai_fusion_evidence.dart',
        'lib/features/astrology/thai/fusion_v2/models/thai_fusion_agreement.dart',
        'lib/features/astrology/thai/fusion_v2/models/thai_fusion_tension.dart',
        'lib/features/astrology/thai/fusion_v2/models/thai_fusion_category_activation.dart',
        'lib/features/astrology/thai/fusion_v2/models/thai_fusion_confidence.dart',
        'lib/features/astrology/thai/fusion_v2/models/thai_fusion_coverage.dart',
        'lib/features/astrology/thai/fusion_v2/models/thai_fusion_source_refs.dart',
      ];

      for (final path in modelPaths) {
        final source = File(path).readAsStringSync();
        for (final forbidden in ThaiFusionEngineContract.forbiddenFusionFieldNames) {
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
          ThaiFusionEngineContract.snapshotFieldNames,
          contains(key),
        );
      }
    });
  });

  group('F1 identity contract audit', () {
    test('fusionSnapshotId formula uses sourceMirrorSnapshotId and fusionVersion', () {
      expect(
        ThaiFusionIdentityContract.fusionSnapshotIdFormula,
        contains('sourceMirrorSnapshotId'),
      );
      expect(
        ThaiFusionIdentityContract.fusionSnapshotIdFormula,
        contains('fusionVersion'),
      );
      expect(ThaiFusionIdentityContract.fusionVersion, 'v0.1.0');
    });

    test('warning contract allows only fusion warning codes', () {
      expect(
        ThaiFusionWarningContract.allowedWarningCodes,
        [
          'FUSION_INPUT_LINEAGE_MISMATCH',
          'FUSION_INSUFFICIENT_COVERAGE',
          'FUSION_SPARSE_SYNTHESIS',
          'FUSION_MIRROR_THEME_DIVERGENCE',
        ],
      );
    });
  });

  group('F1 import boundary validation', () {
    test('fusion_v2 sources do not import forbidden packages', () {
      final fusionDir = Directory('lib/features/astrology/thai/fusion_v2');
      final forbiddenImportPatterns = [
        'signal/',
        'content_lookup/',
        'chart/',
        'birthdata/',
        'ui/',
      ];

      final dartFiles = fusionDir
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
