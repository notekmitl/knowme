import '../domain/exploration_overview.dart';
import 'exploration_overview_golden_fixtures.dart';
import 'exploration_overview_golden_scenario.dart';

/// Runs Exploration Overview golden scenarios (EO-F0).
abstract final class ExplorationOverviewValidationHarness {
  static ExplorationOverview run(ExplorationOverviewGoldenScenario scenario) {
    return ExplorationOverviewGoldenFixtures.build(scenario);
  }

  static bool runAllPassing() {
    for (final scenario in ExplorationOverviewGoldenScenario.values) {
      final overview = run(scenario);
      final issues = ExplorationOverviewGoldenExpectations.verify(
        scenario,
        overview,
      );
      if (issues.isNotEmpty) return false;
    }
    return true;
  }
}
