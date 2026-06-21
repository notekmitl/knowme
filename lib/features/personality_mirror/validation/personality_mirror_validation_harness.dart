import '../application/mirror/personality_confidence_composer.dart';
import '../application/mirror/personality_mirror_engine.dart';
import '../application/personality_lens_load_result.dart';
import 'personality_mirror_confidence_verifier.dart';
import 'personality_mirror_golden_expectations.dart';
import 'personality_mirror_golden_fixtures.dart';
import 'personality_mirror_golden_scenario.dart';
import 'personality_mirror_snapshot_inspector.dart';
import 'personality_mirror_validation_result.dart';

/// Runs Personality Mirror golden scenarios and returns inspectable results.
abstract final class PersonalityMirrorValidationHarness {
  static PersonalityMirrorValidationResult run(
    PersonalityMirrorGoldenScenario scenario,
  ) {
    final load = PersonalityMirrorGoldenFixtures.load(scenario);
    return runFromLoad(scenario.name, load);
  }

  static PersonalityMirrorValidationResult runFromLoad(
    String scenarioName,
    PersonalityLensLoadResult load,
  ) {
    final mirror = PersonalityMirrorEngine.build(load);
    final confidence = PersonalityConfidenceComposer.analyze(
      load: load,
      agreements: mirror.agreements,
      tensions: mirror.tensions,
    );

    final confidenceIssues = PersonalityMirrorConfidenceVerifier.verify(
      load: load,
      agreements: mirror.agreements,
      tensions: mirror.tensions,
      breakdown: confidence,
    );

    PersonalityMirrorGoldenScenario? goldenScenario;
    for (final value in PersonalityMirrorGoldenScenario.values) {
      if (value.name == scenarioName) {
        goldenScenario = value;
        break;
      }
    }

    final scenarioIssues = goldenScenario == null
        ? <String>[]
        : PersonalityMirrorGoldenExpectations.verify(
            goldenScenario,
            mirror,
            confidence,
          );

    final allIssues = [...confidenceIssues, ...scenarioIssues];

    return PersonalityMirrorValidationResult(
      scenarioName: scenarioName,
      passed: allIssues.isEmpty,
      mirror: mirror,
      confidence: confidence,
      inspectionJson: PersonalityMirrorSnapshotInspector.toJson(
        mirror: mirror,
        confidence: confidence,
      ),
      debugReport: PersonalityMirrorSnapshotInspector.toDebugReport(
        mirror: mirror,
        confidence: confidence,
      ),
      confidenceIssues: confidenceIssues,
      scenarioIssues: scenarioIssues,
    );
  }

  static List<PersonalityMirrorValidationResult> runAll() {
    return PersonalityMirrorGoldenScenario.values.map(run).toList();
  }

  static bool runAllPassing() => runAll().every((result) => result.passed);
}
