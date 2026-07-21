import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'validation/human_pattern_activation_audit/human_pattern_activation_audit_report.dart';
import 'validation/human_pattern_activation_audit/human_pattern_activation_audit_runner.dart';

@Timeout(Duration(minutes: 5))
void main() {
  group('Human Pattern Activation Audit V1', () {
    late HumanPatternActivationAuditResult audit;

    setUpAll(() {
      audit = HumanPatternActivationAuditRunner.run();
      HumanPatternActivationAuditReport.writeArtifacts(
        result: audit,
        jsonPath:
            'test/validation/human_pattern_activation_audit/output/results.json',
        markdownPath: 'docs/HUMAN_PATTERN_ACTIVATION_AUDIT_V1.md',
      );
    });

    test('runs all five audits across 200 synthetic humans', () {
      expect(audit.records.length, 200);
      expect(audit.patternDeadZones.populationSize, 200);
      expect(audit.eqSignalSurvival.populationSize, 200);
      expect(audit.narrativeCollapse.populationSize, 200);
      expect(audit.systemDominance.populationSize, 200);
      expect(audit.patternUtilization.populationSize, 200);
    });

    test('confirms 20 never-activated patterns with forensic classification', () {
      expect(audit.patternDeadZones.neverActivated.length, 20);
      for (final entry in audit.patternDeadZones.neverActivated) {
        expect(entry.activationCount, 0);
        expect(entry.primaryBlockReason, isNotEmpty);
        expect(entry.activationRule, isNotEmpty);
        expect(entry.requiredInputs, isNotEmpty);
      }
    });

    test('measures EQ signal survival through all layers', () {
      final input = audit.eqSignalSurvival.eqLayerCounts['mirror_input'] ?? 0;
      expect(input, greaterThan(0));
      expect(audit.eqSignalSurvival.eqSurvivalRates.keys.length, 6);
      expect(audit.eqSignalSurvival.primaryEqLossLayer, isNotEmpty);
    });

    test('documents narrative collapse from 200 to ~82 unique outputs', () {
      expect(audit.narrativeCollapse.layerUniques['narrative'], lessThan(100));
      expect(audit.narrativeCollapse.collapseZones.length, greaterThan(0));
    });

    test('produces root cause analysis and evidence-based conclusions', () {
      expect(audit.rootCauseAnalysis.length, 5);
      expect(audit.evidenceBasedConclusions.length, greaterThanOrEqualTo(8));
    });

    test('writes audit artifacts', () {
      expect(
        File('test/validation/human_pattern_activation_audit/output/results.json')
            .existsSync(),
        isTrue,
      );
      expect(
        File('docs/HUMAN_PATTERN_ACTIVATION_AUDIT_V1.md').existsSync(),
        isTrue,
      );
    });
  });
}
