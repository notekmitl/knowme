import '../domain/home_screen_contract.dart';
import 'home_surface_golden_fixtures.dart';
import 'home_surface_golden_scenario.dart';

/// Runs Home MVP Surface golden scenarios (HX-F1).
abstract final class HomeSurfaceValidationHarness {
  static HomeScreenContract run(HomeSurfaceGoldenScenario scenario) {
    return HomeSurfaceGoldenFixtures.build(scenario);
  }

  static bool runAllPassing() {
    for (final scenario in HomeSurfaceGoldenScenario.values) {
      final contract = run(scenario);
      final issues = HomeSurfaceGoldenExpectations.verify(scenario, contract);
      if (issues.isNotEmpty) return false;
    }
    return true;
  }
}
