import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'validation/human_pattern_activation_audit/human_pattern_activation_audit_report.dart';
import 'validation/human_pattern_activation_audit/human_pattern_activation_audit_runner.dart';

@Timeout(Duration(minutes: 5))
void main() {
  group('Human Pattern Activation Audit V1', () {
    late HumanPatternActivationAuditResult audit;

    setUpAll(() {
      Directory('build/repository-wide-baseline').createSync(recursive: true);
      audit = HumanPatternActivationAuditRunner.run();
      HumanPatternActivationAuditReport.writeArtifacts(
        result: audit,
        jsonPath: 'build/repository-wide-baseline/human-pattern-audit.json',
        markdownPath: 'build/repository-wide-baseline/human-pattern-audit.md',
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

    test('classifies the current 19 never-activated patterns forensically', () {
      expect(audit.patternDeadZones.neverActivated.length, 19);
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

    test('confirms 200 distinct narratives without a collapse zone', () {
      expect(audit.narrativeCollapse.layerUniques['narrative'], 200);
      expect(audit.narrativeCollapse.collapseZones, isEmpty);
    });

    test('produces root cause analysis and evidence-based conclusions', () {
      expect(audit.rootCauseAnalysis.length, 5);
      expect(audit.evidenceBasedConclusions.length, greaterThanOrEqualTo(8));
    });

    test('writes audit artifacts', () {
      expect(
        File(
          'build/repository-wide-baseline/human-pattern-audit.json',
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          'build/repository-wide-baseline/human-pattern-audit.md',
        ).existsSync(),
        isTrue,
      );
    });
  });
}
