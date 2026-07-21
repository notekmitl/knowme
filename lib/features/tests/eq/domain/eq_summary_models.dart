import 'eq_models.dart';
import 'eq_test_type.dart';

/// Read-only inputs for EQ Summary (from `results/*` only).
class EqSummaryInput {
  const EqSummaryInput({
    required this.resultsByType,
  });

  final Map<EqTestType, EqResultSummary> resultsByType;

  bool get hasAllSix =>
      EqSummaryInput.requiredTypes.every(resultsByType.containsKey);

  static const requiredTypes = EqHomeModuleTypes.all;

  EqResultSummary? resultFor(EqTestType type) => resultsByType[type];
}

/// Deterministic EQ Summary output (no persistence).
class EqSummaryContent {
  const EqSummaryContent({
    required this.narrative,
    required this.guidance,
    required this.disclosure,
  });

  final String narrative;
  final String guidance;
  final String disclosure;
}

/// Module list shared by home + summary unlock check.
abstract final class EqHomeModuleTypes {
  static const all = <EqTestType>[
    EqTestType.awareness,
    EqTestType.regulation,
    EqTestType.empathy,
    EqTestType.social,
    EqTestType.stress,
    EqTestType.decision,
  ];
}
