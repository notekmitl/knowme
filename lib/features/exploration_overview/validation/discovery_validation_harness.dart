import '../domain/discovery_item.dart';
import 'discovery_golden_fixtures.dart';
import 'discovery_golden_scenario.dart';

/// Runs Discovery golden scenarios (EO-F1).
abstract final class DiscoveryValidationHarness {
  static List<DiscoveryItem> run(DiscoveryGoldenScenario scenario) {
    return DiscoveryGoldenFixtures.build(scenario);
  }

  static bool runAllPassing() {
    for (final scenario in DiscoveryGoldenScenario.values) {
      final items = run(scenario);
      final issues = DiscoveryGoldenExpectations.verify(scenario, items);
      if (issues.isNotEmpty) return false;
    }
    return true;
  }
}
