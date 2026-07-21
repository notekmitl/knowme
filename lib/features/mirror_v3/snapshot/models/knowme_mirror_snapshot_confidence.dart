/// Composite confidence block for a persisted mirror snapshot.
class KnowMeMirrorSnapshotConfidence {
  const KnowMeMirrorSnapshotConfidence({
    required this.composite,
    required this.agreementBoostEligible,
    required this.tensionPenaltyApplied,
    required this.reinforcementBoostEligible,
  });

  final double composite;
  final bool agreementBoostEligible;
  final bool tensionPenaltyApplied;
  final bool reinforcementBoostEligible;

  Map<String, dynamic> toMap() {
    return {
      'composite': composite,
      'agreementBoostEligible': agreementBoostEligible,
      'tensionPenaltyApplied': tensionPenaltyApplied,
      'reinforcementBoostEligible': reinforcementBoostEligible,
    };
  }

  factory KnowMeMirrorSnapshotConfidence.fromMap(Map<String, dynamic> map) {
    final composite = map['composite'];
    if (composite is! num) {
      throw FormatException('Invalid composite confidence: $composite');
    }

    return KnowMeMirrorSnapshotConfidence(
      composite: composite.toDouble(),
      agreementBoostEligible: map['agreementBoostEligible'] == true,
      tensionPenaltyApplied: map['tensionPenaltyApplied'] == true,
      reinforcementBoostEligible: map['reinforcementBoostEligible'] == true,
    );
  }
}
