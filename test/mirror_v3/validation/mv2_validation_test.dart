import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/mirror_v3/validation/blind_spot/mirror_blind_spot_validator.dart';
import 'package:knowme/features/mirror_v3/validation/confidence/mirror_confidence_validator.dart';
import 'package:knowme/features/mirror_v3/validation/consistency/mirror_consistency_validator.dart';
import 'package:knowme/features/mirror_v3/validation/mirror_validation_harness.dart';
import 'package:knowme/features/mirror_v3/validation/population/mirror_population_validator.dart';
import 'package:knowme/features/mirror_v3/validation/registry/mirror_registry_auditor.dart';

void main() {
  group('MV2.1 Population Validation', () {
    test('runs 100 synthetic bundles', () {
      final report = MirrorPopulationValidator.validate(caseCount: 100);
      expect(report.totalCases, 100);
      expect(report.distribution.agreementPerCase, isNonNegative);
      expect(report.distribution.confidencePerCase, inInclusiveRange(0.0, 1.0));
    });

    test('runs 500 synthetic bundles', () {
      final report = MirrorPopulationValidator.validate(caseCount: 500);
      expect(report.totalCases, 500);
    });

    test('runs 1000 synthetic bundles', () {
      final report = MirrorPopulationValidator.validate(caseCount: 1000);
      expect(report.totalCases, 1000);
      expect(report.reinforcementCount, greaterThan(0));
    });
  });

  group('MV2.2 Consistency Validation', () {
    test('same input produces identical output across repeated runs', () {
      final report = MirrorConsistencyValidator.validate(
        caseCount: 25,
        runsPerCase: 5,
      );

      expect(report.allDeterministic, isTrue);
      expect(report.passed, isTrue);
      expect(report.mismatches, isEmpty);
    });
  });

  group('MV2.3 Confidence Validation', () {
    test('confidence increases with lens agreement depth', () {
      final report = MirrorConfidenceValidator.validate(caseCount: 30);

      expect(report.passed, isTrue);
      expect(report.violations, 0);
      expect(report.monotonicCases, report.caseCount);
    });
  });

  group('MV2.4 Blind Spot Validation', () {
    test('reports blind spot distribution buckets', () {
      final report = MirrorBlindSpotValidator.validate(caseCount: 100);

      expect(report.totalCases, 100);
      expect(report.distribution, hasLength(3));
      expect(
        report.noBlindSpotCases +
            report.singleBlindSpotCases +
            report.multipleBlindSpotCases,
        100,
      );
    });
  });

  group('MV2.5 Registry Coverage Audit', () {
    test('reports used and unused registry keys', () {
      final report = MirrorRegistryAuditor.audit(populationCaseCount: 200);

      expect(report.totalRegistryKeys, 15);
      expect(report.usedKeys, isNotEmpty);
      expect(report.keyUsageCounts.length, 15);
    });

    test('reports semantic duplicates without mutating registry', () {
      final report = MirrorRegistryAuditor.audit(populationCaseCount: 100);

      expect(report.semanticDuplicates, isNotEmpty);
      expect(report.passed, isTrue);
    });
  });

  group('MirrorValidationSnapshot', () {
    test('harness produces combined validation snapshot', () {
      final snapshot = MirrorValidationHarness.run(
        populationCaseCount: 100,
        consistencyCaseCount: 20,
        confidenceCaseCount: 15,
        blindSpotCaseCount: 100,
        registryAuditCaseCount: 200,
        generatedAt: DateTime.utc(2026, 6, 21),
      );

      expect(snapshot.validationVersion, isNotEmpty);
      expect(snapshot.population.totalCases, 100);
      expect(snapshot.consistency.passed, isTrue);
      expect(snapshot.confidence.passed, isTrue);
      expect(snapshot.registryAudit.totalRegistryKeys, 15);
      expect(snapshot.toMap().keys, containsAll([
        'population',
        'consistency',
        'confidence',
        'blindSpot',
        'registryAudit',
        'passed',
      ]));
    });
  });
}
