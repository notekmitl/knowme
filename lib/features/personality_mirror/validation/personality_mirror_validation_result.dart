import '../domain/personality_confidence_breakdown.dart';
import '../domain/personality_mirror_snapshot.dart';

/// Output from [PersonalityMirrorValidationHarness].
class PersonalityMirrorValidationResult {
  const PersonalityMirrorValidationResult({
    required this.scenarioName,
    required this.passed,
    required this.mirror,
    required this.confidence,
    required this.inspectionJson,
    required this.debugReport,
    required this.confidenceIssues,
    required this.scenarioIssues,
  });

  final String scenarioName;
  final bool passed;
  final PersonalityMirrorSnapshot mirror;
  final PersonalityConfidenceBreakdown confidence;
  final Map<String, dynamic> inspectionJson;
  final String debugReport;
  final List<String> confidenceIssues;
  final List<String> scenarioIssues;
}
