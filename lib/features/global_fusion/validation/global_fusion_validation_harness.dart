import '../application/global_fusion_builder.dart';
import '../application/global_fusion_input_loader.dart';
import 'global_fusion_golden_expectations.dart';
import 'global_fusion_golden_fixtures.dart';
import 'global_fusion_golden_scenario.dart';
import 'global_fusion_snapshot_inspector.dart';
import 'global_fusion_validation_result.dart';

/// Runs Global Fusion golden scenarios and returns inspectable results.
abstract final class GlobalFusionValidationHarness {
  static const _loader = GlobalFusionInputLoader();
  static final _fixedGeneratedAt = DateTime.utc(2026, 6, 14);

  static GlobalFusionValidationResult run(GlobalFusionGoldenScenario scenario) {
    final pair = GlobalFusionGoldenFixtures.load(scenario);
    return runFromPair(scenario.name, pair);
  }

  static GlobalFusionValidationResult runFromPair(
    String scenarioName,
    GlobalFusionInputPair pair,
  ) {
    final input = _loader.load(
      astrologySnapshot: pair.astrology,
      personalitySnapshot: pair.personality,
    );
    final snapshot = GlobalFusionBuilder.build(
      input,
      generatedAt: _fixedGeneratedAt,
    );

    GlobalFusionGoldenScenario? goldenScenario;
    for (final value in GlobalFusionGoldenScenario.values) {
      if (value.name == scenarioName) {
        goldenScenario = value;
        break;
      }
    }

    final issues = goldenScenario == null
        ? <String>['unknown scenario: $scenarioName']
        : GlobalFusionGoldenExpectations.verify(goldenScenario, snapshot);

    return GlobalFusionValidationResult(
      scenarioName: scenarioName,
      passed: issues.isEmpty,
      snapshot: snapshot,
      issues: issues,
      inspectionJson: GlobalFusionSnapshotInspector.toJson(snapshot),
      debugReport: GlobalFusionSnapshotInspector.toDebugReport(snapshot),
    );
  }

  static List<GlobalFusionValidationResult> runAll() {
    return GlobalFusionGoldenScenario.values.map(run).toList();
  }

  static bool runAllPassing() => runAll().every((result) => result.passed);
}
