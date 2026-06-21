/// Traceable evidence for a theme activation (internal / audit — not user-facing).
class PersonalityLensEvidence {
  const PersonalityLensEvidence({
    required this.sourceField,
    required this.sourceValue,
    required this.ruleId,
    this.weight = 1.0,
  });

  final String sourceField;
  final String sourceValue;
  final String ruleId;
  final double weight;
}

class PersonalitySourceVersionMeta {
  const PersonalitySourceVersionMeta({
    required this.scoredQuestionCount,
    required this.scoringVersion,
    this.depthTier,
    this.resultScoredAt,
  });

  final int scoredQuestionCount;
  final int scoringVersion;
  final String? depthTier;
  final DateTime? resultScoredAt;
}
