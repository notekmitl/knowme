/// Composed global confidence — not a mirror-confidence average.
class GlobalFusionConfidence {
  const GlobalFusionConfidence({
    required this.composite,
    required this.mirrorDiversityScore,
    required this.evidenceDepthScore,
    required this.agreementStrengthScore,
    required this.coverageScore,
    required this.tensionPenalty,
  });

  final double composite;
  final double mirrorDiversityScore;
  final double evidenceDepthScore;
  final double agreementStrengthScore;
  final double coverageScore;
  final double tensionPenalty;

  Map<String, dynamic> toMap() {
    return {
      'composite': composite,
      'mirrorDiversityScore': mirrorDiversityScore,
      'evidenceDepthScore': evidenceDepthScore,
      'agreementStrengthScore': agreementStrengthScore,
      'coverageScore': coverageScore,
      'tensionPenalty': tensionPenalty,
    };
  }

  factory GlobalFusionConfidence.fromMap(Map<String, dynamic> map) {
    return GlobalFusionConfidence(
      composite: _requiredDouble(map['composite']),
      mirrorDiversityScore: _requiredDouble(map['mirrorDiversityScore']),
      evidenceDepthScore: _requiredDouble(map['evidenceDepthScore']),
      agreementStrengthScore: _requiredDouble(map['agreementStrengthScore']),
      coverageScore: _requiredDouble(map['coverageScore']),
      tensionPenalty: _requiredDouble(map['tensionPenalty']),
    );
  }
}

double _requiredDouble(dynamic raw) {
  if (raw is! num) throw FormatException('Invalid double: $raw');
  return raw.toDouble();
}
