import 'package:knowme/features/astrology/fusion/domain/entities/fusion_agreement.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_insight.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_signal.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_support_level.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/reflection_result.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/theme_family.dart';
import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_snapshot.dart';
import 'package:knowme/features/astrology/fusion/domain/models/source_lens_versions.dart';
import 'package:knowme/features/personality_mirror/application/mirror/personality_mirror_engine.dart';
import 'package:knowme/features/personality_mirror/application/personality_lens_load_result.dart';
import 'package:knowme/features/personality_mirror/domain/personality_core_themes.dart';
import 'package:knowme/features/personality_mirror/domain/personality_coverage.dart';
import 'package:knowme/features/personality_mirror/domain/personality_lens_id.dart';
import 'package:knowme/features/personality_mirror/domain/personality_mirror_constants.dart';
import 'package:knowme/features/personality_mirror/domain/personality_mirror_snapshot.dart';
import 'package:knowme/features/personality_mirror/validation/personality_mirror_fixture_builder.dart';

import 'global_confidence_golden_scenario.dart';
import 'global_fusion_golden_fixtures.dart';

/// Deterministic fixtures for Global Confidence v1 golden validation.
abstract final class GlobalConfidenceGoldenFixtures {
  static GlobalFusionInputPair load(GlobalConfidenceGoldenScenario scenario) {
    return switch (scenario) {
      GlobalConfidenceGoldenScenario.noMirrors => GlobalFusionGoldenFixtures.scenarioF(),
      GlobalConfidenceGoldenScenario.oneMirror => GlobalFusionGoldenFixtures.scenarioA(),
      GlobalConfidenceGoldenScenario.twoMirrorsNoAgreement => _twoMirrorsNoAgreement(),
      GlobalConfidenceGoldenScenario.oneStrongAgreement => GlobalFusionGoldenFixtures.scenarioC(),
      GlobalConfidenceGoldenScenario.manyAgreements => _manyAgreements(),
      GlobalConfidenceGoldenScenario.agreementsWithTensions =>
        _agreementsWithTensions(),
      GlobalConfidenceGoldenScenario.heavyTensions => _heavyTensions(),
    };
  }

  static GlobalFusionInputPair _twoMirrorsNoAgreement() {
    return GlobalFusionInputPair(
      astrology: _astrologyReflectionOnly(),
      personality: _personalityAdaptabilityOnly(),
    );
  }

  static GlobalFusionInputPair _manyAgreements() {
    return GlobalFusionInputPair(
      astrology: _astrologyStructureAndReflection(),
      personality: _personalityStructureAndReflection(),
    );
  }

  static GlobalFusionInputPair _agreementsWithTensions() {
    return GlobalFusionInputPair(
      astrology: _astrologyMultiTensionWithStructureAgreement(),
      personality: _personalityStructureAndSupportive(),
    );
  }

  static AstrologyFusionSnapshot _astrologyMultiTensionWithStructureAgreement() {
    return _baseAstrology(
      signals: const [
        FusionSignal(
          type: FusionSignalType.structure,
          sourceThemes: ['structured'],
          supportingLenses: ['western'],
          supportLevel: FusionSupportLevel.medium,
        ),
        FusionSignal(
          type: FusionSignalType.adaptation,
          sourceThemes: ['flexible'],
          supportingLenses: ['western'],
          supportLevel: FusionSupportLevel.medium,
        ),
        FusionSignal(
          type: FusionSignalType.reflection,
          sourceThemes: ['intuitive'],
          supportingLenses: ['western'],
          supportLevel: FusionSupportLevel.medium,
        ),
        FusionSignal(
          type: FusionSignalType.growth,
          sourceThemes: ['growth_focused'],
          supportingLenses: ['western'],
          supportLevel: FusionSupportLevel.medium,
        ),
      ],
      agreements: const [],
    );
  }

  static PersonalityMirrorSnapshot _personalityStructureAndSupportive() {
    return PersonalityMirrorEngine.build(
      PersonalityLensLoadResult(
        snapshots: {
          PersonalityLensId.mbti: PersonalityMirrorFixtureBuilder.lens(
            lensId: PersonalityLensId.mbti,
            themeIds: const [
              PersonalityCoreThemeIds.structured,
              PersonalityCoreThemeIds.supportive,
            ],
            lensConfidence: 0.65,
          ),
          for (final id in PersonalityLensId.all)
            if (id != PersonalityLensId.mbti)
              id: PersonalityMirrorFixtureBuilder.unavailable(id),
        },
        coverage: PersonalityCoverage(
          availableLensIds: const [PersonalityLensId.mbti],
          missingLensIds: PersonalityLensId.all
              .where((id) => id != PersonalityLensId.mbti)
              .toList(),
          eqModulesCompleted: 0,
          eqModulesExpected: PersonalityLensId.eqLenses.length,
          weightedCoverage: PersonalityMirrorWeights.mbti,
        ),
      ),
    );
  }

  static PersonalityMirrorSnapshot _personalityStructureOnlyMinimal() {
    return PersonalityMirrorEngine.build(
      PersonalityLensLoadResult(
        snapshots: {
          PersonalityLensId.mbti: PersonalityMirrorFixtureBuilder.lens(
            lensId: PersonalityLensId.mbti,
            themeIds: const [PersonalityCoreThemeIds.structured],
            lensConfidence: 0.65,
          ),
          for (final id in PersonalityLensId.all)
            if (id != PersonalityLensId.mbti)
              id: PersonalityMirrorFixtureBuilder.unavailable(id),
        },
        coverage: PersonalityCoverage(
          availableLensIds: const [PersonalityLensId.mbti],
          missingLensIds: PersonalityLensId.all
              .where((id) => id != PersonalityLensId.mbti)
              .toList(),
          eqModulesCompleted: 0,
          eqModulesExpected: PersonalityLensId.eqLenses.length,
          weightedCoverage: PersonalityMirrorWeights.mbti,
        ),
      ),
    );
  }

  static GlobalFusionInputPair _heavyTensions() {
    return GlobalFusionInputPair(
      astrology: _astrologyReflectionAndAdaptability(),
      personality: _personalityStructureAndRelationships(),
    );
  }

  static PersonalityMirrorSnapshot _personalityAdaptabilityOnly() {
    return PersonalityMirrorEngine.build(
      PersonalityLensLoadResult(
        snapshots: {
          PersonalityLensId.mbti: PersonalityMirrorFixtureBuilder.lens(
            lensId: PersonalityLensId.mbti,
            themeIds: const [
              PersonalityCoreThemeIds.flexible,
              PersonalityCoreThemeIds.adaptable,
            ],
            lensConfidence: 0.65,
          ),
          for (final id in PersonalityLensId.all)
            if (id != PersonalityLensId.mbti)
              id: PersonalityMirrorFixtureBuilder.unavailable(id),
        },
        coverage: PersonalityCoverage(
          availableLensIds: const [PersonalityLensId.mbti],
          missingLensIds: PersonalityLensId.all
              .where((id) => id != PersonalityLensId.mbti)
              .toList(),
          eqModulesCompleted: 0,
          eqModulesExpected: PersonalityLensId.eqLenses.length,
          weightedCoverage: PersonalityMirrorWeights.mbti,
        ),
      ),
    );
  }

  static PersonalityMirrorSnapshot _personalityStructureAndReflection() {
    return PersonalityMirrorEngine.build(
      PersonalityLensLoadResult(
        snapshots: {
          PersonalityLensId.mbti: PersonalityMirrorFixtureBuilder.lens(
            lensId: PersonalityLensId.mbti,
            themeIds: const [
              PersonalityCoreThemeIds.structured,
              PersonalityCoreThemeIds.responsible,
              PersonalityCoreThemeIds.reserved,
              PersonalityCoreThemeIds.analytical,
            ],
            lensConfidence: 0.65,
          ),
          PersonalityLensId.bigFive: PersonalityMirrorFixtureBuilder.lens(
            lensId: PersonalityLensId.bigFive,
            themeIds: const [
              PersonalityCoreThemeIds.structured,
              PersonalityCoreThemeIds.responsible,
              PersonalityCoreThemeIds.intuitive,
              PersonalityCoreThemeIds.calm,
            ],
            lensConfidence: 0.65,
          ),
          for (final id in PersonalityLensId.all)
            if (id != PersonalityLensId.mbti && id != PersonalityLensId.bigFive)
              id: PersonalityMirrorFixtureBuilder.unavailable(id),
        },
        coverage: PersonalityCoverage(
          availableLensIds: const [
            PersonalityLensId.mbti,
            PersonalityLensId.bigFive,
          ],
          missingLensIds: PersonalityLensId.all
              .where(
                (id) =>
                    id != PersonalityLensId.mbti &&
                    id != PersonalityLensId.bigFive,
              )
              .toList(),
          eqModulesCompleted: 0,
          eqModulesExpected: PersonalityLensId.eqLenses.length,
          weightedCoverage:
              PersonalityMirrorWeights.mbti + PersonalityMirrorWeights.bigFive,
        ),
      ),
    );
  }

  static PersonalityMirrorSnapshot _personalityStructureAndRelationships() {
    return PersonalityMirrorEngine.build(
      PersonalityLensLoadResult(
        snapshots: {
          PersonalityLensId.mbti: PersonalityMirrorFixtureBuilder.lens(
            lensId: PersonalityLensId.mbti,
            themeIds: const [
              PersonalityCoreThemeIds.structured,
              PersonalityCoreThemeIds.supportive,
            ],
            lensConfidence: 0.65,
          ),
          for (final id in PersonalityLensId.all)
            if (id != PersonalityLensId.mbti)
              id: PersonalityMirrorFixtureBuilder.unavailable(id),
        },
        coverage: PersonalityCoverage(
          availableLensIds: const [PersonalityLensId.mbti],
          missingLensIds: PersonalityLensId.all
              .where((id) => id != PersonalityLensId.mbti)
              .toList(),
          eqModulesCompleted: 0,
          eqModulesExpected: PersonalityLensId.eqLenses.length,
          weightedCoverage: PersonalityMirrorWeights.mbti,
        ),
      ),
    );
  }

  static AstrologyFusionSnapshot _astrologyReflectionOnly() {
    return _baseAstrology(
      signals: const [
        FusionSignal(
          type: FusionSignalType.reflection,
          sourceThemes: ['intuitive'],
          supportingLenses: ['western'],
          supportLevel: FusionSupportLevel.medium,
        ),
      ],
      agreements: const [],
    );
  }

  static AstrologyFusionSnapshot _astrologyStructureAndReflection() {
    return _baseAstrology(
      signals: const [
        FusionSignal(
          type: FusionSignalType.structure,
          sourceThemes: ['structured'],
          supportingLenses: ['western', 'bazi'],
          supportLevel: FusionSupportLevel.high,
        ),
        FusionSignal(
          type: FusionSignalType.structure,
          sourceThemes: ['responsible'],
          supportingLenses: ['bazi'],
          supportLevel: FusionSupportLevel.medium,
        ),
        FusionSignal(
          type: FusionSignalType.reflection,
          sourceThemes: ['intuitive'],
          supportingLenses: ['western'],
          supportLevel: FusionSupportLevel.medium,
        ),
        FusionSignal(
          type: FusionSignalType.reflection,
          sourceThemes: ['analytical'],
          supportingLenses: ['western'],
          supportLevel: FusionSupportLevel.medium,
        ),
      ],
      agreements: const [
        FusionAgreement(
          sourceThemeIds: ['structured', 'responsible'],
          supportingLenses: ['western', 'bazi'],
          supportLevel: FusionSupportLevel.high,
          family: ThemeFamily.structure,
          familyLevel: true,
        ),
      ],
    );
  }

  static AstrologyFusionSnapshot _astrologyReflectionAndAdaptability() {
    return _baseAstrology(
      signals: const [
        FusionSignal(
          type: FusionSignalType.reflection,
          sourceThemes: ['intuitive'],
          supportingLenses: ['western'],
          supportLevel: FusionSupportLevel.medium,
        ),
        FusionSignal(
          type: FusionSignalType.adaptation,
          sourceThemes: ['flexible'],
          supportingLenses: ['western'],
          supportLevel: FusionSupportLevel.medium,
        ),
      ],
      agreements: const [],
    );
  }

  static AstrologyFusionSnapshot _baseAstrology({
    required List<FusionSignal> signals,
    required List<FusionAgreement> agreements,
  }) {
    return AstrologyFusionSnapshot.fromPipeline(
      generatedAt: DateTime.utc(2026, 1, 15),
      signals: signals,
      agreements: agreements,
      tensions: const [],
      reflection: ReflectionResult(
        summary: 'Confidence golden fixture.',
        keyInsights: const ['fixture'],
      ),
      fusionInsight: FusionInsightResult(
        primary: FusionInsight(
          title: 'Fixture insight',
          description: 'Confidence golden validation fixture.',
        ),
      ),
      growthOpportunities: const [],
      futureTendencies: const [],
      sourceLensVersions: const SourceLensVersions(
        westernVersion: 'western_v1_fixture',
        baziVersion: 'bazi_v1_fixture',
      ),
    );
  }
}
