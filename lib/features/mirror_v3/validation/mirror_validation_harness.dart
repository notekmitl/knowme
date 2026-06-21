import 'constants/mirror_validation_constants.dart';
import 'blind_spot/mirror_blind_spot_validator.dart';
import 'confidence/mirror_confidence_validator.dart';
import 'consistency/mirror_consistency_validator.dart';
import 'models/mirror_validation_snapshot.dart';
import 'population/mirror_population_validator.dart';
import 'registry/mirror_registry_auditor.dart';

/// Orchestrates all MV2 validation modules.
abstract final class MirrorValidationHarness {
  static MirrorValidationSnapshot run({
    int populationCaseCount = 100,
    int consistencyCaseCount = 50,
    int confidenceCaseCount = 30,
    int blindSpotCaseCount = 100,
    int registryAuditCaseCount = 500,
    DateTime? generatedAt,
  }) {
    final population = MirrorPopulationValidator.validate(
      caseCount: populationCaseCount,
    );
    final consistency = MirrorConsistencyValidator.validate(
      caseCount: consistencyCaseCount,
    );
    final confidence = MirrorConfidenceValidator.validate(
      caseCount: confidenceCaseCount,
    );
    final blindSpot = MirrorBlindSpotValidator.validate(
      caseCount: blindSpotCaseCount,
    );
    final registryAudit = MirrorRegistryAuditor.audit(
      populationCaseCount: registryAuditCaseCount,
    );

    final passed = population.passed &&
        consistency.passed &&
        confidence.passed &&
        blindSpot.passed &&
        registryAudit.passed;

    return MirrorValidationSnapshot(
      validationVersion: MirrorValidationVersionContract.validationVersion,
      generatedAt: (generatedAt ?? DateTime.now()).toUtc(),
      population: population,
      consistency: consistency,
      confidence: confidence,
      blindSpot: blindSpot,
      registryAudit: registryAudit,
      passed: passed,
    );
  }

  static MirrorValidationSnapshot runPopulationScale(int caseCount) {
    return run(
      populationCaseCount: caseCount,
      consistencyCaseCount: caseCount.clamp(10, 100),
      confidenceCaseCount: 30,
      blindSpotCaseCount: caseCount,
      registryAuditCaseCount: caseCount,
      generatedAt: DateTime.utc(2026, 6, 21),
    );
  }
}
