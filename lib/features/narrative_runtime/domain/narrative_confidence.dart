/// Layered narrative confidence — distinct from pattern passthrough.
class NarrativeConfidence {
  const NarrativeConfidence({
    required this.composite,
    required this.patternConfidence,
    required this.evidenceDepthScore,
    required this.activationStrengthScore,
    required this.coverageScore,
  });

  final double composite;
  final double patternConfidence;
  final double evidenceDepthScore;
  final double activationStrengthScore;
  final double coverageScore;

  String get band {
    if (composite >= 0.75) return 'high';
    if (composite >= 0.45) return 'medium';
    return 'low';
  }

  Map<String, dynamic> toMap() {
    return {
      'composite': composite,
      'patternConfidence': patternConfidence,
      'evidenceDepthScore': evidenceDepthScore,
      'activationStrengthScore': activationStrengthScore,
      'coverageScore': coverageScore,
      'band': band,
    };
  }

  factory NarrativeConfidence.fromMap(Map<String, dynamic> map) {
    return NarrativeConfidence(
      composite: _requiredDouble(map['composite']),
      patternConfidence: _requiredDouble(map['patternConfidence']),
      evidenceDepthScore: _requiredDouble(map['evidenceDepthScore']),
      activationStrengthScore: _requiredDouble(map['activationStrengthScore']),
      coverageScore: _requiredDouble(map['coverageScore']),
    );
  }
}

double _requiredDouble(dynamic raw) {
  if (raw is! num) throw FormatException('Invalid double: $raw');
  return raw.toDouble();
}
