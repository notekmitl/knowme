/// Coverage summary for a persisted mirror snapshot.
class KnowMeMirrorSnapshotCoverage {
  const KnowMeMirrorSnapshotCoverage({
    required this.availableSystems,
    required this.coveredDimensions,
    required this.signalCount,
    required this.weightedCoverage,
  });

  final List<String> availableSystems;
  final List<String> coveredDimensions;
  final int signalCount;
  final double weightedCoverage;

  Map<String, dynamic> toMap() {
    return {
      'availableSystems': availableSystems,
      'coveredDimensions': coveredDimensions,
      'signalCount': signalCount,
      'weightedCoverage': weightedCoverage,
    };
  }

  factory KnowMeMirrorSnapshotCoverage.fromMap(Map<String, dynamic> map) {
    final weighted = map['weightedCoverage'];
    if (weighted is! num) {
      throw FormatException('Invalid weightedCoverage: $weighted');
    }

    return KnowMeMirrorSnapshotCoverage(
      availableSystems: _stringList(map['availableSystems']),
      coveredDimensions: _stringList(map['coveredDimensions']),
      signalCount: _requiredInt(map['signalCount']),
      weightedCoverage: weighted.toDouble(),
    );
  }
}

List<String> _stringList(dynamic raw) {
  if (raw is! List) return const [];
  return raw.whereType<String>().toList(growable: false);
}

int _requiredInt(dynamic raw) {
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  throw FormatException('Invalid int: $raw');
}
