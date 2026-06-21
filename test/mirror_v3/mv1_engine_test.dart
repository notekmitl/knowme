import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_category.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_confidence_level.dart';
import 'package:knowme/features/astrology/thai/theme_v2/enums/thai_theme_category.dart';
import 'package:knowme/features/astrology/thai/theme_v2/models/thai_theme_bundle.dart';
import 'package:knowme/features/astrology/thai/theme_v2/models/thai_theme_contribution.dart';
import 'package:knowme/features/astrology/thai/theme_v2/models/thai_theme_score.dart';
import 'package:knowme/features/mirror_v3/contracts/knowme_mirror_engine_contract.dart';
import 'package:knowme/features/mirror_v3/contracts/knowme_mirror_identity_contract.dart';
import 'package:knowme/features/mirror_v3/contracts/knowme_mirror_registry_contract.dart';
import 'package:knowme/features/mirror_v3/engine/adapters/knowme_mirror_astrology_adapter.dart';
import 'package:knowme/features/mirror_v3/engine/adapters/knowme_mirror_personality_adapter.dart';
import 'package:knowme/features/mirror_v3/engine/knowme_mirror_engine.dart';
import 'package:knowme/features/mirror_v3/engine/models/knowme_mirror_engine_input.dart';
import 'package:knowme/features/mirror_v3/enums/knowme_mirror_dimension_id.dart';
import 'package:knowme/features/mirror_v3/enums/knowme_mirror_pattern_type.dart';
import 'package:knowme/features/mirror_v3/enums/knowme_mirror_source_type.dart';
import 'package:knowme/features/mirror_v3/enums/knowme_mirror_system_id.dart';
import 'package:knowme/features/mirror_v3/models/knowme_mirror_lineage_chain.dart';
import 'package:knowme/features/mirror_v3/registry/knowme_mirror_registry_v0_1.dart';
import 'package:knowme/features/personality_mirror/domain/personality_core_themes.dart';

ThaiThemeBundle _sampleAstrologyBundle() {
  return ThaiThemeBundle(
    bundleId: 'theme-bundle-1',
    sourceInterpretationBundleId: 'interp-bundle-1',
    generatedAt: DateTime.utc(2026, 6, 21, 12),
    themes: [
      ThaiThemeScore(
        themeId: 'analytical',
        category: ThaiThemeCategory.thinkingStyle,
        score: 0.82,
        confidence: ThaiThemeConfidenceLevel.high,
        rank: 1,
        contributions: [
          const ThaiThemeContribution(
            sourceFactId: 'fact-1',
            contentKey: 'thai.lagna.aries',
            contribution: 0.5,
          ),
          const ThaiThemeContribution(
            sourceFactId: 'fact-2',
            contentKey: 'thai.lagna.mercury',
            contribution: 0.32,
          ),
        ],
      ),
      ThaiThemeScore(
        themeId: 'supportive',
        category: ThaiThemeCategory.relationships,
        score: 0.71,
        confidence: ThaiThemeConfidenceLevel.medium,
        rank: 1,
        contributions: [
          const ThaiThemeContribution(
            sourceFactId: 'fact-3',
            contentKey: 'thai.venus.support',
            contribution: 0.71,
          ),
        ],
      ),
    ],
  );
}

KnowMeMirrorLineageChain _sampleLineage() {
  final scopeId = KnowMeMirrorIdentityContract.mirrorScopeId(
    astrologyThemeSnapshotId: 'theme-bundle-1',
    mbtiLensSnapshotId: 'mbti-snap-1',
    bigFiveLensSnapshotId: 'bf-snap-1',
  );

  return KnowMeMirrorLineageChain(
    mirrorScopeId: scopeId,
    astrologyThemeSnapshotId: 'theme-bundle-1',
    astrologyThemeBundleId: 'theme-bundle-1',
    mbtiLensSnapshotId: 'mbti-snap-1',
    bigFiveLensSnapshotId: 'bf-snap-1',
    personalityOnly: false,
    sourceSnapshotVersions: const {
      'thai_astrology': 'theme_v2',
      'mbti': 'personality_mirror.v1',
      'big_five': 'personality_mirror.v1',
    },
  );
}

void main() {
  group('MV0 domain audit', () {
    test('registry contains 15 frozen mirror keys', () {
      expect(KnowMeMirrorRegistryContract.frozenKeyCount, 15);
      expect(KnowMeMirrorRegistryV01.entries, hasLength(15));
      for (final entry in KnowMeMirrorRegistryV01.entries) {
        expect(entry.mirrorKey.startsWith('MIRROR_'), isTrue);
        expect(KnowMeMirrorRegistryContract.isValidMirrorKey(entry.mirrorKey),
            isTrue);
      }
    });

    test('mirrorScopeId is deterministic', () {
      final a = KnowMeMirrorIdentityContract.mirrorScopeId(
        astrologyThemeSnapshotId: 'theme-a',
        mbtiLensSnapshotId: 'mbti-a',
      );
      final b = KnowMeMirrorIdentityContract.mirrorScopeId(
        astrologyThemeSnapshotId: 'theme-a',
        mbtiLensSnapshotId: 'mbti-a',
      );
      expect(a, b);
      expect(a.contains('mirror_scope'), isTrue);
    });

    test('mirrorId is order-independent for theme ids', () {
      final scope = KnowMeMirrorIdentityContract.mirrorScopeId(
        mbtiLensSnapshotId: 'mbti-a',
      );
      final forward = KnowMeMirrorIdentityContract.mirrorId(
        mirrorScopeId: scope,
        mirrorKey: 'MIRROR_THINKING_PATTERN',
        themeIds: ['analytical', 'structured'],
      );
      final reverse = KnowMeMirrorIdentityContract.mirrorId(
        mirrorScopeId: scope,
        mirrorKey: 'MIRROR_THINKING_PATTERN',
        themeIds: ['structured', 'analytical'],
      );
      expect(forward, reverse);
    });
  });

  group('MV1 Mirror Engine', () {
    test('reflect builds bundle with preserved evidence', () {
      final astrologySignals =
          KnowMeMirrorAstrologyAdapter.extract(_sampleAstrologyBundle());
      final personalitySignals = KnowMeMirrorPersonalityAdapter.extractThemes(
        systemId: KnowMeMirrorSystemId.mbti,
        sourceType: KnowMeMirrorSourceType.mbtiTheme,
        sourceLensKey: 'mbti',
        sourceSnapshotId: 'mbti-snap-1',
        themes: [
          PersonalityThemeInput(
            themeId: PersonalityCoreThemeIds.analytical,
            category: FusionCategory.thinkingStyle,
            confidence: 0.78,
            prominence: 0.74,
            evidenceCount: 3,
          ),
        ],
      );

      final result = KnowMeMirrorEngine.reflect(
        KnowMeMirrorEngineInput(
          lineage: _sampleLineage(),
          signals: [...astrologySignals, ...personalitySignals],
          generatedAt: DateTime.utc(2026, 6, 21, 12),
        ),
      );

      expect(result.bundle.mirrors, isNotEmpty);
      expect(result.bundle.structuralHash, isNotEmpty);
      expect(result.compositeConfidence, greaterThan(0));

      final thinkingMirror = result.bundle.mirrors.firstWhere(
        (mirror) => mirror.mirrorKey == 'MIRROR_THINKING_PATTERN',
      );
      expect(thinkingMirror.sourceThemeIds, contains('analytical'));
      expect(thinkingMirror.evidenceRefs.evidenceRefs.length, greaterThan(1));
      expect(thinkingMirror.evidenceRefs.signalIds, isNotEmpty);
    });

    test('detects cross-system agreement on shared thinking pattern', () {
      final astrologySignals =
          KnowMeMirrorAstrologyAdapter.extract(_sampleAstrologyBundle());
      final personalitySignals = KnowMeMirrorPersonalityAdapter.extractThemes(
        systemId: KnowMeMirrorSystemId.mbti,
        sourceType: KnowMeMirrorSourceType.mbtiTheme,
        sourceLensKey: 'mbti',
        sourceSnapshotId: 'mbti-snap-1',
        themes: [
          PersonalityThemeInput(
            themeId: PersonalityCoreThemeIds.analytical,
            category: FusionCategory.thinkingStyle,
            confidence: 0.78,
            prominence: 0.74,
            evidenceCount: 2,
          ),
        ],
      );

      final result = KnowMeMirrorEngine.reflect(
        KnowMeMirrorEngineInput(
          lineage: _sampleLineage(),
          signals: [...astrologySignals, ...personalitySignals],
          generatedAt: DateTime.utc(2026, 6, 21, 12),
        ),
      );

      expect(result.agreements, isNotEmpty);
      expect(
        result.agreements.any(
          (agreement) =>
              agreement.mirrorKey == 'MIRROR_THINKING_PATTERN' &&
              agreement.supportingSystems.length >= 2,
        ),
        isTrue,
      );
    });

    test('detects theme fact reinforcement when evidence count >= 2', () {
      final astrologySignals =
          KnowMeMirrorAstrologyAdapter.extract(_sampleAstrologyBundle());

      final result = KnowMeMirrorEngine.reflect(
        KnowMeMirrorEngineInput(
          lineage: _sampleLineage(),
          signals: astrologySignals,
          generatedAt: DateTime.utc(2026, 6, 21, 12),
        ),
      );

      expect(
        result.reinforcements.any(
          (reinforcement) =>
              reinforcement.patternType ==
                  KnowMeMirrorPatternType.themeFactReinforcement &&
              reinforcement.evidenceCount >= 2,
        ),
        isTrue,
      );
    });

    test('detects dimension coverage blind spots', () {
      final result = KnowMeMirrorEngine.reflect(
        KnowMeMirrorEngineInput(
          lineage: _sampleLineage(),
          signals: KnowMeMirrorAstrologyAdapter.extract(_sampleAstrologyBundle()),
          generatedAt: DateTime.utc(2026, 6, 21, 12),
        ),
      );

      expect(
        result.blindSpots.any(
          (spot) =>
              spot.patternType ==
              KnowMeMirrorPatternType.dimensionCoverageGap,
        ),
        isTrue,
      );
    });

    test('engine contract forbids narrative fields', () {
      expect(
        KnowMeMirrorEngineContract.forbiddenMirrorFieldNames,
        contains('narrative'),
      );
      expect(KnowMeMirrorEngineContract.allowedInputTypeName,
          'KnowMeMirrorEngineInput');
    });

    test('dimensions map from registry entries', () {
      final entry = KnowMeMirrorRegistryV01.get('MIRROR_LIFE_DIRECTION');
      expect(entry?.mirrorDimension, KnowMeMirrorDimensionId.lifeDirection);
    });
  });
}
