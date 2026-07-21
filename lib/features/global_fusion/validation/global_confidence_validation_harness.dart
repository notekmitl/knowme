import '../application/global_fusion_builder.dart';
import '../application/global_fusion_input_loader.dart';
import 'global_confidence_golden_expectations.dart';
import 'global_confidence_golden_fixtures.dart';
import 'global_confidence_golden_scenario.dart';
import 'global_fusion_golden_fixtures.dart';
import 'global_fusion_validation_result.dart';
import 'global_fusion_snapshot_inspector.dart';

/// Runs Global Confidence v1 golden scenarios.
abstract final class GlobalConfidenceValidationHarness {
  static const _loader = GlobalFusionInputLoader();
  static final _fixedGeneratedAt = DateTime.utc(2026, 6, 14);

  static GlobalFusionValidationResult run(
    GlobalConfidenceGoldenScenario scenario,
  ) {
    final pair = GlobalConfidenceGoldenFixtures.load(scenario);
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

    GlobalConfidenceGoldenScenario? goldenScenario;
    for (final value in GlobalConfidenceGoldenScenario.values) {
      if (value.name == scenarioName) {
        goldenScenario = value;
        break;
      }
    }

    final issues = goldenScenario == null
        ? <String>['unknown confidence scenario: $scenarioName']
        : GlobalConfidenceGoldenExpectations.verify(goldenScenario, snapshot);

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
    return GlobalConfidenceGoldenScenario.values.map(run).toList();
  }

  static bool runAllPassing() => runAll().every((result) => result.passed);

  static List<String> verifyComparisons() {
    final agreementOnly = run(
      GlobalConfidenceGoldenScenario.oneStrongAgreement,
    ).snapshot;
    final mixed = run(
      GlobalConfidenceGoldenScenario.agreementsWithTensions,
    ).snapshot;
    return GlobalConfidenceGoldenComparisons.verify(agreementOnly, mixed);
  }
}
