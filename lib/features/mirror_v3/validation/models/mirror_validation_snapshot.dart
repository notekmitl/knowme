import 'mirror_blind_spot_validation_report.dart';
import 'mirror_confidence_validation_report.dart';
import 'mirror_consistency_validation_report.dart';
import 'mirror_population_validation_report.dart';
import 'mirror_registry_audit_report.dart';

/// Combined MV2 validation output contract.
class MirrorValidationSnapshot {
  const MirrorValidationSnapshot({
    required this.validationVersion,
    required this.generatedAt,
    required this.population,
    required this.consistency,
    required this.confidence,
    required this.blindSpot,
    required this.registryAudit,
    required this.passed,
  });

  final String validationVersion;
  final DateTime generatedAt;
  final MirrorPopulationValidationReport population;
  final MirrorConsistencyValidationReport consistency;
  final MirrorConfidenceValidationReport confidence;
  final MirrorBlindSpotValidationReport blindSpot;
  final MirrorRegistryAuditReport registryAudit;
  final bool passed;

  Map<String, dynamic> toMap() {
    return {
      'validationVersion': validationVersion,
      'generatedAt': generatedAt.toUtc().toIso8601String(),
      'population': population.toMap(),
      'consistency': consistency.toMap(),
      'confidence': confidence.toMap(),
      'blindSpot': blindSpot.toMap(),
      'registryAudit': registryAudit.toMap(),
      'passed': passed,
    };
  }
}
