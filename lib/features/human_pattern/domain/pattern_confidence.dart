/// Per-pattern composed confidence (HP5).
class PatternConfidence {
  const PatternConfidence({
    required this.composite,
    required this.humanInfluenceScore,
    required this.coverageScore,
    required this.evidenceDiversityScore,
    required this.activationStrengthScore,
  });

  final double composite;
  final double humanInfluenceScore;
  final double coverageScore;
  final double evidenceDiversityScore;
  final double activationStrengthScore;

  Map<String, dynamic> toMap() {
    return {
      'composite': composite,
      'humanInfluenceScore': humanInfluenceScore,
      'coverageScore': coverageScore,
      'evidenceDiversityScore': evidenceDiversityScore,
      'activationStrengthScore': activationStrengthScore,
    };
  }

  factory PatternConfidence.fromMap(Map<String, dynamic> map) {
    return PatternConfidence(
      composite: _requiredDouble(map['composite']),
      humanInfluenceScore: _requiredDouble(map['humanInfluenceScore']),
      coverageScore: _requiredDouble(map['coverageScore']),
      evidenceDiversityScore: _requiredDouble(map['evidenceDiversityScore']),
      activationStrengthScore: _requiredDouble(map['activationStrengthScore']),
    );
  }
}

double _requiredDouble(dynamic raw) {
  if (raw is! num) throw FormatException('Invalid double: $raw');
  return raw.toDouble();
}
