import '../domain/home_experience_blueprint.dart';
import 'home_experience_golden_fixtures.dart';
import 'home_experience_golden_scenario.dart';

/// Runs Home Experience golden scenarios (HX-F0).
abstract final class HomeExperienceValidationHarness {
  static HomeExperienceBlueprint run(HomeExperienceGoldenScenario scenario) {
    return HomeExperienceGoldenFixtures.build(scenario);
  }

  static bool runAllPassing() {
    for (final scenario in HomeExperienceGoldenScenario.values) {
      final blueprint = run(scenario);
      final issues = HomeExperienceGoldenExpectations.verify(scenario, blueprint);
      if (issues.isNotEmpty) return false;
    }
    return true;
  }
}
