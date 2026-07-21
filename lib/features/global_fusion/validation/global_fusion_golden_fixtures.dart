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
import 'package:knowme/features/personality_mirror/domain/personality_coverage.dart';
import 'package:knowme/features/personality_mirror/domain/personality_lens_id.dart';
import 'package:knowme/features/personality_mirror/domain/personality_mirror_constants.dart';
import 'package:knowme/features/personality_mirror/domain/personality_mirror_snapshot.dart';
import 'package:knowme/features/personality_mirror/validation/personality_mirror_fixture_builder.dart';

import 'global_fusion_golden_scenario.dart';

/// Deterministic mirror snapshots for Global Fusion golden validation.
abstract final class GlobalFusionGoldenFixtures {
  static GlobalFusionInputPair load(GlobalFusionGoldenScenario scenario) {
    return switch (scenario) {
      GlobalFusionGoldenScenario.scenarioA => scenarioA(),
      GlobalFusionGoldenScenario.scenarioB => scenarioB(),
      GlobalFusionGoldenScenario.scenarioC => scenarioC(),
      GlobalFusionGoldenScenario.scenarioD => scenarioD(),
      GlobalFusionGoldenScenario.scenarioE => scenarioE(),
      GlobalFusionGoldenScenario.scenarioF => scenarioF(),
    };
  }

  static GlobalFusionInputPair scenarioA() {
    return GlobalFusionInputPair(
      astrology: _astrologyStructureRich(),
      personality: null,
    );
  }

  static GlobalFusionInputPair scenarioB() {
    return GlobalFusionInputPair(
      astrology: null,
      personality: _personalityStructureOnly(),
    );
  }

  static GlobalFusionInputPair scenarioC() {
    return GlobalFusionInputPair(
      astrology: _astrologyStructureRich(),
      personality: _personalityStructureOnly(),
    );
  }

  static GlobalFusionInputPair scenarioD() {
    return GlobalFusionInputPair(
      astrology: _astrologyAdaptabilityOnly(),
      personality: _personalityStructureOnly(),
    );
  }

  static GlobalFusionInputPair scenarioE() {
    return GlobalFusionInputPair(
      astrology: _astrologyStructureAndAdaptability(),
      personality: _personalityStructureOnly(),
    );
  }

  static GlobalFusionInputPair scenarioF() {
    return const GlobalFusionInputPair(
      astrology: null,
      personality: null,
    );
  }

  static PersonalityMirrorSnapshot _personalityStructureOnly() {
    return PersonalityMirrorEngine.build(
      PersonalityLensLoadResult(
        snapshots: {
          PersonalityLensId.mbti: PersonalityMirrorFixtureBuilder.lens(
            lensId: PersonalityLensId.mbti,
            themeIds: PersonalityMirrorFixtureBuilder.alignedStructureThemes,
            lensConfidence: 0.65,
          ),
          PersonalityLensId.bigFive: PersonalityMirrorFixtureBuilder.lens(
            lensId: PersonalityLensId.bigFive,
            themeIds: PersonalityMirrorFixtureBuilder.alignedStructureThemes,
            lensConfidence: 0.65,
          ),
          for (final id in PersonalityLensId.all)
            if (id != PersonalityLensId.mbti &&
                id != PersonalityLensId.bigFive)
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

  static AstrologyFusionSnapshot _astrologyStructureRich() {
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

  static AstrologyFusionSnapshot _astrologyAdaptabilityOnly() {
    return _baseAstrology(
      signals: const [
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

  static AstrologyFusionSnapshot _astrologyStructureAndAdaptability() {
    return _baseAstrology(
      signals: const [
        FusionSignal(
          type: FusionSignalType.structure,
          sourceThemes: ['structured'],
          supportingLenses: ['western', 'bazi'],
          supportLevel: FusionSupportLevel.high,
        ),
        FusionSignal(
          type: FusionSignalType.adaptation,
          sourceThemes: ['flexible'],
          supportingLenses: ['western'],
          supportLevel: FusionSupportLevel.medium,
        ),
      ],
      agreements: const [
        FusionAgreement(
          sourceThemeIds: ['structured'],
          supportingLenses: ['western', 'bazi'],
          supportLevel: FusionSupportLevel.high,
          family: ThemeFamily.structure,
          familyLevel: true,
        ),
      ],
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
        summary: 'Golden fixture reflection.',
        keyInsights: const ['fixture'],
      ),
      fusionInsight: FusionInsightResult(
        primary: FusionInsight(
          title: 'Fixture insight',
          description: 'Golden validation fixture.',
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

class GlobalFusionInputPair {
  const GlobalFusionInputPair({
    required this.astrology,
    required this.personality,
  });

  final AstrologyFusionSnapshot? astrology;
  final PersonalityMirrorSnapshot? personality;
}
