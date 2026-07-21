/// Composed human confidence — not a direct fusion passthrough (HM5).
class HumanConfidence {
  const HumanConfidence({
    required this.composite,
    required this.fusionInfluenceScore,
    required this.coverageScore,
    required this.evidenceDiversityScore,
    required this.patternStrengthScore,
  });

  final double composite;
  final double fusionInfluenceScore;
  final double coverageScore;
  final double evidenceDiversityScore;
  final double patternStrengthScore;

  Map<String, dynamic> toMap() {
    return {
      'composite': composite,
      'fusionInfluenceScore': fusionInfluenceScore,
      'coverageScore': coverageScore,
      'evidenceDiversityScore': evidenceDiversityScore,
      'patternStrengthScore': patternStrengthScore,
    };
  }

  factory HumanConfidence.fromMap(Map<String, dynamic> map) {
    return HumanConfidence(
      composite: _requiredDouble(map['composite']),
      fusionInfluenceScore: _requiredDouble(map['fusionInfluenceScore']),
      coverageScore: _requiredDouble(map['coverageScore']),
      evidenceDiversityScore: _requiredDouble(map['evidenceDiversityScore']),
      patternStrengthScore: _requiredDouble(map['patternStrengthScore']),
    );
  }
}

double _requiredDouble(dynamic raw) {
  if (raw is! num) throw FormatException('Invalid double: $raw');
  return raw.toDouble();
}
