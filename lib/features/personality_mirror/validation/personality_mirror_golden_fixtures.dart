import '../application/personality_lens_load_result.dart';
import '../domain/personality_core_themes.dart';
import '../domain/personality_coverage.dart';
import '../domain/personality_lens_id.dart';
import '../domain/personality_lens_snapshot.dart';
import '../domain/personality_mirror_constants.dart';
import 'personality_mirror_fixture_builder.dart';
import 'personality_mirror_golden_scenario.dart';

/// Deterministic [PersonalityLensLoadResult] fixtures for golden validation.
abstract final class PersonalityMirrorGoldenFixtures {
  static PersonalityLensLoadResult load(PersonalityMirrorGoldenScenario scenario) {
    return switch (scenario) {
      PersonalityMirrorGoldenScenario.scenarioA => scenarioA(),
      PersonalityMirrorGoldenScenario.scenarioB => scenarioB(),
      PersonalityMirrorGoldenScenario.scenarioC => scenarioC(),
      PersonalityMirrorGoldenScenario.scenarioD => scenarioD(),
    };
  }

  /// MBTI + Big Five aligned on structure/responsibility.
  static PersonalityLensLoadResult scenarioA() {
    final snapshots = _allSlots(
      mbti: PersonalityMirrorFixtureBuilder.lens(
        lensId: PersonalityLensId.mbti,
        themeIds: PersonalityMirrorFixtureBuilder.alignedStructureThemes,
        lensConfidence: 0.65,
      ),
      bigFive: PersonalityMirrorFixtureBuilder.lens(
        lensId: PersonalityLensId.bigFive,
        themeIds: PersonalityMirrorFixtureBuilder.alignedStructureThemes,
        lensConfidence: 0.65,
      ),
    );

    return PersonalityLensLoadResult(
      snapshots: snapshots,
      coverage: _coverage(
        available: const [
          PersonalityLensId.mbti,
          PersonalityLensId.bigFive,
        ],
        weighted:
            PersonalityMirrorWeights.mbti + PersonalityMirrorWeights.bigFive,
      ),
    );
  }

  /// MBTI reserved vs Big Five expressive → core-self tension.
  static PersonalityLensLoadResult scenarioB() {
    final snapshots = _allSlots(
      mbti: PersonalityMirrorFixtureBuilder.lens(
        lensId: PersonalityLensId.mbti,
        themeIds: PersonalityMirrorFixtureBuilder.tensionCoreSelfThemes,
        lensConfidence: 0.65,
      ),
      bigFive: PersonalityMirrorFixtureBuilder.lens(
        lensId: PersonalityLensId.bigFive,
        themeIds: PersonalityMirrorFixtureBuilder.expressiveCoreSelfThemes,
        lensConfidence: 0.65,
      ),
    );

    return PersonalityLensLoadResult(
      snapshots: snapshots,
      coverage: _coverage(
        available: const [
          PersonalityLensId.mbti,
          PersonalityLensId.bigFive,
        ],
        weighted:
            PersonalityMirrorWeights.mbti + PersonalityMirrorWeights.bigFive,
      ),
    );
  }

  /// MBTI only → partial coverage.
  static PersonalityLensLoadResult scenarioC() {
    final snapshots = _allSlots(
      mbti: PersonalityMirrorFixtureBuilder.lens(
        lensId: PersonalityLensId.mbti,
        themeIds: PersonalityMirrorFixtureBuilder.alignedStructureThemes,
        lensConfidence: 0.45,
        themeConfidence: 0.55,
      ),
    );

    return PersonalityLensLoadResult(
      snapshots: snapshots,
      coverage: _coverage(
        available: const [PersonalityLensId.mbti],
        weighted: PersonalityMirrorWeights.mbti,
      ),
    );
  }

  /// MBTI + Big Five + EQ (supportive/diplomatic alignment).
  static PersonalityLensLoadResult scenarioD() {
    final snapshots = _allSlots(
      mbti: PersonalityMirrorFixtureBuilder.lens(
        lensId: PersonalityLensId.mbti,
        themeIds: PersonalityMirrorFixtureBuilder.alignedSupportThemes,
        lensConfidence: 0.85,
        themeConfidence: 0.8,
      ),
      bigFive: PersonalityMirrorFixtureBuilder.lens(
        lensId: PersonalityLensId.bigFive,
        themeIds: PersonalityMirrorFixtureBuilder.alignedSupportThemes,
        lensConfidence: 0.85,
        themeConfidence: 0.8,
      ),
      eqAwareness: PersonalityMirrorFixtureBuilder.lens(
        lensId: PersonalityLensId.eqAwareness,
        themeIds: const [PersonalityCoreThemeIds.supportive],
        lensConfidence: 0.55,
        themeConfidence: 0.7,
      ),
    );

    return PersonalityLensLoadResult(
      snapshots: snapshots,
      coverage: _coverage(
        available: const [
          PersonalityLensId.mbti,
          PersonalityLensId.bigFive,
          PersonalityLensId.eqAwareness,
        ],
        weighted: 1.0,
      ),
    );
  }

  static Map<PersonalityLensId, PersonalityLensSnapshot> _allSlots({
    PersonalityLensSnapshot? mbti,
    PersonalityLensSnapshot? bigFive,
    PersonalityLensSnapshot? eqAwareness,
    PersonalityLensSnapshot? eqRegulation,
    PersonalityLensSnapshot? eqEmpathy,
    PersonalityLensSnapshot? eqSocial,
    PersonalityLensSnapshot? eqDecision,
    PersonalityLensSnapshot? eqStress,
  }) {
    return {
      PersonalityLensId.mbti:
          mbti ?? PersonalityMirrorFixtureBuilder.unavailable(
            PersonalityLensId.mbti,
          ),
      PersonalityLensId.bigFive:
          bigFive ?? PersonalityMirrorFixtureBuilder.unavailable(
            PersonalityLensId.bigFive,
          ),
      PersonalityLensId.eqAwareness:
          eqAwareness ?? PersonalityMirrorFixtureBuilder.unavailable(
            PersonalityLensId.eqAwareness,
          ),
      PersonalityLensId.eqRegulation:
          eqRegulation ?? PersonalityMirrorFixtureBuilder.unavailable(
            PersonalityLensId.eqRegulation,
          ),
      PersonalityLensId.eqEmpathy:
          eqEmpathy ?? PersonalityMirrorFixtureBuilder.unavailable(
            PersonalityLensId.eqEmpathy,
          ),
      PersonalityLensId.eqSocial:
          eqSocial ?? PersonalityMirrorFixtureBuilder.unavailable(
            PersonalityLensId.eqSocial,
          ),
      PersonalityLensId.eqDecision:
          eqDecision ?? PersonalityMirrorFixtureBuilder.unavailable(
            PersonalityLensId.eqDecision,
          ),
      PersonalityLensId.eqStress:
          eqStress ?? PersonalityMirrorFixtureBuilder.unavailable(
            PersonalityLensId.eqStress,
          ),
    };
  }

  static PersonalityCoverage _coverage({
    required List<PersonalityLensId> available,
    required double weighted,
  }) {
    final missing =
        PersonalityLensId.all.where((id) => !available.contains(id)).toList();
    final eqCompleted = PersonalityLensId.eqLenses
        .where((id) => available.contains(id))
        .length;

    return PersonalityCoverage(
      availableLensIds: available,
      missingLensIds: missing,
      eqModulesCompleted: eqCompleted,
      eqModulesExpected: PersonalityLensId.eqLenses.length,
      weightedCoverage: weighted,
    );
  }
}
