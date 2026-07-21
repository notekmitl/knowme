import '../domain/home_snapshot.dart';
import 'home_cohesion_golden_fixtures.dart';
import 'home_cohesion_golden_scenario.dart';

/// Runs Home Cohesion golden scenarios (HC-F0).
abstract final class HomeCohesionValidationHarness {
  static HomeSnapshot run(HomeCohesionGoldenScenario scenario) {
    return HomeCohesionGoldenFixtures.build(scenario);
  }

  static bool runAllPassing() {
    for (final scenario in HomeCohesionGoldenScenario.values) {
      final snapshot = run(scenario);
      final issues = HomeCohesionGoldenExpectations.verify(scenario, snapshot);
      if (issues.isNotEmpty) return false;
    }
    return true;
  }
}
