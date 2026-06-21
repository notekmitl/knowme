import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/personality_mirror/validation/personality_mirror_golden_scenario.dart';
import 'package:knowme/features/personality_mirror/validation/personality_mirror_snapshot_inspector.dart';
import 'package:knowme/features/personality_mirror/validation/personality_mirror_validation_harness.dart';

void main() {
  group('PersonalityMirrorValidationHarness', () {
    for (final scenario in PersonalityMirrorGoldenScenario.values) {
      test('${scenario.name} passes golden expectations', () {
        final result = PersonalityMirrorValidationHarness.run(scenario);

        if (!result.passed) {
          // ignore: avoid_print
          print(result.debugReport);
          // ignore: avoid_print
          print('confidence issues: ${result.confidenceIssues}');
          // ignore: avoid_print
          print('scenario issues: ${result.scenarioIssues}');
        }

        expect(
          result.passed,
          isTrue,
          reason: '${scenario.name} failed: '
              '${[...result.confidenceIssues, ...result.scenarioIssues].join('; ')}',
        );
      });
    }

    test('runAllPassing returns true', () {
      expect(PersonalityMirrorValidationHarness.runAllPassing(), isTrue);
    });

    test('inspector produces structured json and debug report', () {
      final result = PersonalityMirrorValidationHarness.run(
        PersonalityMirrorGoldenScenario.scenarioA,
      );

      expect(result.inspectionJson['version'], isNotNull);
      expect(result.inspectionJson['agreements'], isA<List>());
      expect(result.inspectionJson['confidence'], isA<Map>());
      expect(result.debugReport, contains('Personality Mirror Snapshot'));
      expect(
        PersonalityMirrorSnapshotInspector.toDebugReport(
          mirror: result.mirror,
          confidence: result.confidence,
        ),
        result.debugReport,
      );
    });
  });

  group('Scenario-specific behavior', () {
    test('scenarioA has theme agreement, no tension', () {
      final result = PersonalityMirrorValidationHarness.run(
        PersonalityMirrorGoldenScenario.scenarioA,
      );

      expect(result.mirror.tensions, isEmpty);
      expect(result.mirror.agreements, isNotEmpty);
      expect(result.confidence.agreementBoost, greaterThan(0));
    });

    test('scenarioB has opposing-family tension', () {
      final result = PersonalityMirrorValidationHarness.run(
        PersonalityMirrorGoldenScenario.scenarioB,
      );

      expect(result.mirror.tensions, isNotEmpty);
      expect(result.confidence.contradictionPenalty, greaterThan(0));
    });

    test('scenarioC has low coverage and low confidence', () {
      final result = PersonalityMirrorValidationHarness.run(
        PersonalityMirrorGoldenScenario.scenarioC,
      );

      expect(result.mirror.coverage.weightedCoverage, closeTo(0.45, 0.001));
      expect(result.confidence.compositeBand, 'low');
    });

    test('scenarioD has very high confidence with full coverage', () {
      final result = PersonalityMirrorValidationHarness.run(
        PersonalityMirrorGoldenScenario.scenarioD,
      );

      expect(result.mirror.coverage.weightedCoverage, closeTo(1.0, 0.001));
      expect(result.confidence.compositeBand, 'very_high');
      expect(result.confidence.compositeConfidence, greaterThanOrEqualTo(0.85));
    });
  });
}
