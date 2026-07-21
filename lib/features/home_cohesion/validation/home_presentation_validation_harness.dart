import '../domain/home_presentation_model.dart';
import 'home_presentation_golden_fixtures.dart';
import 'home_presentation_golden_scenario.dart';

/// Runs Home Presentation IA golden scenarios (HC-F1).
abstract final class HomePresentationValidationHarness {
  static HomePresentationModel run(HomePresentationGoldenScenario scenario) {
    return HomePresentationGoldenFixtures.build(scenario);
  }

  static bool runAllPassing() {
    for (final scenario in HomePresentationGoldenScenario.values) {
      final model = run(scenario);
      final issues = HomePresentationGoldenExpectations.verify(scenario, model);
      if (issues.isNotEmpty) return false;
    }
    return true;
  }
}
