import '../domain/global_fusion_snapshot.dart';

/// Result of a Global Fusion golden validation run.
class GlobalFusionValidationResult {
  const GlobalFusionValidationResult({
    required this.scenarioName,
    required this.passed,
    required this.snapshot,
    required this.issues,
    required this.inspectionJson,
    required this.debugReport,
  });

  final String scenarioName;
  final bool passed;
  final GlobalFusionSnapshot snapshot;
  final List<String> issues;
  final Map<String, dynamic> inspectionJson;
  final String debugReport;
}
