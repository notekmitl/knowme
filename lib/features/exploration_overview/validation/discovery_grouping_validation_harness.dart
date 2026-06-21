import '../domain/discovery_grouping_model.dart';
import 'discovery_grouping_golden_fixtures.dart';
import 'discovery_grouping_golden_scenario.dart';

/// Runs Discovery Grouping golden scenarios (HC-F1.5).
abstract final class DiscoveryGroupingValidationHarness {
  static DiscoveryGroupingModel run(DiscoveryGroupingGoldenScenario scenario) {
    return DiscoveryGroupingGoldenFixtures.build(scenario);
  }

  static bool runAllPassing() {
    for (final scenario in DiscoveryGroupingGoldenScenario.values) {
      final model = run(scenario);
      final issues = DiscoveryGroupingGoldenExpectations.verify(scenario, model);
      if (issues.isNotEmpty) return false;
    }
    return true;
  }
}
